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
            agoraKit.leaveChannel(nil)
            UIApplication.shared.isIdleTimerDisabled = false
            self.dismiss(animated: true)
        } else {
            initializeAndJoinChannel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        initializeAndJoinChannel()
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
                    self?.otherAvatar.sd_setImage(with: url, completed: nil)
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
//        imageView.contentMode = .scaleToFill
        otherAvatar.layer.masksToBounds = true
        otherAvatar.layer.cornerRadius = otherAvatar.frame.height / 2
        otherAvatar.layer.borderWidth = 0
        otherAvatar.clipsToBounds = true
        
        
    }

    func initializeAndJoinChannel() {
         // Pass in your App ID here
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: API.appID, delegate: self)
        
        let agora = AgoraChannel()
        
        let joinChannel = JoinChannel(self.agoraKit, agoraChannel: agora, completion: {})

        let email = UserDefaults.standard.value(forKey: "email")
        let agoraRTM = AgoraRtmKit(appId: AgoraChannel.appID, delegate: self)
        
        agoraRTM?.login(byToken: AgoraChannel.token, user: email as! String, completion: { err in
            
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
