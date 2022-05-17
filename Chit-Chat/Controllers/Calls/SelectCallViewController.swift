//
//  SelectCallViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 10/05/2022.
//

import UIKit

class SelectCallViewController: UIViewController {
    var otherUserName: String?
    var otherUserEmail: String?
    var conversationId: String?
    var type: String?
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 5
        
        scrollView.backgroundColor = .systemBackground
        
        scrollView.clipsToBounds = true
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight)
        scrollView.layer.cornerRadius = 15
        return scrollView
    }()
    
    let voiceButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(systemName: "phone.fill")?.sd_resizedImage(with: CGSize(width: 50, height: 50), scaleMode: .aspectFit)?.withTintColor(.systemBlue)
        
        button.setImage(buttonImage, for: .normal)
        button.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    let videoButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(systemName: "video.fill")?.sd_resizedImage(with: CGSize(width: 50, height: 50), scaleMode: .aspectFit)?.withTintColor(.systemBlue)
        
        button.setImage(buttonImage, for: .normal)
        button.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear
        
        voiceButton.addTarget(self, action: #selector(voiceCallTapped), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(videoCallTapped), for: .touchUpInside)
            
        view.addSubview(scrollView)
        scrollView.addSubview(voiceButton)
        scrollView.addSubview(videoButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 5
        scrollView.frame = CGRect(x: 0, y: view.bottom - screenHeight, width: screenWidth, height: screenHeight)
        let size = view.width / 4
        
        voiceButton.frame = CGRect(x: screenWidth / 5, y: 30, width: size, height: size)
        videoButton.frame = CGRect(x: voiceButton.right + 40, y: 30, width: size, height: size)
    }
    
    init(otherUserName: String, otherUserEmail: String, conversationId: String) {
        super.init(nibName: nil, bundle: nil)
        self.otherUserName = otherUserName
        self.otherUserEmail = otherUserEmail
        self.conversationId = conversationId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func voiceCallTapped() {
        guard let otherUserName = self.otherUserName,
        let otherUserEmail = self.otherUserEmail,
        let conversationId = self.conversationId
        else {
            let alert = UIAlertController(title: "Error", message: "There has been an error with the service! Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(alert, animated: true)
            
            return
        }
        
        CallNotificationCenter.shared.sendCallNotification(to: otherUserEmail, calleeName: otherUserName, conversationId: conversationId, isAudio: true, completion: { [weak self] result in
            switch result {
            case .success(_):
                let vc = UIStoryboard(name: "VoiceCall", bundle: nil).instantiateViewController(withIdentifier: "VoiceCall") as! VoiceCallViewController
                vc.otherUserEmail = self?.otherUserEmail
                vc.otherUserName = self?.otherUserName
                
                self?.present(vc, animated: true)
                
                break
                
            case .failure(let error):
                if error as! CallNotificationCenter.CallError == CallNotificationCenter.CallError.userIsInAnotherCall {
                    let alert = UIAlertController(title: "Busy", message: "\(otherUserName) is in another call", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self?.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Error", message: "There has been an error with the service! Please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self?.present(alert, animated: true)
                }
                                
                break
            }
        })
        
    }
    
    @objc func videoCallTapped() {
        guard let otherUserName = self.otherUserName,
        let otherUserEmail = self.otherUserEmail,
        let conversationId = self.conversationId
        else {
            let alert = UIAlertController(title: "Error", message: "There has been an error with the service! Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(alert, animated: true)
            
            return
        }
        
        CallNotificationCenter.shared.sendCallNotification(to: otherUserEmail, calleeName: otherUserName, conversationId: conversationId, isAudio: false, completion: { [weak self] result in
            switch result {
            case .success(_):
                let vc = UIStoryboard(name: "VideoCall", bundle: nil).instantiateViewController(withIdentifier: "VideoCall") as! VideoCallViewController
                vc.otherUserEmail = self?.otherUserEmail
                
                self?.present(vc, animated: true)
                
                break
                
            case .failure(_):
                let alert = UIAlertController(title: "Error", message: "There has been an error with the service! Please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self?.present(alert, animated: true)
                
                break
            }
        })
    }
   

}
