//
//  DatePicker.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

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

/*
struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerView()
    }
}
*/
