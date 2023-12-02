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
    @State var createAlbumSheet = false
    @State var selectedDetent: PresentationDetent = .medium

    // Remove button and fetch onAppear
    // Have button that navigates to create album
    // Make list of fetched albums and if pressed nav to view to display all info of that album
    
    var body: some View {
        VStack {
            
            
                VStack {
                    
                    
                    Spacer()
                    // Your SwiftUI content here
                    
                    Button(action: {
                        createAlbumSheet.toggle()
                               }) {
                                   Text("Create Album")
                                       .font(Font.custom("Chillax", size: 20))
                                       .frame(width: 240, height: 60)
                                       .padding()
                                       .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                                       .foregroundColor(.white)
                               }
                               .sheet(isPresented: $createAlbumSheet) {
                                   NavigationView {
                                       CreateAlbumView(isTabBarHidden: $isTabBarHidden, createAlbumSheet: $createAlbumSheet)
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


/*
 Button(action: {
     slideShowViewModel.showUserGrid.toggle()
 }) {
     Image(systemName: "person.2.fill")
         .resizable()
         .scaledToFit()
         .frame(height: 30)
         .foregroundColor(.white)
         .padding(.vertical)
 }
 .sheet(isPresented: $slideShowViewModel.showUserGrid) {
     UserGridView(selectedDetent: $slideShowViewModel.selectedDetent, album: album)
         .presentationDetents([.medium, .large], selection: $slideShowViewModel.selectedDetent)
         .presentationDragIndicator(.hidden)
         .presentationBackground(.white
         )
 }
*/
