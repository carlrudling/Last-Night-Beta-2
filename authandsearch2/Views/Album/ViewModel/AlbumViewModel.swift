import Foundation
import SwiftUI

class AlbumViewModel: ObservableObject {
    @Published var albumName: String = ""
    @Published var photoLimit: Int = 0
    @Published var endDate = Date()
    @Published var creator: String = ""
    @Published var members: [String] = []
    @Published var showErrorMessage: Bool = false
    @Published var errorMessage: String = ""
    @Published var keyword = ""
    @Published var fetchedUsers: [User] = []
    
    private var userService: UserService // Assuming this is your service class
    
    private var albumService: AlbumService

        // Initialize viewModel with AlbumService
        init(userService: UserService, albumService: AlbumService) {
            self.userService = userService
            self.albumService = albumService
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
    
    // Update Album
        func updateAlbum(originalAlbum: Album, completion: @escaping (Bool) -> Void) {
            var updatedAlbum = originalAlbum
            updatedAlbum.albumName = self.albumName
            updatedAlbum.endDate = self.endDate
            updatedAlbum.photoLimit = self.photoLimit
            updatedAlbum.members = self.members

            // Use AlbumService to update the album in Firestore
            albumService.editAlbum(album: updatedAlbum)
            completion(true) // Call completion handler
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
