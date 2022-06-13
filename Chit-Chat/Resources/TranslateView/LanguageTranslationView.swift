//
//  LanguageTranslationView.swift
//  Chit-Chat
//
//  Created by KhoiLe on 13/06/2022.
//

import UIKit

class LanguageTranslationView: UIView {
    var selectedLanguageFromIndex = 0
    var selectedLanguageToIndex = 0
    var selectedFromLanguage = "English"
    var selectedToLanguage = "English"
    
    // Buttons
    let languageFromButton: UIButton = {
        let button = UIButton()
        button.setTitle("None", for: .normal)
        button.setTitleColor(Appearance.tint, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)

        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = Appearance.tint.cgColor
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    let languageToButton: UIButton = {
        let button = UIButton()
        button.setTitle("None", for: .normal)
        button.setTitleColor(Appearance.tint, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)

        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = Appearance.tint.cgColor
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.right")
        imageView.tintColor = Appearance.appColor
        
        return imageView
    }()

    
//    // Pop up
    let languageFromPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10,height: UIScreen.main.bounds.height / 2))

    let languageToPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10,height: UIScreen.main.bounds.height / 2))
    
    
    func initView() {
        self.backgroundColor = Appearance.system.withAlphaComponent(0.95)
        
        self.addSubview(languageFromButton)
        self.addSubview(languageToButton)
        self.addSubview(image)
        
        languageFromButton.addTarget(self, action: #selector(languageFromTapped), for: .touchUpInside)
        languageToButton.addTarget(self, action: #selector(languageToTapped), for: .touchUpInside)
        
//        languageFromPickerView.delegate = self
//        languageFromPickerView.dataSource = self
//        languageToPickerView.delegate = self
//        languageToPickerView.dataSource = self
        
        languageFromButton.frame = CGRect(x: 15, y: 20, width: self.width - 250, height: 35)
        
        image.frame = CGRect(x: self.width / 2 - 15, y: 25, width: 30, height: 30)
        
        languageToButton.frame = CGRect(x: self.width - 125 - 25, y: 20, width: self.width - 250, height: 35)
    }
    
    @objc func languageFromTapped() {
        let vc = UIViewController()
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 2
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        
        languageFromPickerView.selectRow(selectedLanguageFromIndex, inComponent: 0, animated: false)
        vc.view.addSubview(languageFromPickerView)
        languageFromPickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        languageFromPickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        let alert = UIAlertController(title: "Select Province/City", message: "",
            preferredStyle: .actionSheet)
                                                                    
        alert.popoverPresentationController?.sourceView = languageFromPickerView
        alert.popoverPresentationController?.sourceRect = languageFromPickerView.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {
            (UIAlertAction) in
            self.selectedLanguageFromIndex = self.languageFromPickerView.selectedRow(inComponent: 0)
            self.selectedFromLanguage = languages[self.selectedLanguageFromIndex]
            self.languageFromButton.setTitle(self.selectedFromLanguage, for: .normal)
            //self.languageFromPickerView.selectRow(self.selectedLanguageFromIndex, inComponent: 0, animated: true)
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    @objc func languageToTapped() {
        let vc = UIViewController()
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 2
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        
        languageToPickerView.selectRow(selectedLanguageToIndex, inComponent: 0, animated: false)
        vc.view.addSubview(languageToPickerView)
        languageToPickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        languageToPickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        let alert = UIAlertController(title: "Select Province/City", message: "",
            preferredStyle: .actionSheet)
                                                                    
        alert.popoverPresentationController?.sourceView = languageToPickerView
        alert.popoverPresentationController?.sourceRect = languageToPickerView.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {
            (UIAlertAction) in
            self.selectedLanguageToIndex = self.languageToPickerView.selectedRow(inComponent: 0)
            self.selectedToLanguage = languages[self.selectedLanguageToIndex]
            self.languageToButton.setTitle(self.selectedToLanguage, for: .normal)
            //self.languageToPickerView.selectRow(self.selectedLanguageToIndex, inComponent: 0, animated: true)
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}

extension LanguageTranslationView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == languageFromButton {
            
        } else if pickerView == languageToPickerView {
            
        }
    }
    
}
