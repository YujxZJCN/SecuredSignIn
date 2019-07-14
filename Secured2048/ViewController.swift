//
//  ViewController.swift
//  Secured2048
//
//  Created by Mikeboge on 2019/7/13.
//  Copyright © 2019年 Mikeboge. All rights reserved.
//

import UIKit
import LocalAuthentication
import SkyFloatingLabelTextField
import Alamofire
import Kanna
import CommonCrypto

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoName: UILabel!
    @IBOutlet weak var hiddenEmailLabel: UILabel!
    var url = "http://178.128.26.180:8787"
    var hiddenEmail = "securedemail@secure.com" {
        didSet {
            hiddenEmailLabel.text = "Forward To: " + hiddenEmail
        }
    }
    let nameTextField = SkyFloatingLabelTextField(frame: CGRect(x: 40, y: 40, width: 200, height: 45))
    let emailTextField = SkyFloatingLabelTextField(frame: CGRect(x: 40, y: 40, width: 200, height: 45))
    let darkGreyColor = #colorLiteral(red: 0.5654503107, green: 0.8293422461, blue: 0.8113552928, alpha: 1)
    let lightGreyColor = #colorLiteral(red: 0.5654503107, green: 0.8293422461, blue: 0.8113552928, alpha: 1)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    @IBOutlet weak var formerEmailLabel: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.logo.transform = .identity
            self.logoName.transform = .identity
            self.nameTextField.transform = .identity
            self.emailTextField.transform = .identity
        }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let moveUpTransform = CGAffineTransform.init(translationX: 0, y: -90)
        UIView.animate(withDuration: 0.3, animations: {
            self.logo.transform = moveUpTransform
            self.logoName.transform = moveUpTransform
            self.nameTextField.transform = moveUpTransform
            self.emailTextField.transform = moveUpTransform
        }, completion: nil)
        
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.clipsToBounds = true
            signInButton.layer.cornerRadius = 10
        }
    }
    let blurEffect = UIBlurEffect(style: .dark)
    lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    @IBAction func SignIn(_ sender: UIButton) {
        nameLabel.text = nameTextField.text
        formerEmailLabel.text = emailTextField.text

        let key = "1234567812345678123456781234567812345678123456781234567812345678"
        let iv = ""
        
        let text = emailTextField.text ?? "VLMX@VLMX.com"
        var encryptText: String?
        var decrptText: String?
        encryptText = text.tripleDESEncryptOrDecrypt(op: CCOperation(kCCEncrypt), key: key, iv: iv)
        decrptText = encryptText!.tripleDESEncryptOrDecrypt(op: CCOptions(kCCDecrypt), key: key, iv: iv)
        print("加密内容："+(encryptText ?? "加密失败")+"\n解密内容："+(decrptText ?? "解密失败"))
        
        hiddenEmail = encryptText!
        blurEffectView.frame = view.bounds
        self.view.addSubview(blurEffectView)
        self.view.bringSubviewToFront(signInView)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 2, initialSpringVelocity: 1.5, options: [], animations: {
            self.signInView.transform = .identity
            self.signInView.alpha = 1.0
        }, completion: nil)
    }
    
    @IBOutlet weak var signInView: UIView!
    
    @IBAction func cancel(_ sender: UIButton) {
        let moveDownTransform = CGAffineTransform.init(translationX: 0, y: 380)
        UIView.animate(withDuration: 0.3, animations: {
            self.signInView.transform = moveDownTransform
            self.signInView.alpha = 0.0
        }, completion: { completion in
            self.blurEffectView.removeFromSuperview()
        })
    }
    
    @IBOutlet weak var nameBox: UIButton!
    @IBOutlet weak var shareEmailBox: UIButton!
    @IBOutlet weak var hideMyEmailButton: UIButton!
    
    var share = false {
        didSet {
            if share {
                hide = false
            }
            if share {
                shareEmailBox.setImage(UIImage(named: "check"), for: .normal)
            } else {
                shareEmailBox.setImage(UIImage(named: "circle"), for: .normal)
            }
        }
    }
    var hide = false {
        didSet {
            if hide {
                share = false
            }
            if hide {
                hideMyEmailButton.setImage(UIImage(named: "check"), for: .normal)
            } else {
                hideMyEmailButton.setImage(UIImage(named: "circle"), for: .normal)
            }
        }
    }
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.clipsToBounds = true
            continueButton.layer.cornerRadius = 10
        }
    }
    @IBAction func continueAction(_ sender: UIButton) {
        authenticateWithBiometric()
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        nameTextField.delegate = self
        nameTextField.placeholder = "Name"
        nameTextField.title = "Username"
        nameTextField.tintColor = overcastBlueColor
        nameTextField.textColor = darkGreyColor
        nameTextField.lineColor = lightGreyColor
        nameTextField.selectedTitleColor = overcastBlueColor
        nameTextField.selectedLineColor = overcastBlueColor
        nameTextField.lineHeight = 1.0
        nameTextField.selectedLineHeight = 2.0
        nameTextField.center = self.view.center
        nameTextField.textAlignment = .center
        self.view.addSubview(nameTextField)
        
        emailTextField.delegate = self
        emailTextField.placeholder = "Email"
        emailTextField.title = "Email"
        emailTextField.tintColor = overcastBlueColor
        emailTextField.textColor = darkGreyColor
        emailTextField.lineColor = lightGreyColor
        emailTextField.selectedTitleColor = overcastBlueColor
        emailTextField.selectedLineColor = overcastBlueColor
        emailTextField.lineHeight = 1.0
        emailTextField.selectedLineHeight = 2.0
        emailTextField.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 80)
        emailTextField.textAlignment = .center
        self.view.addSubview(emailTextField)
        
        signInButton.isEnabled = false
        hide = true
        hiddenEmail = "securedemail@secure.com"
        signInButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)

    }
    @IBOutlet weak var ORLabel: UILabel!
    @IBOutlet weak var withDefaultLabel: UILabel!
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if nameTextField.text == "" || emailTextField.text == "" {
            signInButton.isEnabled = false
            signInButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        } else {
            signInButton.isEnabled = true
            signInButton.backgroundColor = #colorLiteral(red: 0.5654503107, green: 0.8293422461, blue: 0.8113552928, alpha: 1)
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let moveDownTransform = CGAffineTransform.init(translationX: 0, y: 380)
        self.signInView.transform = moveDownTransform
        self.signInView.alpha = 0.0
        if nameTextField.text != "" {
            signInButton.alpha = 0.0
            ORLabel.alpha = 0.0
            withDefaultLabel.alpha = 0.0
            nameTextField.lineColor = .darkGray
            emailTextField.lineColor = .darkGray
            nameTextField.isEnabled = false
            if hide {
                emailTextField.text = hiddenEmail
            }
            emailTextField.isEnabled = false
        }
    }
    
    @IBAction func clearName(_ sender: UIButton) {
        nameLabel.text = ""
    }
    @IBAction func shareMyEmailButtonClicked(_ sender: UIButton) {
        share = !share
    }
    
    
    @IBAction func hideMyEmailButtonClicked(_ sender: UIButton) {
        hide = !hide
    }
    
    func authenticateWithBiometric() {
        // Get the local authentication context.
        let localAuthContext = LAContext()
        let reasonText = "Authentication is required to sign in ToDoList"
        var authError: NSError?
        
        if !localAuthContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            if let error = authError {
                print(error.localizedDescription)
            }
            
            // Display the login dialog when Touch ID is not available (e.g. in simulator)
            print("login with Touch ID is not available")
            return
        }
        
        // Perform the Touch ID authentication
        localAuthContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonText, reply: { (success: Bool, error: Error?) -> Void in
            
            // Failure workflow
            if !success {
                if let error = error {
                    switch error {
                    case LAError.authenticationFailed:
                        print("Authentication failed")
                    case LAError.passcodeNotSet:
                        print("Passcode not set")
                    case LAError.systemCancel:
                        print("Authentication was canceled by system")
                    case LAError.userCancel:
                        print("Authentication was canceled by the user")
                    case LAError.biometryNotEnrolled:
                        print("Authentication could not start because you haven't enrolled either Touch ID or Face ID on your device.")
                    case LAError.biometryNotAvailable:
                        print("Authentication could not start because Touch ID / Face ID is not available.")
                    case LAError.userFallback:
                        print("User tapped the fallback button (Enter Password).")
                    default:
                        print(error.localizedDescription)
                    }
                }
                
                // Fallback to password authentication
//                OperationQueue.main.addOperation({
//                    self.showLoginDialog()
//                })
            } else {
                
                // Success workflow
                
                print("Successfully authenticated")
                OperationQueue.main.addOperation({
                    
                    var para: [String : Any] = ["username_login" : "",
                                                "password_login" : "",
                    ]
                    para["username_login"] = self.nameTextField.text
                    if self.share {
                        para["password_login"] = self.formerEmailLabel.text
                    } else {
                        para["password_login"] = self.hiddenEmail
                    }
                    
                    Alamofire.request(self.url, method: .post, parameters: para).responseData { (response) in
                        if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                            print(doc.content ?? "None!")
                        }
                    }
                    
//                    Alamofire.request(self.url, method: .get).responseData { (response) in
//                        if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
//                            print(doc.content)
//                        }
//                    }
                    let game = NumberTileGameViewController(dimension: 4, threshold: 2048)
                    self.blurEffectView.removeFromSuperview()
                    let moveDownTransform = CGAffineTransform.init(translationX: 0, y: 380)
                    self.signInView.transform = moveDownTransform
                    self.signInView.alpha = 0.0
                    self.present(game, animated: true, completion: nil)
                })
            }
            
        })
    }

}

