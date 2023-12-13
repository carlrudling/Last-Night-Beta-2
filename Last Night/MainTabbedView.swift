import SwiftUI

struct MainTabbedView: View {
    @ObservedObject var userService = UserService()
    @State private var isTabBarHidden: Bool = false
    
    @State var selectedTab = 0
    
    var body: some View {
        
        
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab) {
                HomeView(isTabBarHidden: $isTabBarHidden)
                    .tag(0)
                
                CameraView(albumuuid: self.userService.uuid!)
                    .tag(1)
                
                ProfileView()
                    .tag(2)
                
            }
            
            
            
            if !isTabBarHidden {
                HStack {
                    ForEach(TabbedItems.allCases, id: \.self) { item in
                        Button {
                            selectedTab = item.rawValue
                        } label: {
                            CustomTabItem(imageName: item.iconName, isActive: (selectedTab == item.rawValue))
                        }
                        
                        if item != TabbedItems.allCases.last {
                            Spacer() // This will push the buttons apart
                        }
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 6)
                .frame(width: UIScreen.main.bounds.width - 60, height: 50) // Adjust the width to the screen width
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)

            }
        }
    }
}



struct MainTabbedView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabbedView()
    }
}


extension MainTabbedView{
    
    func CustomTabItem(imageName: String, isActive: Bool) -> some View {
        // Container for the image and its background
        ZStack {
            // Background Circle
            Circle()
                .fill(isActive ? Color.darkPurple : .clear)
                .frame(width: 40, height: 40) // Size of the background circle
                .shadow(color: isActive ? Color.black.opacity(0.5) : .clear, radius: 5, x: 0, y: 2)

            // Image
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(isActive ? .white : .gray)
                .frame(width: 25, height: 25) // Size of the image
        }
    }

    
    
}

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

