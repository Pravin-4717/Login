//
//  ViewController.swift
//  LoginTest
//
//  Created by Pravin Palaniappan on 06/01/20.
//  Copyright © 2020 Pravin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		let u1 = User(firstName: "Sunil", lastName: "Shetty", emailId: "sunil@gmail.com", password: "Pra_1015")
		let u2 = User(firstName: "Sunil", lastName: "Shetty", emailId: "sunilgmail.com", password: "Pravin")
		let u3 = User(firstName: "Sunil", lastName: "Shetty", emailId: "sunil@gmail", password: "Pra1015")
		let u4 = User(firstName: "Sunil", lastName: "Shetty", emailId: "sunil.com", password: "1015")
//		signUp(user: u1)
//		signUp(user: u2)
//		signUp(user: u3)
//		signUp(user: u4)
		signIn(user: u1)

	}
	func signIn(user: User) {
		Auth.auth().signIn(withEmail: user.emailId, password: user.password) { (result, error) in
			if let error = error {
				print("login error: ", error.localizedDescription)
				return
			} else if let result = result {
				let db = Firestore.firestore()
				let collection = db.collection("Users")
				collection.document(result.user.uid).getDocument { (document, error) in
					guard error == nil else {
						print(error?.localizedDescription ?? "" )
						return
					}
					if let doc = document, doc.exists {
						if let data = doc.data(),
						let user = User.getUser(data: data) {
							print("Welcome \(user.firstName) \(user.lastName)")
						}
					}
				}

			}
		}
	}
	func signUp(user: User) {
		guard user.emailId.isValidEmail, user.password.isValidPassword else {
			print("email \(user.emailId): \(user.emailId.isValidEmail)")
			print("password \(user.password): \(user.password.isValidPassword)")
			return
		}
		print("valid: \(user)")
		Auth.auth().createUser(withEmail: user.emailId, password: user.password) { (result, error) in
			guard error == nil else {
				print("create user error: ", error?.localizedDescription)
				return
			}
			if let result = result {
				let uid = result.user.uid
				print("pravin debug: ", uid)
				let db = Firestore.firestore()
				let collection = db.collection("Users")
				collection.document(uid).setData(user.data) {
					if let docError = $0 {
						print("add doc error: ", docError.localizedDescription)
					}
				}
			}
		}
	}

}

struct User {
	var firstName: String
	var lastName: String
	var emailId: String
	var password: String

	enum Key: String {
		typealias RawValue = String

		case firstName
		case lastName
	}

	var data: [String: String] {
		return [
			Key.firstName.rawValue: firstName,
			Key.lastName.rawValue: lastName,
		]
	}

	static func getUser(data: [String: Any]) -> User? {
		guard let firstName = data[Key.firstName.rawValue] as? String,
		let lastName = data[Key.lastName.rawValue] as? String else {
			print("Couldnt creaste user with the data")
			return nil
		}
		let user = User(firstName: firstName, lastName: lastName, emailId: "", password: "")
		return user
	}
}

extension String {
	var isValidEmail: Bool {
		return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
	}

	var isValidPassword: Bool {
//		Minimum 8 characters at least 1 Alphabet and 1 Number
		let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
		return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)

	}

}
