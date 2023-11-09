//
//  CreateAlbumView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

import SwiftUI



struct CreateAlbumView: View {

    @EnvironmentObject var userService : UserService
    @State private var albumName = ""
    @State private var  endDate = Date()
    @State private var photoLimit = 0
    @State private var members : [String] = []
    @State private var creator : String = ""
    @Binding var isTabBarHidden: Bool
    @Binding var rootIsActive : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    

    // add creator to members array
    var body: some View {
      
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text("Choose your album name")
                    .font(Font.custom("Chillax", size: 18))
                TextField("Album name", text: $albumName)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax", size: 16))
                    .padding(.bottom, 25)
                Text("PhotoLimit per user per 24h")
                    .font(Font.custom("Chillax", size: 18))
                    .padding(.bottom, -25)
                PhotoLimitSelector(photoLimit: $photoLimit, pickerText: "PhotoLimit per user per 24h")
                Text("Album end-date")
                    .font(Font.custom("Chillax", size: 18))
                DatepickerView(endDate: $endDate, pickerText: "Select photolimit")
                Spacer()
                
                
                NavigationLink(destination: AddMembersView(albumName: $albumName, endDate: $endDate, photoLimit: $photoLimit, creator : $creator, isTabBarHidden: $isTabBarHidden, shouldPopToRootView : self.$rootIsActive), label: {
                    Text("Next")
                        .font(Font.custom("Chillax", size: 20))
                        .frame(maxWidth: .infinity) // Align the button to center horizontally
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    
                })
                
                
                
            }
        
        
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading:
                            Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                                Image(systemName: "chevron.backward")
                                .foregroundColor(.black)
                                .padding(12)
                               // .background(Color.purple)
                             //   .clipShape(Circle())
                                
                            }
                    )
            .onAppear {
                creator = self.userService.uuid ?? ""
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
