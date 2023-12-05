import SwiftUI
import Kingfisher

struct ImageDetailView: View {
    var post : Post
    @EnvironmentObject var postService: PostService
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var imageModel: ImageViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isSaved : Bool = false
    @State private var bounceAmount: CGFloat = 1.0
    @State var showingErrorPopup = false
   
    
    var body: some View {
        ZStack {
            KFImage(URL(string: post.imageURL))
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(width: .infinity, height: .infinity)
            
            if let fetchedUser = userService.fetchedUser {
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
                                    showingErrorPopup = true
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
        .popup(isPresented: $showingErrorPopup) {
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
                            Image(systemName: "exclamationmark.circle") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                                .zIndex(1) // Ensure it's above the background
                            Image(systemName: "exclamationmark.circle.fill") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                            
                                .zIndex(1) // Ensure it's above the background
                            
                        }
                        
                        Text("Permissions not granted")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("To save images you need to allow access to images in settings.")
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
        
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.white)
                .padding(12)
            
        }
        )
        .onAppear {
            userService.fetchUser(by: post.userUuid) { fetchedUser in
                if let user = fetchedUser {
                    print("User fetched: \(user.username)")
                } else {
                    print("Failed to fetch the user.")
                }
            }
          //  selectedDetent = .large
        }
        
        .onDisappear {
            print("onDissapear: \(post.imageURL)")
           // selectedDetent = .medium
        }
    }
}
