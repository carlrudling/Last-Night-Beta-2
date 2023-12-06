import SwiftUI
import Kingfisher

struct UserGridView: View {
    @Binding var selectedDetent: PresentationDetent
    private var users: [User] // Use a private variable instead of a state
    var album: Album
    
    init(selectedDetent: Binding<PresentationDetent>, album: Album, users: [User]) {
        self._selectedDetent = selectedDetent
        self.album = album
        self.users = users
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                    ForEach(users, id: \.uuid) { user in
                        VStack {
                            if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.gray)
                                    .frame(width: 70, height: 70)
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            }
                            Text(user.username)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .padding(5)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            selectedDetent = .medium
        }
    }
}
