import SwiftUI

struct MessageBubble: View {
    var message: Message
    var isCurrentUser: Bool // Add this to determine if the message was sent by the current user
    @State private var showTime = false
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            HStack {
                Text(message.text)
                    .padding()
                    .background(isCurrentUser ? Color(.purple) : Color(.gray))
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: isCurrentUser ? .trailing : .leading)
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
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(isCurrentUser ? .trailing : .leading)
        .padding(.horizontal, 10)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        // For previews, you can arbitrarily decide if the message is from the current user
        MessageBubble(
            message: Message(id: "12345", text: "Hello, this is a message!", senderID: "currentUserID", timestamp: Date()),
            isCurrentUser: true
        )
    }
}
