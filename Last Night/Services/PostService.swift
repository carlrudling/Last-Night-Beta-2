import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class PostService: ObservableObject {
    @Published var post: Post?
    
    private let db = Firestore.firestore()
    
    func createPost(albumId: String, imagePath: String, imageURL: String, userUUID: String) {
        DispatchQueue.global().async {
            let startDate = Date()
            let uploadTime = Date()
            // Step 1: Generate a UUID for the new post
            let newPostUUID = UUID().uuidString
            print("This is the imagePath in craetePost func \(imagePath)")
            // Step 2: Create a Post object
            let newPost = Post(Postuuid: newPostUUID, userUuid: userUUID, imagePath: imagePath, imageURL: imageURL, uploadTime: uploadTime)
            
            
            
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
    
    
    func reportPost(userUUID: String, post: Post, albumDocumentID: String, completion: @escaping (Bool) -> Void) {
        var updatedPost = post

        // Check if the user has already reported this post
        if updatedPost.reports[userUUID] == true {
            completion(false) // Post already reported by this user
            return
        }

        // Report the post
        updatedPost.reports[userUUID] = true

        // Check if the report count has reached the threshold
        let reportCount = updatedPost.reports.count
        if reportCount >= 3 {
            // If threshold reached, remove the post
            removePostFromAlbum(albumDocumentID: albumDocumentID, postID: post.Postuuid)
        }

        // Assuming each album contains its own posts, update the post in the album
        let albumRef = db.collection("albums").document(albumDocumentID)
        albumRef.getDocument { (document, error) in
            if let document = document, document.exists, var album = try? document.data(as: Album.self) {
                if let postIndex = album.posts.firstIndex(where: { $0.Postuuid == post.Postuuid }) {
                    album.posts[postIndex] = updatedPost
                    try? albumRef.setData(from: album) { error in
                        if let error = error {
                            print("Error updating post in album: \(error)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } else {
                    print("Post not found in album")
                    completion(false)
                }
            } else {
                print("Album document does not exist or error: \(error?.localizedDescription ?? "")")
                completion(false)
            }
        }
    }
    
    func removeReport(userUUID: String, post: Post, albumDocumentID: String, completion: @escaping (Bool) -> Void) {
        var updatedPost = post

        // Check if the user has already reported this post
        if updatedPost.reports[userUUID] != true {
            completion(false) // Post was not reported by this user
            return
        }

        // Remove the report for this post
        updatedPost.reports[userUUID] = nil

        // Update the post in the album
        let albumRef = db.collection("albums").document(albumDocumentID)
        albumRef.getDocument { (document, error) in
            if let document = document, document.exists, var album = try? document.data(as: Album.self) {
                if let postIndex = album.posts.firstIndex(where: { $0.Postuuid == post.Postuuid }) {
                    album.posts[postIndex] = updatedPost
                    try? albumRef.setData(from: album) { error in
                        if let error = error {
                            print("Error updating post in album: \(error)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } else {
                    print("Post not found in album")
                    completion(false)
                }
            } else {
                print("Album document does not exist or error: \(error?.localizedDescription ?? "")")
                completion(false)
            }
        }
    }
    
    func hasUserReportedPost(userUUID: String, post: Post) -> Bool {
        return post.reports[userUUID] == true
    }

    
    func removePostFromAlbum(albumDocumentID: String, postID: String) {
        let albumRef = db.collection("albums").document(albumDocumentID)

        albumRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var album = try? document.data(as: Album.self)
                guard let postIndex = album?.posts.firstIndex(where: { $0.Postuuid == postID }) else {
                    print("Post not found in album")
                    return
                }

                // Get the post
                let post = album?.posts[postIndex]

                // Delete the image from Firebase Storage
                let storageRef = Storage.storage().reference(withPath: (post?.imagePath ?? "") + ".jpg" )
                storageRef.delete { error in
                    if let error = error {
                        print("Error removing image from storage: \(error)")
                    } else {
                        print("Image successfully removed from storage")
                        
                        // Remove the post from the album's posts array
                        album?.posts.remove(at: postIndex)

                        // Update the album document in Firestore
                        try? albumRef.setData(from: album) { error in
                            if let error = error {
                                print("Error updating album document: \(error)")
                            } else {
                                print("Post successfully removed from album")
                            }
                        }
                    }
                }
            } else {
                print("Album document does not exist or error: \(error?.localizedDescription ?? "")")
            }
        }
    }


    
}




