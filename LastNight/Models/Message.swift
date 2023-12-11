
import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var senderID: String // The ID of the user who sent the message
    var timestamp: Date
}
