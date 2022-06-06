//
//  GeneralSettings.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 03/05/2022.
//

import Foundation
import UIKit

final class GeneralSettings {
    public static let shared = GeneralSettings()
    
}

// MARK: - Color
extension GeneralSettings {
    public static let primaryColor: UIColor = UIColor(red: 108/255, green: 164/255, blue: 212/255, alpha: 1)
    public static let secondaryColor: UIColor = UIColor(red: 41/255, green: 50/255, blue: 65/255, alpha: 1)    // #293241 41, 50, 65
}

// MARK: - URL String
extension GeneralSettings {
    public static let databaseUrl: String = "https://chit-chat-fc877-default-rtdb.asia-southeast1.firebasedatabase.app"
    public static let nestServiceUrl: String = "https://chit-chat-services.herokuapp.com"
}

// MARK: - String
extension GeneralSettings {
    public static let appName: String = "Chit Chat"
    public static let slogan: String = ""
}

// MARK: - Style Values
extension GeneralSettings {
    public static let borderRadiusButton: Float = 15
    public static let borderRadiusLabel: Float = 15
    public static let borderRadiusImage: Float = 15
}
