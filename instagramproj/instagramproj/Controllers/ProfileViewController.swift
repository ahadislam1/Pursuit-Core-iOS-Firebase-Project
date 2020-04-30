//
//  ProfileViewController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Profile"
        l.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        l.textAlignment = .center
        return l
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle")
        iv.backgroundColor = .systemBackground
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var button: UIButton = {
        let b = UIButton(type: .system)
        b.setTitleColor(UIColor.systemBackground, for: .normal)
        b.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        b.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return b
    }()
    
    private lazy var editButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        b.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        return b
    }()
    
    private lazy var displayNameLabel: UILabel = {
        let l = UILabel()
        l.text = "Display name"
        l.textAlignment = .center
        l.font = UIFont.preferredFont(forTextStyle: .title1)
        return l
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private lazy var emailLabel: UILabel = {
        let l = UILabel()
        l.text = "email"
        return l
    }()
    
    private lazy var countLabel: UILabel = {
        let l = UILabel()
        l.text = "count"
        return l
    }()
    
    var count = 0 {
        didSet {
            countLabel.text = "You have uploaded \(count) images."
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    @objc
    private func buttonPressed() {
        print("buttonPressed")
        didPressButton()
    }
    
    @objc
    private func editButtonPressed() {
        let alertController = UIAlertController(title: "Edit Name",
                                                message: "Edit your display name in the textfield",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let textField = alertController.textFields?.first, let text = textField.text, textField.hasText else {
                return
            }
            
            AuthService.shared.updateUser(text, photoURL: nil)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.showMessage("Error", description: error.localizedDescription)
                    case .finished:
                        self?.displayNameLabel.text = text
                    }
                    },
                      receiveValue: { _ in})
                .store(in: &self.subscriptions)
            
        }
        
        alertController.addTextField { textField in
            textField.delegate = self
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func loadData() {
        guard let user = Auth.auth().currentUser, let url = user.photoURL else {
            return
        }
        imageView.setImage(url: url, in: &subscriptions)
        
        if let name = user.displayName {
            displayNameLabel.text = name
        }
        
        if let email = user.email {
            emailLabel.text = email
        }
        
        IPhotoSingleton.shared.$photos
            .map { $0
                .filter { $0.madeBy == user.displayName}
                .count }
            .assign(to: \.count, on: self)
            .store(in: &subscriptions)
        
        
    }
    
    private func showMessage(_ title: String, description: String? = nil) {
        alert(title: title, text: description)
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    
    
    private func setupSubviews() {
        view.backgroundColor = .systemBackground
        
        setupTitle()
        setupImageView()
        setupDisplayLabel()
        setupButton()
        setupEditButton()
        setupStackView()
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
        }
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalTo(view)
            make.height.equalTo(view.frame.height / 3)
            make.width.equalTo(view.frame.height / 3)
        }
    }
    
    private func setupButton() {
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.bottom.equalTo(imageView.snp.bottom)
            make.trailing.equalTo(imageView.snp.trailing)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
    }
    
    private func setupDisplayLabel() {
        view.addSubview(displayNameLabel)
        
        displayNameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.trailing.equalTo(titleLabel)
        }
    }
    
    private func setupEditButton() {
        view.addSubview(editButton)
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(displayNameLabel.snp.bottom).offset(12)
            make.centerX.equalTo(displayNameLabel.snp.centerX)
        }
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailLabel, countLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(editButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imageURL = info[.imageURL] as? URL,
            let image = info[.originalImage] as? UIImage, let user = Auth.auth().currentUser else {
                return
        }
        
        StorageService.shared.uploadPhoto(id: user.uid, imageURL: imageURL, exp: .user)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.showMessage("Error", description: error.localizedDescription)
                }
                }, receiveValue: { url in
                    AuthService.shared.updateUser(photoURL: url)
                        .sink(receiveCompletion: { [weak self] completion in
                            if case .failure(let error) = completion {
                                self?.showMessage("Error", description: error.localizedDescription)
                            } else {
                                self?.imageView.image = image
                            }
                            picker.dismiss(animated: true, completion: nil)
                            self?.subscriptions.removeAll()
                            },
                              receiveValue: { _ in })
                        .store(in: &self.subscriptions)
            })
            .store(in: &subscriptions)
        
    }
    
    func didPressButton() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.showPicker(sourceType: .camera)
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.showPicker(sourceType: .photoLibrary)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func showPicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
    }
}
