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
    
   
        
        var body: some View {
            VStack {
                // Your SwiftUI content here
                
                Button("Fetch Albums") {
                    fetchAlbums.fetchAlbums(with: user.uuid ?? "GpEq5QJAPMZ8zHTer5Uu6Svpq8B2")
                }
                
                // You can display the fetched albums here
                List(fetchAlbums.queryResultAlbums, id: \.uuid) { album in
                    Text(album.albumName)
                }
            }
        }
    }

struct FetchAlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        FetchAlbumsView()
    }
}
