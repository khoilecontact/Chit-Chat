//
//  PopUpProvinceViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 21/02/2022.
//

import UIKit

class PopUpProvinceViewController: UIViewController {
    
    let provincePicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose a Province/City"
        
        view.backgroundColor = .systemBackground
        
//        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height / 2)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        provincePicker.delegate = self
        provincePicker.dataSource = self
            
        view.addSubview(provincePicker)
        provincePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        provincePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    @objc func doneTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension PopUpProvinceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return city.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return city[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        RegisterViewController.selectedProvince = city[row] as String
    }
}

//extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//            return 1
//        }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        // If it is the gender picker
//        if pickerView == genderPicker {
//            return genderArr.count
//        }
//        // If it s the provice picker
//        else if pickerView == provinceButton {
//            return city.count
//        }
//        // If it s the district picker
//        else if pickerView == districtPicker {
//            return districts[selectedProvinceIndex + 1].count
//        }
//
//        return 0
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        // If it is the gender picker
//        if pickerView == genderPicker {
//            return genderArr[row]
//        }
//        // If it s the provice picker
//        else if pickerView == provinceButton {
//            return city[row]
//        }
//        // If it s the district picker
//        else if pickerView == districtPicker {
//            return districts[selectedProvinceIndex + 1][row]
//        }
//
//        return "Failed to load"
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        // If it is the gender picker
//        if pickerView == genderPicker {
//            selectedGender = genderArr[row] as String
//        }
//        // If it s the provice picker
//        else if pickerView == provinceButton {
//            selectedProvince = city[row] as String
//            selectedProvinceIndex = row
//        }
//        // If it s the district picker
//        else if pickerView == districtPicker {
//            selectedDistrict = districts[selectedProvinceIndex + 1][row] as String
//        }
//    }
//
//
//}
