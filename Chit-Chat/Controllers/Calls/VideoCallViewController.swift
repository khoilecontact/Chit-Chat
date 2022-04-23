//
//  VideoCallViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 22/04/2022.
//

import UIKit
import AgoraRtcKit
import AgoraUIKit

//class VideoCallViewController: UIViewController {
//
//    var localView: UIView!
//    var remoteView: UIView!
//
//    // Server intergration
//    var agoraKit: AgoraRtcEngineKit?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        initView()
//
////        initializeAndJoinChannel()
//
//        let agView = AgoraVideoViewer(connectionData: AgoraConnectionData(appId: "cf8f308e1fb3430e8dd8a4bbf0dcbf6e", appToken: "c5165f9e86314a33bc5c3ce976472c81"))
//        agView.fills(view: self.view)
//        agView.join(channel: "Testing", as: .broadcaster)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
////        remoteView.frame = self.view.bounds
////        localView.frame = CGRect(x: self.view.bounds.width - 90, y: 0, width: 90, height: 160)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//           super.viewDidDisappear(animated)
//           agoraKit?.leaveChannel(nil)
//           AgoraRtcEngineKit.destroy()
//     }
//
//    func initView() {
//        remoteView = UIView()
//        self.view.addSubview(remoteView)
//        localView = UIView()
//        self.view.addSubview(localView)
//
//    }
//
//    func initializeAndJoinChannel() {
//        // Pass in your App ID here
//        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "cf8f308e1fb3430e8dd8a4bbf0dcbf6e", delegate: self)
//        // Video is disabled by default. You need to call enableVideo to start a video stream.
//        agoraKit?.enableVideo()
//        // Create a videoCanvas to render the local video
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.uid = 0
//        videoCanvas.renderMode = .hidden
//        videoCanvas.view = localView
//        agoraKit?.setupLocalVideo(videoCanvas)
//
//        // Join the channel with a token. Pass in your token and channel name here
//        agoraKit?.joinChannel(byToken: "006cf8f308e1fb3430e8dd8a4bbf0dcbf6eIABjNdqResWhwqnusa2+oNX4o84cyO5uB2IqFLvl43LEZ5pjTicAAAAAEAB1KdkmBh5kYgEAAQAGHmRi", channelId: "Testing", info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
//        })
//    }
//
//}
//
//extension VideoCallViewController: AgoraRtcEngineDelegate {
//     // This callback is triggered when a remote user joins the channel
//     func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
//         let videoCanvas = AgoraRtcVideoCanvas()
//         videoCanvas.uid = uid
//         videoCanvas.renderMode = .hidden
//         videoCanvas.view = remoteView
//         agoraKit?.setupRemoteVideo(videoCanvas)
//     }
// }

class VideoCallViewController: UIViewController {
    @IBOutlet var micButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.agoraKit.switchCamera()
    }
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        micButton.isHidden.toggle()
        cameraButton.isHidden.toggle()
        if sender.isSelected {
            agoraKit.leaveChannel(nil)
            UIApplication.shared.isIdleTimerDisabled = false
        } else {
            self.joinChannel.connect()
        }
    }
        
    fileprivate(set) var agoraKit: AgoraRtcEngineKit!
    fileprivate(set) var remoteVideo: RemoteVideoView!
    fileprivate(set) var localVideo: LocalVideoView!
    fileprivate(set) var joinChannel: JoinChannel!
    
    internal var beginLocation: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: API.appID, delegate: self)
        _ = SetupVideo(agoraKit: self.agoraKit)
        
//        initializeAndJoinChannel()
        
        self.joinChannel = JoinChannel(self.agoraKit, completion: {
            self.remoteVideo = RemoteVideoView(frame: self.view.frame)
            self.localVideo = LocalVideoView()
            self.view.addSubview(self.remoteVideo)
            self.view.addSubview(self.localVideo)
            self.localVideo.addGestureRecognizer(UIPanGestureRecognizer(
                                                    target: self,
                                                    action: #selector(self.touched(_:))))
            self.localVideo.setupLocalVideo(self.agoraKit, self.remoteVideo)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
               super.viewDidDisappear(animated)
               agoraKit?.leaveChannel(nil)
               AgoraRtcEngineKit.destroy()
         }
}

