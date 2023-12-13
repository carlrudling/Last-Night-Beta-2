import SwiftUI

struct AddMembersView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumService: AlbumService
    @EnvironmentObject var albumViewModel: AlbumViewModel
    @StateObject var usersLookup = UsersLookupViewModel()
    @Binding var isTabBarHidden: Bool
    @State private var buttonPressed = false
    @State private var isActive: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var createAlbumSheet: Bool
    
    
    var body: some View {
       
        ZStack{
            let keywordBinding = Binding<String>(
                get: {
                    albumViewModel.keyword
                },
                set: {
                    albumViewModel.keyword = $0
                    usersLookup.fetchUsers(with: albumViewModel.keyword)
                }
            )
            VStack {
                
                
                SearchUserBarView(keyword: keywordBinding)
                ScrollView {
                    ForEach(usersLookup.queryResultUsers, id: \.uuid) { user in
                        ProfileDisplayView(user: user)
                        
                    }
                }
                
                NavigationLink(destination: CheckMembersView(createAlbumSheet: $createAlbumSheet, isTabBarHidden: $isTabBarHidden), label: {
                    HStack{
                        Text("Next")
                            .font(Font.custom("Chillax-Regular", size: 16))
                        Image(systemName: "arrow.right")
                    }
                    .frame(width: UIScreen.main.bounds.width - 52, height: 28)
                    .padding(15)
                    .background(.green)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .disabled(!albumViewModel.albumValid)
                    .opacity(!albumViewModel.albumValid ? 0.5 : 1)
                })
                
            }
        }
        .padding(.horizontal, 20)
        .background(
            ZStack{
                Color.backgroundWhite.edgesIgnoringSafeArea(.all)

                BackgroundView()
                    .frame(width: 600, height: 1500)
                    .rotationEffect(.degrees(-50))
                    .offset(y: 300)
            }
        )
        
        
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(12)
            
            
        }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear{
            isTabBarHidden = true
            
        }
        .onDisappear{
            isTabBarHidden = false
        }
    }
    
}
