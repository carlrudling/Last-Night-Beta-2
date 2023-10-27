//
//  FetchAlbumsModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-03.
//
/*
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class FetchAlbums: ObservableObject {
    
    @Published var queryResultAlbums: [Album] = []
    
    private let db = Firestore.firestore()
    

    
    func fetchAlbums(with uuid: String) {
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
}

/*
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
*/
*/


// WAS ONLY USED IN THE HOMEVIEW & AlbumPickerView (in cameraview)!!

// SEE IF IT WORKS USING ALBUMVIEWMODEL INSTEAD, IF WORKS. REMOVE THIS VIEWMODEL!!
