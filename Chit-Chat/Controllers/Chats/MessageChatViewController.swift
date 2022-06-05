//
//  MessagesViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 14/02/2022.
//

import UIKit
import ChatMessageKit
import SDWebImage
import CoreLocation
import AVFoundation
import AVKit
import InputBarAccessoryView
import JGProgressHUD

class MessageChatViewController: MessagesViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail: String
    public let otherUserName: String
    private var conversationId: String?
    public var isNewConversation = false
    
    var messagePosition: Int?
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return  Sender(photo: "",
                       senderId: safeEmail,
                       displayName: "Me")
        
    }
    
    private var otherUserAvatar: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        //        img.layer.borderWidth = 2.5
        //        let gradient = UIImage.gradientImage(bounds: img.bounds, colors: [.systemBlue, .systemRed])
        //        let gradientColor = UIColor(patternImage: gradient)
        //        // img.layer.borderColor = UIColor.systemBlue.cgColor
        //        img.layer.borderColor = gradientColor.cgColor
        img.layer.masksToBounds = true
        img.layer.cornerRadius = 15
        img.clipsToBounds = true
        return img
    }()
    
    private func listenForMessagees(id: String, shouldScrollToBottom: Bool) {
        
        self.spinner.show(in: view)
        
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            guard let strongSelf = self else {return}
            
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                
                strongSelf.messages = messages
                
                DispatchQueue.main.async {
                    self?.isNewConversation = false
                    
                    self?.spinner.dismiss()
                    
                    strongSelf.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    // open conversastion
                    if self?.messagePosition != nil, let position = self?.messagePosition {
                        strongSelf.messagesCollectionView.scrollToItem(at: IndexPath(item: 0, section: position) , at: .centeredVertically, animated: true)
                    }
                    else if shouldScrollToBottom {
                        strongSelf.messagesCollectionView.scrollToLastItem()
                    }
                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    self?.isNewConversation = true
                }
                print("Failed to load messages for conversation: \(error)")
            }
        })
    }
    
    init(with email: String, name: String, id: String?, messagePosition: Int? = nil) {
        self.conversationId = id
        self.otherUserEmail = email
        self.otherUserName = name
        self.messagePosition = messagePosition
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        
        // MARK: - Setup Messages
        // fakeData()
        
        // MARK: - Message Delegate
        messageDelegate()
        configureMessageInputBar()
        setupInputButton()
        stylingpInputBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let conversationId = conversationId {
            listenForMessagees(id: conversationId, shouldScrollToBottom: true)
        } else {
            self.isNewConversation = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        configurateAvatarUserOnNavBar()
        super.viewDidLayoutSubviews()
    }
    
    func navBar() {
        
        addLeftBarButtonItems()
        addRightBarButtonItems()
    }
    
    func addLeftBarButtonItems() {
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward")?.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backBtnTapped))
        
        // let otherBtn = UIBarButtonItem(image: otherUserAvatar.image, style: .plain, target: nil, action: nil)
        let otherBtn = UIBarButtonItem(customView: otherUserAvatar)
        
        navigationItem.leftBarButtonItems = [backItem, otherBtn]
    }
    
    func addRightBarButtonItems()
    {
        let btnContact = UIButton.init(type: .custom)
        let contactIcon = resizeImage(image: (UIImage(systemName: "phone.fill")?.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal))!, targetSize: CGSize(width: 22, height: 22))
        btnContact.setImage(contactIcon, for: .normal)
        btnContact.addTarget(self, action: #selector(contactBtnTapped), for: .touchUpInside)
        
        let btnMenu = UIButton.init(type: .custom)
        let menuIcon = resizeImage(image: (UIImage(systemName: "ellipsis.circle")?.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal))!, targetSize: CGSize(width: 22, height: 22))
        btnMenu.setImage(menuIcon, for: .normal)
        btnMenu.addTarget(self, action: #selector(menuBtnTapped), for: .touchUpInside)
        
        let stackview = UIStackView.init(arrangedSubviews: [btnContact, btnMenu])
        stackview.distribution = .equalSpacing
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.spacing = 10
        
        let rightBarButton = UIBarButtonItem(customView: stackview)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func configurateAvatarUserOnNavBar() {
        otherUserAvatar.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        
        // bright purple: 191, 64, 191
        let gradient = UIImage.gradientImage(bounds: otherUserAvatar.bounds, colors: [.systemPink, .systemYellow, .systemYellow, UIColor(red: 191/255, green: 64/255, blue: 191/255, alpha: 1), .systemPurple, .purple])
        let gradientColor = UIColor(patternImage: gradient)
        otherUserAvatar.layer.borderWidth = 2.5
        otherUserAvatar.layer.borderColor = gradientColor.cgColor
    }
    
    func messageDelegate() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
    }
    
//    func fakeData() {
//        var otherSender = Sender(photo: "", senderId: "other", displayName: "Swift")
//        messages.append(Message(sender: selfSender!,
//                                messageId: "1",
//                                sentDate: Date(),
//                                kind: .text("Hello World")))
//
//        messages.append(Message(sender: otherSender,
//                                messageId: "2",
//                                sentDate: Date(),
//                                kind: .text("This is a conversation from someone who dont like coding")))
//    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            guard let strongSelf = self else {return}
            
            strongSelf.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    func configureMessageInputBar() {
          
         messageInputBar.isTranslucent = false
         messageInputBar.separatorLine.isHidden = true
         messageInputBar.inputTextView.tintColor = .black
        messageInputBar.inputTextView.backgroundColor = GeneralSettings.primaryColor
         // messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
         messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 36)
         messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 36)
         // messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
         // messageInputBar.inputTextView.layer.borderWidth = 1.0
         messageInputBar.inputTextView.layer.cornerRadius = 16.0
         messageInputBar.inputTextView.layer.masksToBounds = true
         messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
         configureInputBarItems()
     }
    
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 2, bottom: 0, right: 2)
        
        messageInputBar.sendButton.setSize(CGSize(width: 80, height: 40), animated: false)
        
        messageInputBar.sendButton.image = resizeImage(image: (UIImage(systemName: "paperplane.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal))!, targetSize: CGSize(width: 24, height: 24))
        
        messageInputBar.sendButton.title = nil
        
        messageInputBar.middleContentViewPadding.right = -38
        
        //        let charCountButton = InputBarButtonItem()
        //            .configure {
        //                $0.title = "0/140"
        //                $0.contentHorizontalAlignment = .right
        //                $0.setTitleColor(UIColor.black, for: .normal)
        //                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        //                $0.setSize(CGSize(width: 50, height: 25), animated: false)
        //            }.onTextViewDidChange { (item, textView) in
        //                item.title = "\(textView.text.count)/140"
        //                let isOverLimit = textView.text.count > 140
        //                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
        //                if isOverLimit {
        //                    item.inputBarAccessoryView?.sendButton.isEnabled = false
        //                }
        //                let color = isOverLimit ? .red : UIColor.black
        //                item.setTitleColor(color, for: .normal)
        //            }
        //        let bottomItems = [.flexibleSpace, charCountButton]
        //        messageInputBar.middleContentViewPadding.bottom = 8
        //        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .none
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    // 38, 37, 37
                    item.imageView?.backgroundColor = .none
                })
            }
    }
    
    private func stylingpInputBar() {
        //        messageInputBar.inputTextView.becomeFirstResponder()
        
        messageInputBar.inputTextView.placeholder = "  Type messages ..."
        messageInputBar.inputTextView.placeholderTextColor = .black
        
        messageInputBar.backgroundView.backgroundColor = GeneralSettings.primaryColor
        
        messageInputBar.backgroundView.layer.cornerRadius = 16
        
        messageInputBar.backgroundView.layer.masksToBounds = true
        
        // Entire InputBar padding
        messageInputBar.padding.top = 6
        messageInputBar.padding.bottom = 0
        
        // send btn padding
        //        messageInputBar.sendButton.inputBarAccessoryView?.padding.top = 15
        //        messageInputBar.sendButton.inputBarAccessoryView?.padding.bottom = 0
        //        messageInputBar.sendButton.inputBarAccessoryView?.padding.right = 20
        
        // or MiddleContentView padding
        messageInputBar.middleContentViewPadding.top = 6
        messageInputBar.middleContentViewPadding.bottom = 2
        
        // or InputTextView padding
        messageInputBar.inputTextView.textContainerInset.top = 6
        messageInputBar.inputTextView.textContainerInset.bottom = 0
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            strongSelf.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            strongSelf.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
            //
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            // present location picker
            strongSelf.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = ({ [weak self] selectedCoordinates in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let messageId = strongSelf.createMessageId(),
                  let conversationId = strongSelf.conversationId,
                  let name = strongSelf.title,
                  let selfSender = strongSelf.selfSender else {
                      return
                  }
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                    size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    print("sent location message")
                }
                else {
                    print("failed to send location message")
                }
            })
        })
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach photo from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            
            let picker = UIImagePickerController()
            
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            strongSelf.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            
            let picker = UIImagePickerController()
            
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            strongSelf.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "Where would you like to attach video from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            
            let picker = UIImagePickerController()
            
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            strongSelf.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            
            let picker = UIImagePickerController()
            
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            strongSelf.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    @objc func contactBtnTapped() {
        let vc = SelectCallViewController(otherUserName: otherUserName, otherUserEmail: otherUserEmail, conversationId: conversationId!)
        vc.definesPresentationContext = true
//        vc.modalPresentationStyle = .popover
//        vc.modalTransitionStyle = .crossDissolve
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 4
        vc.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.present(vc, animated: true)
    }
    
    @objc func menuBtnTapped() {
        if conversationId != nil {
            let vc = UtilitiesMessageChatViewController(name: otherUserName, email: otherUserEmail, conversationId: conversationId!)
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @objc func backBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension MessageChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let name = title,
              let selfSender = selfSender else {
                  return
              }
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            // upload Image
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    // send message
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        if success {
                            print("sent photo message")
                        }
                        else {
                            print("failed to send photo message")
                        }
                        
                    })
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
            })
            // ---
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            // upload Video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    // send message
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        if success {
                            print("sent photo message")
                        }
                        else {
                            print("failed to send photo message")
                        }
                        
                    })
                case .failure(let error):
                    print("message video upload error: \(error)")
                }
            })
            // ---
        }
        
        
        
        // Send image
        
    }
}

