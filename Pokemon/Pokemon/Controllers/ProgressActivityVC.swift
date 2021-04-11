//
//  ProgressActivityVC.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 08.02.21.
//

import UIKit

class ProgressActivityVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var progress = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = .blue

        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.startAnimating()
        view.addSubview(progress)

        progress.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progress.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

// Reacting to activity progress extension
extension ProgressActivityVC
{
    func createProgressView() {
        let child = ProgressActivityVC()

        // add the activity view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // then remove the activity view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}
