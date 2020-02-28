//
//  OTPView.swift
//  OTPDemo
//
//  Created by mac-00015 on 24/01/20.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import UIKit

public protocol OTPViewDelegate: class {
    
    /// Called whenever the textfield has to become first responder. Called for the first field when loading
    ///
    /// - Parameter index: the index of the field.
    /// - Returns: return true to show keyboard
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool
    
    /// Called whenever all the OTP fields have been entered. It'll be called immediately after `hasEnteredAllOTP` delegate method is called.
    ///
    /// - Parameter otpString: The entered otp characters
    func enteredOTP(otpString: String)
    
    /// Called whenever an OTP is entered.
    ///
    /// - Parameter hasEntered: `hasEntered` will be `true` if all the OTP fields have been filled.
    /// - Returns: return if OTP entered is valid or not. If false and all otp has been entered, then error.
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool
}

open class OTPView: UIView {

    /// Different display type for text fields.
    public enum DisplayType {
        case box
        case underlined
        case round
    }
    
    /// Different input type for OTP fields.
    public enum KeyboardType: Int {
        case numeric
        case alphabet
        case alphaNumeric
    }
    
    public enum SecureEntryDisplayType: String {
        case dot = "ic_dot"
        case star = "ic_star"
        case none = ""
    }
    
    /// Define the display type for OTP fields.
    open var otpFieldDisplayType: DisplayType = .underlined
    
    /// Defines the number of OTP field needed.
    @IBInspectable
    open var fieldsCount: Int = 4
    
    /// Defines the type of the data that can be entered into OTP fields.
    
    open var fieldInputType: KeyboardType = .numeric
    
    /// Define the font to be used to OTP field.
    @IBInspectable
    open var fieldFont: UIFont = UIFont.systemFont(ofSize: 20)
    
    /// For secure OTP entry set it to `true`.
    @IBInspectable
    open var isSecureEntry: Bool = false
    
    /// If set to `false`, the blinking cursor for OTP field will not be visible. Defaults to `true`.
    @IBInspectable
    open var requireCursor: Bool = true
    
    /// For setting cursor color, if `requireCursor` is set to true.
    @IBInspectable
    open var cursorColor: UIColor = .black
    
    /// Defines the size of OTP field.
    @IBInspectable
    open var fieldSize: CGFloat = 500
    
    /// Space between 2 OTP field.
    @IBInspectable
    open var separatorSpace: CGFloat = 16
    
    /// For setting border width.
    @IBInspectable
    open var borderWidth: CGFloat = 2
    
    /// If set, then editing can be done to intermediate fields even though previous fields are empty. Else editing will take place from last filled text field only.
    @IBInspectable
    open var shouldAllowIntermediateEditing: Bool = false
    
    /// Set this value if a background color is needed when a text is not enetered in the OTP field.
    @IBInspectable
    open var emptyFieldBackgroundColor: UIColor = .clear
    
    /// Set this value if a background color is needed when a text is enetered in the OTP field.
    @IBInspectable
    open var enteredFieldBackgroundColor: UIColor = .clear
    
    /// Set this value if a border color is needed when a text is not enetered in the OTP field.
    @IBInspectable
    open var emptyFieldBorderColor: UIColor = .black
    
    /// Set this value if a border color is needed when a text is enetered in the OTP field.
    @IBInspectable
    open var enteredFieldBorderColor: UIColor = .black
    
    /// Optional value if a border color is needed when the otp entered is invalid/incorrect.
    @IBInspectable
    open var errorBorderColor: UIColor?
    
    /// Value for number of writed otp textField
    @IBInspectable
    open private(set) var numberOfEnteredField = 0
    
    /// For desplaying sybols for secure text entry
    open var secureEntrySymbol: SecureEntryDisplayType = .star
    
    /// Color for secureEntry symbol
    @IBInspectable
    open var secureEntrySymbolColor: UIColor = UIColor(red: 236/255, green: 43/255, blue: 78/255, alpha: 1.0)
    
