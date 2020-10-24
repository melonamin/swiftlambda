import Foundation
import ArgumentParser
import ShellOut

struct Swiftlambda: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "AWS Lambda Swift functions made easy",
        version: "0.0.1",
        subcommands: [
            New.self,
            Build.self,
            Deploy.self
        ]
    )

    func validate() throws {
        guard let _ = try? shellOut(to: "which docker") else {
            throw ValidationError("No docker found")
        }
        guard let _ = try? shellOut(to: "which aws") else {
            throw ValidationError("No aws-cli found")
        }
        guard let _ = try? shellOut(to: "which swift") else {
            throw ValidationError("No swift found")
        }
    }
}

Swiftlambda.main()
