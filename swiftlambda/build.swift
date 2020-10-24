import Foundation
import ArgumentParser
import ShellOut

let currentDirectory = "current directory"

extension Swiftlambda {

    struct Build: ParsableCommand {
        static var configuration =
            CommandConfiguration(abstract: "Build and package Swift code for AWS Lambda deployment.")

        @Option(name: .shortAndLong, help: "Filepath to Swift Package directory.")
        var source: String = currentDirectory

        mutating func validate() throws {
            guard source != "" else {
                throw ValidationError("Set a proper source")
            }
        }

        mutating func run() {
            if source == currentDirectory {
                source = FileManager.default.currentDirectoryPath
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
            do {
                print("Building in Docker container...")
                let command = """
                    docker run --rm -v "\(source)":/src -w /src swift:5.3-amazonlinux2 \
                    swift build --product "\(executable)" -c release
                """
                let output = try shellOut(to: command)
                print(output)
            } catch {
                guard let error = error as? ShellOutError else {return}
                print(error.message)
            }
        }
    }
}
