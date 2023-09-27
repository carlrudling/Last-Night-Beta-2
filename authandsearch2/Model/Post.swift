//
//  Post.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-04.
//

import Foundation
import UIKit

struct Post: Codable {
    var Postuuid: String
    var userUuid: String
    var imageURL : String
    
    
    func toDictionary() -> [String: Any] {
            return [
                "Postuuid": Postuuid,
                "userUuid": userUuid,
                "imageURL": imageURL
            ]
        }
    
    /*
    func asDictionary() throws -> [String: Any] {
           let data = try JSONEncoder().encode(self)
           guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
               throw NSError(domain: "Error converting Post to Dictionary", code: 0, userInfo: nil)
           }
           return dictionary
       }
     */
}
