

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



