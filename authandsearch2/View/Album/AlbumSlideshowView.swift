//
//  AlbumSlideshowView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-01.
//
import SwiftUI

struct AlbumSlideshowView: View {
    @EnvironmentObject var imageModel: ImageViewModel
    @Binding var isTabBarHidden: Bool
    var album: Album
    @State private var currentImageIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var imagesForSlideshow: [UIImage] = []
    @State private var showPhotoGrid = false
    @State private var playButtonPressed: Bool = false  // New state variable
    
    
    // Function to format the image path
    func formattedImagePath(from imageURL: String) -> String {
        let imagePath = "\(imageURL).jpg"
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
        let imagePaths = album.posts.map { formattedImagePath(from: $0.imageURL) }
        ImageViewModel.preloadImages(paths: imagePaths) { images in
            imagesForSlideshow = images
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    
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
                            PhotoGridView(photos: imagesForSlideshow)
                                .background(Color.white)
                                .frame(width: .infinity, height: geometry.size.height * (2/3))
                            //  .offset(y: geometry.size.height * (1/3))// Experiment with this line
                                .edgesIgnoringSafeArea(.all)
                            
                            
                        }
                        
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    
                    
                    
                }
                .edgesIgnoringSafeArea(.all)
            }
            .edgesIgnoringSafeArea(.all)
            
        }
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
    var photos: [UIImage]  // Your array of UIImages
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                ForEach(0..<photos.count, id: \.self) { index in
                    NavigationLink(destination: ImageDetailView(image: photos[index])) {
                        Image(uiImage: photos[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: (UIScreen.main.bounds.width - (2 * 4)) / 3)
                        //.cornerRadius(2)  // Uncomment this if you want rounded corners on each image
                    }
                }
            }
            .padding(.all, 2)
        }
        
        
        .edgesIgnoringSafeArea(.all)
        .frame(width: .infinity, height: .infinity)
    }
}


// There is a issue here This struct only gets accessed to an Image, it has no way to know the reference of the Image in order to know who (user) posted it
// View for Image fullscreen
struct ImageDetailView: View {
    var image: UIImage
    @EnvironmentObject var post : PostViewModel
    @EnvironmentObject var user : UserViewModel
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
            .frame(width: .infinity, height: .infinity)
            .edgesIgnoringSafeArea(.all)
        
    }
    
}


struct AlbumSlideshowView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAlbum = Album(uuid: "dummy", albumName: "dummy", photoLimit: 0, creator: "dummy")
        let isTabBarHidden = Binding<Bool>(get: { true }, set: { _ in })
        AlbumSlideshowView(isTabBarHidden: isTabBarHidden, album: dummyAlbum)
    }
}