extension String {
    
    /**
     3DES的加密过程 和 解密过程
     
     - parameter op : CCOperation： 加密还是解密
     CCOperation（kCCEncrypt）加密
     CCOperation（kCCDecrypt) 解密
     
     - parameter key: 加解密key
     - parameter iv : 可选的初始化向量，可以为nil
     - returns      : 返回加密或解密的参数
     */
    
    func tripleDESEncryptOrDecrypt(op: CCOperation, key: String, iv: String) -> String? {
        
        // Key
        let keyData: NSData = key.data(using: String.Encoding.utf8, allowLossyConversion: true)! as NSData
        let keyBytes = UnsafeMutableRawPointer(mutating: keyData.bytes)
        
        var data: NSData!
        if op == CCOperation(kCCEncrypt) {//加密内容
            data  = self.data(using: String.Encoding.utf8, allowLossyConversion: true)! as NSData
        }
        else {//解密内容
            data =  NSData(base64Encoded: self, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        }
        
        let dataLength    = size_t(data.length)
        let dataBytes     = UnsafeMutableRawPointer(mutating: data.bytes)
        
        // 返回数据
        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSize3DES)
        let cryptPointer = UnsafeMutableRawPointer(mutating: cryptData?.bytes)
        let cryptLength  = size_t(cryptData!.length)
        
        //  可选 的初始化向量
        let viData :NSData = iv.data(using: String.Encoding.utf8, allowLossyConversion: true)! as NSData
        let viDataBytes    = UnsafeMutableRawPointer(mutating: viData.bytes)
        
        // 特定的几个参数
        let keyLength              = size_t(kCCKeySize3DES)
        let operation: CCOperation = UInt32(op)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithm3DES)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)
        
        var numBytesCrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation, // 加密还是解密
            algoritm, // 算法类型
            options,  // 密码块的设置选项
            keyBytes, // 秘钥的字节
            keyLength, // 秘钥的长度
            viDataBytes, // 可选初始化向量的字节
            dataBytes, // 加解密内容的字节
            dataLength, // 加解密内容的长度
            cryptPointer, // output data buffer
            cryptLength,  // output data length available
            &numBytesCrypted) // real output data length
        
        
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            
            cryptData!.length = Int(numBytesCrypted)
            if op == CCOperation(kCCEncrypt)  {
                let base64cryptString = cryptData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                return base64cryptString
            }
            else {
                let base64cryptString = String.init(data: cryptData! as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                return base64cryptString
            }
        } else {
            print("Error: \(cryptStatus)")
        }
        return nil
    }
}

