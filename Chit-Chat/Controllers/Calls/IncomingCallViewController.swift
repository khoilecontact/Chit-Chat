//
//  IncomingCallViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 14/05/2022.
//

import UIKit

class IncomingCallViewController: UIViewController {
    @IBOutlet var callerImage: UIImageView!
    @IBOutlet var callerName: UILabel!
    @IBOutlet var acceptCallButton: UIButton!
    @IBOutlet var denyCallButton: UIButton!
    
    var otherUserName: String?
    var otherUserEmail: String?
    var callType: String?
    private var senderPhotoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CallNotificationCenter.shared.listenCanceledCallCallee(completion: { [weak self] isEnded in
            if isEnded {
                self?.dismiss(animated: true)
            }
        })
    }
    
    func configUI() {
        guard let otherUserName = otherUserName,
              let otherUserEmail = otherUserEmail,
              let callType = callType
        else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
        let path = "images/\(safeEmail)_profile_picture.png"
        
        // fetch from DB
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            guard let strongSelf = self else {return}
            
            switch result {
            case .success(let url):
                strongSelf.senderPhotoURL = url
                DispatchQueue.main.async {
                    strongSelf.callerImage.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to fetch avatar with error: \(error) call")
            }
        })
        
        callerImage.image?.withTintColor(Appearance.tint)
        callerImage.contentMode = .scaleAspectFill
//        imageView.contentMode = .scaleToFill
        callerImage.layer.masksToBounds = true
        callerImage.layer.cornerRadius = callerImage.frame.height / 2
        callerImage.layer.borderWidth = 0
        callerImage.clipsToBounds = true
        
        self.callerName.text = "\(otherUserName) is making a \(callType) call"
    }
    
    @IBAction func acceptCallTapped(_ sender: Any) {
        guard let callType = callType else {
            return
        }

        switch callType {
        case "Audio":
            let vc = UIStoryboard(name: "VoiceCall", bundle: nil).instantiateViewController(withIdentifier: "VoiceCall") as! VoiceCallViewController
            vc.otherUserEmail = self.otherUserEmail
            vc.otherUserName = self.otherUserName
            vc.isCalled = true
            
            self.present(vc, animated: true)
            
            break
            
        case "Video":
            let vc = UIStoryboard(name: "VideoCall", bundle: nil).instantiateViewController(withIdentifier: "VideoCall") as! VideoCallViewController
            vc.otherUserEmail = self.otherUserEmail
            vc.isCalled = true
            
            self.present(vc, animated: true)
            
            break
        
        default:
            let alert = UIAlertController(title: "Error", message: "There has been an error occured! Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
            break
        }
    }
    

    @IBAction func denyCallTapped(_ sender: Any) {
        CallNotificationCenter.shared.denyIncomingCall(completion: {result in
            switch result {
            case .success(_):
                self.dismiss(animated: true)
                break
                
            case .failure(_):
                let alert = UIAlertController(title: "Error", message: "There has been an error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true)
                }))
                
                self.present(alert, animated: true)
            }
        })
    }
}
