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
        timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            withAnimation { // Using withAnimation to trigger the transition
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
                    AnyView(Image(uiImage: imagesForSlideshow[currentImageIndex])
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all))
                    //.transition(.move(edge: .trailing)) // Applying opacity transition
                    
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
                                PhotoGridView(selectedDetent: $selectedDetent, posts: album.posts)
                                    .presentationDetents([.medium, .large], selection: $selectedDetent)
                                    .presentationDragIndicator(.hidden)
                                    .presentationBackground(.white
                                    )
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
                                UserGridView(selectedDetent: $selectedDetent, album: album)
                                    .presentationDetents([.medium, .large], selection: $selectedDetent)
                                    .presentationDragIndicator(.hidden)
                                    .presentationBackground(.white
                                    )
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
