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
    //var members : [User] = []
    var members : [String] = []
    var creator : String
    //var posts : [Post] = []
    
}



/*
enum photoLimit: CaseIterable {
case None
case Ten
case Fifteen
case Twenty
}
*/