    /// Placeholder for text field
    open var txtPlaceholder: SecureEntryDisplayType = .star
    
    /// Placeholder Color
    @IBInspectable
    open var placeholderColor: UIColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    
    /// Text Color for text field
    @IBInspectable
    open var textColor: UIColor = .black
    
    open weak var delegate: OTPViewDelegate?
    
    fileprivate var enteredOTP = [String]()
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK:- Initialization and Helper methods -
extension OTPView {
    
    /// Call this method to create the OTP field view. This method should be called at the last after necessary customization needed. If any property is modified at a later stage is simply ignored.
    open func initializeOTPUI() {
        
        layer.masksToBounds = true
        layoutIfNeeded()
        
        initializeOTPFields()
    }
    
    // Set up the fields
    fileprivate func initializeOTPFields() {
        
        enteredOTP.removeAll()
        
        for index in stride(from: 0, to: fieldsCount, by: 1) {
            
            let oldOtpField = viewWithTag(index + 1) as? OTPTextField
            oldOtpField?.removeFromSuperview()
            
            let otpField = getOTPField(forIndex: index)
            otpField.adjustsFontSizeToFitWidth = true
            otpField.minimumFontSize = 8
            let lblStr = UILabel(frame: otpField.frame)
            lblStr.tag = otpField.tag + fieldsCount
            addSubview(lblStr)
            addSubview(otpField)
            
            enteredOTP.append("")
        }
    }
    
    // Initalize the required OTP fields
    fileprivate func getOTPField(forIndex index: Int) -> OTPTextField {
        
        let hasOddNumberOfFields = (fieldsCount % 2 == 1)
        let txtWidth = (self.frame.width / CGFloat(fieldsCount)) - separatorSpace
        if fieldSize > self.frame.height {
            fieldSize = self.frame.height
        }
        if txtWidth < fieldSize {
            fieldSize = txtWidth
        }
        var fieldFrame = CGRect(x: 0, y: 0, width: fieldSize, height: fieldSize)
        
        // If odd, then center of self will be center of middle field. If false, then center of self will be center of space between 2 middle fields.
        if hasOddNumberOfFields {
            // Calculate from middle each fields x and y values so as to align the entire view in center
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * (fieldSize + separatorSpace) + fieldSize / 2)
        } else {
            // Calculate from middle each fields x and y values so as to align the entire view in center
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * fieldSize + CGFloat(fieldsCount / 2 - index - 1) * separatorSpace + separatorSpace / 2)
        }
        
        fieldFrame.origin.y = (bounds.size.height - fieldSize) / 2
        
        let otpField = OTPTextField(frame: fieldFrame)
        otpField.delegate = self
        otpField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpField.tag = index + 1
        otpField.font = fieldFont
        
        // Set input type for OTP fields
        switch fieldInputType {
        case .numeric:
            otpField.keyboardType = .numberPad
        case .alphabet:
            otpField.keyboardType = .alphabet
        case .alphaNumeric:
            otpField.keyboardType = .namePhonePad
        }
        
        if requireCursor {
            otpField.tintColor = cursorColor
        } else {
            otpField.tintColor = UIColor.clear
        }
        
        otpField.backgroundColor = emptyFieldBackgroundColor
        
        otpField.initalizeUI(forFieldType: otpFieldDisplayType, placeholderText: txtPlaceholder.rawValue, borderColor: emptyFieldBorderColor, placeholderColor: placeholderColor)
        
