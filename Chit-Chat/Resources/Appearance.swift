//
//  Appearance.swift
//  Chit-Chat
//
//  Created by KhoiLe on 18/02/2022.
//

import Foundation
import UIKit

public class Appearance {
    public static var tint: UIColor = {
        if #available(iOS 13, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        /// Return the color for Dark Mode
                        return UIColor.white
                    } else {
                        /// Return the color for Light Mode
                        return UIColor.black
                    }
                }
            } else {
                /// Return a fallback color for iOS 12 and lower.
                return UIColor.black
            }
    }()
    
    public static var system: UIColor = {
        if #available(iOS 13, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        /// Return the color for Dark Mode
                        return UIColor.black
                    } else {
                        /// Return the color for Light Mode
                        return UIColor.white
                    }
                }
            } else {
                /// Return a fallback color for iOS 12 and lower.
                return UIColor.black
            }
    }()
    
    public static var appColor: UIColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
}
