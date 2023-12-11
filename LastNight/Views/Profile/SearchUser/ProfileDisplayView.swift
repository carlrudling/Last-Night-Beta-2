import SwiftUI

struct ProfileDisplayView: View {
    var user: User
    @EnvironmentObject var albumViewModel: AlbumViewModel
    @State private var isTapped: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .foregroundColor(.white)
                .onTapGesture {
                    if albumViewModel.members.contains( user.uuid) {
                        // Member is already in the array, so remove them
                        if let index = albumViewModel.members.firstIndex(of: user.uuid) {
                            albumViewModel.members.remove(at: index)
                        }
                        //  albumViewModel.members.remove(user.uuid)
                        isTapped.toggle()
                    } else {
                        // Member is not in the array, so add them
                        albumViewModel.members.append(user.uuid)
                        isTapped.toggle()
                    }
                    
                }
                .cornerRadius(13)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 25))
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                VStack(alignment: .leading){
                    Text("\(user.firstName) \(user.lastName)")
                        .font(Font.custom("Chillax-Regular", size: 16))
                        .foregroundColor(.black)
                    Text("\(user.username)")
                        .font(Font.custom("Chillax-Regular", size: 12))
                        .foregroundColor(.black)
                    
                    
                }
                Spacer()
                Image(systemName: isTapped ? "checkmark.circle.fill" : "")
                    .font(.system(size: 25))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                
            }
            .padding(.horizontal, 10)
        }
        .frame(width: UIScreen.main.bounds.width - 52, height: 80)
    }
}
