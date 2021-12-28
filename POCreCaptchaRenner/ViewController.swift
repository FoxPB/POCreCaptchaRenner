//
//  ViewController.swift
//  POCreCaptchaRenner
//
//  Created by Ricardo Caldeira on 17/12/21.
//

import UIKit
import Lottie
import ReCaptcha

class ViewController: UIViewController {
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var recaptchaView: UIView!
    @IBOutlet weak var messageErrorLabel: UILabel!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var sucessLabel: UILabel!
    
    private struct Constants {
        static let webViewTag = 123
        static let testLabelTag = 321
    }

    private var recaptcha: ReCaptcha!

    private var locale: Locale?
    private var endpoint = ReCaptcha.Endpoint.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .light
        setupRecaptcha()
        hiddenRecaptcha()
        changeStatusReadButton()
        
        //dismissKeyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let tapRecaptcha = UITapGestureRecognizer(target: self, action: #selector(self.iAmNotRobot))
        clearView.addGestureRecognizer(tapRecaptcha)
        
        cardNumberTextField.addTarget(self, action: #selector(self.changeStatusReadButton), for: .editingChanged)
    }
    
    @objc func dismissKeyboard() {
        changeStatusReadButton()
        view.endEditing(true)
    }
    
    func setupRecaptcha() {
        animationView.isHidden = true
        messageErrorLabel.isHidden = true
        clearView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        clearView.layer.borderWidth = 1
        clearView.layer.cornerRadius = 5
        
        recaptcha = try! ReCaptcha(endpoint: endpoint, locale: locale)

        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = Constants.webViewTag

            // For testing purposes
            // If the webview requires presentation, this should work as a way of detecting the webview in UI tests
            self?.view.viewWithTag(Constants.testLabelTag)?.removeFromSuperview()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            label.tag = Constants.testLabelTag
            label.accessibilityLabel = "webview"
            self?.view.addSubview(label)
        }
    }
    
    func hiddenRecaptcha() {
        recaptchaView.isHidden = true
    }
    
    func showAndResetRecaptcha() {
        animationView.isHidden = true
        messageErrorLabel.isHidden = true
        checkView.isHidden = false
        recaptchaView.isHidden = false
    }
    
    @objc func changeStatusReadButton() {
        sucessLabel.isHidden = true
        if cardNumberTextField.text != "" && recaptchaView.isHidden == true {
            readButton.layer.opacity = 1
            readButton.isEnabled = true
        } else if cardNumberTextField.text != "" && checkView.isHidden == true  {
            readButton.layer.opacity = 1
            readButton.isEnabled = true
        } else {
            readButton.layer.opacity = 0.7
            readButton.isEnabled = false
        }
    }
    
    func showLoadingAnimation() {
        clearView.isHidden = false
        messageErrorLabel.isHidden = true
        let animation = Animation.named("loading")
      
        animationView.animation = animation
        animationView.loopMode = .loop
        animationView.play()
        animationView.isHidden = false
    }
    
    func showCheckAnimation() {
        let animation = Animation.named("success")
        animationView.animation = animation
        animationView.loopMode = .playOnce
        animationView.play()
        animationView.isHidden = false
        checkView.isHidden = true
        changeStatusReadButton()
    }
    
    func showErrorAnimation() {
        let animation = Animation.named("error-animation")
        animationView.animation = animation
        animationView.isHidden = false
        animationView.loopMode = .playOnce
        animationView.play { _ in
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                self.animationView.isHidden = true
                self.messageErrorLabel.isHidden = false
                self.checkView.isHidden = false
            }
        }
    }
    
    @IBAction func readButtonTouchUpInside(_ sender: Any) {
        if (cardNumberTextField.text == "3333" || cardNumberTextField.text == "9999") && animationView.isHidden == true  {
            showAndResetRecaptcha()
            changeStatusReadButton()
        } else {
            sucessLabel.isHidden = false
        }
    }
    
    @objc
    private func iAmNotRobot() {
        showLoadingAnimation()
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            if self.cardNumberTextField.text == "9999" {
                self.showErrorAnimation()
            } else {
                self.validate()
            }
        }
    }
    
    private func validate() {
        recaptcha?.validate(on: view) { [weak self] (result: ReCaptchaResult) in
            switch result {
            case .token(let token):
                print("RESUTADO Sucesso: \(token)")
                self?.showCheckAnimation()
            case .error(let error):
                print("Error: \(error)")
                self?.showErrorAnimation()
            }
        }
    }
}

    

