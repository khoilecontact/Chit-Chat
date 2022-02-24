//
//  DarkModeViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 20/02/2022.
//

import UIKit

class DarkModeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let options = ["Light", "Dark", "System"]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DarkModeCell.self, forCellReuseIdentifier: DarkModeCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 15
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        tableView.frame = CGRect(x: 20, y: 20, width: scrollView.frame.width - 40, height: 156)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: DarkModeCell.identifier, for: indexPath) as! DarkModeCell
        
        if let selectedAppearance = UserDefaults.standard.value(forKey: "appearance") as? String {
            if name == selectedAppearance {
                cell.configure(with: name, isChecked: true)
            } else {
                cell.configure(with: name, isChecked: false)
            }
        } else {
            UserDefaults.standard.set("Light", forKey: "appearance")
            if name == "Light" {
                cell.configure(with: name, isChecked: true)
            } else {
                cell.configure(with: name, isChecked: false)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMode = options[indexPath.row]
        
        switch selectedMode {
        case "Light":
            if #available(iOS 13.0, *) {
                view.window?.overrideUserInterfaceStyle = .light
                UserDefaults.standard.set("Light", forKey: "appearance")
            }
            break
        case "Dark":
            if #available(iOS 13.0, *) {
                view.window?.overrideUserInterfaceStyle = .dark
                UserDefaults.standard.set("Dark", forKey: "appearance")
            }
            break
        default:
            if #available(iOS 13.0, *) {
                view.window?.overrideUserInterfaceStyle = .unspecified
                UserDefaults.standard.set("System", forKey: "appearance")
            }
            break
        }
        
        
        
    }

}

class DarkModeCell: UITableViewCell {
    static let identifier = "DarkModeCell"
    
    private let cellLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private let isCheckLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellLabel)
        contentView.addSubview(isCheckLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellLabel.frame = CGRect(x: 10, y: 0, width: contentView.width - 40, height: 52)
        
        isCheckLabel.frame = CGRect(x: cellLabel.right, y: 0, width: 20, height: 52)
    }
    
    public func configure(with name: String, isChecked: Bool) {
        cellLabel.text = name
        if isChecked {
            isCheckLabel.text = "✓"
        }
    }
    
    public func checkLabel() {
        isCheckLabel.text = "✓"
    }
    
    public func unCheckLabel() {
        isCheckLabel.text = ""
    }
}
