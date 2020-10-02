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
        case alterPhone
        
        var url: String {
            switch self {
            case .logIn:
                return "login"
            case .createAccount:
                return "register"
            case .alterPhone:
                return "account"
            }
        }
        var method: HTTPMethod {
            switch self {
            case .logIn, .createAccount:
                return .post
            case .alterPhone:
                return .put
            }
        }
        var headers: HTTPHeaders? {
            switch self {
            case .alterPhone:
                guard let token = Network.shared.account?.token else { return nil }
                return  ["Authorization": "Token \(token)"]
            case .logIn, .createAccount:
                return nil
            }
        }
    }
    
    private func reqAccount(params: Parameters, requestType: LogInRequestType) -> DataRequest {
        let request = AF.request(Network.djangoURL + requestType.url, method: requestType.method, parameters: params, headers: requestType.headers)
        return request
    }
    
    func retrieveToken(email: String, password: String, result: @escaping (Result<Bool, Errors.LogIn>) -> Void) {
        let params: Parameters = [
            "username": email,
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
        
        let req = reqAccount(params: params, requestType: .createAccount)
        let decoder = JSONDecoder()
        req.responseJSON(queue: DispatchQueue.global(qos: .userInteractive)) { (response) in
            
            for _ in 1...10 {
                print(response.value)
            }
            
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
    
    /// if newNumber is nil, then the phone number will be deleted
    func alterUserPhoneNumber(newNumber: String?, complete: @escaping (Bool) -> Void) {
        var params: Parameters = [:]
        if let number = newNumber {
            params["phone"] = number
        }
        
        let req = reqAccount(params: params, requestType: .alterPhone)
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
    
    
}
