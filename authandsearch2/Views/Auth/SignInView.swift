//
//  SignInView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-12.
//
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        VStack {
            Text("Sign In")
                .font(.system(size: 25))
                .foregroundColor(.black)
                .padding(.top, 40)
                .padding(.bottom, 40)
            
            Form {
                Section(header: Text("Using Email & Password")){
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
                        authViewModel.validateSignInInputs()
                        if authViewModel.signInValid {
                            userService.signIn(email: authViewModel.email, password: authViewModel.password)
                        }
                    }) {
                        HStack{
                            Text("SIGN IN")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(.blue)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .opacity(!authViewModel.signInValid ? 0.5 : 1)
                }
            }
            .frame(height: 300)
            .scrollContentBackground(.hidden)
            Spacer()
            NavigationLink(destination: SignUpView()) {
                HStack(spacing: 3) {
                    Text("Already have an account?")
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

