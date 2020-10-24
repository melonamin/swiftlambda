import Foundation
import ShellOut

struct SwiftPackage: Codable {
    struct Product: Codable {
        let name: String
    }
    struct ToolsVersion: Codable {
        let _version: String
    }

    let products: [Product]
    let toolsVersion: ToolsVersion

    private static func parse(json: String?) -> Self? {
        guard let json = json else {return nil}
        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(Self.self, from: Data(json.utf8))
    }

    enum PackageParsingError: Error {
        case cantFindPackage
        case cantParsePackage
    }

    static func parseSwiftPackageManifest(at source: String) -> Result<Self, PackageParsingError> {
        print("Parsing Swift Package manifest")
        let result: Result<Self, PackageParsingError>
        var swiftTarget: String?
        do {
            swiftTarget = try shellOut(to: "swift package dump-package", at: source)
        } catch {
            if let error = error as? ShellOutError {
                print(error.message)
            }
            result = .failure(.cantFindPackage)
            return result
        }

        guard let packageInfo = SwiftPackage.parse(json: swiftTarget),
              let _ = packageInfo.products.first?.name
        else {
            print("Can't parse Swift Package manifest")
            result = .failure(.cantParsePackage)
            return result
        }
        result = .success(packageInfo)
        return result
    }
}
