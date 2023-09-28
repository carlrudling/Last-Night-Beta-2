//
//  ContentView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var user : UserViewModel
    @EnvironmentObject var album : AlbumViewModel
    @EnvironmentObject var post: PostViewModel

    var body: some View {
        NavigationView {
            if user.userIsAuthenticatedAndSynced {
              //  createAlbumView()
               // FetchAlbumsView()
                //CameraView2(albumuuid: "")
               CameraView(albumuuid: "LUjUOcK9ByPlcyjYYrda")
            } else {
                AuthenticationView()
            }
        }
    }
}
/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
