//
//  UserGridView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

import SwiftUI
import Kingfisher

struct UserGridView: View {
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var userService: UserService
    
    @Binding var selectedDetent: PresentationDetent
    @State private var users: [User] = [] // State to hold the fetched users
    var album: Album
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                    ForEach(users, id: \.uuid) { user in
                        VStack {
                            if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.gray)
                                    .frame(width: 70, height: 70)
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            }
                            Text(user.username)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .padding(5)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            albumService.fetchUsersFromAlbum(album: album, userService: userService) { fetchedUsers in
                users = fetchedUsers // Updating the state with fetched users
                    
            }
            selectedDetent = .medium
        }
    }
}
