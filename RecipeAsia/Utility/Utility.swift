//
//  Utility.swift
//  RecipeAsia
//
//  Created by Shikha Sharma on 2/21/20.
//  Copyright © 2020 Shikha Sharma. All rights reserved.
//


import UIKit

// MARK: Utility
class Utility {
    
    // MARK:- Function to make characters of label text bold and big if under range
    static func attributedString(from string: String, boldRange: NSRange?) -> NSAttributedString {
        let attrs = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor : UIColor(red: 0 / 255.0, green: 164 / 255.0, blue: 241 / 255.0, alpha: 1.0)
            
        ]
        let nonBoldAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)
            ] as [NSAttributedString.Key : Any]
        let attrStr = NSMutableAttributedString(string: string.replacingOccurrences(of: ".", with: ","), attributes: nonBoldAttribute)
        if let range = boldRange {
            attrStr.setAttributes(attrs, range: range)
        }
        return attrStr
    }
    
}


// MARK: IBInspectable Extension
extension UIView {
    @IBInspectable
    // MARK: View Corner Radius
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    // MARK: View Border width
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    // MARK: View Border Color
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    // MARK: View Radius Shadow
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    // MARK: View Radius Opacity
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    // MARK: View Shadown offset
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    // MARK: View Shadow color
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