        return otpField
    }
    
    // Check if previous text fields have been entered or not.
    fileprivate func isPreviousFieldsEntered(forTextField textField: UITextField) -> Bool {
        
        var isTextFilled = true
        var nextOTPField: UITextField?
        
        // If intermediate editing is not allowed, then check for last filled field in forward direction.
        if !shouldAllowIntermediateEditing {
            
            for index in stride(from: 1, to: fieldsCount + 1, by: 1) {
                
                let tempNextOTPField = viewWithTag(index) as? UITextField
                
                if let tempNextOTPFieldText = tempNextOTPField?.text, tempNextOTPFieldText.isEmpty {
                    nextOTPField = tempNextOTPField
                    
                    break
                }
            }
            
            if let nextOTPField = nextOTPField {
                isTextFilled = (nextOTPField == textField || (textField.tag) == (nextOTPField.tag - 1))
            }
        }
        
        return isTextFilled
    }
    
    // Helper function to get the OTP String entered
    fileprivate func calculateEnteredOTPString(isDeleted: Bool) {
        
        if isDeleted {
            
            _ = delegate?.hasEnteredAllOTP(hasEntered: false)
            
            self.numberOfEnteredField -= 1
            
            // Set the default enteres state for otp entry
            for index in stride(from: 0, to: fieldsCount, by: 1) {
                
                var otpField = viewWithTag(index + 1) as? OTPTextField
                
                if otpField == nil {
                    otpField = getOTPField(forIndex: index)
                }
                
                let fieldBackgroundColor = (otpField?.text ?? "").isEmpty ? emptyFieldBackgroundColor : enteredFieldBackgroundColor
                let fieldBorderColor = (otpField?.text ?? "").isEmpty ? emptyFieldBorderColor : enteredFieldBorderColor
                
                otpField?.backgroundColor = fieldBackgroundColor
                otpField?.layer.borderColor = fieldBorderColor.cgColor
                if otpFieldDisplayType == .underlined {
                    otpField?.shapeLayer.strokeColor = fieldBorderColor.cgColor
                }
            }
        } else {
            
            var enteredOTPString = ""
            
            // Check for entered OTP
            for index in stride(from: 0, to: enteredOTP.count, by: 1) {
                
                if !enteredOTP[index].isEmpty {
                    enteredOTPString.append(enteredOTP[index])
                }
            }
            self.numberOfEnteredField = enteredOTPString.count
            
            if enteredOTPString.count == fieldsCount {
                
                delegate?.enteredOTP(otpString: enteredOTPString)
                self.endEditing(true)
                
                // Check if all OTP fields have been filled or not. Based on that call the 2 delegate methods.
                let isValid = delegate?.hasEnteredAllOTP(hasEntered: (enteredOTPString.count == fieldsCount)) ?? false
                
                // Set the error state for invalid otp entry
                for index in stride(from: 0, to: fieldsCount, by: 1) {
                    
                    var otpField = viewWithTag(index + 1) as? OTPTextField
                    
                    if otpField == nil {
                        otpField = getOTPField(forIndex: index)
                    }
                    
                    if !isValid {
                        // Set error border color if set, if not, set default border color
                        otpField?.layer.borderColor = (errorBorderColor ?? enteredFieldBorderColor).cgColor
                        if otpFieldDisplayType == .underlined {
                            otpField?.shapeLayer.strokeColor = (errorBorderColor ?? enteredFieldBorderColor).cgColor
                        }
                    } else {
                        otpField?.layer.borderColor = enteredFieldBorderColor.cgColor
                        if otpFieldDisplayType == .underlined {
                            otpField?.shapeLayer.strokeColor = enteredFieldBorderColor.cgColor
                        }
                    }
                }
            }
        }
    }
    
    @objc fileprivate func textFieldDidChange(_ textField: UITextField) {
        
        // here check you text field's input Type
        if #available(iOS 12.0, *) {
            if textField.textContentType == UITextContentType.oneTimeCode {
                
                //here split the text to your text fields
                if let otpCode = textField.text, otpCode.count == fieldsCount {
                    
                    textField.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: textField.tag - 1)])
                    textField.backgroundColor = enteredFieldBackgroundColor
                    textField.layer.borderColor = enteredFieldBorderColor.cgColor
                    if let txt = viewWithTag(textField.tag - 1) as? OTPTextField, otpFieldDisplayType == .underlined {
                        txt.shapeLayer.strokeColor = enteredFieldBorderColor.cgColor
                    }
                }
            }
        }
    }
    
    // For clear all entered OTP
    public func clearOTP() {
        
        for index in stride(from: 0, to: fieldsCount, by: 1) {
            
            let oldOtpField = viewWithTag(index + 1) as? OTPTextField
            self.deleteText(in: oldOtpField!)
        }
    }
}

