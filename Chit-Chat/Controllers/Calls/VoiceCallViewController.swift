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
    
    @IBOutlet var otherAvatar: UIImageView!
    @IBOutlet var micButton: UIButton!
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
            let safeEmail = DatabaseManager.safeEmail(emailAddress: self.otherUserEmail as! String)
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
         agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "cf8f308e1fb3430e8dd8a4bbf0dcbf6e", delegate: self)

        let email = UserDefaults.standard.value(forKey: "email")
        let agoraRTM = AgoraRtmKit(appId: "cf8f308e1fb3430e8dd8a4bbf0dcbf6e", delegate: self)
        
        agoraRTM?.login(byToken: "c5165f9e86314a33bc5c3ce976472c81", user: email as! String, completion: { err in
            
        })
        
        let lobbyChannel = agoraRTM?.createChannel(withId: "lobby", delegate: nil)
        
         // Join the channel with a token. Pass in your token and channel name here
         agoraKit?.joinChannel(byToken: "006cf8f308e1fb3430e8dd8a4bbf0dcbf6eIABjNdqResWhwqnusa2+oNX4o84cyO5uB2IqFLvl43LEZ5pjTicAAAAAEAB1KdkmBh5kYgEAAQAGHmRi", channelId: "Testing", info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
         })
     }

}



extension VoiceCallViewController: AgoraRtcEngineDelegate {
     func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
     }
 }
