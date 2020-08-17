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
    
    
    enum LogInRequestType {
        case logIn
        case createAccount
    }
    
    private func reqLogIn(params: Parameters, requestType: LogInRequestType) -> DataRequest {
        var url: String {
            switch requestType {
            case .logIn:
                return "login"
            case .createAccount:
                return "register"
            }
        }
        let request = AF.request(Network.djangoURL + url, method: HTTPMethod.post, parameters: params)
        return request
    }
    
    func retrieveToken(email: String, password: String, result: @escaping (Result<Bool, Errors.LogIn>) -> Void) {
        let params: Parameters = [
            "username": email,
            "password": password
        ]
        
        let req = reqLogIn(params: params, requestType: .logIn)
        req.validate().responseJSON { (response) in
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
                result(Result.failure(.other))
            }
        }
    }
    
    func registerUser(email: String, username: String, password: String, completion: @escaping (Result<Bool, Errors.LogIn>) -> Void) {
        let params: Parameters = [
            "email": email,
            "password": password,
            "username": username
        ]
        
        let req = reqLogIn(params: params, requestType: .createAccount)
        
        req.validate().responseJSON { (response) in
            guard let data = response.data, response.error == nil else {
                completion(Result.failure(.unableToCreateAccount))
                return
            }
            
            do {
                let registerResponse = try JSONDecoder().decode(Account.self, from: data)
                Network.shared.account = registerResponse
                registerResponse.writeToKeychain()
                completion(Result.success(true))
            } catch {
                
            }
            
            
            
        }
        
    }
    
}
