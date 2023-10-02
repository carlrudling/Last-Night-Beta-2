//
//  UserViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//

/*
 import Foundation
 import FirebaseAuth
 import FirebaseFirestore
 import FirebaseFirestoreSwift
 
 class UserViewModel: ObservableObject {
 @Published var user: User?
 @Published var queriedUsers: [User] = []
 
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
 
 // Firebase Auth Functions
 func signIn(email: String, password: String) {
 auth.signIn(withEmail: email, password: password) {[weak self] result, error in guard result != nil, error == nil else {return}
 DispatchQueue.main.async {
 self?.sync()
 }
 }
 }
 
 func signUp(username: String, email: String, firstName: String, lastName: String, password: String) {
 auth.createUser(withEmail: email, password: password) { [weak self] result, error in guard result != nil, error == nil else {return}
 DispatchQueue.main.async {
 self?.add(User(uuid: (self?.uuid)!, username: username, firstName: firstName, lastName: lastName))
 self?.sync()
 }
 
 }
 }
 
 func signOut() {
 do {
 try auth.signOut()
 self.user = nil
 } catch {
 print("Error signing out user: \(error)")
 }
 }
 
 // firestore functions for user data
 
 private func sync() {
 guard userIsAuthenticated else {return}
 db.collection("users").document(self.uuid!).getDocument { (document, error) in
 guard document != nil, error == nil else {return}
 do {
 try self.user = document!.data(as: User.self)
 } catch {
 print("Sync error \(error)")
 }
 }
 }
 private func add(_ user: User) {
 guard userIsAuthenticated else { return}
 
 do {
 let document = db.collection("users").document(self.uuid!)
 try document.setData(from: user)
 document.updateData(["keywordsForLookup": user.keywordsForLookup])
 } catch {
 print("error adding: \(error)")
 }
 }
 
 
 private func update() {
 guard userIsAuthenticatedAndSynced else {return}
 do {
 let document = db.collection("users").document(self.uuid!)
 try document.setData(from: user)
 document.updateData(["keywordsForLookup": user!.keywordsForLookup])
 
 } catch {
 print("error updating: \(error)")
 }
 }
 }
 */


import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var queryResultUsers: [User] = []
    
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
    
    // Firebase Auth Functions
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else { return }
            DispatchQueue.main.async {
                self?.sync()
            }
            
        }
    }
    
    func signUp(username: String, email: String, firstName: String, lastName: String, password: String, profileImage: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else { return }
            DispatchQueue.main.async {
                self?.add(User(uuid: (self?.uuid)!, username: username, firstName: firstName, lastName: lastName, profileImage: profileImage))
                self?.sync()
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
        } catch {
            print("Error signing out user: \(error)")
        }
    }
    
    // Firestore Functions for User Data
    private func sync() {
        guard userIsAuthenticated else { return }
        db.collection("users").document(self.uuid!).getDocument { (document, error) in
            guard document != nil, error == nil else { return }
            do {
                try self.user = document!.data(as: User.self)
            } catch {
                print("Sync error: \(error)")
            }
        }
    }
    
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
    
    func checkAuthenticationStatus() {
        if auth.currentUser != nil {
            // User is signed in, sync their data
            self.sync()
        } else {
            // No user is signed in
            self.user = nil
        }
    }

    
    
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        // Ensure the user is authenticated and has a UUID
        /*
        guard userIsAuthenticatedAndSynced, let uuid = uuid else {
            completion(NSError(domain: "UserViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"]))
            return
        }
        */
        print("uploadProfileImage called")
        guard userIsAuthenticated else {
            print("user is not auth")
            return }
        guard let uuid = uuid else { return }
        // Create a unique identifier for the image
        let imageUUID = UUID().uuidString
        
        // Create a reference to Firebase Storage where the image will be uploaded
        let storageRef = Storage.storage().reference().child("\(imageUUID).jpg")
       
        // Convert the UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "UserViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image compression failed"]))
            return
        }
        
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            print("putData callback called")  // Debug line
            if let error = error {
                print("Error in putData: \(error)")  // Debug li
                completion(error)
                return
            }
            
            // Get the full path of the uploaded image
            let imagePath = storageRef.fullPath
            
            // Update the user's document in Firestore with the path of the profile image
            self.db.collection("users").document(uuid).updateData([
                "profileImage": imagePath
            ]) { error in
                completion(error)
                print(error ?? "")
            }
        }
    }
    
    
    
}


