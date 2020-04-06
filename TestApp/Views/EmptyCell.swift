//
//  EmptyCell.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/6/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import SwiftUI

struct EmptyCell: View {
    var body: some View {
        HStack {
            Image(systemName: "tortoise.fill")
                .font(Font.system(size: 25.0, weight: .semibold, design: .rounded))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Loading data from server...")
                    .font(Font.system(size: 18.0, weight: .medium, design: .rounded))
                Text("It seems it's taking a while! Meanwhile go grab a beer 🍺")
                .font(Font.system(size: 16.0, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct EmptyCell_Previews: PreviewProvider {
    static var previews: some View {
        EmptyCell()
    }
}
