//
//  PersonalInformationViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 20/02/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD

class PersonalInformationViewController: UIViewController, UINavigationControllerDelegate {
    var showingAlert = false
    var alertMessage = ""
    var genderArr = ["Male", "Female"]
    var selectedGender = "Male"
    
    private let spinner = JGProgressHUD(style: .dark)
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.contentSize = CGSize(width: 320, height: 900)
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = Appearance.tint
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // Continue to next field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = Appearance.tint.cgColor
        field.placeholder = "First Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        
        return field
    }()
    
    let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // Continue to next field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = Appearance.tint.cgColor
        field.placeholder = "Last Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        
        return field
    }()
    
    let bioField: UITextField = {
        let field = UITextField()
        
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // Continue to next field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = Appearance.tint.cgColor
        field.placeholder = "Enter your bio"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        
        return field
    }()
    
    let dobLabel: UILabel = {
        let label = UILabel()
        label.text = "Day of birth:"
        label.textColor = Appearance.tint
        return label
    }()
    
    let dobField: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = .autoupdatingCurrent
        picker.date = .now
        picker.datePickerMode = .date
        
        return picker
    }()
    
    let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Gender:"
        label.textColor = Appearance.tint
        return label
    }()
    
    let genderPicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    let provinceLabel: UILabel = {
        let label = UILabel()
        label.text = "Province/City:"
        label.textColor = Appearance.tint
        return label
    }()
    
    let provincePicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    let districtLabel: UILabel = {
        let label = UILabel()
        label.text = "District:"
        label.textColor = Appearance.tint
        return label
    }()
    
    let districtPicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    let changePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Password", for: .normal)
        button.backgroundColor = UIColor.systemGray2
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.titleLabel?.textAlignment = .center
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Personal Information"
        
        view.backgroundColor = .systemBackground
        
        // UIPickerViews delegate
        genderPicker.delegate = self
        genderPicker.dataSource = self
        provincePicker.delegate = self
        provincePicker.dataSource = self
        districtPicker.delegate = self
        districtPicker.dataSource = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(bioField)
        scrollView.addSubview(dobLabel)
        scrollView.addSubview(dobField)
        scrollView.addSubview(genderLabel)
        scrollView.addSubview(genderPicker)
        scrollView.addSubview(provinceLabel)
        scrollView.addSubview(provincePicker)
        scrollView.addSubview(districtLabel)
        scrollView.addSubview(districtPicker)
        scrollView.addSubview(changePasswordButton)
        scrollView.addSubview(saveButton)
        
        imageView.isUserInteractionEnabled =  true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: size, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        firstNameField.frame = CGRect(x: 20, y: imageView.bottom + 25, width: scrollView.width - 235, height: 52)
        
        lastNameField.frame = CGRect(x: firstNameField.right + 15, y: imageView.bottom + 25, width: scrollView.width - 230, height: 52)
        
        bioField.frame = CGRect(x: 20, y: firstNameField.bottom + 20, width: scrollView.width - 60, height: 100)
        
        dobLabel.frame = CGRect(x: 25, y: bioField.bottom + 20 , width: 150, height: 52)
        
        dobField.frame = CGRect(x: dobLabel.right + 20, y: bioField.bottom + 20 , width: scrollView.width - 230, height: 52)
        
        genderLabel.frame = CGRect(x: 25, y: dobLabel.bottom + 25 , width: 150, height: 52)
        
        genderPicker.frame = CGRect(x: genderLabel.right + 20, y: dobLabel.bottom + 10 , width: scrollView.width - 220, height: 100)
        
        provinceLabel.frame = CGRect(x: 25, y: genderLabel.bottom + 25 , width: 250, height: 52)
        
        provincePicker.frame = CGRect(x: genderLabel.right + 20, y: genderLabel.bottom + 10 , width: scrollView.width - 220, height: 100)
        
        districtLabel.frame = CGRect(x: 25, y: provinceLabel.bottom + 25 , width: 150, height: 52)
        
        districtPicker.frame = CGRect(x: genderLabel.right + 20, y: provinceLabel.bottom + 10 , width: scrollView.width - 220, height: 100)
        
        changePasswordButton.frame = CGRect(x: 20, y: districtLabel.bottom + 40, width: scrollView.width - 120, height: 40)
        
        saveButton.frame = CGRect(x: 30, y: changePasswordButton.bottom + 30, width: scrollView.width - 60, height: 52)
    }
    
    @objc func didTapChangeProfilePicture() {
        presentPhotoActionSheet()
    }
}

extension PersonalInformationViewController: UIImagePickerControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Where do you want to take picture from", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage]
        imageView.image = selectedImage as? UIImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}


extension PersonalInformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // If it is the gender picker
        if pickerView == genderPicker {
            return genderArr.count
        }
        // If it s the provice picker
        else if pickerView == provincePicker {
            return 100
        }
        // If it s the district picker
        else if pickerView == districtPicker {
            return 100
        }
        
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // If it is the gender picker
        if pickerView == genderPicker {
            return genderArr[row]
        }
        // If it s the provice picker
        else if pickerView == provincePicker {
            return "province"
        }
        // If it s the district picker
        else if pickerView == districtPicker {
            return "district"
        }
        
        return "Failed to load"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // If it is the gender picker
        if pickerView == genderPicker {
            selectedGender = genderArr[row] as String
        }
        // If it s the provice picker
        else if pickerView == provincePicker {
            
        }
        // If it s the district picker
        else if pickerView == districtPicker {
            
        }
    }
    
    
}

