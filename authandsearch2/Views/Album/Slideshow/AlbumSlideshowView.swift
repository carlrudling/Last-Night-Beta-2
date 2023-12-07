import SwiftUI
import Kingfisher


struct AlbumSlideshowView: View {
    @EnvironmentObject var imageModel: ImageViewModel
    @EnvironmentObject var slideShowViewModel: SlideShowViewModel
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumService: AlbumService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var isTabBarHidden: Bool
    private let availableDetents: [PresentationDetent] = [.medium, .large]
    var album: Album
    @State private var users: [User] = []
    
    
    // Function to start the slideshow
    func startSlideshow() {
        slideShowViewModel.playButtonPressed = true  // Set to true when play button is pressed
        slideShowViewModel.timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            withAnimation { // Using withAnimation to trigger the transition
                if slideShowViewModel.currentImageIndex < slideShowViewModel.imagesForSlideshow.count - 1 {
                    slideShowViewModel.currentImageIndex += 1
                } else {
                    slideShowViewModel.timer?.invalidate()
                    slideShowViewModel.timer = nil
                    slideShowViewModel.currentImageIndex = 0
                    slideShowViewModel.playButtonPressed = false
                }
            }
            
        }
    }
    
    
    //Fetch Users
    private func fetchUsers() {
        albumService.fetchUsersFromAlbum(album: album, userService: userService) { fetchedUsers in
            users = fetchedUsers
        }
    }
    
    // Function to stop the slideshow
    func stopSlideshow() {
        slideShowViewModel.timer?.invalidate()
        slideShowViewModel.timer = nil
        
    }
    
    // Function to preload all images
    func preloadImages() {
        // Sort the posts by upload time
        let sortedPosts = album.posts.sorted { $0.uploadTime < $1.uploadTime }
        
        // Then map them to image paths
        let imagePaths = sortedPosts.map { slideShowViewModel.formattedImagePath(from: $0.imagePath) }
        
        // Continue with image preloading as before
        ImageViewModel.preloadImages(paths: imagePaths) { images in
            slideShowViewModel.imagesForSlideshow = images
            slideShowViewModel.isLoading = false  // Done loading
        }
    }
    
    var body: some View {
        VStack {
            
            
            ZStack {
                
                // Loading until all Images are fetched
                if slideShowViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2) // Optional: Increase the size of the loader
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
                }
                
                //--
                // Black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Carousel view when play button is pressed
                if slideShowViewModel.playButtonPressed {
                CarouselView(currentImageIndex: $slideShowViewModel.currentImageIndex,
                images: slideShowViewModel.imagesForSlideshow)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
                } else {
                // Play button
                Button(action: startSlideshow) {
                Image(systemName: "play.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                
                // Play button and other controls
                    /*
                    VStack {
                        Spacer()
                        
                        // Play button to start/stop slideshow
                        Button(action: {
                            if slideShowViewModel.timer == nil {
                                startSlideshow()
                            } else {
                                stopSlideshow()
                            }
                        }) {
                            Image(systemName: slideShowViewModel.timer == nil ? "play.circle" : "pause.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.white)
                        }
                    }
                     */
                //--
                // Black background before slideshow starts
                    /*
                if !slideShowViewModel.playButtonPressed {
                    Color.black.edgesIgnoringSafeArea(.all)
                }
               
                // Slideshow images
                if slideShowViewModel.playButtonPressed, slideShowViewModel.imagesForSlideshow.indices.contains(slideShowViewModel.currentImageIndex) {
                    AnyView(Image(uiImage: slideShowViewModel.imagesForSlideshow[slideShowViewModel.currentImageIndex])
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all))
                    //.transition(.move(edge: .trailing)) // Applying opacity transition
                    
                }
                     
                
                
                VStack {
                    Spacer()
                    
                    // Play button to start slideShow
                    Button {
                        if slideShowViewModel.timer == nil {
                            startSlideshow()
                        } else {
                            stopSlideshow()
                        }
                    } label: {
                        if slideShowViewModel.timer == nil {
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
                    */
                    
                    
                // Image Button to see photoGrid
                
                HStack {
                    Spacer()
                    VStack {
                        
                        if slideShowViewModel.timer == nil || slideShowViewModel.currentImageIndex == 0  {
                            
                            
                            Button {
                                slideShowViewModel.isAnimating = true
                                let watermarkImage = UIImage(named: "watermark")!
                                slideShowViewModel.createAndWatermarkVideo(images: slideShowViewModel.imagesForSlideshow, watermarkImage: watermarkImage) { result in
                                    DispatchQueue.main.async {
                                        slideShowViewModel.isAnimating = false
                                        
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.down.to.line")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(slideShowViewModel.successMessage ? .green :
                                                        slideShowViewModel.errorMessage ? .red : .white)
                                    .padding(.vertical)
                                    .scaleEffect(slideShowViewModel.isAnimating ? 1.1 : 1.0)
                                    .opacity(slideShowViewModel.isAnimating ? 0.3 : 1.0)
                                    .animation(slideShowViewModel.isAnimating ? Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: slideShowViewModel.isAnimating)
                                
                            }
                            if slideShowViewModel.successMessage {
                                Text("Saved")
                                    .foregroundColor(.green)
                                    .font(.system(size: 12))
                                    .offset(y: slideShowViewModel.successMessage ? -15 : -30)
                                    .opacity(slideShowViewModel.successMessage ? 1.0 : 0.0)
                                //.animation(.easeOut(duration: 0.5), value: slideShowViewModel.successMessage)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation{
                                                slideShowViewModel.successMessage = false
                                            }
                                        }
                                    }
                            }
                            if slideShowViewModel.errorMessage {
                                Text("Try again")
                                    .foregroundColor(.red)
                                    .font(.system(size: 12))
                                    .offset(y: slideShowViewModel.errorMessage ? -15 : -30)
                                    .opacity(slideShowViewModel.errorMessage ? 1.0 : 0.0)
                                //.animation(.easeOut(duration: 0.5), value: slideShowViewModel.errorMessage)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation{
                                                slideShowViewModel.errorMessage = false
                                            }
                                        }
                                    }
                            }
                            NavigationLink(
                                destination: MessagesView(albumID: album.documentID ?? "", albumName: album.albumName, users: users) )  {
                                    Image(systemName: "message")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)
                                }
                            
                            
                            Button(action: {
                                slideShowViewModel.showPhotoGrid.toggle()
                            }) {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                            }
                            .sheet(isPresented: $slideShowViewModel.showPhotoGrid) {
                                PhotoGridView(selectedDetent: $slideShowViewModel.selectedDetent, posts: album.posts)
                                    .presentationDetents([.medium, .large], selection: $slideShowViewModel.selectedDetent)
                                    .presentationDragIndicator(.hidden)
                                    .presentationBackground(.white
                                    )
                            }
                            
                            
                            Button(action: {
                                slideShowViewModel.showUserGrid.toggle()
                            }) {
                                Image(systemName: "person.2.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                            }
                            .sheet(isPresented: $slideShowViewModel.showUserGrid) {
                                UserGridView(selectedDetent: $slideShowViewModel.selectedDetent, album: album, users: users)
                                    .presentationDetents([.medium, .large], selection: $slideShowViewModel.selectedDetent)
                                    .presentationDragIndicator(.hidden)
                                    .presentationBackground(.white
                                    )
                            }
                            
                        }
                        }
                    }
                }  }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Group {
            if !slideShowViewModel.playButtonPressed {
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                        .padding(12)
                    
                }
            }
        }
        )
        .popup(isPresented: $slideShowViewModel.slideShowCreatePopUp) {
            VStack{
                ZStack { // 4
                    
                    VStack{
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        ZStack{
                            Image(systemName: "play.circle") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                                .zIndex(1) // Ensure it's above the background
                            Image(systemName: "play.circle.fill") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.purple)
                            
                                .zIndex(1) // Ensure it's above the background
                            
                        }
                        
                        Text("New Slideshow Created")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("New slideshow has been created with selected images.")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                    }
                    .padding(.top, -40) // Make space for the checkmark at the top
                    
                }
                .frame(width: 300, height: 200, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
                
                .background(
                    // Clipped background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                )
                
                
            }
            .frame(width: 300, height: 300, alignment: .center)
            //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
            .background(.clear)
            
            
            
        }
        
        .onAppear {
            isTabBarHidden = true
            slideShowViewModel.posts = album.posts  // Update posts in the ViewModel
            slideShowViewModel.isAnimating = false
            preloadImages()
            fetchUsers()
            
        }
        .onDisappear {
            stopSlideshow()
            isTabBarHidden = false
        }
        
    }
    
}






