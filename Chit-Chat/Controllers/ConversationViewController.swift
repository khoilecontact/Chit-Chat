//
//  ConversationViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 03/02/2022.
//

import UIKit

class ConversationViewController: UIViewController {
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        //Fix this so real device can run without error
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
