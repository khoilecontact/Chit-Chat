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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
