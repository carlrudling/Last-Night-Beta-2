//
//  PhotoLimitSelector.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

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
