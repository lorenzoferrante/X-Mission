//
//  ProgressBar.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/5/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import SwiftUI

public struct ProgressBar: View {
    @State var isShowing = false
    @Binding var progress: CGFloat
    @Binding var barWidth: CGFloat
 
    public var body: some View {
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .opacity(0.3)
                    .frame(maxWidth: .infinity, maxHeight: 8.0)
                Rectangle()
                    .foregroundColor(progress == 100 ? Color.green : Color.blue)
                    .frame(width: self.isShowing ? barWidth * (self.progress / 100.0) : 0.0, height: 8.0)
                    .animation(.linear(duration: 0.6))
            }
            .onAppear {
                self.isShowing = true
            }
            .cornerRadius(4.0)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(isShowing: false, progress: .constant(25.0), barWidth: .constant(.infinity))
    }
}
