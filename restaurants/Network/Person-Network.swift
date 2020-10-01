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
        case getFriends
        case deleteFriend
        
        func url(int: Int?) -> String {
            switch self {
            case .relatedPeople:
                return "findusers"
            case .answerFriendRequest:
                return "friendrequest/\(int!)/"
            case .sendFriendRequest:
                return "friendrequest"
            case .getFriends:
                return "friend"
            case .deleteFriend:
                return "friend/\(int!)/"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .relatedPeople, .getFriends:
                return .get
            case .answerFriendRequest:
                return .put
            case .sendFriendRequest:
                return .post
            case .deleteFriend:
                return .delete
            }
        }
    }
    
    private func reqPerson(params: Parameters?, requestType: PersonRequestType, id: Int? = nil) -> DataRequest? {
        guard let token = Network.shared.account?.token else { return nil }
        let headers: HTTPHeaders = ["Authorization": "Token \(token)"]
        let request = AF.request(Network.djangoURL + requestType.url(int: id), method: requestType.method, parameters: params, headers: headers)
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
        let params: [String:Any] = ["accept_request": accept]
        guard let req = reqPerson(params: params, requestType: .answerFriendRequest, id: request.id) else { complete(false); return }
        req.responseJSON(queue: .global(qos: .background)) { (response) in
            guard let code = response.response?.statusCode, response.error == nil else {
                complete(false)
                return
            }
            
            if code == Network.createdCode {
                complete(true)
            } else if code == Network.deletedCode {
                complete(true)
            } else {
                complete(false)
            }
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
    
    func getFriends(friendsFound: @escaping (Result<[Person.Friend], Errors.Friends>) -> Void) {
        guard let req = reqPerson(params: nil, requestType: .getFriends) else { return }
        req.responseJSON(queue: .global(qos: .userInteractive)) { [unowned self] (response) in
            guard let data = response.data, response.error == nil else {
                print(response.error as Any)
                friendsFound(Result.failure(.other))
                return
            }
            
            do {
                var friends = try self.decoder.decode([Person.Friend].self, from: data)
                friends.sort { (p1, p2) -> Bool in
                    p1.friend.username ?? "" < p2.friend.username ?? ""
                }
                friendsFound(Result.success(friends))
            } catch {
                print(error)
                friendsFound(Result.failure(.other))
            }
        }
    }
    
    func deleteFriend(friend: Person.Friend, complete: @escaping (Bool) -> Void) {
        let req = reqPerson(params: nil, requestType: .deleteFriend, id: friend.friendID)
        req?.responseJSON(queue: .global(qos: .background), completionHandler: { (response) in
            guard let statusCode = response.response?.statusCode else { complete(false); return }
            complete(statusCode == Network.deletedCode)
        })
    }
    
}
