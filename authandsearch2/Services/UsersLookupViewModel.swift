//
//  UsersLookupViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//
/*
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class UsersLookupViewModel: ObservableObject {
    @Published var queriedUsers: [User] = []
    
    private let db = Firestore.firestore()
    
    func fetchUsers(from keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).getDocuments {
            querySnapshot, error in guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedUsers = documents.compactMap {queryDocumentSnapshot in try? queryDocumentSnapshot.data(as: User.self)
                
            }
        }
    }
}
*/


import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class UsersLookupViewModel: ObservableObject {
    @Published var queryResultUsers: [User] = []
    
    private let db = Firestore.firestore()
    
    func fetchUsers(with keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("No documents")
                return
            }
            self.queryResultUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
}

