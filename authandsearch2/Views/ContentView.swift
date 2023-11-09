//
//  ContentView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var post: PostViewModel
    @EnvironmentObject var fetchAlbumModel: FetchAlbums
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationStack {
            if userService.userIsAuthenticatedAndSynced {
                MainTabbedView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear(perform: userService.checkAuthenticationStatus)  // call checkAuthenticationStatus when ContentView appears
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
