//
//  OnBoardView.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/7/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import SwiftUI

struct OnBoardView: View {
    @State var imageName = "iPad-OnBoarding"
    @State var imageNameDark = "iPad-OnBoarding-Dark"
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20.0) {
            Text("Welcome to X-Mission")
                .font(Font.system(size: 40.0, weight: .bold, design: .rounded))
                .padding(.top, 50.0)
            
            GeometryReader { geo in
                Image(self.colorScheme == .dark ? self.imageNameDark : self.imageName)
                .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: geo.size.width * 0.8)
            }
            .frame(height: 300)
            
            Text("X-Mission let's you remotely control a Transmission server via RPC.\nFirst set up your Transmission remote server, then open X-Mission' settings and insert your server configuration. It's just simple as that!")
                .foregroundColor(Color.primary.opacity(0.8))
                .padding([.leading, .trailing], 30.0)
                .lineLimit(.none)
                .padding(.top, 0)
                .padding(.bottom, 20.0)
                .multilineTextAlignment(.center)
                .font(Font.system(size: 20.0, weight: .regular, design: .rounded))
            
            Button(action: {
                NotificationCenter.default.post(name: .needCloseOnBoard, object: nil)
            }) {
                Text("Start X-Mission")
                    .font(Font.system(size: 25.0, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding([.leading, .trailing], 20.0)
                    .padding([.top, .bottom], 15.0)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            }
                .padding(.bottom, 30.0)
            
            
        }
    }
}

struct OnBoardView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .center) {
            GeometryReader { geo in
                OnBoardView()
                    .frame(width: geo.size.width, height: 1200, alignment: .center)
            }
        }
    }
}
