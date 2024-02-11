//
//  SettingsTableView.swift
//  Moodthread
//
//  Created by AC on 10/20/23.
//

import UIKit

class SettingsTableViewController : UIViewController, UITableViewDelegate {
    
    var labels: Dictionary<Int, String> = [:]
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRectZero, style: .insetGrouped)
        
        table.backgroundColor = .white
        table.rowHeight = 200
        table.sectionHeaderTopPadding = 0
        table.sectionHeaderHeight = 0.0;
        table.sectionFooterHeight = 0.0;

//        table.rowHeight = UITableView.automaticDimension
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.layer.cornerCurve = .continuous
        table.layer.cornerRadius = 10
//        table.isScrollEnabled = false
//        table.alwaysBounceVertical = false
        
        return table
    }()
    
    init(labels: Dictionary<Int, String>) {
        super.init(nibName: nil, bundle: nil)
        self.labels = labels
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        configureUI() 
    }
    
    func addSubviews() {
        view.addSubview(tableView)
    }

    func configureUI() {
        configureTableView()
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10),
            tableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        //
        let label = header.viewWithTag(1000) as? UILabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if labels.keys.count <= section { return nil }
        let view = UITableViewHeaderFooterView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: tableView.sectionHeaderHeight))
        view.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let label = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: tableView.bounds.width, height: tableView.sectionHeaderHeight))
        label.textColor = UIColor.black
        label.text = labels[section]
        label.textAlignment = .center
        label.tag = 1000
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        return view
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

