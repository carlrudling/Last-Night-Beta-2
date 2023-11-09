//
//  AddMembersView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

import SwiftUI


import SwiftUI

struct AddMembersView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumService : AlbumService
    @StateObject var usersLookup = UsersLookupViewModel()
    @State var keyword = ""
    @State private  var members : [String] = []
    @Binding private var albumName : String
    @Binding private var  endDate : Date
    @Binding private var photoLimit : Int
    @Binding private var creator : String
    @Binding var isTabBarHidden: Bool
    @State private var buttonPressed = false
    @State private var isActive: Bool = false
    @Binding var shouldPopToRootView : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    
    init(albumName: Binding<String>, endDate: Binding<Date>, photoLimit: Binding<Int>, creator: Binding<String>, isTabBarHidden: Binding<Bool>, shouldPopToRootView : Binding<Bool>) {
        _albumName = albumName
        _endDate = endDate
        _photoLimit = photoLimit
        _creator = creator
        _isTabBarHidden = isTabBarHidden
        _shouldPopToRootView = shouldPopToRootView
        
    }
    
    
    var body: some View {
        let keywordBinding = Binding<String>(
            get: {
                keyword
            },
            set: {
                keyword = $0
                usersLookup.fetchUsers(with: keyword)
            }
        )
        VStack {
            
            
            SearchUserBarView(keyword: keywordBinding)
            ScrollView {
                ForEach(usersLookup.queryResultUsers, id: \.uuid) { user in
                    ProfileDisplayView(user: user, members: $members)
                    
                }
            }
            
       
                Button {
                    buttonPressed = true
                    albumService.createAlbum(albumName: albumName, endDate: endDate, photoLimit: photoLimit, members: members, creator: creator)
                    self.shouldPopToRootView = false
                    
                } label: {
                    Text("Create Album")
                        .font(Font.custom("Chillax", size: 20))
                        .frame(maxWidth: .infinity) // Align the button to center horizontally
                        .padding()
                        .background(buttonPressed ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    

                }
                
              
                
                
            
            
            
            
            
        }
        .padding(.horizontal, 20)
      
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
            members.append(self.userService.uuid!)
            isTabBarHidden = true
            
        }
        .onDisappear{
            isTabBarHidden = false
        }
    }
    
}


// Propably you need to create another struct and call it when onTapgesture that displays the member (as selected)


struct AddMembersView_Previews: PreviewProvider {
    static var previews: some View {
        let albumName = Binding<String>(get: { "Sample Album" }, set: { _ in })
        let endDate = Binding<Date>(get: { Date() }, set: { _ in })
        let photoLimit = Binding<Int>(get: { 10 }, set: { _ in })
        let creator = Binding<String>(get: {"Sample creator"}, set: { _ in})
        let isTabBarHidden = Binding<Bool>(get: { true }, set: { _ in })
        let shouldPopToRootView = Binding<Bool>(get: { true }, set: { _ in })
        
        return AddMembersView(albumName: albumName, endDate: endDate, photoLimit: photoLimit, creator: creator, isTabBarHidden: isTabBarHidden, shouldPopToRootView: shouldPopToRootView)
    }
}
