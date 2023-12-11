
import SwiftUI

struct MessageField: View {
    @ObservedObject var messagesService: MessagesService
    @State private var message = ""
    @EnvironmentObject var userService: UserService

    var body: some View {
        HStack {
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)
            
            Button {
                messagesService.sendMessage(text: message, senderID: userService.uuid ?? "", toAlbum: messagesService.albumID)
                message = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(.purple))
                    .cornerRadius(50)
                    
                
            }

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.gray))
        .cornerRadius(100)
        .padding()
    }
}


struct CustomTextField: View {
    var placeholder: Text
    @Binding var text : String
    var editingChanged: (Bool) -> () = {_ in}
    var commit: () -> () = {}
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .opacity(0.5)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