extension OTPView: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let shouldBeginEditing = delegate?.shouldBecomeFirstResponderForOTP(otpFieldIndex: (textField.tag - 1)) ?? true
        if shouldBeginEditing {
            return isPreviousFieldsEntered(forTextField: textField)
        }
        
        return shouldBeginEditing
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        // Check since only alphabet keyboard is not available in iOS
        if !replacedText.isEmpty && fieldInputType == .alphabet && replacedText.rangeOfCharacter(from: .letters) == nil {
            return false
        }
        
        if replacedText.count >= 1 {
            // If field has a text already, then replace the text and move to next field if present
            enteredOTP[textField.tag - 1] = string
            
            if isSecureEntry {
                
                let fullString = NSMutableAttributedString(string: "")
                let imageAttachment = NSTextAttachment()
                textField.text = "M"
                textField.textColor = enteredFieldBackgroundColor
                let origImage = UIImage(named: secureEntrySymbol.rawValue)
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                if #available(iOS 13.0, *) {
                    imageAttachment.image = tintedImage
                } else {
                    imageAttachment.image = tintedImage?.imageWithColor(color: .red)
                }
                imageAttachment.bounds = CGRect(x: 0, y: 0, width: (textField.text?.widthOfString(usingFont: fieldFont) ?? 0), height: (textField.text?.widthOfString(usingFont: fieldFont) ?? 0))
                let imageString = NSAttributedString(attachment: imageAttachment)
                fullString.append(imageString)
                if let lbl = self.viewWithTag(textField.tag + fieldsCount) as? UILabel, secureEntrySymbol != .none {
                    
                    lbl.textAlignment = .center
                    lbl.attributedText = fullString
                    if #available(iOS 13.0, *) {
                        lbl.textColor = secureEntrySymbolColor
                    }
                }
            } else {
                textField.text = string
                textField.textColor = textColor
            }
            
            textField.backgroundColor = enteredFieldBackgroundColor
            textField.layer.borderColor = enteredFieldBorderColor.cgColor
            if let txt = viewWithTag(textField.tag) as? OTPTextField, otpFieldDisplayType == .underlined {
                txt.shapeLayer.strokeColor = enteredFieldBorderColor.cgColor
            }
            
            let nextOTPField = viewWithTag(textField.tag + 1)
            
            if let nextOTPField = nextOTPField {
                nextOTPField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            
            // Get the entered string
            calculateEnteredOTPString(isDeleted: false)
        } else {
            
            let currentText = textField.text ?? ""
            
            if textField.tag > 1 && currentText.isEmpty {
                
                if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                    deleteText(in: prevOTPField)
                }
            } else {
                deleteText(in: textField)
                
                if textField.tag > 1 {
                    if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                        prevOTPField.becomeFirstResponder()
                    }
                }
            }
        }
        
        return false
    }
    
    private func deleteText(in textField: UITextField) {
        
        // If deleting the text, then move to previous text field if present
        enteredOTP[textField.tag - 1] = ""
        textField.text = ""
        
        if let lbl = self.viewWithTag(textField.tag + fieldsCount) as? UILabel {
            lbl.text = ""
        }
        
        textField.backgroundColor = emptyFieldBackgroundColor
        textField.layer.borderColor = emptyFieldBorderColor.cgColor
        
        textField.becomeFirstResponder()
        
        // Get the entered string
        calculateEnteredOTPString(isDeleted: true)
    }
}

extension String {

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

extension UIImage {
    
    func imageWithColor(color:UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.clip(to: rect, mask: self.cgImage!)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let imageFromCurrentContext = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: imageFromCurrentContext!.cgImage!, scale: 1.0, orientation:.downMirrored)
    }
}
