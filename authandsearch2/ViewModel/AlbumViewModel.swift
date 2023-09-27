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
    
    

   // @EnvironmentObject var user : UserViewModel

    
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
    
    
    // Firestore Functions for albums
    
    private func addAlbum(_ album: Album) {
        guard userIsAuthenticated else {return}
        do {
            let document = db.collection("albums").document()
                try document.setData(from: album)
            } catch {
                print("Error albumSettings: \(error)")
                
            }
        }
   // Seems to be creating the uuid the same as user.uuid instead of a unique for the album
    func createAlbum(albumName: String, endDate: Date, photoLimit: Int, members: [String], creator: String) {
        DispatchQueue.main.async {
            self.addAlbum(Album(uuid: self.albumUUid, albumName: albumName, endDate: endDate, photoLimit: photoLimit, members: members, creator: creator))
            self.syncAlbums()

        }
    }
    
    
    func addMembers(Albumuuid: String, member : String) {
        guard userIsAuthenticated else {return}
            let document = db.collection("albums").document(Albumuuid)
            document.updateData(["members": FieldValue.arrayUnion([member])
                                ]) {error in
                if let error = error {
                    print("Error adding post: \(error)")
                } else {
                    print("Post added suvvessfully")
                }
            }
    }
    
    private func syncAlbums() {
        guard userIsAuthenticated else { return }
        db.collection("albums").document(UUID().uuidString).getDocument { (document, error) in
            guard document != nil, error == nil else { return }
            do {
                try self.album = document!.data(as: Album.self)
            } catch {
                print("Sync error: \(error)")
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


        
    /*
     Album:
     var uuid: String
     var albumName: String
     var endDate = Date()
     var photoLimit : Int
     var members : [User] = []
     
     User:
     var uuid: String
     var username: String
     var firstName: String
     var lastName: String
     var signUpDate = Date.now
     var keywordsForLookup: [String] {
     
    func signUp(username: String, email: String, firstName: String, lastName: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else { return }
            DispatchQueue.main.async {
                self?.add(User(uuid: (self?.uuid)!, username: username, firstName: firstName, lastName: lastName))
                self?.sync()
            }
        }
    }
    */
    
    // Firestore Functions for User Data
    
    private func add(_ user: User) {
        guard userIsAuthenticated else { return }
        do {
            let document = db.collection("users").document(self.uuid!)
            try document.setData(from: user)
            document.updateData(["keywordsForLookup": user.keywordsForLookup])
            print("Added document")
        } catch {
            print("Error adding: \(error)")
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
}


