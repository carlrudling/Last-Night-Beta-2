//
//  User.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//
/*
import Foundation


struct User: Codable {
    var uuid: String
    var username : String
    var firstName: String
    var lastName : String
    var signUpDate = Date.now
    var keywordsForLookup: [String] {
        [self.username.generateStringSequence(), self.firstName.generateStringSequence(), self.lastName.generateStringSequence(), "\(self.firstName) \(self.lastName)".generateStringSequence()].flatMap { $0 }
    }
}


extension String {
    func generateStringSequence() -> [String] {
        // Ex) "Mark" => ["M", "MA", "MAR", "MARK"]
        guard self.count > 0 else {return []}
        var sequences: [String] = []
        for i in 1...self.count {
            sequences.append(String(self.prefix(i)))
        }
        return sequences
    }
}
*/


import Foundation

struct User: Codable, Identifiable {
    var uuid: String
    var username: String
    var firstName: String
    var lastName: String
    var profileImage: String
    var signUpDate = Date.now
    var keywordsForLookup: [String] {
        [self.username.generateStringSequence(), self.firstName.generateStringSequence(), self.lastName.generateStringSequence(), "\(self.firstName) \(self.lastName)".generateStringSequence()].flatMap { $0 }
    }
    
    var id: String {
            return uuid
        }
}

extension String {
    func generateStringSequence() -> [String] {
        /// E.g) "Mark" yields "M", "Ma", "Mar", "Mark"
        var sequences: [String] = []
        for i in 1...self.count {
            sequences.append(String(self.prefix(i)))
        }
        return sequences
    }
}

