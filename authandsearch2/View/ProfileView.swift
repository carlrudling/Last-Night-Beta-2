//
//  ProfileView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-29.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var user : UserViewModel
    
    func formattedImagePath(from imagepaths: String) -> String {
        let imagePath = imagepaths
        print(imagePath)
        return imagePath
    }
    
    var body: some View {
        VStack {
            if let userProfile = user.user, userProfile.profileImage != "" {
                FirebaseImageView(imagePath: formattedImagePath(from: userProfile.profileImage))
                    .clipShape(Circle())  // This line makes the image circular
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional: Adds a border
                    .shadow(radius: 10)  // Optional: Adds a shadow
                    .frame(height: 200)
                    .padding(.top, 80)
            }
            
            HStack {
                Text(user.user?.firstName ?? "Name")
                Text(user.user?.lastName ?? "")
            }
            .font(.system(size: 20))
            Text(user.user?.username ?? "Unknown")
                .font(.system(size: 16))
            Spacer()
            
            Button(action: {
                       user.signOut()
                   }) {
                       Text("Sign Out")
                           .font(.system(size: 25))
                           .frame(width: 150)
                           .padding()
                           .background(Color.red)
                           .foregroundColor(.white)
                           .clipShape(Capsule())
                           .frame(width: 150)
                           .padding(.bottom, 80)
                   }
               }
        }
    }


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

