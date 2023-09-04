//
//  AuthenticationView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//
/*
import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack {
            VStack {
                SignInView()
                NavigationLink("Sign Up!", destination: SignUpView())
                
            }
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var user: UserViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            SecureField("Password", text: $password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            Button(action: {
                user.signIn(email: email, password: password)
            }) {
                Text("Sign In")
            }
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var user: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    
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
            Button {
                user.signUp(username: username, email: email, firstName: firstName, lastName: lastName, password: password)
            } label: {
                Text("Sign Up")
            }

        }
    }
}
*/
 
import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack {
            SignInView()
            NavigationLink("Sign Up!", destination: SignUpView())
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var user: UserViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .disableAutocorrection(true)
             SecureField("Password", text: $password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            Button(action: {
                user.signIn(email: email, password: password)
            }) {
                Text("Sign In")
            }
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var user: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    
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
                user.signUp(username: username, email: email, firstName: firstName, lastName: lastName, password: password)
            }) {
                Text("Sign Up")
            }
        }
    }
}


/*

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
*/
