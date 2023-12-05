//
//  Album.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-30.
//


import Foundation
import FirebaseFirestoreSwift


struct Album: Codable {
    var uuid: String
    var albumName: String
    var endDate = Date()
    var photoLimit : Int
    var members : [String] = []
    var creator : String
    var posts : [Post] = []
    var thumbnailURL: String? // Add this line
    var messages: [Message] = []

    
    @DocumentID var documentID: String? // Adding a documentID property


    
    var isActive: Bool {
        return endDate > Date()
    }
   
}

