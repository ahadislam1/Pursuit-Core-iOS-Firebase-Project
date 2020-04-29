//
//  ViewController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/28/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
import Combine

class LoginViewController: UIViewController {
    
    //MARK: UI Objects
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Email"
        textField.backgroundColor = .white
        textField.borderStyle = .bezel
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(validateFields(sender:)), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Password"
        textField.backgroundColor = .white
        textField.borderStyle = .bezel
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(validateFields(sender:)), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(tryLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Dont have an account?  ",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: [NSAttributedString.Key.foregroundColor:  UIColor.systemBlue]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(showSignUp), for: .touchUpInside)
        return button
    }()
    
    private var bottomConstraint: Constraint? = nil
    
    private var subscriptions = Set<AnyCancellable>()
    private var keyboardSubscriptions = Set<AnyCancellable>()
    
    private var loginHasText = PassthroughSubject<Bool, Never>()
    private var passHasText = PassthroughSubject<Bool, Never>()
    
    //MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        setupSubViews()
        
        updateLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notifyKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelKeyboard()
    }
    
    private func updateLoginButton() {
        loginHasText
            .combineLatest(passHasText)
            .map { $0 && $1 }
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &subscriptions)
    }
    
    private func notifyKeyboard() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
            .compactMap { $0.userInfo?["UIKeyboardFrameBeginUserInfoKey"] as? CGRect }
            .sink(receiveValue: { [weak self] rect in
                print(rect)
                self?.bottomConstraint?.update(offset: -rect.height)
                
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                }
            })
            .store(in: &keyboardSubscriptions)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .sink(receiveValue: { [weak self] _ in
                self?.bottomConstraint?.update(offset: 0)
                
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                }
            })
            .store(in: &keyboardSubscriptions)
    }
    
    private func cancelKeyboard() {
        keyboardSubscriptions.forEach { $0.cancel() }
    }
    
    //MARK: Obj-C methods
    
    @objc func validateFields(sender: UITextField) {
        if sender == emailTextField {
            loginHasText.send(emailTextField.hasText)
        } else {
            passHasText.send(passwordTextField.hasText)
        }
    }
    
    @objc func showSignUp() {
        let signupVC = SignupViewController()
        signupVC.modalPresentationStyle = .formSheet
        present(signupVC, animated: true, completion: nil)
    }
    
    @objc func tryLogin() {
        AuthService.shared.loginUser(email: emailTextField.text!, password: passwordTextField.text!)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showMessage("Error", description: error.localizedDescription)
                case .finished:
                    UIViewController.showVC(viewcontroller: ViewController())
                }
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    //MARK: Private methods
    
    private func showMessage(_ title: String, description: String? = nil) {
      alert(title: title, text: description)
      .sink(receiveValue: { _ in })
      .store(in: &subscriptions)
    }
    
    //MARK: UI Setup
    
    private func setupSubViews() {
        setupCreateAccountButton()
        setupLoginStackView()
    }
    
    private func setupLoginStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField,loginButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        self.view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(createAccountButton).offset(-50)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
            make.height.equalTo(130)
        }
        
        
    }
    
    private func setupCreateAccountButton() {
        view.addSubview(createAccountButton)
        
        createAccountButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            self.bottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.height.equalTo(50)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

