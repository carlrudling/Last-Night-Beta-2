import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessagesService: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = ""
    let albumID: String
    private let db = Firestore.firestore()

    init(albumID: String) {
           self.albumID = albumID
           getMessages(forAlbum: albumID)
       }
    
    func getMessages(forAlbum albumID: String) {
        db.collection("albums").document(albumID).collection("messages").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            self.messages = documents.compactMap{ document -> Message? in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("Error decoding document into Message \(error)")
                    return nil
                }
            }
            self.messages.sort { $0.timestamp < $1.timestamp }
            
            if let id = self.messages.last?.id  {
                self.lastMessageId = id
            }
        }
    }
    
    func sendMessage(text: String, senderID: String, toAlbum albumID: String) {
        do {
            let newMessage = Message(id: "\(UUID())", text: text, senderID: senderID, timestamp: Date())
            
            try db.collection("albums").document(albumID).collection("messages").document().setData(from: newMessage)
            
        } catch {
            print("Error adding message to Firestore \(error)")
        }
    }

}
