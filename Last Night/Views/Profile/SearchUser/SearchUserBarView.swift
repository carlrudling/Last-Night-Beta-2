import SwiftUI

struct SearchUserBarView: View {
    @Binding var keyword: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)
                TextField("Search users...", text: $keyword)
                .font(Font.custom("Chillax-Regular", size: 16))
                .autocapitalization(.none)
                .foregroundColor(.black)


            }
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding()
    }
}

