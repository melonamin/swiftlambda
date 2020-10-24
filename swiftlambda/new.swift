import Foundation
import ArgumentParser
import ShellOut

extension Swiftlambda {
    struct New: ParsableCommand {
        static var configuration =
            CommandConfiguration(abstract: "New AWS Lambda Swift template.")

        @Option(name: .shortAndLong, help: "Name.")
        var name: String

        @Option(name: .shortAndLong, help: "Filepath.")
        var out: String = currentDirectory


        func validate() throws {
            guard name != "" else {
                throw ValidationError("Name")
            }
            guard let _ = try? shellOut(to: "which swift") else {
                throw ValidationError("swift not found.")
            }
        }

        mutating func run() {
            if out == currentDirectory {
                out = FileManager.default.currentDirectoryPath
            }
            guard let url = URL(string: out) else {
                print("Invalid out path: \(out)")
                return
            }

            let directoryPath = url.appendingPathComponent(name).absoluteString

            let fileManager = FileManager.default
            do {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
                return
            }

            do {
                try shellOut(to: "swift package init --type executable", at: directoryPath)
                updatePackageDefinition(name: name, path: url)
            } catch {
                guard let error = error as? ShellOutError else {return}
                print(error.message)
                try? fileManager.removeItem(atPath: directoryPath)
            }
        }

        func updatePackageDefinition(name: String, path: URL) {
            let packageManifest = """
            // swift-tools-version:5.3
            // The swift-tools-version declares the minimum version of Swift required to build this package.

            import PackageDescription

            let package = Package(
                name: "\(name)",
                platforms: [
                    .macOS(.v10_13),
                ],
                products: [
                    .executable(name: "\(name)", targets: ["\(name)"]),
                ],
                dependencies: [
                    .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "0.1.0"),
                ],
                targets: [
                    .target(
                        name: "\(name)",
                        dependencies: [
                            .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime")
                        ]),
                ]
            )
            """

            let handler = """
                import AWSLambdaRuntime

                Lambda.run { (context, name: String, callback: @escaping (Result<String, Error>) -> Void) in
                    callback(.success("Hello, \(name)"))
                }
            """
            let packageManifestPath = path.appendingPathComponent(name).appendingPathComponent("Package.swift").absoluteString
            NSData(data: Data(packageManifest.utf8)).write(toFile: packageManifestPath, atomically: true)

            let handlerPath = path
                .appendingPathComponent(name)
                .appendingPathComponent("Sources")
                .appendingPathComponent(name)
                .appendingPathComponent("main.swift")
                .absoluteString
            NSData(data: Data(handler.utf8)).write(toFile: handlerPath, atomically: true)
            print(handlerPath)
        }
    }
}
