
import SwiftUI

struct AlbumPickerView: View {
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var userService: UserService
    @State var albumName: String = ""
    @State private var showList = false  // State variable to control visibility of list
    @Binding var selectedAlbumID: String
    
    
    
    var body: some View {
        VStack {
            // Button to toggle list visibility
            Button(action: {
                withAnimation {  // Animates the transition
                    self.showList.toggle()  // Toggle showList value between true and false
                }
            }) {
                
                Text(albumName == "" ? "Select album" : albumName)
                    .foregroundColor(Color.white)
                
            }
            .frame(width: 180)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
            .contentShape(Rectangle())
            
            
            if showList {
                HStack {
                    ScrollView {
                        VStack {
                            ForEach(albumService.queryResultAlbums, id: \.uuid) { album in
                                if album.isActive {
                                    Text(album.albumName)
                                        .frame(width: 180)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                                        .contentShape(Rectangle())
                                    
                                        .onTapGesture {
                                            albumName = album.albumName
                                            selectedAlbumID = album.uuid
                                            print(albumName)
                                            print(selectedAlbumID)
                                            self.showList.toggle()
                                        }
                                }
                            }
                        }
                    }
                    .frame(width: 200, height: 300)
                    .offset(y: showList ? 0 : -400)  // Offset modifier to control position of list
                }
            }
            
        }
        .onAppear {
            // Make safe, creates Fatal error: Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
            // This happens when pressing SignOut button from profileView
            guard let uuid = userService.uuid else {return}
            albumService.fetchAlbums(forUserWithID: userService.uuid ?? "")
        }
    }
}
