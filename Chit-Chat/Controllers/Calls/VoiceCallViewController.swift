//
//  VoiceCallViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 22/04/2022.
//

import UIKit
import AgoraRtcKit


class VoiceCallViewController: UIViewController {

    var agoraKit: AgoraRtcEngineKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeAndJoinChannel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }

    func initializeAndJoinChannel() {
         // Pass in your App ID here
         agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "cf8f308e1fb3430e8dd8a4bbf0dcbf6e", delegate: self)

         // Join the channel with a token. Pass in your token and channel name here
         agoraKit?.joinChannel(byToken: "006cf8f308e1fb3430e8dd8a4bbf0dcbf6eIABjNdqResWhwqnusa2+oNX4o84cyO5uB2IqFLvl43LEZ5pjTicAAAAAEAB1KdkmBh5kYgEAAQAGHmRi", channelId: "Testing", info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
         })
     }

}

extension VoiceCallViewController: AgoraRtcEngineDelegate {
     func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
     }
 }
