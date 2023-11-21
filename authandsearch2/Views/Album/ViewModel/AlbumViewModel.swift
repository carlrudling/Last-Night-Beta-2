//
//  AlbumViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-13.
//


import Foundation
import SwiftUI

class AlbumViewModel: ObservableObject {
    @Published var albumName: String = ""
    @Published var photoLimit: Int = 0
    @Published var endDate = Date()
    @Published var creator: String = ""
    @Published var members : [String] = []
    @Published var showErrorMessage: Bool = false
    @Published var errorMessage: String = ""
    @Published var keyword = ""
    @Published var fetchedUsers: [User] = []
    
    private var userService: UserService // Assuming this is your service class

    init(userService: UserService) {
          self.userService = userService
      }
    
var albumValid: Bool {
    !albumName.isEmpty
}
var isActive: Bool {
    return endDate > Date()
    
}
    
    func validateInputs() {
        if albumName.isEmpty {
            errorMessage = "albumName cannot be empty."
            showErrorMessage = true
        } else {
            showErrorMessage = false
        }
    }
    
    func fetchAllUsers() {
        // Clear current fetched users
        fetchedUsers = []
        
        for uuid in members {
            userService.fetchUser(by: uuid) { [weak self] user in
                DispatchQueue.main.async {
                    if let user = user {
                        self?.fetchedUsers.append(user)
                    }
                }
            }
        }
    }
    func resetValues() {
            albumName = ""
            photoLimit = 0
            endDate = Date()
            creator = ""
            members = []
            showErrorMessage = false
            errorMessage = ""
            keyword = ""
            fetchedUsers = []
        }

}

enum photoLimity: CaseIterable, Identifiable {
    
    case None, ten, fifteen, twenty
    
    var id: Self { self }
    
    var description: String {
        
        switch self {
        case .None:
            return "0"
        case .ten:
            return "10"
        case .fifteen:
            return "15"
        case .twenty:
            return "20"
        }
    }
    
    var intValue: Int {
        
        switch self {
        case .None:
            return 0
        case .ten:
            return 10
        case .fifteen:
            return 15
        case .twenty:
            return 20
        }
        
    }
}
