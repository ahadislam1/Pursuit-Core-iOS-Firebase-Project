//
//  ViewController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
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
    
    private var photos = [IPhoto]()
    
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        setupCollectionView()
        setupNavigation()
    }
    
    @objc
    private func barButtonPressed() {
        //TODO: Segue to create controller
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
        cell.configureCell(photos[indexPath.count])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: Segue to detail view
    }
    
    
}
