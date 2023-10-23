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
    @State private var email = "hi@boy.com"
    @State private var password = "123456"
    
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
                user.signUp(username: "\(username)", email: email, firstName: firstName, lastName: lastName, password: password, profileImage: profileImage, profileImageURL: profileImageURL)
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
