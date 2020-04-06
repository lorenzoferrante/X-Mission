//
//  ErrorCell.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/6/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import SwiftUI

struct ErrorCell: View {
    
    var body: some View {
        HStack {
            Image(systemName: "ant.fill")
                .font(Font.system(size: 25.0, weight: .semibold, design: .rounded))
                .foregroundColor(.red)
            
            VStack(alignment: .leading) {
                Text("There was a problem trying to connect to the server")
                    .font(Font.system(size: 18.0, weight: .medium, design: .rounded))
                Text("Try to check your settings")
                .font(Font.system(size: 16.0, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ErrorCell_Previews: PreviewProvider {
    static var previews: some View {
        ErrorCell()
    }
}
