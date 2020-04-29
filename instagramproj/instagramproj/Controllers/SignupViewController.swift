//
//  SignupController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
import Combine

class SignupViewController: UIViewController {
    
    //MARK: UI Objects
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Firebae: Create Account"
        label.font = label.font.withSize(28)
        label.textColor = UIColor(red: 255/255, green: 86/255, blue: 0/255, alpha: 1.0)
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Email"
        textField.backgroundColor = .white
        textField.borderStyle = .bezel
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(validateFields(sender:)), for: .editingChanged)
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
        return textField
    }()
    
    lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 67/255, blue: 0/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(trySignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    private let didLoadSubject = PassthroughSubject<Void, Never>()
    
    private var keyboardSubscriptions = Set<AnyCancellable>()
    private var signHasText = PassthroughSubject<Bool, Never>()
    private var passHasText = PassthroughSubject<Bool, Never>()
    
    public var didLoad: AnyPublisher<Void, Never> {
        return didLoadSubject.eraseToAnyPublisher()
    }
    
    private var disappearSubject = PassthroughSubject<Void, Never>()
    
    public var disappear: AnyPublisher<Void, Never> {
        return disappearSubject.eraseToAnyPublisher()
    }
    
    //MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        setupHeaderLabel()
        setupCreateStackView()
        updateLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didLoadSubject.send(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disappearSubject.send(())
    }
    
    //MARK: Obj-C Methods
    
    @objc func validateFields(sender: UITextField) {
        if sender == emailTextField {
            signHasText.send(emailTextField.hasText)
        } else {
            passHasText.send(passwordTextField.hasText)
        }
    }
    
    @objc func trySignUp() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showMessage("Error", description: "Please fill out all fields.")
            return
        }
        
        AuthService.shared.createUser(email: email, password: password)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showMessage("Error", description: error.localizedDescription)
                case .finished:
                    UIViewController.showVC(viewcontroller: TabBarController())
                }
                }, receiveValue: {_ in})
            .store(in: &subscriptions)
    }
    
    //MARK: Private methods
    
    private func showMessage(_ title: String, description: String? = nil) {
        alert(title: title, text: description)
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    private func updateLoginButton() {
        signHasText
            .combineLatest(passHasText)
            .map { $0 && $1 }
            .assign(to: \.isEnabled, on: createButton)
            .store(in: &subscriptions)
    }
    
    //MARK: UI Setup
    
    private func setupHeaderLabel() {
        view.addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.08)
        }
    }
    
    private func setupCreateStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,createButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        self.view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(100)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
        }
    }
}
