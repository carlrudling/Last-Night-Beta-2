import SwiftUI
import CoreImage.CIFilterBuiltins
import Kingfisher
import Combine

struct AlbumInfoView: View {
    @EnvironmentObject var imageModel: ImageViewModel
    @Binding var isTabBarHidden: Bool
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var userService: UserService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var users: [User] = []
    @State private var leaveAlbum: Bool = false
    @State private var editAlbumSheeet = false
    @State private var countdownText: String = "" // State variable for countdown text
    @State private var timer: AnyCancellable?

    var album: Album
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Function to start the countdown timer
        private func startCountdownTimer() {
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
                self.updateCountdown()
            }
        }

        // Function to stop the countdown timer
        private func stopCountdownTimer() {
            timer?.cancel()
            timer = nil
        }
    
    func formattedImagePath(from imagePath: String) -> String {
        let imagePath = "\(imagePath).jpg"
        print(imagePath)
        return imagePath
    }
    
    private func truncatedUsername(_ username: String) -> String {
        let maxLength = 8
        if username.count > maxLength {
            let index = username.index(username.startIndex, offsetBy: maxLength)
            return String(username[..<index]) + ".."
        }
        return username
    }
    
    
    // Function to update countdown
        private func updateCountdown() {
            let currentDate = Date()
            let endDate = album.endDate

            if currentDate < endDate {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: endDate)

                let days = components.day ?? 0
                let hours = components.hour ?? 0
                let minutes = components.minute ?? 0
                let seconds = components.second ?? 0

                countdownText = "Time remaining: \(days)d \(hours)h \(minutes)m \(seconds)s"
            } else {
                countdownText = "Album has ended"
            }
        }
    
    
    var body: some View {
        ZStack{
            /*
             VStack{
             HStack{
             Spacer()
             NavigationLink(
             destination: MessagesView(albumID: album.documentID ?? "", albumName: album.albumName, users: users) )  {
             Image(systemName: "message")
             .resizable()
             .scaledToFill()
             .foregroundColor(.black)
             .frame(width: 30, height: 30)
             }
             }
             Spacer()
             }
             .padding(.top, 20)
             .padding(.trailing, 18)
             .zIndex(2.0)
             */
            ScrollView(.vertical) {
                VStack {
                    
                    Text(album.albumName)
                        .foregroundColor(.black)
                        .font(Font.custom("Chillax-Medium", size: 30))
                        .padding(.bottom, 10)
                    Text(countdownText)
                        .font(Font.custom("Chillax-Regular", size: 12))
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                    Text("Scan to join!")
                        .font(Font.custom("Chillax-Regular", size: 14))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    ZStack{
                        openEndedShapeView(height: 85, width: 85)
                        QRCodeView(data: album.documentID ?? "")
                    }
                    
                    Spacer()
    
                    ZStack{
                        HStack{
                            Spacer()
                          
                                VStack{
                                    NavigationLink(destination:  CameraView(albumuuid: self.userService.uuid!), label: {
                                        Image(systemName: "camera")
                                            .font(.system(size: 25))
                                            .foregroundColor(.black)

                                })
                                    .padding(.horizontal, 12)
                                    .padding(.top, -280)


                            Button {
                                leaveAlbum = true
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 25))
                                    .foregroundColor(.black)
                                    .padding(.bottom, -5)
                                    .padding(.horizontal, 5)
                                
                            }
                            }
                            
                        }
                        VStack{
                            
                            Text("In the album")
                                .foregroundColor(.black)
                                .font(Font.custom("Chillax-Regular", size: 14))
                        
                        // Thin line
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black)
                            .padding(.vertical, 2)
                    }
                        .padding(.top, 20)
                        .padding(.bottom, -20)
                    }
                   
                }
               
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 1) {
                    ForEach(users, id: \.uuid) { user in
                        VStack {
                            if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            } else {
                                ZStack{
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 60, height: 60)
                                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                }
                            }
                            Text(truncatedUsername(user.username))
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .padding(5)
                    }
                }
                .padding()
                
            }
            .padding(.top, 20)
        
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
        .popup(isPresented: $leaveAlbum) {
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
                        
                        Text("Sure you want to leave?")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("If you leave the album all your posts will be deleted.")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.top, 5)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        HStack(spacing: 0) {
                            Button {
                                leaveAlbum = false
                            } label: {
                                Text("No")
                                    .font(.system(size: 20))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                    )
                                    .foregroundColor(.black)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 10)
                            }
                            
                            Button {
                                guard let albumdocID = album.documentID else {return}
                                guard let userUUID = userService.uuid else {return}
                                albumService.leaveAlbum(albumDocumentID: albumdocID)
                                albumService.removeUserPosts(userUUID: userUUID, albumDocumentID: albumdocID)
                                // NAVIGATE TO HOME SCREEN, Pop the stack?
                                
                            } label: {
                                Text("Yes")
                                    .font(.system(size: 20))
                                    .frame(width: 80)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red)
                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
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
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                )
                
            }
            .frame(width: 300, height: 300, alignment: .center)
            //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
            .background(.clear)
            
        }
        .sheet(isPresented: $editAlbumSheeet) {
            NavigationView {
                EditAlbumView(editAlbumSheeet: $editAlbumSheeet, isTabBarHidden: $isTabBarHidden, album: album)
            }
        }
        .onAppear{
            isTabBarHidden = false
            albumService.fetchUsersFromAlbum(album: album, userService: userService) { fetchedUsers in
                users = fetchedUsers // Updating the state with fetched users
            }
            updateCountdown() // Update countdown on appear
                       let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                       _ = self.onReceive(timer) { _ in
                           self.updateCountdown()
                       }
            startCountdownTimer() // Start countdown on appear

        }
        .onDisappear{
            stopCountdownTimer() // Stop countdown on disappear
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.black)
                        .padding(12)
                }
            }
            if album.creator == userService.uuid {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editAlbumSheeet.toggle()
                    } label: {
                        Text("Edit")
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .foregroundColor(.black)
                            .padding(.top, 15)
                    }
                    
                }
            }
        }
    }
}

struct openEndedShapeView: View {
    @State var height: CGFloat
    @State var width: CGFloat
    
    
    var body: some View {
        HStack{
            VStack{
                RoundedRectangle(cornerRadius: 40)
                    .trim(from: 3/4, to: 1)
                    .stroke(.black, lineWidth: 2)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(270))
                
                RoundedRectangle(cornerRadius: 40)
                    .trim(from: 3/4, to: 1)
                    .stroke(.black, lineWidth: 2)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(180))
                
            }
            VStack {
                
                RoundedRectangle(cornerRadius: 40)
                    .trim(from: 3/4, to: 1)
                    .stroke(.black, lineWidth: 2)
                    .frame(width: width, height: height)
                
                RoundedRectangle(cornerRadius: 40)
                    .trim(from: 3/4, to: 1)
                    .stroke(.black, lineWidth: 2)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(90))
                
            }
        }
    }
}
