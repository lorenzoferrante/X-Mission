//
//  MenuListView.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/5/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import SwiftUI

struct MenuListView: View {
    @State var menuIcon: String
    @State var menuLabel: String
    
    var body: some View {
        HStack {
            Image(systemName: menuIcon)
                .font(Font.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.secondary)
                .padding()
            Text(menuLabel)
                .font(Font.system(size: 20, weight: .semibold, design: .rounded))
            Spacer()
        }
    }
}

struct MenuListView_Previews: PreviewProvider {
    static var previews: some View {
        MenuListView(menuIcon: "", menuLabel: "")
        .frame(width: 300, height: 50)
    }
}
