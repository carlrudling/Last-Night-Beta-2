import SwiftUI

struct MessagesView: View {
    @StateObject var messagesService: MessagesService
    @State private var albumName: String
    @EnvironmentObject var userService: UserService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    init(albumID: String, albumName: String) {
        _messagesService = StateObject(wrappedValue: MessagesService(albumID: albumID))
        self._albumName = State(initialValue: albumName) // Correct initialization of albumName
    }
    
    var body: some View {
        VStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesService.messages, id: \.id) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderID == userService.uuid // You need to provide the current user's ID here
                            )
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .onChange(of: messagesService.lastMessageId) { id in
                        withAnimation{
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.purple))
            
            MessageField(messagesService: messagesService)
            
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline) // Set the display mode to inline
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.backward") // Back icon
                    }
                    .foregroundColor(.white)
                    .padding(12)
                    
                    Text(albumName) // Album name next to back button
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(albumID: "dummyAlbumID", albumName: "Dummy Album Name")
    }
}


