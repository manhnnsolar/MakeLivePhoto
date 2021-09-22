//
//  AVAsset-extensions.swift
//
//  Created by Joe Pagliaro on 10/5/17.
//  Copyright © 2017 Limit Point LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    func postAlert(_ title: String, message: String) {
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            let alert = UIAlertController(title: title, message: message,
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            let popOver = alert.popoverPresentationController
            popOver?.sourceView  = self.view
            popOver?.sourceRect = self.view.bounds
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            
            self.present(alert, animated: true, completion: nil)
            
        })
        
    }
}
