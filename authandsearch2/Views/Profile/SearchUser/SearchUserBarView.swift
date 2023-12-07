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
                TextField("Searching for...", text: $keyword)
                .font(Font.custom("Chillax-Regular", size: 16))
                .autocapitalization(.none)
                .foregroundColor(.black)

            }
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}

