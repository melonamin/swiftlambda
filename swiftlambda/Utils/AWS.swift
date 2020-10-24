import Foundation

struct AWS: Codable {
    let LastUpdateStatus: String

    static func parseAWSResponse(json: String) -> Bool {
        let jsonDecoder = JSONDecoder()
        guard let response = try? jsonDecoder.decode(Self.self, from: Data(json.utf8)) else {
            return false
        }
        return response.LastUpdateStatus == "Successful"
    }
}
