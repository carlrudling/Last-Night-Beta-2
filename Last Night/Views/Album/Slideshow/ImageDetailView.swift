import SwiftUI
import Kingfisher

struct ImageDetailView: View {
    var post : Post
    @EnvironmentObject var postService: PostService
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var imageModel: ImageViewModel
    @EnvironmentObject var albumService: AlbumService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isSaved : Bool = false
    @State private var bounceAmount: CGFloat = 1.0
    @State var showingErrorPopup = false
    @State var setAlbumPlaceholder = false
    @State var reportPost = false
    @State var removeReport = false
    @State var reportPostFail = false

   
    var album: Album
    
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
                                ZStack{
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 40, height: 40)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                }
                               
                            }
                        }
                        .padding(.leading, 25)
                        
                        
                        
                        Text(fetchedUser.username)
                            .font(Font.custom("Chillax-Regular", size: 16))
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
                            albumService.updateAlbumThumbnail(albumUUID: album.documentID ?? "", thumbnailURL: post.imageURL) { success in
                                if success {
                                    // Handle successful update, e.g., show confirmation to user
                                    setAlbumPlaceholder.toggle()
                                } else {
                                    // Handle error
                                }
                            }
                        }) {
                            ZStack{
                                Image(systemName: "star")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                   
                                
                                Image(systemName: setAlbumPlaceholder ? "star.fill" : "")
                                    .font(.system(size: 17))
                                    .foregroundColor(.yellow)
                                   
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        
                        Button(action: {
                            if postService.hasUserReportedPost(userUUID: userService.uuid ?? "", post: post) {
                                removeReport.toggle()
                                print("You have already reported this post.")
                            } else {
                                reportPost.toggle()
                                print("You have not reported this post.")
                                
                            }}) {
                            Image(systemName:"exclamationmark.triangle")
                                .font(.system(size: 24))
                                .foregroundColor( .white)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                        
                    


                        
                        
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
                                .font(.system(size: 24))
                                .foregroundColor( isSaved ? .green : .white)
                                .padding(.horizontal, 20)
                        }
                        
                        if  isSaved {
                            Text("Saved")
                                .font(Font.custom("Chillax-Regular", size: 12))
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
                                .foregroundColor(.white)
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
                            .font(Font.custom("Chillax-Medium", size: 18))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("To save images you need to allow access to images in settings.")
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .foregroundColor(.white)
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
                            .fill(
                                LinearGradient(stops: [
                                    .init(color: .lightPurple, location: 0.001),
                                    .init(color: .darkPurple, location: 0.99)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                
                )
            }
            .frame(width: 300, height: 300, alignment: .center)
            //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
            .background(.clear)
           
    
   
    }
        
        .popup(isPresented: $reportPost) {
            VStack{
                ZStack { // 4
                    
                    VStack{
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        ZStack{
                            Image(systemName: "exclamationmark.triangle") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                                .zIndex(1) // Ensure it's above the background
                            Image(systemName: "exclamationmark.triangle.fill") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                                .zIndex(1) // Ensure it's above the background
                        }
                        
                        Text("Want to report this post?")
                            .font(Font.custom("Chillax-Medium", size: 18))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("After 3 users have made a report the post will be deleted.")
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        HStack(spacing: 0) {
                            Button {
                                reportPost = false
                            } label: {
                                Text("No")
                                    .font(Font.custom("Chillax-Regular", size: 18))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                            //.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    )
                                    .foregroundColor(.black)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 10)
                            }
                            
                            Button {
                               //REPORT POST
                                postService.reportPost(userUUID: userService.uuid ?? "", post: post, albumDocumentID: album.documentID ?? "") { success in
                                       if success {
                                           reportPost = false
                                           print("Report successful")
                                       } else {
                                           reportPost = false
                                           Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                               reportPostFail = true
                                               
                                           }
                                           print("Report failed or already reported by this user")
                                       }
                                   }
                                
                            } label: {
                                Text("Yes")
                                    .font(Font.custom("Chillax-Regular", size: 18))
                                    .frame(width: 80)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    )
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                
                            }
                            
                        }
                        
                    }
                    .padding(.top, -40) // Make space for the checkmark at the top
                    
                }
                .frame(width: 300, height: 240, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
                
                .background(
                    // Clipped background
                    RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(stops: [
                                    .init(color: .lightPurple, location: 0.001),
                                    .init(color: .darkPurple, location: 0.99)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
)
            }
            .frame(width: 300, height: 300, alignment: .center)
            //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
            .background(.clear)
            
        }
        
        .popup(isPresented: $removeReport) {
            VStack{
                ZStack { // 4
                    
                    VStack{
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        ZStack{
                            Image(systemName: "exclamationmark.triangle") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                                .zIndex(1) // Ensure it's above the background
                            Image(systemName: "exclamationmark.triangle.fill") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                                .zIndex(1) // Ensure it's above the background
                        }
                        
                        Text("Want to remove report?")
                            .font(Font.custom("Chillax-Medium", size: 18))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("If you press yes your report will be removed, remember reports are anonymous.")
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        HStack(spacing: 0) {
                            Button {
                                removeReport = false
                            } label: {
                                Text("No")
                                    .font(Font.custom("Chillax-Regular", size: 18))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                            //.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    )
                                    .foregroundColor(.black)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 10)
                            }
                            
                            Button {
                               //REPORT POST
                                postService.removeReport(userUUID: userService.uuid ?? "", post: post, albumDocumentID: album.documentID ?? "") { success in
                                    if success {
                                        removeReport = false
                                        print("Report successful")
                                    } else {
                                        removeReport = false
                                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                            reportPostFail = true
                                            
                                        }
                                        print("Report failed or already reported by this user")
                                    }
                                }
                            } label: {
                                Text("Yes")
                                    .font(Font.custom("Chillax-Regular", size: 18))
                                    .frame(width: 80)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    )
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                
                            }
                            
                        }
                        
                    }
                    .padding(.top, -40) // Make space for the checkmark at the top
                    
                }
                .frame(width: 300, height: 240, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
                
                .background(
                    // Clipped background
                    RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(stops: [
                                    .init(color: .lightPurple, location: 0.001),
                                    .init(color: .darkPurple, location: 0.99)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
)
            }
            .frame(width: 300, height: 300, alignment: .center)
            //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
            .background(.clear)
            
        }
        
        
        .popup(isPresented: $reportPostFail) {
            VStack{
                ZStack { // 4
                    
                    VStack{
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        ZStack{
                            Image(systemName: "multiply.circle") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                                .zIndex(1) // Ensure it's above the background
                            Image(systemName: "multiply.circle.fill") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                            
                                .zIndex(1) // Ensure it's above the background
                            
                        }
                        
                        Text("Something went wrong")
                            .font(Font.custom("Chillax-Medium", size: 18))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("Your request couldn't be sent, please try again later.")
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .foregroundColor(.white)
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
                            .fill(
                                LinearGradient(stops: [
                                    .init(color: .lightPurple, location: 0.001),
                                    .init(color: .darkPurple, location: 0.99)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
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
