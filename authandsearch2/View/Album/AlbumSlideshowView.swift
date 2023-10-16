//
//  AlbumSlideshowView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-01.
//
import SwiftUI
import Drawer
import Kingfisher


struct AlbumSlideshowView: View {
    @EnvironmentObject var imageModel: ImageViewModel
    @Binding var isTabBarHidden: Bool
    var album: Album
    @State private var currentImageIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var imagesForSlideshow: [UIImage] = []
    @State private var showPhotoGrid = false
    @State private var playButtonPressed: Bool = false  // New state variable
    @State private var isLoading: Bool = true
    @State var heights = [CGFloat(500)]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    
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
                
                // Remove PhotoGrid if tap outside
                if showPhotoGrid {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())  // Important for registering taps
                        .onTapGesture {
                            print("showphotogrid = false")
                            showPhotoGrid = false // Hide the popup when tapped outside
                        }
                }
                
                
                // Image Button to see photoGrid
                
                HStack {
                    Spacer()
                    VStack {
                        if timer == nil || currentImageIndex == 0  {
                            Button {
                                withAnimation {
                                    showPhotoGrid.toggle()
                                }
                            } label: {
                                
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.white)
                                
                                
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                VStack{
                    Spacer()
                    
                    
                    if showPhotoGrid {
                        
                        /*
                         PhotoGridView(photos: imagesForSlideshow)
                         .background(Color.white)
                         .frame(width: .infinity, height: geometry.size.height * (2/3))
                         //  .offset(y: geometry.size.height * (1/3))// Experiment with this line
                         .edgesIgnoringSafeArea(.all)
                         
                         */
                        
                        Drawer(heights: $heights) {
                            ZStack{
                                Color(UIColor.white)
                                
                                VStack {
                                    ZStack{
                                        Color(UIColor.white)
                                        
                                        HStack{
                                            Spacer()
                                            Image(systemName: "plus")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28, height: 28)
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 10)
                                                .padding(.top, 3)
                                                .roundedCorner(20, corners: [.topLeft, .topRight])
                                            
                                        }
                                    }
                                    .frame(width: .infinity, height: 40)
                                    .roundedCorner(20, corners: [.topLeft, .topRight])


                                    
                                    
                                    Spacer()
                                    
                                    PhotoGridView(posts: album.posts)
                                        .edgesIgnoringSafeArea(.all)

                                    
                                }
                                .edgesIgnoringSafeArea(.all)

                            }
                            .edgesIgnoringSafeArea(.all)
                            .roundedCorner(20, corners: [.topLeft, .topRight])

                            
                        }.edgesIgnoringSafeArea(.vertical)
                            .roundedCorner(20, corners: [.topLeft, .topRight])

                    }
                    
                }
                
                
                
                
                
            }
            
            
            
            
        }
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
        .edgesIgnoringSafeArea(.all)
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
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                ForEach(posts, id: \.Postuuid) { post in
                    //  if let url = URL(string: post.imageURL) {
                    //      let processor = ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300))
                    NavigationLink(destination: ImageDetailView(post: post)) {
                        KFImage(URL(string: post.imageURL))
                        //     .setProcessor(processor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (UIScreen.main.bounds.width - (2 * 4)) / 3)
                        //.cornerRadius(2)  // Uncomment this if you want rounded corners on each image
                    }
                    //}
                }
            }
            .padding(.all, 2)
        }
        .edgesIgnoringSafeArea(.all)
        .padding(.top, -7)

    }
}






// There is a issue here This struct only gets accessed to an Image, it has no way to know the reference of the Image in order to know who (user) posted it
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

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

// CHeck if I can actually swipe back when navigating? Because the extensions doesn't seem to be here. Find in createAlbumView
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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
//Drawer = for grid
// Qgrid could be better to than lasyVgrid
// When creating the load screen and the is finished screen the animation could be synqed with confetti libary?

// SwiftUIX should definetly checkout
