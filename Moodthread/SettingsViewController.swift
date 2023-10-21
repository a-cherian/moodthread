//
//  SettingsViewController.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class SettingsViewController: UIViewController {
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Sample Submenu", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        addSubviews()
        configureUI()
    }
    
    func addSubviews() {
        view.addSubview(button)
    }

    func configureUI() {
        configureButton()
    }
    
    func configureButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 100),
            button.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc func didTap() {
        self.navigationController?.pushViewController(MenuViewController(), animated: false)
    }
}

