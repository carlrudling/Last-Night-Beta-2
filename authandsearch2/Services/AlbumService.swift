import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


class AlbumService: ObservableObject {
    @Published var user: User?
    @Published var album: Album?
    @Published var queryResultAlbums: [Album] = []
    @Published var fetchedUsers: [User] = []
    @Published var finishedAlbumsWithThumbnails: [Album] = []
    
    
    @DocumentID var id: String? = UUID().uuidString
    
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    var uuid: String? {
        auth.currentUser?.uid
    }
    var userIsAuthenticated: Bool {
        auth.currentUser != nil
    }
    var userIsAuthenticatedAndSynced: Bool {
        user != nil && userIsAuthenticated
    }
    
    var albumUUid = UUID().uuidString
    
    
    //MARK: - CREATE ALBUM
    // ADD_ALBUM
    private func addAlbum(_ album: Album) {
        guard userIsAuthenticated else {return}
        do {
            let _ = try db.collection("albums").addDocument(from: album)
        } catch {
            print("Error albumSettings: \(error)")
        }
    }
    
    
    // CREATE_ALBUM
    func createAlbum(albumName: String, endDate: Date, photoLimit: Int, members: [String], creator: String) {
        DispatchQueue.main.async {
            let album = Album(uuid: self.albumUUid, albumName: albumName, endDate: endDate, photoLimit: photoLimit, members: members, creator: creator)
            self.addAlbum(album)
            self.syncAlbums()
        }
    }
    
    
    
    // ADD_MEMBERS
    func addMembers(documentID: String, member: String, completion: @escaping (Bool) -> Void) {
        guard userIsAuthenticated else {
            completion(false)
            return
        }
        let document = db.collection("albums").document(documentID)
        document.updateData(["members": FieldValue.arrayUnion([member])]) { error in
            if let error = error {
                print("Error adding member: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Member added successfully")
                completion(true)
            }
        }
    }
    
    
    private func syncAlbums() {
        guard userIsAuthenticated else { return }
        db.collection("albums").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("No documents")
                return
            }
            self.queryResultAlbums = documents.compactMap { queryDocumentSnapshot in
                var album = try? queryDocumentSnapshot.data(as: Album.self)
                album?.documentID = queryDocumentSnapshot.documentID // Setting the documentID
                return album
            }
        }
    }
    
    //MARK: - FETCH, EDIT & UPDATE ALBUMS
    func fetchAlbums(forUserWithID uuid: String) {
        db.collection("albums").whereField("members", arrayContains: uuid).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("No documents")
                return
            }
            self.queryResultAlbums = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Album.self)
            }
        }
    }
    
    
    // EDIT_ALBUM
    func editAlbum(album: Album) {
        guard let documentID = album.documentID else {
            print("Error: Cannot edit album without a documentID")
            return
        }
        
        // Convert album to dictionary as Firestore needs [String: Any] to update data
        do {
            let albumData = try Firestore.Encoder().encode(album)
            db.collection("albums").document(documentID).updateData(albumData) { error in
                if let error = error {
                    print("Error updating album: \(error.localizedDescription)")
                } else {
                    print("Album successfully updated")
                    // Optionally, refresh local data or post a notification to update the UI
                    self.fetchAlbums(forUserWithID: album.creator) // assuming the creator ID is the one used to fetch albums
                }
            }
        } catch let error {
            print("Error encoding album: \(error.localizedDescription)")
        }
    }
    
    
    
    private func update() {
        guard userIsAuthenticatedAndSynced else { return }
        do {
            let document = db.collection("users").document(self.uuid!)
            try document.setData(from: user)
            document.updateData(["keywordsForLookup": self.user!.keywordsForLookup])
        } catch {
            print("Error updating: \(error)")
        }
    }
    
    //MARK: - Fetch Users, Leave Album & Remove Posts
    func fetchUsersFromAlbum(album: Album, userService: UserService, completion: @escaping ([User]) -> Void) {
        // An array to hold the fetched User objects
        var fetchedUsers: [User] = []
        
        // Using a DispatchGroup to handle the asynchronous fetching of users
        let dispatchGroup = DispatchGroup()
        
        // Iterating over each member UUID in the album
        for memberUuid in album.members {
            dispatchGroup.enter() // Entering the group before each async call
            
            // Fetching each user by UUID
            userService.fetchUser(by: memberUuid) { user in
                if let user = user {
                    fetchedUsers.append(user) // Adding the fetched user to the array
                }
                dispatchGroup.leave() // Leaving the group when the fetching is done
            }
        }
        
        // After all the users have been fetched
        dispatchGroup.notify(queue: .main) {
            completion(fetchedUsers) // Returning the fetched users in the completion handler
        }
    }
    
    
    // LEAVE_ALBUM
    func leaveAlbum(albumDocumentID: String) {
        guard let userUUID = uuid, userIsAuthenticated else { return }
        
        let albumDocument = db.collection("albums").document(albumDocumentID)
        
        albumDocument.updateData([
            "members": FieldValue.arrayRemove([userUUID])
        ]) { error in
            if let error = error {
                print("Error leaving album: \(error.localizedDescription)")
            } else {
                print("Successfully left the album")
            }
        }
    }
    
    // REMOVE_USER_POSTS_IMAGES
    func removeUserPosts(userUUID: String, albumDocumentID: String) {
        // Step 1: Find all posts made by the user in the album
        db.collection("posts").whereField("userUuid", isEqualTo: userUUID).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // Step 2: For each post document
                for document in querySnapshot!.documents {
                    guard let post = try? document.data(as: Post.self) else {
                        print("Error serializing document")
                        continue
                    }
                    
                    // Step 3: Delete the image from Firebase Storage
                    let storageRef = Storage.storage().reference(withPath: post.imagePath)
                    storageRef.delete { error in
                        if let error = error {
                            print("Error removing image from storage: \(error)")
                        } else {
                            print("Image successfully removed from storage")
                        }
                    }
                    
                    // Step 4: Delete the post from Firestore
                    self.db.collection("posts").document(document.documentID).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
            }
        }
        
    }
    
    
    // MARK: - FUNC FOR FINISHED ALBUMS
    // METHODS TESTED FOR PROFILEVIEW GRID
    func fetchFinishedAlbums(forUserWithID uuid: String, completion: @escaping ([Album]) -> Void) {
        db.collection("albums").whereField("members", arrayContains: uuid).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            
            var albums: [Album] = []
            
            for document in documents {
                if var album = try? document.data(as: Album.self) {
                    // Check if a thumbnailURL exists for the album
                    if let thumbnailURL = album.thumbnailURL {
                        album.thumbnailURL = thumbnailURL // Set the thumbnailURL for the album
                    }
                    
                    albums.append(album)
                }
            }
            
            completion(albums)
        }
    }
}


