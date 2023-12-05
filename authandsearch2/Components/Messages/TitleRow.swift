//
//  TitleRow.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-12-04.
//

import SwiftUI

struct TitleRow: View {

    var name: String
    
    var body: some View {
        HStack(spacing: 20) {
                Image(systemName: "person")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title).bold()
                
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "phone.fill")
                .foregroundColor(.gray)
                .padding(10)
                .background(.white)
                .cornerRadius(50)
           
            }
        .padding()
        

        }
    }


struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        TitleRow(name: "GDANSK")
    }
}
