//
//  Person-Network.swift
//  restaurants
//
//  Created by Steven Dito on 9/29/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import Alamofire

extension Network {
    
    private enum PersonRequestType {
        case relatedPeople
        case answerFriendRequest
        case sendFriendRequest
        
        func url(int: Int? = nil) -> String {
            switch self {
            case .relatedPeople:
                return "findusers"
            case .answerFriendRequest:
                return "friendrequest/\(int!)/"
            case .sendFriendRequest:
                return "friendrequest"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .relatedPeople:
                return .get
            case .answerFriendRequest:
                return .put
            case .sendFriendRequest:
                return .post
            }
        }
    }
    
    private func reqPerson(params: Parameters, requestType: PersonRequestType) -> DataRequest? {
        guard let token = Network.shared.account?.token else { return nil }
        let headers: HTTPHeaders = ["Authorization": "Token \(token)"]
        let request = AF.request(Network.djangoURL + requestType.url(), method: requestType.method, parameters: params, headers: headers)
        return request
    }
    
    func getPeopleToAddForUser(phoneNumbers: [String], peopleFound: @escaping (Result<Person.FindRelated, Errors.Friends>) -> Void) {
        guard phoneNumbers.count > 0 else { peopleFound(Result.failure(.other)); return }
        let params: Parameters = ["numbers": phoneNumbers.joined(separator: ",")]
        
        guard let req = reqPerson(params: params, requestType: .relatedPeople) else { return }
        req.responseJSON(queue: DispatchQueue.global(qos: .userInteractive)) { [unowned self] (response) in
            guard let data = response.data, response.error == nil else {
                peopleFound(Result.failure(.other))
                return
            }
            
            do {
                let accountsFound = try self.decoder.decode(Person.FindRelated.self, from: data)
                peopleFound(Result.success(accountsFound))
            } catch {
                peopleFound(Result.failure(.other))
                return
            }
        }
    }
    
    func answerFriendRequest(request: Person.PersonRequest, accept: Bool, complete: @escaping (Bool) -> Void) {
        #warning("need to complete and implement")
        let params: [String:Any] = ["accept_request": accept]
        guard let req = reqPerson(params: params, requestType: .answerFriendRequest) else { complete(false); return }
        req.responseJSON(queue: .global(qos: .background)) { (response) in
            <#code#>
        }
    }
    
    func sendFriendRequest(toPerson: Person, complete: @escaping (Bool) -> Void) {
        guard let id = toPerson.id else { return }
        let params: [String:Any] = ["to_user_id": id]
        guard let req = reqPerson(params: params, requestType: .sendFriendRequest) else { complete(false); return }
        req.responseJSON(queue: .global(qos: .background), completionHandler: { (response) in
            if let response = response.response {
                if response.statusCode == Network.createdCode {
                    complete(true)
                } else {
                    complete(false)
                }
            } else {
                complete(false)
            }
        })
    }
    
}
