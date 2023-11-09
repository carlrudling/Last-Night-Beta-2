//
//  SignUpView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userService: UserService
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var profileImage = ""
    @State private var profileImageURL = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .disableAutocorrection(true)
             SecureField("Password", text: $password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            Button(action: {
                userService.signUp(username: "\(username)", email: email, firstName: firstName, lastName: lastName, password: password, profileImage: profileImage, profileImageURL: profileImageURL)
            }) {
                Text("Sign Up")
            }
        }
    }
}
