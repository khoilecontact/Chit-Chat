//
//  RegisterViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 03/02/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController, UINavigationControllerDelegate {
    var showingAlert = false
    var alertMessage = ""
    var genderArr = ["Male", "Female"]
    var selectedGender = "Male"
    
    private let spinner = JGProgressHUD(style: .dark)
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        return imageView
    }()
    
    let imageLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose your avartar"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // Continue to next field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 0
        field.layer.borderColor = UIColor.black.cgColor
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
        field.layer.borderWidth = 0
        field.layer.borderColor = UIColor.black.cgColor
        field.placeholder = "Last Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        
        return field
    }()
    
    let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // Continue to next field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 0
        field.layer.borderColor = UIColor.black.cgColor
        field.placeholder = "Email..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        
        return field
    }()
    
    let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 0
        field.layer.borderColor = UIColor.black.cgColor
        field.placeholder = "Password... (>= 6 letters)"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        field.isSecureTextEntry = true
        
        return field
    }()
    
    let rePasswordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 0
        field.layer.borderColor = UIColor.black.cgColor
        field.placeholder = "Re-Password..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        field.isSecureTextEntry = true
        
        return field
    }()
    
    let dobLabel: UILabel = {
        let label = UILabel()
        label.text = "Day of birth:"
        label.textColor = .black
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
        label.textColor = .black
        return label
    }()
    
    let genderPicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
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

        title = "Sign up"
        
        view.backgroundColor = .systemBackground
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign up", style: .done, target: self, action: #selector(registerButtonTapped))
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        genderPicker.delegate = self
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(imageLabel)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(rePasswordField)
        scrollView.addSubview(dobLabel)
        scrollView.addSubview(dobField)
        scrollView.addSubview(genderLabel)
        scrollView.addSubview(genderPicker)
        scrollView.addSubview(registerButton)
        
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
        
        imageLabel.frame = CGRect(x: 20, y: imageView.bottom + 5, width: scrollView.width - 50, height: 25)
        
        firstNameField.frame = CGRect(x: 20, y: imageLabel.bottom + 25, width: scrollView.width - 235, height: 52)
        
        lastNameField.frame = CGRect(x: firstNameField.right + 15, y: imageLabel.bottom + 25, width: scrollView.width - 230, height: 52)
        
        emailField.frame = CGRect(x: 20, y: firstNameField.bottom + 20, width: scrollView.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 20, y: emailField.bottom + 20 , width: scrollView.width - 60, height: 52)
        
        rePasswordField.frame = CGRect(x: 20, y: passwordField.bottom + 20 , width: scrollView.width - 60, height: 52)
        
        dobLabel.frame = CGRect(x: 25, y: rePasswordField.bottom + 20 , width: 150, height: 52)
        
        dobField.frame = CGRect(x: dobLabel.right + 20, y: rePasswordField.bottom + 20 , width: scrollView.width - 230, height: 52)
        
        genderLabel.frame = CGRect(x: 25, y: dobLabel.bottom + 25 , width: 150, height: 52)
        
        genderPicker.frame = CGRect(x: genderLabel.right + 20, y: dobLabel.bottom + 10 , width: scrollView.width - 220, height: 100)
        
        registerButton.frame = CGRect(x: scrollView.width / 4, y: genderPicker.bottom + 30 , width: scrollView.width - 175, height: 52)
        
        // Add underlines
        let firstNameFieldBottomLine = CALayer()
        firstNameFieldBottomLine.backgroundColor = UIColor.black.cgColor
        firstNameFieldBottomLine.frame = CGRect(x: 5, y: firstNameField.frame.height - 2, width: firstNameField.frame.width - 1, height: 1)
        firstNameField.layer.addSublayer(firstNameFieldBottomLine)
        
        let lastNameFieldBottomLine = CALayer()
        lastNameFieldBottomLine.backgroundColor = UIColor.black.cgColor
        lastNameFieldBottomLine.frame = CGRect(x: 5, y: lastNameField.frame.height - 2, width: lastNameField.frame.width - 1, height: 1)
        lastNameField.layer.addSublayer(lastNameFieldBottomLine)
        
        let emailFieldBottomLine = CALayer()
        emailFieldBottomLine.backgroundColor = UIColor.black.cgColor
        emailFieldBottomLine.frame = CGRect(x: 5, y: emailField.frame.height - 2, width: emailField.frame.width - 1, height: 1)
        emailField.layer.addSublayer(emailFieldBottomLine)
        
        let passwordFieldBottomLine = CALayer()
        passwordFieldBottomLine.backgroundColor = UIColor.black.cgColor
        passwordFieldBottomLine.frame = CGRect(x: 5, y: passwordField.frame.height - 2, width: passwordField.frame.width - 1, height: 1)
        passwordField.layer.addSublayer(passwordFieldBottomLine)
        
        let rePasswordFieldBottomLine = CALayer()
        rePasswordFieldBottomLine.backgroundColor = UIColor.black.cgColor
        rePasswordFieldBottomLine.frame = CGRect(x: 5, y: rePasswordField.frame.height - 2, width: rePasswordField.frame.width - 1, height: 1)
        rePasswordField.layer.addSublayer(rePasswordFieldBottomLine)
        
        let dobBottomLine = CALayer()
        dobBottomLine.backgroundColor = UIColor.black.cgColor
        dobBottomLine.frame = CGRect(x: 0, y: dobLabel.frame.height - 4, width: dobLabel.frame.width - 1, height: 1)
        dobLabel.layer.addSublayer(dobBottomLine)
        
        let genderLabelBottomLine = CALayer()
        genderLabelBottomLine.backgroundColor = UIColor.black.cgColor
        genderLabelBottomLine.frame = CGRect(x: 0, y: genderLabel.frame.height - 4, width: genderLabel.frame.width - 1, height: 1)
        genderLabel.layer.addSublayer(genderLabelBottomLine)
        
    }
    
    @objc func didTapChangeProfilePicture() {
        presentPhotoActionSheet()
    }
    
    @objc func registerButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        let isValid = validate()
        
        if !isValid {
            alertUserLoginError()
        }
        
        guard let email = emailField.text, let password = passwordField.text, let firstName = firstNameField.text, let lastName = lastNameField.text else {
            return
        }
        
        let dob = dobField.date.toString(dateFormat: "dd-MM-YYYY")
        
        var isMale = true
        switch selectedGender {
        case "Female":
            isMale = false
            break
            
        default:
            isMale = true
            break
        }
        
        spinner.show(in: view)

        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard !exists else {
                self?.showingAlert = true
                self?.alertMessage = "Email already exists!"
                self?.alertUserLoginError()
                return
            }
        })

        
        // Firebase Register
        if !showingAlert {
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in
                
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                let userId = UUID().uuidString
                guard authResult != nil, error == nil else {
                    print("Error creating User: \(String(describing: error))")
                    return
                }
                
                guard let firstName = self?.firstNameField.text, let lastName = self?.lastNameField.text else {
                    return
                }
                
                let user = User(id: userId, firstName: firstName, lastName: lastName, email: email, dob: dob, isMale: isMale)
                
                DatabaseManager.shared.insertUser(with: user, completion: {success in
                    if success {
                        //upload image
                        guard let image = self?.imageView.image, let data = image.pngData() else {
                            return
                        }
                        
                        UserDefaults.standard.setValue(email, forKey: "email")
                        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                        
                        let fileName = user.profilePictureFileName
                        StorageManager.shared.uploadFrofilePicture(with: data, fileName: fileName, completion: { result in
                            switch result {
                                case .success(let downloadUrl):
                                    UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                   print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    } 
                })
                
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Opps!", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
//    @objc func didTapRegister() {
//        let vc = RegisterViewController()
//        vc.title = "Create Account"
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
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
        
        guard let email = emailField.text, !email.isEmpty else {
            showingAlert = true
            alertMessage = "Please enter an Email"
            return false
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            showingAlert = true
            alertMessage = "Please enter a Password"
            return false
        }
        
        guard let rePassword = rePasswordField.text, !rePassword.isEmpty else {
            showingAlert = true
            alertMessage = "Please repeat your Password"
            return false
        }
        
        if !email.contains("@") && email.contains(",") && email.contains("-") {
            showingAlert = true
            alertMessage = "Please input a valid email"
            return false
        }
        
        if password.count < 6 {
            showingAlert = true
            alertMessage = "Password must contains at least 6 letters"
            return false
        }
        
        if password != rePassword {
            showingAlert = true
            alertMessage = "Your repassword does not match your password"
            return false
        }
        
        
        return true
    }
   
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate {
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


extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderArr.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = genderArr[row] as String
    }
    
    
}

