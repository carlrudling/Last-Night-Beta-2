import SwiftUI
import Kingfisher // Assuming you use Kingfisher for image loading

struct MessageBubble: View {
    var message: Message
    var senderUsername: String?
    var senderProfileImageURL: String?
    var isCurrentUser: Bool
    @State private var showTime = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !isCurrentUser {
                profileImageView // Profile image on the left for received messages
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading) {
                Text(senderUsername ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                messageContentView
            }
            
            if isCurrentUser {
                profileImageView // Profile image on the right for sent messages
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.horizontal, 10)
    }
    
    private var profileImageView: some View {
        Group {
            if let urlString = senderProfileImageURL, !urlString.isEmpty, let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray) // You can set any color you like
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
        }
    }

    
    private var messageContentView: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            Text(message.text)
                .padding()
                .background(isCurrentUser ? Color(.purple) : Color(.gray))
                .cornerRadius(30)
                .onTapGesture {
                    showTime.toggle()
                }
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(isCurrentUser ? .trailing : .leading, 25)
            }
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(
            message: Message(id: "12345", text: "Hello, this is a message!", senderID: "currentUserID", timestamp: Date()),
            senderUsername: "Sender",
            senderProfileImageURL: nil, // Or an empty string
            isCurrentUser: false
        )
    }
}
