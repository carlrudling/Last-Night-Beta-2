import SwiftUI
import Kingfisher

struct ProfileView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumService: AlbumService
    @State var editProfileSheet = false
    
    let spacing = 40.0

    private func refreshProfileData() {
            userService.refreshUserData()
        }
    
    var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter
        }
    
    
    var body: some View {
        NavigationView{
       
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
                    .font(Font.custom("Chillax-Regular", size: 16))
                    .foregroundColor(.black)
                    
                    Text(userService.user?.username ?? "Unknown")
                        .font(Font.custom("Chillax-Regular", size: 12))
                        .foregroundColor(.black)
                        .padding(.bottom, 20)
                    
                    Text("Memories")
                        .font(Font.custom("Chillax-Regular", size: 16))
                        .foregroundColor(.black)
                        .padding(.bottom, 20)
                    
                    Rectangle()
                        .frame(width: 200, height: 1) // Width of 200 points and height of 1 point
                        .foregroundColor(.black) // Set the color of the line
                    
                    
                    let cardWidth: CGFloat = 240
                    let horizontalPadding = (UIScreen.main.bounds.width - cardWidth) / 2
                    // Horizontal scroll view of albums with thumbnail images
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: spacing) {
                            ForEach(albumService.finishedAlbumsWithThumbnails, id: \.uuid) { album in
                                if let thumbnailURL = album.thumbnailURL, let url = URL(string: thumbnailURL) {
                                    NavigationLink(destination: AlbumSlideshowView(isTabBarHidden: .constant(false), album: album)) {
                                        
                                        ZStack{
                                            Rectangle()
                                                .fill(.white)
                                                .frame(width: cardWidth, height: 320 )
                                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                                                .cornerRadius(2)
                                            VStack{
                                                Text("\(dateFormatter.string(from: album.creationDate)) - \(dateFormatter.string(from: album.endDate))")
                                                    .font(Font.custom("Chillax-Regular", size: 14))
                                                    .foregroundColor(.black)
                                                    .offset(y: 10)
                                                    
                                                   
                                                    
                                                KFImage(url)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: UIScreen.main.bounds.width / 3 + 80, height: 230) // Adjust the width as needed
                                                    .clipped()
                                                   
                                                    .padding(.bottom, -20)
                                    
                                                
                                                Text("\(album.albumName)")
                                                    .font(Font.custom("Barrbar", size: 35))
                                                    .foregroundColor(.black)
                                                  
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, horizontalPadding) // Apply dynamic padding here
                    }
                    Spacer()
                }
                .background(
                    ZStack{
                        Color.backgroundWhite.edgesIgnoringSafeArea(.all)

                        BackgroundView()
                            .frame(width: 600, height: 1500)
                            .rotationEffect(.degrees(-50))
                            .offset(y: 300)
                    }
                )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editProfileSheet.toggle()
                    }) {
                        Text("Edit")
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .foregroundColor(.black)
                        .padding(.top, 15)                       }
                }
            }
            .sheet(isPresented: $editProfileSheet, onDismiss: refreshProfileData) {
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
            userService.refreshUserData()
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

