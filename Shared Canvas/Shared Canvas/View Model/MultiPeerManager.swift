//
//  MultiPeerManager.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/27/23.
//

import Foundation
import MultipeerConnectivity
import Observation
import OSLog

@Observable
// MARK: MCP Manager
class MultiPeerManager : NSObject {
    // Log
    private let log = Logger()
    
    // MCP
    private let serviceType = "shared-canvas"
    private var myPeerID : MCPeerID
    var session : MCSession
    var serviceAdvertiser : MCNearbyServiceAdvertiser
    var serviceBrowser : MCNearbyServiceBrowser
    var invitationHandler : ((Bool, MCSession?) -> Void)?
    
    // Shared Canvas Instance
    var canvas : Canvas?
    
    // States
    var isHost = false
    var isBrowsing = false
    var isAdvertising = false
    var isHosting : Bool { isHost && isAdvertising }
    
    var isConnected : Bool { !session.connectedPeers.isEmpty }
//    var isShared : Bool { isConnected || canvas != nil }
    
    var receivedInvite : Bool = false
    var receivedInviteFrom : MCPeerID?
    
    var sessionHost : MCPeerID?
    var foundPeers = [MCPeerID]()
    var connectedPeers : [MCPeerID] { session.connectedPeers }
    var connectedPeersCount : Int = 0  // trigger update of host button view
    
    // init / deinit
    init(username: String) {
//        print("MCP init()")
        let peerID = MCPeerID(displayName: username)
        myPeerID = peerID
        
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
    
    deinit {
//        print("MCP deinit()")
        stopAdvertising()
        stopBrowsing()
    }

    // send join invitation
    func invitePeer(_ peerID: MCPeerID) {
        if foundPeers.contains(peerID) && !connectedPeers.contains(peerID) {
//            print("Inviting peer: \(peerID.displayName)...")
            serviceBrowser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
            self.sessionHost = peerID
            self.isHost = false
            self.canvas = nil
        } else {
//            print("Peer not found / already connected: \(peerID.displayName)")
        }
    }
}


// MARK: Advertiser
extension MultiPeerManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
           log.error("[Advertiser] did Not Start Advertising Peer: \(String(describing: error))")
       }
    
    // Invitation handling
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.info("[Advertiser] did Receive Invitation From Peer: \(String(describing: peerID))")
        DispatchQueue.main.async {
            self.isHost = true
            self.receivedInvite = true
            self.receivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}


// MARK: Browser
extension MultiPeerManager : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("[Browser] did Not Start Browsing For Peers: \(String(describing: error))")
    }
    
    // Found a peer
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        log.info("[Browser] Found Peer: \(String(describing: peerID)).")
        DispatchQueue.main.async {
            if !self.foundPeers.contains(peerID) {
                self.foundPeers.append(peerID)
            }
        }
    }
    
    // Lost a peer
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("[Browser] Lost Peer: \(String(describing: peerID)).")
        DispatchQueue.main.async {
            self.foundPeers.removeAll(where: { $0 == peerID })
        }
    }
}


// MARK: Session
extension MultiPeerManager : MCSessionDelegate {
    
    // Peer changed state
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("[Session] Peer \(peerID) did Change State: \(state.rawValue) (\(state.name))")
        
        connectedPeersCount = session.connectedPeers.count  // trigger update of host button view
        
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                if peerID == self.sessionHost {
                    self.disconnect()
                }
//                print("\tdidChange .notConnected finished")
            }
        case .connected:
            DispatchQueue.main.async {
                if self.connectedPeers.count >= 9 {
                    self.stopAdvertising()
                }
                if self.isHost {
                    let defaultCanvas = Canvas(name: "MCP Default Canvas", creatorIdentifier: CreatorIdentifier(username: UserDefaults.standard.string(forKey: "username")!, userUUIDString: UserDefaults.standard.string(forKey: "userUUID")!), creationDate: Date(), lastModifiedDate: Date(), width: 100, height: 75, backgroundCanvasColor: CanvasColor(CGColor.random()))
                    self.sendCanvas(self.canvas ?? defaultCanvas, to: peerID)
                    
                }
//                print("\tdidChange .connected finished")
            }
        default:  // .connecting or sth else
