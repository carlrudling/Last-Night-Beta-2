import SwiftUI
import Kingfisher

struct ProfileView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumService: AlbumService
    @State var editProfileSheet = false
    
    let spacing = 2.0
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    Color.purple
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: UIScreen.main.bounds.width, height: 100 )
                    Spacer()
                }
                VStack {
                    if let userProfile = userService.user, let profileImageURL = userProfile.profileImageURL, profileImageURL != "" {
                        
                        KFImage(URL(string: profileImageURL))
                            .resizable()
                            .placeholder {
                                ProgressView() // Placeholder while loading
                            }
                            .scaledToFill() // The image will fill the frame and clip the excess parts
                            .clipShape(Circle())  // This line makes the image circular
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional: Adds a border
                            .shadow(radius: 10)  // Optional: Adds a shadow
                            .frame(width: 100, height: 100) // Set both width and height
                            .padding(.top, 40)
                        
                        
                        
                        
                    }
                    else {
                        Circle()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray) // You can set any color you like
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional: Adds a border
                            .shadow(radius: 10)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white) // You can set the icon color
                            )
                            .padding(.top, 40)
                    }
                    HStack {
                        Text(userService.user?.firstName ?? "Name")
                        Text(userService.user?.lastName ?? "")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    
                    Text(userService.user?.username ?? "Unknown")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.bottom, 20)
                    
                    // Grid of albums with thumbnail images
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: spacing) {
                        ForEach(albumService.finishedAlbumsWithThumbnails, id: \.uuid) { album in
                            if let thumbnailURL = album.thumbnailURL, let url = URL(string: thumbnailURL) {
                                NavigationLink(destination: AlbumSlideshowView(isTabBarHidden: .constant(false), album: album)) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width / 3, height: 180)
                                        .clipped()
                                        .overlay(
                                            Image(systemName: "play.circle")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                                .opacity(0.8)
                                        )
                                }
                            }
                        }
                        
                    }
                    Spacer()
                }
            }
            .background(Color.white) // Set the background color to white
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editProfileSheet.toggle()
                    }) {
                        Text("Edit")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                        .padding(.top, 15)                       }
                }
            }
            .sheet(isPresented: $editProfileSheet) {
                NavigationView {
                    EditProfileView(editProfileSheet: $editProfileSheet)
                }
            }
            
            
        }
        .onAppear {
            albumService.fetchFinishedAlbums(forUserWithID: userService.uuid ?? "") { [weak albumService] albums in
                albumService?.finishedAlbumsWithThumbnails = albums
                albums.forEach { album in
                    print("Album in onAppear ProfileView: \(album.albumName), thumbnailURL: \(album.thumbnailURL ?? "nil")")
                }
            }
        }
        
    }
}



struct FirebaseProfileImageView: View {
    @ObservedObject  var imageLoader: ImageViewModel
    
    init(imagePath: String) {
        imageLoader = ImageViewModel(imagePath: imagePath)
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            ProgressView()  // or a placeholder image
        }
    }
}