//Kingfisher = Checkout
// Qgrid could be better to than lasyVgrid
// When creating the load screen and the is finished screen the animation could be synqed with confetti libary?

// SwiftUIX should definetly checkout

/*
 var body: some View {
 ZStack {
 // Black background
 Color.black.edgesIgnoringSafeArea(.all)
 
 // Carousel view when play button is pressed
 if slideShowViewModel.playButtonPressed {
 CarouselView(currentImageIndex: $slideShowViewModel.currentImageIndex,
 images: slideShowViewModel.imagesForSlideshow)
 .edgesIgnoringSafeArea(.all)
 .transition(.opacity)
 } else {
 // Play button
 Button(action: startSlideshow) {
 Image(systemName: "play.circle")
 .resizable()
 .scaledToFit()
 .frame(width: 100, height: 100)
 .foregroundColor(.white)
 }
 .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
 
 // Play button and other controls
 VStack {
 Spacer()
 
 // Play button to start/stop slideshow
 Button(action: {
 if slideShowViewModel.timer == nil {
 startSlideshow()
 } else {
 stopSlideshow()
 }
 }) {
 Image(systemName: slideShowViewModel.timer == nil ? "play.circle" : "pause.circle")
 .resizable()
 .scaledToFit()
 .frame(width: 100, height: 100)
 .foregroundColor(.white)
 }
 Spacer()
 }
 // Other buttons like photoGrid, userGrid, etc.
 HStack {
 Spacer()
 VStack {
 Spacer()
 if slideShowViewModel.timer == nil || slideShowViewModel.currentImageIndex == 0  {
 
 
 Button {
 slideShowViewModel.isAnimating = true
 let watermarkImage = UIImage(named: "watermark")!
 slideShowViewModel.createAndWatermarkVideo(images: slideShowViewModel.imagesForSlideshow, watermarkImage: watermarkImage) { result in
 DispatchQueue.main.async {
 slideShowViewModel.isAnimating = false
 
 }
 }
 } label: {
 Image(systemName: "arrow.down.to.line")
 .resizable()
 .scaledToFit()
 .frame(height: 30)
 .foregroundColor(slideShowViewModel.successMessage ? .green :
 slideShowViewModel.errorMessage ? .red : .white)
 .padding(.vertical)
 .scaleEffect(slideShowViewModel.isAnimating ? 1.1 : 1.0)
 .opacity(slideShowViewModel.isAnimating ? 0.3 : 1.0)
 .animation(slideShowViewModel.isAnimating ? Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: slideShowViewModel.isAnimating)
 
 }
 if slideShowViewModel.successMessage {
 Text("Saved")
 .foregroundColor(.green)
 .font(.system(size: 12))
 .offset(y: slideShowViewModel.successMessage ? -15 : -30)
 .opacity(slideShowViewModel.successMessage ? 1.0 : 0.0)
 //.animation(.easeOut(duration: 0.5), value: slideShowViewModel.successMessage)
 .onAppear {
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
 withAnimation{
 slideShowViewModel.successMessage = false
 }
 }
 }
 }
 if slideShowViewModel.errorMessage {
 Text("Try again")
 .foregroundColor(.red)
 .font(.system(size: 12))
 .offset(y: slideShowViewModel.errorMessage ? -15 : -30)
 .opacity(slideShowViewModel.errorMessage ? 1.0 : 0.0)
 //.animation(.easeOut(duration: 0.5), value: slideShowViewModel.errorMessage)
 .onAppear {
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
 withAnimation{
 slideShowViewModel.errorMessage = false
 }
 }
 }
 }
 
 
 
 Button(action: {
 slideShowViewModel.showPhotoGrid.toggle()
 }) {
 Image(systemName: "photo")
 .resizable()
 .scaledToFit()
 .frame(height: 30)
 .foregroundColor(.white)
 .padding(.vertical)
 }
 .sheet(isPresented: $slideShowViewModel.showPhotoGrid) {
 PhotoGridView(selectedDetent: $slideShowViewModel.selectedDetent, posts: album.posts)
 .presentationDetents([.medium, .large], selection: $slideShowViewModel.selectedDetent)
 .presentationDragIndicator(.hidden)
 .presentationBackground(.white
 )
 }
 
 
 Button(action: {
 slideShowViewModel.showUserGrid.toggle()
 }) {
 Image(systemName: "person.2.fill")
 .resizable()
 .scaledToFit()
 .frame(height: 30)
 .foregroundColor(.white)
 .padding(.vertical)
 }
 .sheet(isPresented: $slideShowViewModel.showUserGrid) {
 UserGridView(selectedDetent: $slideShowViewModel.selectedDetent, album: album)
 .presentationDetents([.medium, .large], selection: $slideShowViewModel.selectedDetent)
 .presentationDragIndicator(.hidden)
 .presentationBackground(.white
 )
 }
 
 
 }
 Spacer()
 }
 }
 }
 
 }
 .edgesIgnoringSafeArea(.all)
 .navigationBarBackButtonHidden(true)
 .navigationBarItems(leading:
 Group {
 if !slideShowViewModel.playButtonPressed {
 Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
 Image(systemName: "chevron.backward")
 .foregroundColor(.white)
 .padding(12)
 
 
 }
 }
 }
 )
 .popup(isPresented: $slideShowViewModel.slideShowCreatePopUp) {
 VStack{
 ZStack { // 4
 
 VStack{
 HStack{
 Spacer()
 Image(systemName: "xmark")
 .font(.system(size: 18))
 .foregroundColor(.black)
 .padding(10)
 }
 Spacer()
 }
 
 VStack {
 ZStack{
 Image(systemName: "play.circle") // SF Symbol for checkmark
 .font(.system(size: 80))
 .foregroundColor(.white)
 
 .zIndex(1) // Ensure it's above the background
 Image(systemName: "play.circle.fill") // SF Symbol for checkmark
 .font(.system(size: 80))
 .foregroundColor(.purple)
 
 .zIndex(1) // Ensure it's above the background
 
 }
 
 Text("New Slideshow Created")
 .font(.system(size: 22))
 .foregroundColor(.black)
 .bold()
 .padding(.bottom, 5)
 .padding(.top, 2)
 
 Text("New slideshow has been created with selected images.")
 .font(.system(size: 16))
 .foregroundColor(.black)
 .padding(.top, 10)
 .padding(.horizontal, 20)
 .multilineTextAlignment(.center)
 
 Spacer()
 
 }
 .padding(.top, -40) // Make space for the checkmark at the top
 
 }
 .frame(width: 300, height: 200, alignment: .center)
 //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
 
 .background(
 // Clipped background
 RoundedRectangle(cornerRadius: 20)
 .fill(Color.white)
 .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
 )
 
 
 }
 .frame(width: 300, height: 300, alignment: .center)
 //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
 .background(.clear)
 
 
 
 }
 
 .onAppear {
 isTabBarHidden = true
 slideShowViewModel.posts = album.posts  // Update posts in the ViewModel
 slideShowViewModel.isAnimating = false
 preloadImages()
 
 }
 .onDisappear {
 stopSlideshow()
 isTabBarHidden = false
 }
 
 }
 
 
 
 */
