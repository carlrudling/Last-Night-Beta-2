//
//  FetchAlbumsView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-01.
//

import SwiftUI
import FirebaseAuth

struct FetchAlbumsView: View {
    @StateObject private var fetchAlbums = FetchAlbums() // Create an instance of FetchAlbums
    @EnvironmentObject var user: UserViewModel
    
    
    // Remove button and fetch onAppear
    // Have button that navigates to create album
    // Make list of fetched albums and if pressed nav to view to display all info of that album
    
    var body: some View {
        VStack {
            
            
            NavigationView {
                VStack {
                    
                    
                    Spacer()
                    // Your SwiftUI content here
                    
                    NavigationLink(destination: createAlbumView(), label: {
                        Text("Create Album")
                            .font(Font.custom("Chillax", size: 20))
                            .frame(width: 240, height: 60) // Align the button to center horizontally
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                            .foregroundColor(.white)
                            .contentShape(Rectangle())
                        
                        
                    })
                    .padding()
                    
                    ScrollView {
                        VStack {
                            ForEach(fetchAlbums.queryResultAlbums, id: \.uuid) { album in
                                NavigationLink(
                                    destination: AlbumInfoView(album: album)
                                ) {
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
        }

        
        .onAppear{
            fetchAlbums.fetchAlbums(with: user.uuid ?? "")
        }
    }
}

struct FetchAlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        FetchAlbumsView()
    }
}
