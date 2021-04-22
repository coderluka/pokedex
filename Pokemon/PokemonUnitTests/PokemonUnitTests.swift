//
//  PokemonUnitTests.swift
//  PokemonUnitTests
//
//  Created by Johanna Geretschläger on 22.04.21.
//

import XCTest
import Firebase
import FirebaseAuth
@testable import Pokemon

class PokemonUnitTests: XCTestCase {
    
    var vc: LoginViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        FirebaseApp.configure()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        vc = storyboard.instantiateViewController(identifier: "loginVC") as! LoginViewController
        self.vc.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.signOutCurrentUser()
    }

    func testLoginWithCorrectCredentials() throws {
        Auth.auth().signIn(withEmail: "Ash@Ketchup.com", password: "1234567890", completion: { authResult, error in
            guard let signedInUser = authResult?.user, error == nil else {
                let signInError = error as! NSError
                print("Login failed!")
                return
            }
            print("Login successful!")
        })
        sleep(5)
        XCTAssertEqual(Auth.auth().currentUser?.email, "ash@ketchup.com")
    }
    
    /*func testLoginWithIncorrectCredentials() throws {
        print("hellofromtest2")
        Auth.auth().signIn(withEmail: "Ash@Ketchup.com", password: "password", completion:  { authResult, error in
            guard let signedInUser = authResult?.user, error == nil else {
                let signInError = error as! NSError
                print("Login failed!")
                return
            }
            print("Login successful!")
        })
        sleep(5)
        XCTAssertNil(Auth.auth().currentUser)
    }*/

}

extension PokemonUnitTests {
    func signOutCurrentUser() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully!")
        } catch let error {
            print("Could not sign out user: \(error.localizedDescription)")
        }
    }
}

