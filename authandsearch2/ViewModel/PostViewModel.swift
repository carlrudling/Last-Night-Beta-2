//
//  PostViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-08.
//
/*
 import Foundation
 import FirebaseAuth
 import FirebaseFirestore
 import FirebaseFirestoreSwift
 import FirebaseStorage
 
 class PostViewModel: ObservableObject {
 @Published var post: Post?
 
 
 
 private let db = Firestore.firestore()
 
 
 func createPost(albumId: String, imagePath: String, userUUID: String) {
 
 // Get a reference to the image in Firebase Storage using the path
 let storageRef = Storage.storage().reference(withPath: imagePath)
 
 // Fetch the download URL
 storageRef.downloadURL { (url, error) in
 if let error = error {
 print("Error fetching download URL: \(error)")
 return
 }
 
 guard let downloadURL = url else {
 print("No download URL found.")
 return
 }
 
 // Now you have both the path (imageURL) and the downloadURL
 
 
 // Step 1: Generate a UUID for the new post
 let newPostUUID = UUID().uuidString
 
 // Step 2: Create a Post object
 let newPost = Post(Postuuid: newPostUUID, userUuid: userUUID, imagePath: imagePath, imageURL: downloadURL.absoluteString)
 
 // Step 3: Query the albums collection to find the document with the specified albumId
 self.db.collection("albums")
 .whereField("uuid", isEqualTo: albumId)
 .getDocuments { (querySnapshot, error) in
 if let error = error {
 print("Error finding album: \(error)")
 return
 }
 
 // Step 4: For each document found (though there should only be one),
 // add the post to the posts array in the document
 for document in querySnapshot!.documents {
 let documentRef = document.reference
 documentRef.updateData([
 "posts": FieldValue.arrayUnion([newPost.toDictionary()])
 ]) { error in
 if let error = error {
 print("Error creating post: \(error)")
 } else {
 print("Post created successfully")
 }
 }
 }
 }
 }
 }
 }
 
 */

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class PostViewModel: ObservableObject {
    @Published var post: Post?
    
    private let db = Firestore.firestore()
    
    func createPost(albumId: String, imagePath: String, imageURL: String, userUUID: String) {
        DispatchQueue.global().async {
            let startDate = Date()
            // Step 1: Generate a UUID for the new post
            let newPostUUID = UUID().uuidString
            print("This is the imagePath in craetePost func \(imagePath)")
            // Step 2: Create a Post object
            let newPost = Post(Postuuid: newPostUUID, userUuid: userUUID, imagePath: imagePath, imageURL: imageURL)
            
            
            
            // Step 3: Query the albums collection to find the document with the specified albumId
            self.db.collection("albums")
                .whereField("uuid", isEqualTo: albumId)
                .getDocuments { (querySnapshot, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error finding album: \(error)")
                            return
                        }
                        
                        // Step 4: For each document found (though there should only be one),
                        // add the post to the posts array in the document
                        for document in querySnapshot!.documents {
                            let documentRef = document.reference
                            documentRef.updateData([
                                "posts": FieldValue.arrayUnion([newPost.toDictionary()])
                            ]) { error in
                                if let error = error {
                                    print("Error creating post: \(error)")
                                } else {
                                    print("CreatePost: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")
                                    print("Post created successfully")
                                }
                            }
                        }
                    }
                }
            
            
        }
    }
    
}




