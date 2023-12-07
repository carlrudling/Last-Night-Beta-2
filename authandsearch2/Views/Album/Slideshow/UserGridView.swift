import SwiftUI
import Kingfisher

struct UserGridView: View {
    @Binding var selectedDetent: PresentationDetent
    private var users: [User]
    var album: Album

    init(selectedDetent: Binding<PresentationDetent>, album: Album, users: [User]) {
        self._selectedDetent = selectedDetent
        self.album = album
        self.users = users
    }

    private func truncatedUsername(_ username: String) -> String {
        let maxLength = 8
        if username.count > maxLength {
            let index = username.index(username.startIndex, offsetBy: maxLength)
            return String(username[..<index]) + ".."
        }
        return username
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    // Small rounded rectangle
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 8)

                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 1) {
                        ForEach(users, id: \.uuid) { user in
                            VStack {
                                if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 40, height: 40)
                                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                }
                                Text(truncatedUsername(user.username))
                                    .font(Font.custom("Chillax-Regular", size: 12))
                                    .foregroundColor(.black)
                            }
                            .padding(5)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            selectedDetent = .medium
        }
    }
}
