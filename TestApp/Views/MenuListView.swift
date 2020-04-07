//
//  MenuListView.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/5/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
class ItemsObserver: ObservableObject {
    var didChange = PassthroughSubject<Int, Never>()
    
    @Published var data = 0 {
        didSet {
            update()
        }
    }
    
    func update() {
        didChange.send(data)
    }
    
    init(items: Int) {
        self.data = items
    }
}

struct MenuListView: View {
    @State var menuIcon: String
    @State var menuLabel: String
    @ObservedObject var items: ItemsObserver = ItemsObserver(items: 0)
    
    var body: some View {
        HStack {
            Image(systemName: menuIcon)
                .font(Font.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.secondary)
                .padding()
            
            Text(menuLabel)
                .font(Font.system(size: 20, weight: .semibold, design: .rounded))
            
            Spacer()
        
            if !(["Settings", "Logs"].contains(menuLabel)) {
                ZStack {
                    Text("\(items.data)")
                        .padding(10.0)
                        .font(Font.system(size: 18.0, weight: .heavy, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.6))
                        .background(Color.secondary.opacity(0.6))
                        .clipShape(Circle())
                }.padding(.trailing, 10.0)
            }
        }
    }
}

struct MenuListView_Previews: PreviewProvider {
    static var previews: some View {
        MenuListView(menuIcon: "arrow.down", menuLabel: "Downloading")
        .frame(width: 300, height: 50)
            .background(Color.secondary.opacity(0.2))
    }
}
