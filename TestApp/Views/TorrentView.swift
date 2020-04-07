//
//  TorrentView.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/5/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
class TorrentObserved: ObservableObject {
    var didChange = PassthroughSubject<Torrent, Never>()
    
    @Published var data = Torrent() {
        didSet {
            update()
        }
    }
    
    func update() {
        didChange.send(data)
    }
    
    init(torrentData: Torrent) {
        self.data = torrentData
    }
}

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

struct TorrentView: View {
    @ObservedObject var torrent: TorrentObserved
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(torrent.data.name!)
                    .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Button(action: {
                        if self.torrent.data.status! == 0 {
                            print("Stopped torrent: \(self.torrent.data.id!) - \(self.torrent.data.name!)")
                            RPCCLient.shared.torrentToggle(id: self.torrent.data.id!, needStart: true)
                        } else if [4, 2, 6].contains(self.torrent.data.status!) {
                            print("Started torrent: \(self.torrent.data.id!) - \(self.torrent.data.name!)")
                            RPCCLient.shared.torrentToggle(id: self.torrent.data.id!, needStart: false)
                        }
                    }) {
                        Image(systemName: getButtonStatus())
                            .font(Font.system(size: 22.0))
                    }
                    
                    Button(action: {
                        NotificationCenter.default.post(name: .needRemoveTorrent, object: nil, userInfo: ["id": self.torrent.data.id!])
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .font(Font.system(size: 22.0))
                    }.padding(.leading, 20.0)
                }
                
                HStack {
                    Text(String(format: "↓ %.2f Mb/s", convertToMB(torrent.data.rateDownload!)))
                    Text(String(format: "- (%.2f%% done)", torrent.data.percentDone!*100))
                }
                .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.secondary)
                
                GeometryReader { geometry in
                    HStack {
                        ProgressBar(
                            isShowing: false,
                            progress: .constant(CGFloat(self.torrent.data.percentDone! * 100)),
                            barWidth: .constant(geometry.size.width))
                        Spacer()
                    }
                }
                
                Text("\(convertStatus(torrent.data.status!)) - \(getETAString(seconds: torrent.data.eta!))")
                .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.secondary)
            }
            Spacer()
        }
    .padding()
    }
    
    private func getButtonStatus() -> String {
        let status: [Int] = [TR_STATUS.TR_STATUS_DOWNLOAD.rawValue,
                             TR_STATUS.TR_STATUS_DOWNLOAD_WAIT.rawValue,
                             TR_STATUS.TR_STATUS_SEED.rawValue,
                             TR_STATUS.TR_STATUS_CHECK.rawValue]
        if status.contains(torrent.data.status!) {
            return "pause.fill"
        }
        return "arrow.clockwise"
    }
    
    private func convertToMB(_ bytes: Int) -> Double {
        return Double(bytes) * 1e-6
    }
    
    private func convertETA(seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func getETAString(seconds: Int) -> String {
        if torrent.data.percentDone == 1.0 {
            return "Finished"
        }
        if seconds == -1 {
            return "ETA not available"
        }
        if seconds == -2 {
            return "ETA unknown"
        }
        
        var eta = ""
        let (h, m, s) = convertETA(seconds: seconds)
        
        if (h != 0) { eta += "\(h)h "}
        if (m != 0) { eta += "\(m)m "}
        if (s != 0) { eta += "\(s)s remaining"}
        
        return eta
    }
    
    private func convertStatus(_ status: Int) -> String {
        return TR_STATUS.toString(TR_STATUS(rawValue: status)!)()
    }
}


struct TorrentView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TorrentView(torrent: TorrentObserved(torrentData: Torrent(
            id: 0,
            name: "Parasite (2019) [BluRay] [1080p] [YTS.LT]",
            percentDone: 0.4034,
            status: 2,
            totalSize: 123345,
            eta: 654,
            rateDownload: 5455000)))
        }
        
    }
}
