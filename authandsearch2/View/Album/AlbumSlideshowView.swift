//
//  AlbumSlideshowView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-01.
//
import SwiftUI
import Kingfisher


struct AlbumSlideshowView: View {
    @EnvironmentObject var imageModel: ImageViewModel
    @Binding var isTabBarHidden: Bool
    var album: Album
    @State private var currentImageIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var imagesForSlideshow: [UIImage] = []
    @State private var showPhotoGrid = false
    @State private var showUserGrid = false
    @State private var playButtonPressed: Bool = false  // New state variable
    @State private var isLoading: Bool = true
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isNavigationLinkActive: Bool = false
    @State var selectedDetent: PresentationDetent = .medium
    private let availableDetents: [PresentationDetent] = [.medium, .large]

    
    // Function to format the image path
    func formattedImagePath(from imagePath: String) -> String {
        let imagePath = "\(imagePath).jpg"
        print(imagePath)
        return imagePath
    }
    
    // Function to start the slideshow
    func startSlideshow() {
        playButtonPressed = true  // Set to true when play button is pressed
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if currentImageIndex < imagesForSlideshow.count - 1 {
                currentImageIndex += 1
            } else {
                timer?.invalidate()
                timer = nil
                currentImageIndex = 0
                playButtonPressed = false
                
                
            }
            
        }
        
    }
    
    
    
    // Function to stop the slideshow
    func stopSlideshow() {
        timer?.invalidate()
        timer = nil
        
    }
    
    // Function to preload all images
    func preloadImages() {
        let imagePaths = album.posts.map { formattedImagePath(from: $0.imagePath) }
        ImageViewModel.preloadImages(paths: imagePaths) { images in
            imagesForSlideshow = images
            isLoading = false  // Done loading
        }
    }
    
    var body: some View {
        VStack {
            
            
            ZStack {
                
                // Loading until all Images are fetched
                if isLoading {
                    ProgressView()
                        .scaleEffect(2) // Optional: Increase the size of the loader
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
                }
                
                
                // Black background before slideshow starts
                if !playButtonPressed {
                    Color.black.edgesIgnoringSafeArea(.all)
                }
                
                // Slideshow images
                if playButtonPressed, imagesForSlideshow.indices.contains(currentImageIndex) {
                    Image(uiImage: imagesForSlideshow[currentImageIndex])
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                }
                
                
                VStack {
                    Spacer()
                    
                    // Play button to start slideShow
                    Button {
                        if timer == nil {
                            startSlideshow()
                        } else {
                            stopSlideshow()
                        }
                    } label: {
                        if timer == nil {
                            Image(systemName: "play.circle" )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
                
                // Image Button to see photoGrid
                
                HStack {
                    Spacer()
                    VStack {
                        
                        if timer == nil || currentImageIndex == 0  {
                            
                            Button(action: {
                                showPhotoGrid.toggle()
                            }) {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                            }
                            .sheet(isPresented: $showPhotoGrid) {
                                PhotoGridView(posts: album.posts)
                                    .presentationDetents([.medium, .large], selection: $selectedDetent)
                                    .presentationDragIndicator(.hidden)
                            }
                            
                            
                            Button(action: {
                                showUserGrid.toggle()
                            }) {
                                Image(systemName: "person.2.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                            }
                            .sheet(isPresented: $showUserGrid) {
                                UserGridView(album: album)
                                    .presentationDetents([.medium, .large], selection: $selectedDetent)
                                    .presentationDragIndicator(.hidden)
                            }
                            
                            
                        }
                    }
                }  }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Group {
            if !playButtonPressed {
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                        .padding(12)
                    
                }
            }
        }
        )
        
        .onAppear {
            isTabBarHidden = true
            preloadImages()
        }
        .onDisappear {
            stopSlideshow()
            isTabBarHidden = false
        }
        
    }
    
}

// PhotoGrid, a grid of all the images
struct PhotoGridView: View {
    @EnvironmentObject var post: PostViewModel
    var posts: [Post]
    let spacing: CGFloat = 1  // Change this to the spacing you want
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                    ForEach(posts, id: \.Postuuid) { post in
                        NavigationLink(destination: ImageDetailView(post: post)) {
                            let thumbnailSize = CGSize(width: 300, height: 300)
                            KFImage(URL(string: post.imageURL))
                                .setProcessor(DownsamplingImageProcessor(size: thumbnailSize))
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width - spacing * 2) / 3)
                            
                                .clipped()
                        }
                       
                    }
                
                }
                
                //.padding(.horizontal, 1) // Reduced padding
                
            }
            .frame(maxHeight: .infinity)
            .padding(.top, -7)
        }
    }
}


