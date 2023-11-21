//
//  CreateAlbumView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

import SwiftUI



struct CreateAlbumView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumViewModel: AlbumViewModel
    @Binding var isTabBarHidden: Bool
    @Binding var rootIsActive : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

       
    // add creator to members array
    var body: some View {
      
            VStack() {
                Text("Create Album")
                    .font(.system(size: 25))
                    .foregroundColor(.black)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                Form {
                    Section(footer: albumViewModel.showErrorMessage ? Text("\(albumViewModel.errorMessage)").foregroundColor(.red) : Text("")){
                        TextField("Album name", text: $albumViewModel.albumName)
                            .disableAutocorrection(true)
                            .font(Font.custom("Chillax", size: 16))
                                                                    
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
                }
                .frame(height: 500)
                .scrollContentBackground(.hidden)

                Spacer()
                
                
                NavigationLink(destination: AddMembersView(isTabBarHidden: $isTabBarHidden, rootIsActive: $rootIsActive), label: {
                    HStack{
                        Text("Next")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(width: UIScreen.main.bounds.width - 52, height: 28)
                    .padding(15)
                    .background(.green)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .disabled(!albumViewModel.albumValid)
                    .opacity(!albumViewModel.albumValid ? 0.5 : 1)
                   // .onTapGesture {
                  //      albumViewModel.validateInputs()
                   // }
                    
                })
                .isDetailLink(false)
            }
            .background(
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 600, height: 1500)
                    .rotationEffect(.degrees(-50))
                    .offset(y: 300)
                    .cornerRadius(10), alignment: .center
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
            .gesture(
                TapGesture().onEnded {
                    UIApplication.shared.endEditing()
                }
            )
        
        
        }
    }


struct CreateAlbumView_Previews: PreviewProvider {
    @State static private var isTabBarHidden = false
    @State static private var rootIsActive = false
    static var previews: some View {
        CreateAlbumView(isTabBarHidden: $isTabBarHidden, rootIsActive: $rootIsActive)
    }
}