extension MessageChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = selfSender,
              let messageId = createMessageId() else {
                  return
              }
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        if isNewConversation {
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: title ?? "User", firstMessage: message, completion: { [weak self] success in
                
                guard let strongSelf = self else {return}
                
                if success {
                    print("Message sent")
                    strongSelf.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    strongSelf.conversationId = newConversationId
                    strongSelf.listenForMessagees(id: newConversationId, shouldScrollToBottom: true)
                    strongSelf.messageInputBar.inputTextView.text = nil
                }
                else {
                    print("Failed to send")
                }
            })
        }
        else {
            guard let conversationId = conversationId,
                  let name = title else {
                      return
                  }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                
                guard let strongSelf = self else {return}
                
                if success {
                    strongSelf.messageInputBar.inputTextView.text = nil
                    print("message sent")
                }
                else {
                    print("Failed to send")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        return newIdentifier
    }
}

extension MessageChatViewController: MessagesLayoutDelegate, MessagesDataSource, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // our message that we've sent
            return .systemGreen
        }
        
        // anything else
        return .lightGray
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            // our image
            if let currentUserImageURL = senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            }
            else {
                // ${safeEmail}_profile_picture.png
                
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch from DB
                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                    guard let strongSelf = self else {return}
                    
                    switch result {
                    case .success(let url):
                        strongSelf.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("Failed to fetch avatar with error: \(error)")
                    }
                })
                
            }
        }
        else {
            // other user
            if let otherUserImageURL = otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserImageURL, completed: nil)
                // otherUserAvatar.sd_setImage(with: otherUserImageURL, placeholderImage: resizeImage(image: UIImage(systemName: "person.crop.circle")!, targetSize: CGSize(width: 30, height: 30)))
                otherUserAvatar.sd_setImage(with: otherUserImageURL, placeholderImage: nil, context: [.imageTransformer: SDImageResizingTransformer(size: CGSize(width: 30, height: 30), scaleMode: .fill)])
            }
            else {
                // ${safeOtherEmail}_profile_picture.png
                
                let email = otherUserEmail
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch from DB
                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                    guard let strongSelf = self else {return}
                    
                    switch result {
                    case .success(let url):
                        strongSelf.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                            // strongSelf.otherUserAvatar.sd_setImage(with: url, placeholderImage: resizeImage(image: UIImage(systemName: "person.crop.circle")!, targetSize: CGSize(width: 30, height: 30)))
                            strongSelf.otherUserAvatar.sd_setImage(with: url, placeholderImage: nil, context: [.imageTransformer: SDImageResizingTransformer(size: CGSize(width: 30, height: 30), scaleMode: .fill)])
                        }
                    case .failure(let error):
                        print("Failed to fetch avatar with error: \(error)")
                    }
                })
            }
        }
        
    }
}

extension MessageChatViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            
            let vc = LocationPickerViewController(coordinates: coordinates)
            vc.title = "Location"
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            
            let vc = PhotoViewerViewController(with: imageUrl)
            
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
    
    func didTapCalling(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .audioCall(_):
            guard let conversationId = self.conversationId
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
                        let alert = UIAlertController(title: "Busy", message: "\(String(describing: self?.otherUserName)) is in another call", preferredStyle: .alert)
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
            break
        case .videoCall(_):
            guard let conversationId = self.conversationId
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
            break
        default:
            break
        }
    }
}

//extension MessageChatViewController: UIViewControllerTransitioningDelegate {
//
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return PresentTransition()
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return DismissTransition()
//    }
//}
