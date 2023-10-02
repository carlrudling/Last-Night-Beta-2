//
//  AlbumSlideshowView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-01.
//
import SwiftUI
/*
 struct AlbumSlideshowView: View {
 @EnvironmentObject var imageModel : ImageViewModel
 @Binding var isTabBarHidden: Bool
 var album: Album
 @State private var currentImageIndex: Int = 0
 @State private var timer: Timer? = nil
 @State private var imagesForSlideshow : [UIImage] = []
 
 func formattedImagePath(from imageURL: String) -> String {
 let imagePath = "\(imageURL).jpg"
 print(imagePath)
 return imagePath
 }
 
 func startSlideshow() {
 timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
 if currentImageIndex < album.posts.count - 1 {
 currentImageIndex += 1
 } else {
 timer?.invalidate()
 timer = nil
 }
 }
 }
 
 func stopSlideshow() {
 timer?.invalidate()
 timer = nil
 }
 
 var body: some View {
 
 
 ZStack {
 if album.posts.indices.contains(currentImageIndex) {
 FirebaseImageView(imagePath: formattedImagePath(from: album.posts[currentImageIndex].imageURL))
 .edgesIgnoringSafeArea(.all)
 }
 VStack {
 Spacer()
 Button {
 if timer == nil {
 startSlideshow()
 } else {
 stopSlideshow()
 }
 } label: {
 Image(systemName: timer == nil ? "play.circle" : "pause.circle")
 .resizable()
 .scaledToFit()
 .frame(width: 100, height: 100)
 .foregroundColor(.white)
 }
 Spacer()
 
 
 
 }
 }
 .onAppear{
 isTabBarHidden = true
 }
 .onDisappear {
 stopSlideshow()
 }
 }
 }
 */

struct AlbumSlideshowView: View {
    @EnvironmentObject var imageModel: ImageViewModel
    @Binding var isTabBarHidden: Bool
    var album: Album
    @State private var currentImageIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var imagesForSlideshow: [UIImage] = []
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
        }
        .onAppear {
            isTabBarHidden = true
            preloadImages()
        }
        .onDisappear {
            stopSlideshow()
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
