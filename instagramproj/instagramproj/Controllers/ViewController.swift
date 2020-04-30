//
//  ViewController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import Combine

class ViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        cv.backgroundColor = .systemGroupedBackground
        return cv
    }()
    
    private lazy var barButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(barButtonPressed))
        return button
    }()
    
    private var photos = [IPhoto]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        loadData()
        setupCollectionView()
        setupNavigation()
    }
    
    @objc
    private func barButtonPressed() {
        navigationController?.pushViewController(CreateViewController(), animated: true)
    }
    
    private func loadData() {
        IPhotoSingleton.shared.$photos
            .assign(to: \.photos, on: self)
            .store(in: &subscriptions)
        
        do {
            try IPhotoSingleton.shared.loadPhotos()
        } catch {
            showMessage("Error", description: error.localizedDescription)
        }
        
    }
    
    private func showMessage(_ title: String, description: String? = nil) {
         alert(title: title, text: description)
             .sink(receiveValue: { _ in })
             .store(in: &subscriptions)
     }
    
    private func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupSubviews() {
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = DetailViewController(photo: photos[indexPath.row])
        present(detail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 200, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    
}
