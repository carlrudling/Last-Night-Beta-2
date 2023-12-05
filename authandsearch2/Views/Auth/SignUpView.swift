import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.system(size: 25))
                .foregroundColor(.black)
                .padding(.top, 40)
                .padding(.bottom, 40)
            
            Form{
                Section(header: Text("Using Email & Password")){
                    TextField("Username", text: $authViewModel.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("First Name", text: $authViewModel.firstName)
                    TextField("Last Name", text: $authViewModel.lastName)
                    TextField("Email", text: $authViewModel.email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $authViewModel.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    if authViewModel.showErrorMessage {
                        withAnimation {
                            Text("\(authViewModel.errorMessage)")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                        }
                    }
                    Button(action: {
                        authViewModel.validateInputs()
                        if authViewModel.signUpisValid {
                            userService.signUp(username: "@\(authViewModel.username)", email: authViewModel.email, firstName: authViewModel.firstName, lastName: authViewModel.lastName, password: authViewModel.password, profileImage: authViewModel.profileImage, profileImageURL: authViewModel.profileImageURL)
                        }
                    }) {
                        HStack{
                            Text("SIGN UP")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(.blue)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .opacity(!authViewModel.signUpisValid ? 0.5 : 1)
                    
                }
            }
            .frame(height: 500)
            .scrollContentBackground(.hidden)
            Spacer()
            NavigationLink(destination: SignInView()) {
                HStack(spacing: 3) {
                    Text("Don't have an account?")
                        .foregroundColor(.white)
                    Text("Sign in")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
        }
        .background(
            Rectangle()
                .fill(Color.blue)
                .frame(width: 600, height: 1500)
                .rotationEffect(.degrees(-50))
                .offset(y: 300)
                .cornerRadius(10), alignment: .center
        )
    }
}



struct SignUpView_Previews: PreviewProvider {
   
    static var previews: some View {
        let sampleAuthViewModel = AuthViewModel()
        SignUpView()
            .environmentObject(sampleAuthViewModel)
    }
}
