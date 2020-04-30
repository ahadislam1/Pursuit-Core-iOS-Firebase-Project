//
//  UIImageView+Combine.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import SnapKit
import Combine

extension UIImageView {
    func setImage(url: URL, in subscriptions: inout Set<AnyCancellable>) {
        let indicator = UIActivityIndicatorView(style: .large)
        self.addSubview(indicator)
        indicator.startAnimating()
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { UIImage(data: $0.data) }
            .eraseToAnyPublisher()
            .replaceError(with: UIImage(systemName: "icloud.slash"))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self, weak indicator] image in
                    self?.image = image
                    indicator?.stopAnimating()
            })
            .store(in: &subscriptions)
    }
}
