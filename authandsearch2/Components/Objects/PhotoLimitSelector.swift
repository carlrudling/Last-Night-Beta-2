import SwiftUI

struct PhotoLimitSelector: View {
    @Binding var photoLimit: Int
    @State private var selectedOption: photoLimity = .None
    @State var pickerText: String
    
    
    var body: some View {
        Picker("\(pickerText)", selection: $selectedOption) {
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
