//
//  CreateViewController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import FirebaseAuth

class CreateViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var button: UIButton = {
        let b = UIButton(type: .contactAdd)
        b.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return b
    }()
    
    private lazy var barButton: UIBarButtonItem = {
        let b = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(barButtonPressed))
        b.isEnabled = false
        return b
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    private var imageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    private var imageURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSubviews()
        setupNavigation()
        updateUI()
    }
    
    private func updateUI() {
        imageSubject
            .map { $0 != nil }
            .assign(to: \.isEnabled, on: barButton)
            .store(in: &subscriptions)
        
        imageSubject
            .assign(to: \.image, on: imageView)
            .store(in: &subscriptions)
        
        imageView.image = UIImage(systemName: "icloud")
    }
    
    @objc private func buttonPressed() {
        didPressButton()
    }
    
    @objc private func barButtonPressed() {
        guard let user = Auth.auth().currentUser, let name = user.displayName else {
            return
        }
        barButton.isEnabled = false
        let activityIndicator = UIActivityIndicatorView(style: .large)
        view.addSubview(activityIndicator)
        activityIndicator.color = .systemOrange
        activityIndicator.startAnimating()
        if let url = imageURL {
            let id = UUID().uuidString
            StorageService.shared.uploadPhoto(id: id, imageURL: url, exp: .photo)
            .sink(receiveCompletion: {_ in},
                  receiveValue: {[unowned self] url in
                    FirestoreService.shared.createPhoto(photo: IPhoto(id: id, imageURL: url.absoluteString, createdAt: Date(), madeBy: name))
                    .sink(receiveCompletion: {[weak self, weak activityIndicator] _ in
                        activityIndicator?.stopAnimating()
                        self?.navigationController?.popViewController(animated: true)
                        }, receiveValue: {_ in})
                        .store(in: &self.subscriptions)
            })
            .store(in: &subscriptions)
        }
        
    }
    
    private func setupNavigation() {
        navigationItem.title = "Upload an image"
        navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupSubviews() {
        setupImageView()
        setupButton()
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.frame.height / 3)
        }
    }
    
    private func setupButton() {
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(imageView)
            make.top.equalTo(imageView.snp.bottom).offset(20)
        }
    }

}

extension CreateViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imageURL = info[.imageURL] as? URL,
            let image = info[.originalImage] as? UIImage else {
                return
        }
        
        imageSubject.send(image)
        self.imageURL = imageURL
        dismiss(animated: true, completion: nil)
        
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
