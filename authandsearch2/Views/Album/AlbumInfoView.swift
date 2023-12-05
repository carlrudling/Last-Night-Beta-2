

import SwiftUI
import CoreImage.CIFilterBuiltins
import Kingfisher

struct AlbumInfoView: View {
    @EnvironmentObject var imageModel : ImageViewModel
    @Binding var isTabBarHidden: Bool
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var userService: UserService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var users: [User] = []
    @State private var leaveAlbum: Bool = false
    @State private var editAlbumSheeet = false
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
            VStack {
                
                Text(album.albumName)
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                Text("Ending: \(dateFormatter.string(from: album.endDate))")
                    .foregroundColor(.black)
                    .font(.system(size: 12))
                Text("Scan to join!")
                    .foregroundColor(.black)
                    .font(.system(size: 12))
                ZStack{
                    openEndedShapeView(height: 85, width: 85)
                    QRCodeView(data: album.documentID ?? "")
                }
                
                Spacer()
                Text("In the album")
                    .foregroundColor(.black)
                    .font(.system(size: 12))
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
                            ZStack{
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 70)
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.gray)
                                    .frame(width: 70, height: 70)
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            }
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
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    .padding(.bottom, 80)
            }
            
            
        }
        .background(
            Rectangle()
                .fill(Color.blue)
                .frame(width: 600, height: 1500)
                .rotationEffect(.degrees(-50))
                .offset(y: 300)
                .cornerRadius(10), alignment: .center
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
                            .font(.system(size: 18))
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
