//
//  Account-Network.swift
//  restaurants
//
//  Created by Steven Dito on 8/15/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire

extension Network {
    
    static let djangoURL = "http://127.0.0.1:8000/"
    
    private struct LogInErrorResponse: Decodable {
        var email: [String]?
        var username: [String]?
    }
    
    enum LogInRequestType {
        case logIn
        case createAccount
        case alterUserPhoneNumberOrColor
        case searchForAccounts
        case refreshAccount
        case initiatePasswordReset
        case checkPasswordResetCode
        case setNewPassword
        
        var url: String {
            switch self {
            case .logIn:
                return "login"
            case .createAccount:
                return "register"
            case .alterUserPhoneNumberOrColor, .searchForAccounts:
                return "account"
            case .refreshAccount:
                return "refresh"
            case .initiatePasswordReset, .setNewPassword:
                return "resetpassword"
            case .checkPasswordResetCode:
                return "verifypasswordreset"
            }
        }
        var method: HTTPMethod {
            switch self {
            case .logIn, .createAccount, .initiatePasswordReset, .checkPasswordResetCode:
                return .post
            case .alterUserPhoneNumberOrColor, .setNewPassword:
                return .put
            case .searchForAccounts, .refreshAccount:
                return .get
            }
        }
        var headers: HTTPHeaders? {
            switch self {
            case .alterUserPhoneNumberOrColor, .searchForAccounts, .refreshAccount:
                guard let token = Network.shared.account?.token else { return nil }
                return  ["Authorization": "Token \(token)"]
            case .logIn, .createAccount, .initiatePasswordReset, .checkPasswordResetCode, .setNewPassword:
                return nil
            }
        }
    }
    
    private func reqAccount(params: Parameters?, requestType: LogInRequestType) -> DataRequest {
        let request = AF.request(Network.djangoURL + requestType.url, method: requestType.method, parameters: params, headers: requestType.headers)
        return request
    }
    
    func retrieveToken(identifier: String, password: String, result: @escaping (Result<Bool, Errors.LogIn>) -> Void) {
        let params: Parameters = [
            "identifier": identifier,
            "password": password
        ]
        
        let req = reqAccount(params: params, requestType: .logIn)
        req.validate().responseJSON(queue: DispatchQueue.global(qos: .userInteractive)) { (response) in
            guard let data = response.data, response.error == nil else {
                result(Result.failure(.unableToLogIn))
                return
            }
            do {
                let logInResponse = try JSONDecoder().decode(Account.self, from: data)
                Network.shared.account = logInResponse
                logInResponse.writeToKeychain()
                result(Result.success(true))
            } catch let err {
                print(err)
                result(Result.failure(.unableToLogIn))
            }
        }
    }
    
    func registerUser(email: String, username: String, password: String, completion: @escaping (Result<Bool, Errors.LogIn>) -> Void) {
        let params: Parameters = [
            "email": email,
            "password": password,
            "username": username
        ]
        #warning("for loggoing in on loading screen, have a cancel button and thus having a loading screen")
        let req = reqAccount(params: params, requestType: .createAccount)
        let decoder = JSONDecoder()
        req.responseJSON(queue: DispatchQueue.global(qos: .userInteractive)) { (response) in
            
            guard let data = response.data, response.error == nil else {
                completion(Result.failure(.unableToCreateAccount))
                return
            }
            do {
                
                let registerResponse = try decoder.decode(Account.self, from: data)
                Network.shared.account = registerResponse
                registerResponse.writeToKeychain()
                completion(Result.success(true))
            } catch {
                do {
                    let res = try decoder.decode(LogInErrorResponse.self, from: data)
                    var err: Errors.LogIn {
                        if res.email != nil && res.username != nil {
                            return .emailAndUsernameInUse
                        } else if res.email != nil {
                            return .emailInUse
                        } else if res.username != nil {
                            return .emailInUse
                        } else {
                            return .unableToLogIn
                        }
                    }
                    completion(Result.failure(err))
                } catch {
                    completion(Result.failure(.unableToCreateAccount))
                }
            }
        }
    }
    
