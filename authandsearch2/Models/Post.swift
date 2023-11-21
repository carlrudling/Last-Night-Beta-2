//
//  Post.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-04.
//

import Foundation
import UIKit

struct Post: Codable, Identifiable {
    var Postuuid: String
    var userUuid: String
    var imagePath: String
    var imageURL: String
    var uploadTime: Date
    
    var id: String {
            return Postuuid
        }
    
    func toDictionary() -> [String: Any] {
            return [
                "Postuuid": Postuuid,
                "userUuid": userUuid,
                "imagePath": imagePath,
                "imageURL": imageURL,
                "uploadTime": uploadTime
            ]
        }
    
  
}
