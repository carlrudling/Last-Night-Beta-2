import Foundation
import FirebaseFirestoreSwift


struct Album: Codable {
    var uuid: String
    var albumName: String
    var endDate: Date
    var creationDate: Date
    var photoLimit : Int
    var members : [String] = []
    var creator : String
    var posts : [Post] = []
    var thumbnailURL: String?
    var messages: [Message] = []

    
    @DocumentID var documentID: String? // Adding a documentID property


    
    var isActive: Bool {
        return endDate > Date()
    }
   
}

