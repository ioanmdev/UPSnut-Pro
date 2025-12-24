//
//  LoadingScreen.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 29.07.2022.
//

import Foundation
import UIKit

public func animateLoading(context: UIViewController)
{
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 20, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.medium
    loadingIndicator.startAnimating();

    alert.view.addSubview(loadingIndicator)
    context.present(alert, animated: true, completion: nil)
}

public func stopLoading(context: UIViewController)
{
    context.dismiss(animated: false, completion: nil)
}
