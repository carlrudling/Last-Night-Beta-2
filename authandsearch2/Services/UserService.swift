import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class UserService: ObservableObject {
    @Published var user: User?
    @Published var queryResultUsers: [User] = []
    @Published var fetchedUser: User?
    
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    var uuid: String? {
        auth.currentUser?.uid
    }
    var userIsAuthenticated: Bool {
        auth.currentUser != nil
    }
    var userIsAuthenticatedAndSynced: Bool {
        user != nil && userIsAuthenticated
    }
    
    // MARK: - Firebase Auth Functions
    // SIGN IN
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else { return }
            DispatchQueue.main.async {
                self?.sync()
            }
            
        }
    }
    // SIGN UP
    func signUp(username: String, email: String, firstName: String, lastName: String, password: String, profileImage: String, profileImageURL: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else { return }
            DispatchQueue.main.async {
                self?.add(User(uuid: (self?.uuid)!, username: username, firstName: firstName, lastName: lastName, profileImage: profileImage, profileImageURL: profileImageURL))
                self?.sync()
            }
        }
    }
    //SIGN OUT
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
        } catch {
            print("Error signing out user: \(error)")
        }
    }
    
    //Check the user's authentication status
    func checkAuthenticationStatus() {
        if auth.currentUser != nil {
            // User is signed in, sync their data
            self.sync()
        } else {
            // No user is signed in
            self.user = nil
        }
    }
    
    // MARK: - User Data Functions
    
    //Sync User Data from Firestore
    private func sync() {
        guard userIsAuthenticated else { return }
        db.collection("users").document(self.uuid!).getDocument { (document, error) in
            guard document != nil, error == nil else { return }
            do {
                try self.user = document!.data(as: User.self)
            } catch {
                print("Sync error: \(error)")
            }
        }
    }
    //Add a new user to Firestore
    private func add(_ user: User) {
        guard userIsAuthenticated else { return }
        do {
            let document = db.collection("users").document(self.uuid!)
            try document.setData(from: user)
            document.updateData(["keywordsForLookup": user.keywordsForLookup])
            print("Added document")
        } catch {
            print("Error adding: \(error)")
        }
    }
    //Update the existing user's data in the Firestore
    private func update() {
        guard userIsAuthenticatedAndSynced else { return }
        do {
            let document = db.collection("users").document(self.uuid!)
            try document.setData(from: user)
            document.updateData(["keywordsForLookup": self.user!.keywordsForLookup])
        } catch {
            print("Error updating: \(error)")
        }
    }
    
    
    // FETCH_USER
    func fetchUser(by uuid: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(uuid).getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                
                // These values might be optional, so it's okay to assign nil if they don't exist
                let profileImage = data["profileImage"] as? String ?? ""
                let profileImageURL = data["profileImageURL"] as? String ?? ""
                
                
                self.fetchedUser = User(
                    uuid: data["uuid"] as! String,
                    username: data["username"] as! String,
                    firstName: data["firstName"] as! String,
                    lastName: data["lastName"] as! String,
                    profileImage: profileImage,
                    profileImageURL: profileImageURL
                )
                completion(self.fetchedUser) // Call the completion handler here
            } else {
                print("User not found \(error?.localizedDescription ?? "")")
                completion(nil) // Call the completion handler here with nil to indicate user wasn't found
            }
        }
    }
    
    
    // MARK: - Profile Image & User Info update
    // RESIZE_IMAGES
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    // UPLOAD_PROFILE_IMAGES
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        guard userIsAuthenticated, let uuid = uuid else {
            print("user is not auth or UUID is missing")
            completion(NSError(domain: "UserViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated or UUID is missing"]))
            return
        }
        
        let imageUUID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images/\(imageUUID).jpg")
        
        guard let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 200, height: 200)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "UserViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image resizing or compression failed"]))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            print("putData callback called")
            if let error = error {
                print("Error in putData: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            // Image uploaded, now get the download URL
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                guard let downloadURL = url else {
                    completion(NSError(domain: "UserViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not retrieve download URL"]))
                    return
                }
                
                // Update the user's document in Firestore with the download URL
                self.db.collection("users").document(uuid).updateData([
                    "profileImageURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("Error updating Firestore: \(error.localizedDescription)")
                    }
                    completion(error)
                }
            }
        }
    }
    //Fetch the Image URL to display via KingFisher
    func fetchImageDownloadURL(imagePath: String, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child(imagePath)
        storageRef.downloadURL { (url, error) in
            completion(url)
        }
    }
    
    // UPDATE_USER_PROFILE
    func updateUserProfile(firstName: String, lastName: String, username: String, completion: @escaping (Error?) -> Void) {
        guard let uuid = uuid else {
            completion(NSError(domain: "UserViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "UUID is missing"]))
            return
        }
        
        // Prepare the data dictionary with the updates
        var updates = [String: Any]()
        if !firstName.isEmpty {
            updates["firstName"] = firstName
        }
        if !lastName.isEmpty {
            updates["lastName"] = lastName
        }
        if !username.isEmpty {
            updates["username"] = username
        }
        
        // Update Firestore document
        db.collection("users").document(uuid).updateData(updates) { error in
            if let error = error {
                print("Error updating user: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            // Optionally, if you want to update the local 'user' object after a successful Firestore update:
            if let user = self.user {
                if !firstName.isEmpty {
                    self.user?.firstName = firstName
                }
                if !lastName.isEmpty {
                    self.user?.lastName = lastName
                }
                if !username.isEmpty {
                    self.user?.username = username
                }
                // Publish the changes to subscribers of the 'user' object
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
            
            // No error, pass nil to the completion handler
            completion(nil)
        }
    }
    
    
    
}

