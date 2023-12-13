import SwiftUI

struct DatepickerView: View {
    @Binding var endDate: Date
    @State var pickerText: String
    
    var body: some View {
        VStack {
            DatePicker("\(pickerText)", selection: $endDate, in: Date.now...)
                .font(Font.custom("Chillax", size: 16))
            
        }
    }
}
