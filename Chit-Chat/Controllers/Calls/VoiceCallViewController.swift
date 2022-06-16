//
//  VoiceCallViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 22/04/2022.
//

import UIKit
import AgoraRtcKit
import AgoraUIKit
import AgoraRtmKit

class VoiceCallViewController: UIViewController, AgoraRtmDelegate {
    var agoraKit: AgoraRtcEngineKit!
    var otherUserEmail: String?
    var otherUserName: String?
    var isCalled: Bool? = nil
    
    @IBOutlet var otherAvatar: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var micButton: UIButton!
    @IBOutlet var speakerButton: UIButton!
    
    @IBAction func didClickSpeakerButton(_ sender: UIButton) {
        if sender.isSelected {
            SetSessionPlayerOff()
            speakerButton.setImage(UIImage(named: "speakerSmall"), for: .normal)
        } else {
            SetSessionPlayerOn()
            speakerButton.setImage(UIImage(named: "speaker"), for: .normal)
        }
        
        sender.isSelected.toggle()
        
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.agoraKit.muteLocalAudioStream(sender.isSelected)
    }

    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        micButton.isHidden.toggle()
        if sender.isSelected {
            if isCalled == nil {
                CallNotificationCenter.shared.endCallCaller(to: self.otherUserEmail!, completion: { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.agoraKit.leaveChannel(nil)
                        UIApplication.shared.isIdleTimerDisabled = false
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
                CallNotificationCenter.shared.endCallCallee( completion: { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.agoraKit.leaveChannel(nil)
                        UIApplication.shared.isIdleTimerDisabled = false
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
            
            
        } else {
            initializeAndJoinChannel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        initializeAndJoinChannel()
        SetSessionPlayerOff()
        
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
    
    
    
    func configView() {
        if otherUserEmail == nil {
            otherAvatar.image = UIImage(systemName: "person.circle")
        } else {
            let safeEmail = DatabaseManager.safeEmail(emailAddress: self.otherUserEmail!)
            let fileName = safeEmail + "_profile_picture.png"
            let path = "images/" + fileName
            
            StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                switch result {
                case .failure(let error):
                    print("Failed to download image URL: \(error)")
                    self?.otherAvatar.image = UIImage(systemName: "person.circle")?.withTintColor(Appearance.tint)
                    
                    break
                
                case .success(let url):
                    DispatchQueue.main.async {
                        self?.otherAvatar.sd_setImage(with: url, completed: nil)
                    }
                    break
                }
            })
            
            if otherUserName == nil {
                nameLabel.text = "Unknown User"
            } else {
                nameLabel.text = self.otherUserName
            }
        }
        
        otherAvatar.image?.withTintColor(Appearance.tint)
        otherAvatar.contentMode = .scaleAspectFill
        otherAvatar.layer.masksToBounds = true
        otherAvatar.layer.cornerRadius = otherAvatar.frame.height / 2
        otherAvatar.layer.borderWidth = 0
        otherAvatar.clipsToBounds = true
        
        
    }

    func initializeAndJoinChannel() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraChannel.appID, delegate: self)
        
        let agora = AgoraChannel()
        
        let joinChannel = JoinChannel(self.agoraKit, agoraChannel: agora, completion: {})

        let email = UserDefaults.standard.value(forKey: "email")
        let agoraRTM = AgoraRtmKit(appId: AgoraChannel.appID, delegate: self)
        
        
        agoraRTM?.login(byToken: AgoraChannel.token, user: email as! String, completion: { err in
            print("RTM login failed: \(err)")
        })

        
        AgoraChannel.shared.createChannel(completion: { result in
            switch result {
            case .failure(_):
                print("Error in creating new channel")
                break
            
            case .success(_):
                DispatchQueue.main.async {
                    joinChannel.connect()
                }
                
            }
        })
       
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
    
    func SetSessionPlayerOn()
    {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch _ {
        }
    }
    
    func SetSessionPlayerOff()
    {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }

}


extension VoiceCallViewController: AgoraRtcEngineDelegate {
     func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
     }
}

