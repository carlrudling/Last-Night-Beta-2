import SwiftUI

struct CreateAlbumView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumViewModel: AlbumViewModel
    @Binding var isTabBarHidden: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showUserGrid = false
    @Binding var createAlbumSheet: Bool
    @State private var keyboardIsShown: Bool = false
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
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
                Text("Create Album")
                    .font(.custom("Chillax-Medium", size: 20))
                    .font(.system(size: 25))
                    .foregroundColor(.black)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                
                Form {
                    Section(footer: albumViewModel.showErrorMessage ? Text("\(albumViewModel.errorMessage)").foregroundColor(.red) : Text("")){
                        TextField("Album name", text: $albumViewModel.albumName)
                            .disableAutocorrection(true)
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .onTapGesture {
                                // When tapping on the TextField, indicate that the keyboard is shown
                                keyboardIsShown = true
                            }
                    }
                    /*
                    Section(){
                        Text("Photo limit")
                            .font(Font.custom("Chillax-Regular", size: 16))
                        Picker("Photo limit", selection: $albumViewModel.photoLimit) {
                            ForEach(photoLimity.allCases) { option in
                                Text(String(describing: option))
                                    .tag(option.intValue)
                                    .font(Font.custom("Chillax-Regular", size: 16))
                                
                            }
                        }
                        .pickerStyle(.segmented)
                        .font(Font.custom("Chillax-Regular", size: 16))
                    }
                    */
                    Section{
                        DatePicker("End date", selection: $albumViewModel.endDate, in: Date.now...)
                            .font(Font.custom("Chillax-Regular", size: 16))

                    }
                }
                .frame(height: 500)
                .scrollContentBackground(.hidden)
                .zIndex(0) // Ensure the form is below the invisible layer
                
                
                Spacer()
                
                
                NavigationLink(destination: AddMembersView(isTabBarHidden: $isTabBarHidden, createAlbumSheet: $createAlbumSheet), label: {
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
            albumViewModel.creator = self.userService.uuid ?? ""
            isTabBarHidden = true
        }
        .onDisappear{
            isTabBarHidden = false
            
        }
        
    }
}

