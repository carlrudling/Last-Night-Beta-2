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
    var userThumbnailURLs: [String: String] = [:] // Dictionary mapping user UUIDs to thumbnail URLs
    var messages: [Message] = []

    
    @DocumentID var documentID: String? // Adding a documentID property


    
    var isActive: Bool {
        return endDate > Date()
    }
    
    func isSameDay() -> Bool {
        let calendar = Calendar.current

        let creationDay = calendar.component(.day, from: creationDate)
        let creationMonth = calendar.component(.month, from: creationDate)
        let creationYear = calendar.component(.year, from: creationDate)

        let endDay = calendar.component(.day, from: endDate)
        let endMonth = calendar.component(.month, from: endDate)
        let endYear = calendar.component(.year, from: endDate)

        return creationDay == endDay && creationMonth == endMonth && creationYear == endYear
    }
   
}