//            print("\tdidChange .default finished")
            break
        }
    }
    
    // Received Data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
//            print("received data")
            let decoder = JSONDecoder()
            if let receivedCanvas = try? decoder.decode(Canvas.self, from: data) {
                self.canvas = receivedCanvas
//                print("\tReceived a canvas.")
            } else if let action = try? decoder.decode(Action.self, from: data) {
                switch action.actionType {
                case .add:
                    let element = action.element
                    let id = action.elementID
                    self.canvas?.elements.removeAll(where: { $0.element.id == id })
                    self.canvas?.addElement(element!.element)
                case .erase:
                    let erasedElementIDs = action.elementIDs!
                    self.canvas?.elements.removeAll(where: { erasedElementIDs.contains($0.element.id) })
                case .move:
                    let offset = action.translation!
                    let id = action.elementID
                    if let i = self.canvas?.elements.firstIndex(where: { $0.element.id == id }) {
                        self.canvas?.elements[i].element.move(by: offset)
                    }
                case .canvasParameter:
                    break
                }
            } else {
//                print("\tReceived some data (not canvas / string).")
            }
//            print("\tdidReceive data finished")
        }
    }
    
    // Not Supported: Resource / Stream
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("[Session] Not supported: receiving stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("[Session] Not supported: receiving resource")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("[Session] Not supported: receiving resource")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
}


// MARK: extension
extension MultiPeerManager {
    
    /* Maintaining shared canvas instance */
    func prepareSharedCanvas(_ canvas: Canvas) {
        self.canvas = canvas
    }
    
    func clearSharedCanvas() {
        self.canvas = nil
    }
    
    /* Handling MPC connections */
    func disconnect() {
        session.disconnect()
        stopAdvertising()
        foundPeers.removeAll()
        sessionHost = nil
        clearSharedCanvas()
        connectedPeersCount = 0
    }
    
    func startBrowsing() {
//        print("startBrowsing()")
        serviceBrowser.startBrowsingForPeers()
        isBrowsing = true
        isHost = false
    }

    func stopBrowsing() {
//        print("stopBrowsing()")
        serviceBrowser.stopBrowsingForPeers()
        isBrowsing = false
        foundPeers.removeAll()
    }

    func startAdvertising() {
//        print("startAdvertising()")
        serviceAdvertiser.startAdvertisingPeer()
        isAdvertising = true
        isHost = true
        sessionHost = myPeerID
    }

    func stopAdvertising() {
//        print("stopAdvertising()")
        serviceAdvertiser.stopAdvertisingPeer()
        isAdvertising = false
        isHost = false
    }
    
    /* Sending Data */
    func sendCanvas(_ canvas: Canvas, to peerID: MCPeerID? = nil) {
        if let data = try? JSONEncoder().encode(canvas) {
            sendData(data, to: peerID)
        }
    }
    
    func sendAction(_ action: Action) {
        if let data = try? JSONEncoder().encode(action) {
            sendData(data)
        }
    }
    
    // helper function: send any data to all peers
    private func sendData(_ data: Data, to peerID: MCPeerID? = nil) {
        guard !connectedPeers.isEmpty else { return }
//        print("Sending data to \(connectedPeers.count) Peers ...")
        do {
            let receivers : [MCPeerID] = peerID == nil ? session.connectedPeers : [peerID!]
            try session.send(data, toPeers: receivers, with: .reliable)
//            print("\t(Sent!)")
        } catch {
//            print("\tError sending data: \(error.localizedDescription)")
        }
    }
}


extension MCSessionState {
    var name : String {
        switch self {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case.notConnected:
            return "not connected"
        @unknown default:
            return "(unknown)"
        }
    }
}
