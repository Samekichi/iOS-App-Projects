//
//  ConnectedPeersPopoverView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 12/10/23.
//

import SwiftUI

struct ConnectedPeersPopoverView: View {
    @Environment(MultiPeerManager.self) var manager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Connected Peers")
                .foregroundStyle(.gray)
                .font(.title3)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(manager.connectedPeers, id: \.self) { peer in
                        Text(peer.displayName)
                            .foregroundStyle(.primary)
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }
}

