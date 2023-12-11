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
        ZStack{
            
            VStack{
                HStack{
                  Text("Last Night")
                        .font(.custom("Barrbar", size: 30))
                        .foregroundColor(.black)
                        .padding(.leading, 15)
                        .padding(.top, 40)
                    Spacer()
                }
                Spacer()
            }
            VStack {
                Image("Discoball-Homeview2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .padding(.top, -220)
                    .edgesIgnoringSafeArea(.top)
                    .padding(.bottom, 60)
                
                Button(action: {
                    createAlbumSheet.toggle()
                }) {
                    ZStack {
                        // Background with shadow
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.lightPurple)
                            .frame(width: 280, height: 80)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        // Overlay gradient
                        HStack {
                            Spacer()
                            LinearGradient(stops: [
                                .init(color: .clear, location: 0.8),
                                .init(color: .black.opacity(0.1), location: 1.0),
                            ], startPoint: .leading, endPoint: .trailing)
                        }
                        .frame(width: 280, height: 80)
                        .cornerRadius(10)
                        
                        // Button Text
                        Text("Create Album")
                            .font(.custom("Chillax-Medium", size: 20))
                            .foregroundColor(.white)
                    }
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
                                    
                                    ZStack {
                                        // Background with shadow
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(album.isActive ? Color.darkPurple : .green)
                                            .frame(width: 280, height: 80)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        
                                        // Overlay gradient
                                        HStack {
                                            Spacer()
                                            LinearGradient(stops: [
                                                .init(color: .clear, location: 0.8),
                                                .init(color: .black.opacity(0.1), location: 1.0),
                                            ], startPoint: .leading, endPoint: .trailing)
                                        }
                                        .frame(width: 280, height: 80)
                                        .cornerRadius(10)
                                        
                                        // Button Text
                                        Text(album.albumName)
                                            .font(.custom("Chillax-Regular", size: 18))
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                            
                        }
                        
                    }
                }
                .frame(maxHeight: 300)
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
            .background(
                ZStack{
                    Color.backgroundWhite.edgesIgnoringSafeArea(.all)
                    
                    // First Layer: Custom Background View
                    BackgroundView()
                        .frame(width: 600, height: 1500)
                        .rotationEffect(.degrees(-50))
                        .offset(y: 300)
                }
                )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        
        
        
        
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

