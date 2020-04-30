//
//  DetailViewController.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
import Combine

class DetailViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .callout)
        return l
    }()
    
    private lazy var dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .caption1)
        return l
    }()
    
    private let photo: IPhoto
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(photo: IPhoto) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupImageView()
        setupLabel()
        setupDateLabel()
        configureUI()
    }
    
    private func configureUI() {
        if let url = URL(string: photo.imageURL) {
        imageView.setImage(url: url, in: &subscriptions)
        }
        label.text = photo.madeBy
        dateLabel.text = "\(photo.createdAt)"
        
    }
    
    private func setupSubviews() {
        setupImageView()
        setupLabel()
        setupDateLabel()
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(view.frame.height * 2 / 3)
        }
    }
    
    private func setupLabel() {
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setupDateLabel() {
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(12)
            make.leading.trailing.equalTo(label)
        }
    }

}