struct UserGridView: View {
    @EnvironmentObject var albumViewModel: AlbumViewModel
    var album: Album

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                    ForEach(albumViewModel.fetchedUsers, id: \.uuid) { user in
                        VStack {
                            if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                            Text(user.username)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(5)
                    }
                }
                .padding()
            }
            .navigationTitle("User Grid")
        }
        .onAppear {
            albumViewModel.fetchUsers(from: album, userViewModel: UserViewModel())
        }
    }
}








// View for Image fullscreen
struct ImageDetailView: View {
    var post : Post
    @EnvironmentObject var postVM : PostViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var imageModel: ImageViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isSaved : Bool = false
    @State private var bounceAmount: CGFloat = 1.0
    
    
    var body: some View {
        ZStack {
            KFImage(URL(string: post.imageURL))
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(width: .infinity, height: .infinity)
            
            if let fetchedUser = userViewModel.fetchedUser {
                VStack {
                    Spacer()
                    HStack {
                        Group {
                            
                            if let urlString = fetchedUser.profileImageURL, let url = URL(string: urlString) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                
                                
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.gray)
                                    .frame(width: 40, height: 40)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                        .padding(.leading, 25)
                        
                        
                        
                        Text(fetchedUser.username)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            imageModel.requestPhotoLibraryPermission { permissionGranted in
                                if permissionGranted {
                                    if let url = URL(string: post.imageURL) {
                                        KingfisherManager.shared.retrieveImage(with: url) { result in
                                            switch result {
                                            case .success(let value):
                                                imageModel.saveImageToLibrary(image: value.image)
                                                isSaved = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    withAnimation {
                                                        isSaved = false
                                                    }
                                                }
                                            case .failure(let error):
                                                print("Error downloading image: \(error)")
                                                isSaved = false
                                            }
                                        }
                                    }
                                } else {
                                    // This won't display a Text view, but will print in the console.
                                    // You might need a different mechanism to inform the user, like an alert.
                                    print("Without accepting access to your images, you can't save the image")
                                }
                            }
                        }) {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 28))
                                .foregroundColor( isSaved ? .green : .white)
                                .padding(.horizontal, 20)
                        }
                        
                        if  isSaved {
                            Text("Saved")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                                .offset(y: isSaved ? 0 : -20)
                                .opacity(isSaved ? 1.0 : 0.0)
                            
                        }
                    }
                    
                    
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.white)
                .padding(12)
            
        }
        )
        .onAppear {
            userViewModel.fetchUser(by: post.userUuid) { fetchedUser in
                if let user = fetchedUser {
                    print("User fetched: \(user.username)")
                } else {
                    print("Failed to fetch the user.")
                }
            }
        }
        
        .onDisappear {
            print("onDissapear: \(post.imageURL)")
        }
    }
}

struct AlbumSlideshowView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAlbum = Album(uuid: "dummy", albumName: "dummy", photoLimit: 0, creator: "dummy")
        let isTabBarHidden = Binding<Bool>(get: { true }, set: { _ in })
        AlbumSlideshowView(isTabBarHidden: isTabBarHidden, album: dummyAlbum)
    }
}



//Kingfisher = Checkout
// Qgrid could be better to than lasyVgrid
// When creating the load screen and the is finished screen the animation could be synqed with confetti libary?

// SwiftUIX should definetly checkout
