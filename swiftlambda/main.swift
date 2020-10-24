import Foundation
import ArgumentParser
import ShellOut

struct Swiftlambda: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "AWS Lambda Swift functions made easy",
        version: "swiftlambda version 1.0.0",
        subcommands: [
            New.self,
            Build.self,
            Deploy.self
        ]
    )
}

Swiftlambda.main()
