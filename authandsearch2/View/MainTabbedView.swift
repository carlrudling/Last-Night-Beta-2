//
//  MainTabbedView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-29.
//


enum TabbedItems: Int, CaseIterable{
    case start = 0
    case camera
    case profile
    
    
    var iconName: String{
        switch self {
        case .start:
            return "party.popper"
        case .camera:
            return "camera"
        case .profile:
            return "person"
        }
    }
}


import SwiftUI

struct MainTabbedView: View {
    @ObservedObject var user = UserViewModel()
    
    
    @State var selectedTab = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                CameraView(albumuuid: self.user.uuid!)
                    .tag(1)
                
                ProfileView()
                    .tag(2)
                
            }
            
            
            
            
            ZStack{
                HStack{
                    ForEach((TabbedItems.allCases), id: \.self){ item in
                        Button{
                            selectedTab = item.rawValue
                        } label: {
                            CustomTabItem(imageName: item.iconName, isActive: (selectedTab == item.rawValue))
                        }
                    }
                }
                .padding(6)
            }
            .frame(width: 260, height: 70)
            .background(.purple.opacity(0.2))
            .background(.white)
            .cornerRadius(35)
            .padding(.horizontal, 26)
        }
    }
}


struct MainTabbedView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabbedView()
    }
}


extension MainTabbedView{
    
    func CustomTabItem(imageName: String, isActive: Bool) -> some View{
        
        HStack(spacing: 10){
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .frame(width: 25, height: 25)
            
            Spacer()
        }
        .frame(width: 70, height: 70)
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(50)
    }
}
