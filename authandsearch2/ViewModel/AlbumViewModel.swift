//
//  AlbumViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-30.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class AlbumViewModel: ObservableObject {
    @Published var user: User?
    @Published var album: Album?
    @Published var queryResultAlbums: [Album] = []
    @Published var fetchedUsers: [User] = []

    
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
    func addMembers(documentID: String, member: String) {
        guard userIsAuthenticated else {return}
        let document = db.collection("albums").document(documentID)
        document.updateData(["members": FieldValue.arrayUnion([member])]) { error in
            if let error = error {
                print("Error adding member: \(error.localizedDescription)")
            } else {
                print("Member added successfully")
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
    
    
    func fetchUsersFromAlbum(album: Album, userViewModel: UserViewModel, completion: @escaping ([User]) -> Void) {
        // An array to hold the fetched User objects
        var fetchedUsers: [User] = []
        
        // Using a DispatchGroup to handle the asynchronous fetching of users
        let dispatchGroup = DispatchGroup()
        
        // Iterating over each member UUID in the album
        for memberUuid in album.members {
            dispatchGroup.enter() // Entering the group before each async call
            
            // Fetching each user by UUID
            userViewModel.fetchUser(by: memberUuid) { user in
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

}


