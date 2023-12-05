
import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var profileImage: String = ""
    @Published var profileImageURL: String = ""
    @Published var showErrorMessage: Bool = false
    @Published var errorMessage: String = ""
    
    var signUpisValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !username.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count > 5
    }
    
    
    var signInValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count > 5
        
    }
    
    func validateInputs() {
        if username.isEmpty {
            errorMessage = "Username cannot be empty."
            showErrorMessage = true
        }
        else if firstName.isEmpty {
            errorMessage = "First name cannot be empty."
            showErrorMessage = true
        } else if lastName.isEmpty {
            errorMessage = "Last name cannot be empty."
            showErrorMessage = true
        }  else if email.isEmpty {
            errorMessage = "Email cannot be empty."
            showErrorMessage = true
        } else if !email.contains("@") {
            errorMessage = "Email is invalid."
            showErrorMessage = true
        } else if password.count <= 5 {
            errorMessage = "Password must be more than 5 characters."
            showErrorMessage = true
        } else {
            showErrorMessage = false
        }
    }
    
    func validateSignInInputs() {
        if email.isEmpty {
            errorMessage = "Email cannot be empty."
            showErrorMessage = true
        } else if !email.contains("@") {
            errorMessage = "Email is invalid."
            showErrorMessage = true
        } else if password.count <= 5 {
            errorMessage = "Password must be more than 5 characters."
            showErrorMessage = true
        } else {
            showErrorMessage = false
        }
    }
    
}
