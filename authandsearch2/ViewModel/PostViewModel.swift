//
//  PostViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-08.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class PostViewModel: ObservableObject {
    @Published var post: Post?
    @Published var album: Album?
    @Published var user: User?
    
    private let db = Firestore.firestore()
    
    
    func createPost(albumID: String, imageURL: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // Step 1: Generate a UUID for the new post
        let newPostUUID = UUID().uuidString
        
        // Step 2: Get the user's UID (userUuid)
        let userUUID = user.uid
        
        // Step 3: Create a Post object
        let newPost = Post(Postuuid: newPostUUID, userUuid: userUUID, imageURL: imageURL)
        
        // Step 4: Save the Post object to Firestore
        let documentRef = db.collection("albums").document(albumID)
        documentRef.updateData([
            "posts": FieldValue.arrayUnion([newPost])
        ]) { error in
            if let error = error {
                print("Error creating post: \(error)")
            } else {
                print("Post created successfully")
            }
        }
    }
}


    /*
    
func createAlbum(albumName: String, endDate: Date, photoLimit: Int, members: [String], creator: String) {
    DispatchQueue.main.async {
        self.addAlbum(Album(uuid: (self.uuid)!, albumName: albumName, endDate: endDate, photoLimit: photoLimit, members: members, creator: creator))
        self.syncAlbums()

    }
}
     
     
     private func addAlbum(_ album: Album) {
         guard userIsAuthenticated else {return}
         do {
             let document = db.collection("albums").document()
                 try document.setData(from: album)
             } catch {
                 print("Error albumSettings: \(error)")
                 
             }
         }
     
     
     
*/
