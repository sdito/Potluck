//
//  Account.swift
//  restaurants
//
//  Created by Steven Dito on 8/16/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation



class Account: Decodable {
    
    static let emailKey = "django-keychain-email"
    static let usernameKey = "django-keychain-username"
    static let idKey = "django-keychain-id"
    static let tokenKey = "django-keychain-token"
    static let phoneKey = "django-keychain-phone"
    
    var email: String
    var username: String
    let id: Int
    let token: String
    var phone: String?
    
    init(email: String, username: String, id: Int, token: String, phone: String?) {
        self.email = email
        self.username = username
        self.id = id
        self.token = token
        self.phone = phone
    }
    
    static func readFromKeychain() -> Account? {
        let keyChain = Network.shared.keychain
        let username = keyChain.get(Account.usernameKey)
        let email = keyChain.get(Account.emailKey)
        let token = keyChain.get(Account.tokenKey)
        let phone = keyChain.get(Account.phoneKey)
        let id = Int(keyChain.get(Account.idKey) ?? "-1")
        
        if let email = email, let token = token, let username = username, let id = id {
            let account = Account(email: email, username: username, id: id, token: token, phone: phone)
            return account
        } else {
            return nil
        }
    }
    
    func writeToKeychain() {
        let keyChain = Network.shared.keychain
        keyChain.set(self.username, forKey: Account.usernameKey)
        keyChain.set(self.email, forKey: Account.emailKey)
        keyChain.set(self.token, forKey: Account.tokenKey)
        keyChain.set("\(self.id)", forKey: Account.idKey)
        
        if let phone = self.phone {
            keyChain.set(phone, forKey: Account.phoneKey)
        } else {
            keyChain.delete(Account.phoneKey)
        }
        
        NotificationCenter.default.post(name: .userLoggedIn, object: self)
    }
    
    func updatePhone(newPhone: String?) {
        self.phone = newPhone
        let keyChain = Network.shared.keychain
        keyChain.delete(Account.phoneKey)
        if let phone = newPhone {
            keyChain.set(phone, forKey: Account.phoneKey)
        }
    }
    
    func logOut() {
        let keyChain = Network.shared.keychain
        keyChain.delete(Account.usernameKey)
        keyChain.delete(Account.emailKey)
        keyChain.delete(Account.tokenKey)
        keyChain.delete(Account.phoneKey)
        keyChain.delete(Account.idKey)
        Network.shared.account = nil
        
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }
    
    
}
