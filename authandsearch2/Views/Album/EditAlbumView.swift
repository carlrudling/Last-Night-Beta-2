import SwiftUI



struct EditAlbumView: View {
    @EnvironmentObject var albumService : AlbumService
    @EnvironmentObject var userService : UserService
    @EnvironmentObject var albumViewModel : AlbumViewModel
    @State private var keyboardIsShown: Bool = false
    @State var confirmationPopup = false
    @Binding var editAlbumSheeet: Bool
    @Binding var isTabBarHidden: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var album: Album
    
    // Initialize ViewModel with Current Album Data
    private func initializeViewModel() {
        albumViewModel.albumName = album.albumName
        albumViewModel.endDate = album.endDate
        albumViewModel.photoLimit = album.photoLimit
        albumViewModel.members = album.members
        albumViewModel.fetchAllUsers()
    }
    
    
    
    var isAlbumNameValid: Bool {
        !albumViewModel.albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Handle Update Logic
    private func handleUpdate() {
        albumViewModel.updateAlbum(originalAlbum: album) { success in
            if success {
                self.presentationMode.wrappedValue.dismiss()
            } else {
                // Handle error
            }
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
    
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // add creator to members array
    var body: some View {
        
        ZStack {
            // Invisible layer that will only react when the keyboard is shown
            if keyboardIsShown {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Hide the keyboard when the clear area is tapped
                        hideKeyboard()
                        keyboardIsShown = false // Update the state
                    }
                    .zIndex(5) // Make sure this is above the form
                    .frame(width: 300, height: 300)
            }
   
            VStack() {
                
                Form {
                    Section(footer: albumViewModel.showErrorMessage ? Text("\(albumViewModel.errorMessage)").foregroundColor(.red) : Text("")){
                        TextField("Album name", text: $albumViewModel.albumName)
                            .disableAutocorrection(true)
                            .font(Font.custom("Chillax", size: 16))
                            .onTapGesture {
                                // When tapping on the TextField, indicate that the keyboard is shown
                                keyboardIsShown = true
                            }
                    }
                    Section(footer: Text("Swipe to change")){
                        Text("Photo limit")
                        Picker("Photo limit", selection: $albumViewModel.photoLimit) {
                            ForEach(photoLimity.allCases) { option in
                                Text(String(describing: option))
                                    .tag(option.intValue)
                                
                            }
                        }
                        .pickerStyle(.segmented)
                        .font(Font.custom("Chillax", size: 18))
                    }
                    Section{
                        DatePicker("End date", selection: $albumViewModel.endDate, in: Date.now...)
                    }
                    List {
                        Section(header: Text("Members"),footer: Text("Swipe left to remove a member")) {
                            ForEach(albumViewModel.fetchedUsers, id: \.id) { user in
                                Text(user.username)
                            }
                            .onDelete(perform: delete)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .scrollContentBackground(.hidden)
                .zIndex(0) // Ensure the form is below the invisible layer
                
                
                Spacer()
            }
            VStack{
                Spacer()
                
                Button {
                    confirmationPopup = true
                } label: {
                    Text("Save changes")
                        .font(Font.custom("Chillax", size: 20))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.lightPurple)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(!isAlbumNameValid) // Disable the button if album name is not valid
                .zIndex(2) // Ensure the form is below the invisible layer
                .padding(.bottom, 50)
                
            }
           
        }
        .popup(isPresented: $confirmationPopup) {
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
                            Image(systemName: "questionmark.circle") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                                .zIndex(1) // Ensure it's above the background
                            Image(systemName: "questionmark.circle.fill") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.yellow)
                            
                                .zIndex(1) // Ensure it's above the background
                        }
                        
                        Text("Sure you want to change?")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                            .foregroundColor(.black)
                        
                        Text("If you press 'yes', the settings you've set here will become the new default.")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.top, 5)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        Spacer()
                        HStack(spacing: 0) {
                            Button {
                                confirmationPopup = false
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
                                handleUpdate()
                                albumViewModel.resetValues()
                                
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
                
                
            }
            .frame(width: 300, height: 300, alignment: .center)
            //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
            .background(.clear)
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
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(12)
        }
        )
        .onAppear {
            initializeViewModel()
            isTabBarHidden = true
            albumService.fetchUsersFromAlbum(album: album, userService: userService) { fetchedUsers in
                albumViewModel.fetchedUsers = fetchedUsers
            }
        }
        .onDisappear{
            isTabBarHidden = false
            albumViewModel.resetValues()
            
        }
    }
    
}



