//
//  ProfileView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-29.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    @EnvironmentObject var user: UserViewModel
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink(destination: EditProfileView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .padding(20)
                }
            }
            if let userProfile = user.user, let profileImageURL = userProfile.profileImageURL, profileImageURL != "" {
                
                KFImage(URL(string: profileImageURL))
                    .resizable()
                    .placeholder {
                        ProgressView() // Placeholder while loading
                    }
                    .scaledToFill() // The image will fill the frame and clip the excess parts
                    .clipShape(Circle())  // This line makes the image circular
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional: Adds a border
                    .shadow(radius: 10)  // Optional: Adds a shadow
                    .frame(width: 100, height: 100) // Set both width and height
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



struct FirebaseProfileImageView: View {
    @ObservedObject  var imageLoader: ImageViewModel
    
    init(imagePath: String) {
        imageLoader = ImageViewModel(imagePath: imagePath)
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            ProgressView()  // or a placeholder image
        }
    }
}

/*
struct ProfileView_Previews: PreviewProvider {
    @State var profileImage : UIImage
    static var previews: some View {
        ProfileView( profileImage: UIImage)
    }
}

*/
