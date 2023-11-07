

import SwiftUI
import CoreImage.CIFilterBuiltins
import Kingfisher

struct AlbumInfoView: View {
    @EnvironmentObject var imageModel : ImageViewModel
    @Binding var isTabBarHidden: Bool
    @EnvironmentObject var albumViewModel: AlbumViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var users: [User] = []
    @State private var leaveAlbum: Bool = false

    var album: Album
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    func formattedImagePath(from imagePath: String) -> String {
        let imagePath = "\(imagePath).jpg"
        print(imagePath)
        return imagePath
    }
    
    var body: some View {
        
        ScrollView(.vertical) {
            HStack{
                Spacer()
                NavigationLink(destination: EditAlbumView(isTabBarHidden: $isTabBarHidden, album: album)) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .padding(20)
                }
                

            }
            Spacer()
            VStack {
               
                Text(album.albumName)
                    .foregroundColor(.black)
                Text(dateFormatter.string(from: album.endDate))
                    .foregroundColor(.black)
                QRCodeView(data: album.documentID ?? "")
                
            }
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                ForEach(users, id: \.uuid) { user in
                    VStack {
                        if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.gray)
                                .frame(width: 70, height: 70)
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        }
                        Text(user.username)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                    .padding(5)
                }
            }
            .padding()
            
            Button(action: {
                leaveAlbum = true
            }) {
                Text("Leave album")
                    .font(.system(size: 25))
                    .frame(width: 150)
                    .padding()
                    .background(
                        // Clipped background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    )
                    .foregroundColor(.white)
                    .frame(width: 150)
                    .padding(.bottom, 80)
            }

            
        }
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
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("If you leave the album all your posts will be deleted.")
                            .font(.system(size: 16))
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
                                guard let userUUID = userViewModel.uuid else {return}
                                albumViewModel.leaveAlbum(albumDocumentID: albumdocID)
                                albumViewModel.removeUserPosts(userUUID: userUUID, albumDocumentID: albumdocID)
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
        .background(.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(12)
            
        }
        )
        .onAppear{
            isTabBarHidden = false
            albumViewModel.fetchUsersFromAlbum(album: album, userViewModel: userViewModel) { fetchedUsers in
                users = fetchedUsers // Updating the state with fetched users
            }
        }
    }
        
}

/*

struct AlbumInfoView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy Album instance for preview purposes
        let dummyAlbum = Album(uuid: "dummy", albumName: "dummy", photoLimit: 0, creator: "dummy")
        let isTabBarHidden = Binding<Bool>(get: { true }, set: { _ in })
        // Pass the dummy Album instance to AlbumInfoView
        return AlbumInfoView(isTabBarHidden: isTabBarHidden, album: dummyAlbum)
    }
}
*/
struct QRCodeView: View {
    var data: String
    
    var body: some View {
        Image(uiImage: generateQRCode(from: data))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
    }
}


// CREATES CORNER RADIUS ON SELECTED CORNER

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

