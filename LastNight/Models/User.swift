

import Foundation

struct User: Codable, Identifiable {
    var uuid: String
    var username: String
    var firstName: String
    var lastName: String
    var profileImage: String
    var profileImageURL: String?
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

