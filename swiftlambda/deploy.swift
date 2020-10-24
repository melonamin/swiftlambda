import Foundation
import ArgumentParser
import ShellOut

//Adopted from https://github.com/swift-server/swift-aws-lambda-runtime/blob/main/Examples/LambdaFunctions/scripts/package.sh
let deployScript = """
    #!/bin/bash

    set -eu

    executable=$1

    target=.build/lambda/$executable
    rm -rf "$target"
    mkdir -p "$target"
    cp ".build/release/$executable" "$target/"

    ldd ".build/release/$executable" | grep swift | awk '{print $3}' | xargs cp -L -t "$target"

    cd "$target"
    ln -s "$executable" "bootstrap"
"""

extension Swiftlambda {
    struct Deploy: ParsableCommand {
        static var configuration =
            CommandConfiguration(abstract: "Deploy new AWS Lambda function.")

        @Option(name: .shortAndLong, help: "Filepath to Swift Package directory.")
        var source: String = currentDirectory

        @Option(name: .shortAndLong, help: "AWS Lambda name.")
        var name: String

        @Option(name: .shortAndLong, help: "AWS Lambda execution role.")
        var role: String = ""

        @Flag(name: .shortAndLong, help: "Update existing function.")
        var update: Bool = false

        func validate() throws {
            guard name != "" else {
                throw ValidationError("Provide a valid name.")
            }

            if !update && role == "" {
                throw ValidationError("Provide a valid AWS role.")
            }

            guard let _ = try? shellOut(to: "which docker") else {
                throw ValidationError("docker not found.")
            }
            guard let _ = try? shellOut(to: "which swift") else {
                throw ValidationError("swift not found.")
            }
            guard let _ = try? shellOut(to: "which aws") else {
                throw ValidationError("aws-cli not found.")
            }
        }

        mutating func run() {
            if source == currentDirectory {
                source = FileManager.default.currentDirectoryPath
            }
            guard let url = URL(string: source) else {
                print("Invalid source path: \(source)")
                return
            }
            var _packageInfo: SwiftPackage?
            switch SwiftPackage.parseSwiftPackageManifest(at: source) {
                case .success(let packageInfo):
                    _packageInfo = packageInfo
                case .failure(_):
                    return
            }

            guard let packageInfo = _packageInfo, let executable = packageInfo.products.first?.name
            else {return}
            print("Using '\(executable)' as target. Swift \(packageInfo.toolsVersion._version)")

            let deployScriptPath = url.appendingPathComponent(".build/swiftlambda.sh").absoluteString

            let fileManager = FileManager.default
            NSData(data: Data(deployScript.utf8)).write(toFile: deployScriptPath, atomically: true)

            do {
                let logMessage = "Collecting '\(executable)' dependencies..."
                print(logMessage)
                let command = """
                    docker run --rm -v \(source):/src -w /src swift:5.3-amazonlinux2 \
                    /bin/bash .build/swiftlambda.sh \(executable)
                """
                try shellOut(to: command)
                outputReplaceLastLine(with: "\(logMessage) done!")
            } catch {
                guard let error = error as? ShellOutError else {return}
                print(error.message)
            }

            try? fileManager.removeItem(atPath: deployScriptPath)

            do {
                var logMessage = "Preparing archive for upload..."
                print(logMessage)
                let lambdaPath = url.appendingPathComponent(".build/lambda/\(executable)").absoluteString
                try shellOut(to: ["cd \(lambdaPath)", "zip --symlinks lambda.zip *"])
                outputReplaceLastLine(with: "\(logMessage) done!\nArchive: \(lambdaPath)\\lambda.zip")

                logMessage = "\(update ? "Updating":"Creating") \(name) lambda..."
                print(logMessage)

                let createCommand = """
                    aws lambda create-function --function-name \(name) \
                    --zip-file fileb://\(lambdaPath)/lambda.zip --runtime provided.al2 --handler Provided \
                    --role \(role)
                """
                let updateCommand = """
                        aws lambda update-function-code --function-name \(name) \
                        --zip-file fileb://\(lambdaPath)/lambda.zip
                    """
                let output = try shellOut(to: update ? updateCommand:createCommand)
                let success =  AWS.parseAWSResponse(json: output)
                outputReplaceLastLine(with: "\(logMessage) \( success ? "done!":"failed!")")
                if !success {
                    print(output)
                }
            } catch {
                guard let error = error as? ShellOutError else {return}
                print(error.message)
            }
        }
    }
}
