//
//  Extensions.swift
//  Chit-Chat
//
//  Created by KhoiLe on 25/01/2022.
//

import Foundation
import UIKit

extension UIView {
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
}

extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //Fix this so real device can run without error
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }

}

extension String {
    func toDate(dateFormat format : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.date(from: self)
    }
}

extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)

        // This makes it left to right, default is top to bottom
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}

extension Array where Element: Any {
    static func != (left: [Element], right: [Element]) -> Bool { return !(left == right) }
    static func == (left: [Element], right: [Element]) -> Bool {
        if left.count != right.count { return false }
        var right = right
        loop: for leftValue in left {
            for (rightIndex, rightValue) in right.enumerated() where areEqual(leftValue, rightValue) {
                right.remove(at: rightIndex)
                continue loop
            }
            return false
        }
        return true
    }
}

extension Dictionary where Value: Any {
    static func != (left: [Key : Value], right: [Key : Value]) -> Bool { return !(left == right) }
    static func == (left: [Key : Value], right: [Key : Value]) -> Bool {
        if left.count != right.count { return false }
        for element in left {
            guard   let rightValue = right[element.key],
                areEqual(rightValue, element.value) else { return false }
        }
        return true
    }
}
