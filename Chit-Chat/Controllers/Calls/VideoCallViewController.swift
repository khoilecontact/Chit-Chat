//
//  VideoCallViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 22/04/2022.
//

import UIKit
import AgoraRtcKit
import AgoraUIKit

class VideoCallViewController: UIViewController, AgoraRtcEngineDelegate {
    var otherUserEmail: String?
    var isCalled: Bool? = nil
    
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
            if isCalled == nil {
                CallNotificationCenter.shared.endCallCaller(to: self.otherUserEmail!, completion: { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.agoraKit.leaveChannel(nil)
                        UIApplication.shared.isIdleTimerDisabled = false
                        //self?.dismiss(animated: true)
                        self?.view.window?.rootViewController?.dismiss(animated: true)
                        
                        break
                        
                    case .failure(_):
                        let alert = UIAlertController(title: "Error", message: "There has been an error with the service! Please try again later", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self?.present(alert, animated: true)
                        
                        break
                    }
                })
            } else {
                CallNotificationCenter.shared.endCallCallee(completion: { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.agoraKit.leaveChannel(nil)
                        UIApplication.shared.isIdleTimerDisabled = false
                        //self?.dismiss(animated: true)
                        self?.view.window?.rootViewController?.dismiss(animated: true)
                        
                        break
                        
                    case .failure(_):
                        let alert = UIAlertController(title: "Error", message: "There has been an error with the service! Please try again later", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self?.present(alert, animated: true)
                        
                        break
                    }
                })
            }
            
            self.dismiss(animated: true)
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
        self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraChannel.appID, delegate: self)
        _ = SetupVideo(agoraKit: self.agoraKit)
        
        let agora = AgoraChannel()
        
        self.joinChannel = JoinChannel(self.agoraKit, agoraChannel: agora, completion: {
            self.remoteVideo = RemoteVideoView(frame: self.view.frame)
            self.localVideo = LocalVideoView()
            self.view.addSubview(self.remoteVideo)
            self.view.addSubview(self.localVideo)
            self.localVideo.addGestureRecognizer(UIPanGestureRecognizer(
                                                    target: self,
                                                    action: #selector(self.touched(_:))))
            self.localVideo.setupLocalVideo(self.agoraKit, self.remoteVideo)
        })
        
        if isCalled != nil {
            listenEndedCallCallee()
        } else {
            listenEndedCallCaller()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
               super.viewDidDisappear(animated)
               agoraKit?.leaveChannel(nil)
               AgoraRtcEngineKit.destroy()
         }
    
    func listenEndedCallCallee() {
        CallNotificationCenter.shared.listenCanceledCallCallee(completion: { [weak self] isEnded in
            if isEnded {
                self?.view.window?.rootViewController?.dismiss(animated: true)
            }
        })
    }
    
    func listenEndedCallCaller() {
        CallNotificationCenter.shared.listenCallEndedCaller(of: self.otherUserEmail!, completion: { [weak self] isEnded in
            if isEnded {
                self?.view.window?.rootViewController?.dismiss(animated: true)
            }
        })
    }
}

