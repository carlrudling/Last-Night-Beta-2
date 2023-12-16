import Foundation
import SwiftUI

struct CheckMembersView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumViewModel: AlbumViewModel
    @EnvironmentObject var albumService : AlbumService
    @State private var buttonPressed = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var createAlbumSheet: Bool
    @Binding var isTabBarHidden: Bool
    
    
    
    var body: some View {

            VStack{
                List {
                    Section(footer: Text("Swipe left to remove a member")
                        .font(Font.custom("Chillax-Regular", size: 14))
                    ) {
                        ForEach(albumViewModel.fetchedUsers, id: \.id) { user in
                            Text(user.username)
                                .font(Font.custom("Chillax-Regular", size: 20))
                            
                        }
                        .onDelete(perform: delete)
                    }
                }
                .padding(.top, 40)
                .frame(height: 500)
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Members")
                            .font(Font.custom("Chillax-Regular", size: 20))
                            .foregroundColor(.black) // Set the color if needed
                    }
                }
                
                
                
                
                Spacer()
                Button {
                    buttonPressed = true
                    albumViewModel.members.append(self.userService.uuid!)
                    albumService.createAlbum(albumName: albumViewModel.albumName, endDate: albumViewModel.endDate, photoLimit: albumViewModel.photoLimit, members: albumViewModel.members, creator: albumViewModel.creator)
                    albumViewModel.resetValues()
                    createAlbumSheet = false
                    isTabBarHidden = false
                    
                    
                } label: {
                    Text("Create Album")
                        .font(Font.custom("Chillax-Regular", size: 20))
                        .frame(maxWidth: .infinity) // Align the button to center horizontally
                        .padding()
                        .background(buttonPressed ? Color.green : Color.white)
                        .foregroundColor(buttonPressed ? .white : Color.black)
                        .clipShape(Capsule())
                        .padding(.bottom, 40)
                    
                    
                }
                
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
        .edgesIgnoringSafeArea(.all)
        .padding(.horizontal, 20)
        .onAppear {
            albumViewModel.fetchAllUsers()
            print("The members: \(albumViewModel.members)")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(12)
            
        }
        )
        .onDisappear{
            isTabBarHidden = false
            
        }
    }
    
    func delete(at offsets: IndexSet) {
        // Remove the user from fetchedUsers
        let idsToDelete = offsets.map { albumViewModel.fetchedUsers[$0].id }
        albumViewModel.fetchedUsers.remove(atOffsets: offsets)
        
        // Also remove the corresponding UUIDs from members
        albumViewModel.members.removeAll { idsToDelete.contains($0) }
        print("The members: \(albumViewModel.members)")
    }
}
