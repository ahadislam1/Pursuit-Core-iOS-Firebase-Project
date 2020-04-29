//
//  UIVIewController+Combine.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import Combine

extension UIViewController {
    
    func alert(title: String, text: String?) -> AnyPublisher<Void, Never> {
      let alertVC = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)

      return Future { resolve in
        alertVC.addAction(UIAlertAction(title: "OK",
                                        style: .default) { _ in
          resolve(.success(()))
        })

        self.present(alertVC, animated: true, completion: nil)
      }
      .handleEvents(receiveCancel: {
        self.dismiss(animated: true)
      })
      .eraseToAnyPublisher()
    }
}
