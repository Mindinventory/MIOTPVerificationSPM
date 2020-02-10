//
//  OTPTextField.swift
//  OTPDemo
//
//  Created by mac-00015 on 24/01/20.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import UIKit

class OTPTextField: UITextField {
    
    /// Border color info for field
    var borderColor: UIColor = .lightGray
    
    /// Border width info for field
    var borderWidth: CGFloat = 1
    
    var shapeLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initalizeUI(forFieldType type: OTPView.DisplayType, placeholderText: String, borderColor: UIColor, placeholderColor: UIColor) {
        
        self.borderColor = borderColor
        if #available(iOS 12.0, *) {
            self.textContentType = .oneTimeCode
        }
        
        switch type {
        case .round:
            layer.cornerRadius = bounds.size.width / 2
        case .box:
            layer.cornerRadius = 0
        default:
            addBottomView()
        }
        
        let imageAttachment = NSTextAttachment(data: nil, ofType: nil)
        let origImage = UIImage(named: placeholderText)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            imageAttachment.image = tintedImage
        } else {
            imageAttachment.image = tintedImage?.imageWithColor(color: placeholderColor)
        }
        let strFinal = NSAttributedString(attachment: imageAttachment)
        let attributedText = NSMutableAttributedString(attributedString: strFinal)
        if #available(iOS 13.0, *) {
            attributedText.addAttributes([NSAttributedString.Key.foregroundColor: placeholderColor], range: NSMakeRange(0, attributedText.length))
        }
        self.attributedPlaceholder = attributedText
        
        if type == .box || type == .round {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
        }
        
        autocorrectionType = .no
        textAlignment = .center
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        _ = delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: "")
    }
    
    // Helper function to create a underlined bottom view
    func addBottomView() {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.size.height))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        path.close()
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = borderWidth
        shapeLayer.fillColor = backgroundColor?.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        
        layer.addSublayer(shapeLayer)
    }
}
