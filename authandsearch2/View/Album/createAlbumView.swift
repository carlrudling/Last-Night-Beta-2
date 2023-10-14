//
//  createAlbumView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-30.
//

import SwiftUI



struct createAlbumView: View {
    @EnvironmentObject var album : AlbumViewModel
    @EnvironmentObject var user : UserViewModel
    @State private var albumName = ""
    @State private var  endDate = Date()
    @State private var photoLimit = 0
    @State private var members : [String] = []
    @State private var creator : String = ""
    @Binding var isTabBarHidden: Bool
    @Binding var rootIsActive : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    // add creator to members array
    var body: some View {
      
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text("Choose your album name")
                    .font(Font.custom("Chillax", size: 18))
                TextField("Album name", text: $albumName)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax", size: 16))
                    .padding(.bottom, 25)
                Text("PhotoLimit per user per 24h")
                    .font(Font.custom("Chillax", size: 18))
                    .padding(.bottom, -25)
                photoLimitSelector(photoLimit: $photoLimit)
                Text("Album end-date")
                    .font(Font.custom("Chillax", size: 18))
                datePicker(endDate: $endDate)
                Spacer()
                
                
                NavigationLink(destination: AddMembersView(albumName: $albumName, endDate: $endDate, photoLimit: $photoLimit, creator : $creator, isTabBarHidden: $isTabBarHidden, shouldPopToRootView : self.$rootIsActive), label: {
                    Text("Next")
                        .font(Font.custom("Chillax", size: 20))
                        .frame(maxWidth: .infinity) // Align the button to center horizontally
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    
                })
                
                
                
            }
        
        
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading:
                            Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                                Image(systemName: "chevron.backward")
                                .foregroundColor(.black)
                                .padding(12)
                               // .background(Color.purple)
                             //   .clipShape(Circle())
                                
                            }
                    )
            .onAppear {
                creator = self.user.uuid ?? ""
                isTabBarHidden = true
            }
            .gesture(
                TapGesture().onEnded {
                    UIApplication.shared.endEditing()
                }
            )
        
        
        }
    }

/*
 OTHER WAY
 struct SampleDetails: View {
     @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

     var btnBack : some View { Button(action: {
         self.presentationMode.wrappedValue.dismiss()
         }) {
             HStack {
             Image("ic_back") // set image here
                 .aspectRatio(contentMode: .fit)
                 .foregroundColor(.white)
                 Text("Go back")
             }
         }
     }
     
     var body: some View {
             List {
                 Text("sample code")
         }
         .navigationBarBackButtonHidden(true)
         .navigationBarItems(leading: btnBack)
     }
 }
 */


enum photoLimity: CaseIterable, Identifiable {
    
    case None, ten, fifteen, twenty
    
    var id: Self { self }
    
    var description: String {
        
        switch self {
        case .None:
            return "0"
        case .ten:
            return "10"
        case .fifteen:
            return "15"
        case .twenty:
            return "20"
        }
    }
    
    var intValue: Int {
        
        switch self {
        case .None:
            return 0
        case .ten:
            return 10
        case .fifteen:
            return 15
        case .twenty:
            return 20
        }
        
    }
}

struct photoLimitSelector: View {
    @Binding var photoLimit: Int
    @State private var selectedOption: photoLimity = .None
    
    
    
    var body: some View {
        Picker("PhotoLimit per user per 24h", selection: $selectedOption) {
            // 1
            ForEach(photoLimity.allCases) { option in
                
                // 2
                Text(String(describing: option))
                    .tag(option.intValue)
                
            }
        }
        .pickerStyle(.wheel)
        .frame(maxHeight: 120)
        .onChange(of: selectedOption) { newValue in
            photoLimit = newValue.intValue // Update photoLimit with the selected intValue
        }
        
        
    }
}


struct datePicker: View {
    @Binding var endDate: Date
    
    var body: some View {
        VStack {
            DatePicker("Select date", selection: $endDate, in: Date.now...)
                .font(Font.custom("Chillax", size: 16))
            //.datePickerStyle(GraphicalDatePickerStyle())
            // .frame(maxHeight: 400)
        }
    }
}


struct createAlbumView_Previews: PreviewProvider {
    @State static private var isTabBarHidden = false
    @State static private var rootIsActive = false
    static var previews: some View {
        createAlbumView(isTabBarHidden: $isTabBarHidden, rootIsActive: $rootIsActive)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


// This is supposed to keep swipeback function possible while creating a custom back button
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    // public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //     true
    // }

    // To make it works also with ScrollView but not simultaneously
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

}
