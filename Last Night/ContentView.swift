import SwiftUI


struct ContentView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var postService: PostService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationStack {
            if userService.userIsAuthenticatedAndSynced {
                MainTabbedView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear(perform: userService.checkAuthenticationStatus) 
    }
}