    /// if newNumber is nil, then the phone number will be deleted, both can't be nil
    func alterUserPhoneNumberOrColor(newNumber: String?, newColor: String?, complete: @escaping (Bool) -> Void) {
        var params: Parameters = [:]
        
        if let number = newNumber {
            params["phone"] = number
        }
        
        if let color = newColor {
            params["color"] = color
        }
        
        let req = reqAccount(params: params, requestType: .alterUserPhoneNumberOrColor)
        req.responseJSON(queue: .global(qos: .background)) { (response) in
            if let response = response.response {
                if response.statusCode == Network.okCode {
                    complete(true)
                } else {
                    complete(false)
                }
            } else {
                complete(false)
            }
            return
        }
    }
    
    func searchForAccountsBy(term: String, accountsFound: @escaping (Result<[Person], Errors.Friends>) -> Void) {
        let parmas: Parameters = ["search": term]
        let req = reqAccount(params: parmas, requestType: .searchForAccounts)
        req.responseJSON(queue: .global(qos: .userInteractive)) { [unowned self] (response) in
            guard let data = response.data, response.error == nil else {
                accountsFound(Result.failure(.other))
                return
            }
            
            do {
                let accounts = try self.decoder.decode([Person].self, from: data)
                accountsFound(Result.success(accounts))
            } catch {
                accountsFound(Result.failure(.other))
            }
            
        }
    }
    
    func initiatePasswordReset(usernameOrEmail: String, passwordResetRequest: @escaping (Account.PasswordResetRequest?) -> Void) {
        let params: Parameters = ["identifier":usernameOrEmail]
        let req = reqAccount(params: params, requestType: .initiatePasswordReset)
        req.responseJSON(queue: .global(qos: .userInteractive)) { [unowned self] (response) in
            guard let data = response.data, response.error == nil else {
                passwordResetRequest(nil)
                return
            }
            
            do {
                let value = try self.decoder.decode(Account.PasswordResetRequest.self, from: data)
                passwordResetRequest(value)
            } catch {
                print("Decoding error for Account.PasswordResetRequest")
                print(error)
                passwordResetRequest(nil)
            }
            
        }
    }
    
    func checkPasswordResetCode(code: String, passwordReset: Account.PasswordResetRequest?, complete: @escaping (Account.CodeResponse?) -> Void) {
        let params: Parameters = [
            "id": passwordReset?.id ?? -1, // the server will recognizer 1 as a dummy, reason is to not let user know their username or email were not valid
            "reset_code": code
        ]
        let req = reqAccount(params: params, requestType: .checkPasswordResetCode)
        req.responseJSON(queue: .global(qos: .userInteractive)) { [unowned self] (response) in
            guard let data = response.data, response.error == nil else {
                complete(nil)
                return
            }
            
            do {
                let codeResponse = try self.decoder.decode(Account.CodeResponse.self, from: data)
                complete(codeResponse)
            } catch {
                print("Error decoding Account.CodeResponse")
                print(error)
                complete(nil)
            }
        }
    }
    
    func setNewPassword(token: String, newPassword: String, success: @escaping (Bool) -> Void) {
        
        let params: Parameters = [
            "token": token,
            "new_password": newPassword
        ]
        let req = reqAccount(params: params, requestType: .setNewPassword)
        req.response(queue: .global(qos: .userInteractive)) { (response) in
            guard let statusCode = response.response?.statusCode else { success(false); return }
            success(statusCode == Network.okCode)
        }
    }
    
    func refreshAccount() {
        guard let acc = Network.shared.account else { return }
        let req = reqAccount(params: nil, requestType: .refreshAccount)
        req.responseJSON(queue: .global(qos: .background)) { [unowned self] (response) in
            //#error("need to implement in account and stuff on login/register also")
            guard let data = response.data, response.error == nil else { return }
            do {
                let refresh = try self.decoder.decode(Account.Refresh.self, from: data)
                acc.email = refresh.email
                acc.phone = refresh.phone
                acc.username = refresh.username
                acc.color = refresh.hex_color
                acc.writeToKeychain()
            } catch {
                print(error)
            }
        }
    }
    
    
}
