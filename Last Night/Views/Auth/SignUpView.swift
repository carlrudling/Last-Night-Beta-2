import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(Font.custom("Chillax-Regular", size: 25))
                .foregroundColor(.black)
                .padding(.top, 40)
                .padding(.bottom, 40)
            
            Form{
                Section(header: Text("Using Email & Password")
                    .font(Font.custom("Chillax-Regular", size: 16))
){
                    TextField("Username", text: $authViewModel.username)
                        .font(Font.custom("Chillax-Regular", size: 16))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("First Name", text: $authViewModel.firstName)
                        .font(Font.custom("Chillax-Regular", size: 16))
                    TextField("Last Name", text: $authViewModel.lastName)
                        .font(Font.custom("Chillax-Regular", size: 16))
                    TextField("Email", text: $authViewModel.email)
                        .font(Font.custom("Chillax-Regular", size: 16))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $authViewModel.password)
                        .font(Font.custom("Chillax-Regular", size: 16))
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
                            self.presentationMode.wrappedValue.dismiss()

                        }
                    }) {
                        HStack{
                            Text("SIGN UP")
                                .font(Font.custom("Chillax-Medium", size: 20))
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
                        .font(Font.custom("Chillax-Regular", size: 16))
                        .foregroundColor(.white)
                    Text("Sign in")
                        .font(Font.custom("Chillax-Medium", size: 16))
                        .foregroundColor(.white)
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .background(
            BackgroundView()
                .frame(width: 600, height: 1500)
                .rotationEffect(.degrees(-50))
                .offset(y: 300)
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
