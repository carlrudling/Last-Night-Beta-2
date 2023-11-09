import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack {
            SignInView()
            NavigationLink("Sign Up!", destination: SignUpView())
        }
    }
}



