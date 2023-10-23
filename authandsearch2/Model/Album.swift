//
//  Album.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-30.
//

import Foundation

struct Album: Codable {
    var uuid: String
    var albumName: String
    var endDate = Date()
    var photoLimit : Int
    var members : [String] = []
    var creator : String
    var posts : [Post] = []

    
    var isActive: Bool {
        return endDate > Date()
    }
   
}



// Should Propably add a new variable saying isActive which if album.endDate < Date()  Bool = false
// If isActive = true Can add posts, can add members, can change settings
// Navigate to slideshoView if isActive = false
