//
//  ContentView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var album: AlbumViewModel
    @EnvironmentObject var post: PostViewModel
    @EnvironmentObject var fetchAlbumModel: FetchAlbums
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationStack {
            if user.userIsAuthenticatedAndSynced {
                MainTabbedView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear(perform: user.checkAuthenticationStatus)  // call checkAuthenticationStatus when ContentView appears
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
