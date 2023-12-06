import SwiftUI

struct MessagesView: View {
    @StateObject var messagesService: MessagesService
    @State private var albumName: String
    @State private var userDictionary: [String: User] = [:]
    @State private var keyboardIsShown: Bool = false

    @EnvironmentObject var userService: UserService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    
    init(albumID: String, albumName: String, users: [User]) {
        _messagesService = StateObject(wrappedValue: MessagesService(albumID: albumID))
        self._albumName = State(initialValue: albumName)
        self._userDictionary = State(initialValue: Dictionary(uniqueKeysWithValues: users.map { ($0.uuid, $0) }))
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        
        
        ZStack {
            // Invisible layer that will only react when the keyboard is shown
            if keyboardIsShown {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Hide the keyboard when the clear area is tapped
                        hideKeyboard()
                        keyboardIsShown = false // Update the state
                    }
                    .zIndex(5) // Make sure this is above the form
                    .frame(width: 300, height: 300)
                
            }
            VStack {
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(messagesService.messages, id: \.id) { message in
                                if let sender = userDictionary[message.senderID] {
                                    let profileImageURL = sender.profileImageURL // This might be nil, an empty string, or a valid URL
                                    
                                    MessageBubble(
                                        message: message,
                                        senderUsername: sender.username,
                                        senderProfileImageURL: profileImageURL,
                                        isCurrentUser: message.senderID == userService.uuid
                                    )
                                }
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
                    .onTapGesture {
                        keyboardIsShown = true
                    }
                
            }
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



