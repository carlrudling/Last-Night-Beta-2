//
//  FetchAlbumsView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-01.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var userService: UserService
    @Binding var isTabBarHidden: Bool
    @State private var isActive : Bool = false
    
    
    // Remove button and fetch onAppear
    // Have button that navigates to create album
    // Make list of fetched albums and if pressed nav to view to display all info of that album
    
    var body: some View {
        VStack {
            
            
                VStack {
                    
                    
                    Spacer()
                    // Your SwiftUI content here
                    
                    NavigationLink(destination: CreateAlbumView(isTabBarHidden: $isTabBarHidden, rootIsActive: $isActive), isActive: $isActive) {
                        Text("Create Album")
                            .font(Font.custom("Chillax", size: 20))
                            .frame(width: 240, height: 60) // Align the button to center horizontally
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                            .foregroundColor(.white)
                            .contentShape(Rectangle())
                                            // ... styling ...
                                    }
                    .isDetailLink(false)
                    .navigationBarTitleDisplayMode(.inline)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                                        // this sets the screen title in the navigation bar, when the screen is visible
                            Text("Primary View")
                                    }
                                }
                    ScrollView {
                        VStack {
                            ForEach(albumService.queryResultAlbums, id: \.uuid) { album in
                                NavigationLink(
                                    destination: Group {
                                        if album.isActive {
                                            AlbumInfoView(isTabBarHidden: $isTabBarHidden, album: album)
                                        } else {
                                            
                                            AlbumSlideshowView(isTabBarHidden: $isTabBarHidden, album: album)
                                        }
                                    })  {
                                        Text(album.albumName)
                                            .frame(width: 240, height: 40)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                                            .contentShape(Rectangle())
                                            .foregroundColor(.white)
                                    }
                                
                            }
                            
                        }
                    }
                    .frame(maxHeight: 300)
                    .padding(.bottom, 120)
                    
                    
                }
            }
        
        
        
        .onAppear{
            albumService.fetchAlbums(forUserWithID: userService.uuid ?? "")
            isTabBarHidden = false
        }
    }
}

struct FetchAlbumsView_Previews: PreviewProvider {
    @State static private var isTabBarHidden = false
    
    static var previews: some View {
        HomeView(isTabBarHidden: $isTabBarHidden)
    }
}

// Maybe it is a carusell to make it look better
// SwiftUIWheelPicker?

