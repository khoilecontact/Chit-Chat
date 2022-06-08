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
    var selectedProvince = ""
    var selectedProvinceIndex = -1
    var selectedDistrict = ""
    var currentUser = User(id: "", firstName: "", lastName: "", email: "", dob: "", isMale: true, province: "", district: "")
    
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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray2.cgColor
        
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
        field.layer.borderColor = UIColor.systemGray2.cgColor
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
        field.layer.borderColor = UIColor.systemGray2.cgColor
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
        field.layer.borderColor = UIColor.systemGray2.cgColor
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
    
    let provinceButton: UIButton = {
        let button = UIButton()
        button.setTitle("none", for: .normal)
        button.setTitleColor(Appearance.tint, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)

        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray2.cgColor
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    let districtLabel: UILabel = {
        let label = UILabel()
        label.text = "District:"
        label.textColor = Appearance.tint
        return label
    }()
    
    let districtButton: UIButton = {
        let button = UIButton()
        button.setTitle("none", for: .normal)
        button.setTitleColor(Appearance.tint, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)

        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray2.cgColor
        button.backgroundColor = .systemBackground
        return button
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
        button.setTitleColor(UIColor.white, for: .normal)
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
    
    // Pop up
    let provincePickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10,height: UIScreen.main.bounds.height / 2))
    
    let districtPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10,height: UIScreen.main.bounds.height / 2))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Personal Information"
        
        view.backgroundColor = .systemBackground
        
        provinceButton.addTarget(self, action: #selector(provinceTapped), for: .touchUpInside)
        districtButton.addTarget(self, action: #selector(districtTapped), for: .touchUpInside)
        changePasswordButton.addTarget(self, action: #selector(didTapChangePassword), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        
        // UIPickerViews delegate
        genderPicker.delegate = self
        genderPicker.dataSource = self
        provincePickerView.delegate = self
        provincePickerView.dataSource = self
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
        scrollView.addSubview(provinceButton)
        scrollView.addSubview(districtLabel)
        scrollView.addSubview(districtButton)
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
        
        provinceButton.frame = CGRect(x: genderLabel.right + 20, y: genderLabel.bottom + 30 , width: scrollView.width - 220, height: 35)
        
        districtLabel.frame = CGRect(x: 25, y: provinceLabel.bottom + 25 , width: 150, height: 52)
        
        districtButton.frame = CGRect(x: genderLabel.right + 20, y: provinceLabel.bottom + 30 , width: scrollView.width - 220, height: 35)
        
        changePasswordButton.frame = CGRect(x: 20, y: districtLabel.bottom + 40, width: scrollView.width - 120, height: 40)
        
        saveButton.frame = CGRect(x: 30, y: changePasswordButton.bottom + 30, width: scrollView.width - 60, height: 52)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to download image URL: \(error)")
                self?.imageView.image = UIImage(systemName: "person.circle")?.withTintColor(Appearance.tint)
                
                break
            
            case .success(let url):
                self?.imageView.sd_setImage(with: url, completed: nil)
            }
        })

        
        DatabaseManager.shared.getDataFor(path: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let data):
                guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                      let lastName = userData["last_name"] as? String,
                      let bio = userData["bio"] as? String,
                      let id = userData["id"] as? String,
                      let isMale = userData["is_male"] as? Bool,
                      let province = userData["province"] as? String,
                      let district = userData["district"] as? String,
                      let dob = userData["dob"] as? String
                else {
                          return
                      }
                
                self?.selectedGender = isMale ? "Male" : "Female"
                self?.selectedProvince = province
                self?.selectedProvinceIndex = city.firstIndex(of: province) ?? 0
                self?.selectedDistrict = district
                
                self?.currentUser = User(id: id, firstName: firstName, lastName: lastName, email: email, dob: dob, isMale: isMale, province: "", district: "")
                self?.firstNameField.text = firstName
                self?.lastNameField.text = lastName
                self?.bioField.text = bio
                
                if let dobDate = dob.toDate(dateFormat: "dd-MM-yyyy") {
                    self?.dobField.date = dobDate
                }
                
                if province != "" {
                    let provinceIndex = city.firstIndex(of: province)
                    self?.provincePickerView.selectRow(provinceIndex ?? 0, inComponent: 0, animated: false)
                    self?.provinceButton.setTitle(province, for: .normal)
                    
                    let districtIndex = districts[provinceIndex ?? 0].firstIndex(of: district)
                    self?.districtPicker.selectRow(districtIndex ?? 0, inComponent: 0, animated: false)
                    self?.districtButton.setTitle(district, for: .normal)
                    self?.districtPicker.reloadAllComponents()
                }
                
                // Disable change password button if user use linked account
                let user = Auth.auth().currentUser
                let provider = user!.providerData[0].providerID
                
                if provider != "password" {
                    self?.changePasswordButton.isEnabled = false
                }
                
                break
            case .failure(let error):
                print("Error in getting user info: \(error)")
                break
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapChangeProfilePicture() {
        presentPhotoActionSheet()
    }
    
    @objc func provinceTapped() {
        let vc = UIViewController()
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 2
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        
        
        provincePickerView.selectRow(selectedProvinceIndex, inComponent: 0, animated: false)
        vc.view.addSubview(provincePickerView)
        provincePickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        provincePickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        let alert = UIAlertController(title: "Select Province/City", message: "",
            preferredStyle: .actionSheet)
                                                                    
        alert.popoverPresentationController?.sourceView = provincePickerView
        alert.popoverPresentationController?.sourceRect = provincePickerView.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {
            (UIAlertAction) in
            self.selectedProvinceIndex = self.provincePickerView.selectedRow(inComponent: 0)
            self.selectedProvince = city[self.selectedProvinceIndex]
            self.provinceButton.setTitle(self.selectedProvince, for: .normal)
            
            DispatchQueue.main.async {
                self.districtPicker.reloadAllComponents()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func districtTapped() {
        let vc = UIViewController()
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 2
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        
        
        districtPicker.selectRow(0, inComponent: 0, animated: false)
        vc.view.addSubview(districtPicker)
        districtPicker.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        districtPicker.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        let alert = UIAlertController(title: "Select Province/City", message: "",
            preferredStyle: .actionSheet)
                                                                    
        alert.popoverPresentationController?.sourceView = districtPicker
        alert.popoverPresentationController?.sourceRect = districtPicker.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {
            (UIAlertAction) in
            self.selectedDistrict = districts[self.selectedProvinceIndex][self.districtPicker.selectedRow(inComponent: 0)]
            self.districtButton.setTitle(self.selectedDistrict, for: .normal)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapChangePassword() {
        let vc = ChangePasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapSave() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        bioField.resignFirstResponder()
        
        let isValid = validate()
        
        if !isValid {
            alertUserLoginError()
        }
        
        let currentUser = Auth.auth().currentUser
        
        spinner.show(in: view)
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let bio = bioField.text else {
            return
        }
        
        let dob = dobField.date.toString(dateFormat: "dd-MM-YYYY")
        let isMale = selectedGender == "Male" ? true : false
        
        let updateArray: [String: Any] = [
            "first_name" : firstName,
            "last_name" : lastName,
            "bio" : bio,
            "dob" : dob,
            "is_male" : isMale,
            "province" : selectedProvince,
            "district" : selectedDistrict
        ]
        
        let user = User(id: currentUser?.uid ?? "", firstName: firstName, lastName: lastName, email: email, dob: dob, isMale: isMale, province: selectedProvince, district: selectedDistrict)
        
        DatabaseManager.shared.updateUserInfo(with: email, changesArray: updateArray, completion: { [weak self] success in
            print(success)
            if success {
                //upload image
                guard let image = self?.imageView.image, let data = image.pngData() else
                {
                    return
                }
                
                let fileName = user.profilePictureFileName
                StorageManager.shared.uploadFrofilePicture(with: data, fileName: fileName, completion: { result in
                    switch result {
                    case .success(let downloadUrl):
                        UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                    case .failure(let error):
                        print("Storage manager error: \(error)")
                        
                        let arlet = UIAlertController(title: "Failed!", message: "Your avatar updating failed! Please try again later", preferredStyle: .alert)
                        arlet.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self?.present(arlet, animated: true, completion: nil)
                        return
                    }
                })
                
                let arlet = UIAlertController(title: "Success!", message: "Your information has been updated", preferredStyle: .alert)
                arlet.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(arlet, animated: true, completion: nil)
                
            } else {
                let arlet = UIAlertController(title: "Failed!", message: "Your information updating failed! Please try again later", preferredStyle: .alert)
                arlet.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(arlet, animated: true, completion: nil)
            }
        })
        
        DispatchQueue.main.async {
            self.spinner.dismiss(animated: true)
        }
    }
    
    func validate() -> Bool {
        guard let firstName = firstNameField.text, !firstName.isEmpty else {
            showingAlert = true
            alertMessage = "Please enter your Firstname"
            return false
        }
        
        guard let lastName = lastNameField.text, !lastName.isEmpty else {
            showingAlert = true
            alertMessage = "Please enter your Lastname"
            return false
        }
        
//        if selectedProvince == "" {
//            showingAlert = true
//            alertMessage = "Please select your province/city"
//            return false
//        }
//
//        if selectedDistrict == "" {
//            showingAlert = true
//            alertMessage = "Please select your district"
//            return false
//        }
        
        return true
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Opps!", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
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
        else if pickerView == districtPicker {
            return districts[selectedProvinceIndex].count
        }
        // If it s the district picker
        else if pickerView == provincePickerView {
            return city.count
        }
        
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // If it is the gender picker
        if pickerView == genderPicker {
            return genderArr[row]
        }
        // If it s the district picker
        else if pickerView == districtPicker {
            return districts[selectedProvinceIndex][row]
        }
        // If it s the provice picker
        else if pickerView == provincePickerView {
            return city[row]
        }
        
        return "none"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // If it is the gender picker
        if pickerView == genderPicker {
            selectedGender = genderArr[row] as String
        }
        // If it s the district picker
        else if pickerView == districtPicker {
            selectedDistrict = districts[selectedProvinceIndex][row] as String
        }
        // If it s the provice picker
        else if pickerView == provincePickerView{
        }
        
    }
    
    
}

