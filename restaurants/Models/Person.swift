//
//  Person.swift
//  restaurants
//
//  Created by Steven Dito on 9/29/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import Contacts
import PhoneNumberKit

class Person: Decodable {
    var phone: String?
    var username: String?
    var actualName: String?
    var id: Int?
    var hex_color: String?
    lazy var alreadyInteracted = false
    
    var color: UIColor {
        return UIColor(hex: hex_color) ?? Colors.random
    }
    
    init(phone: String, username: String?, actualName: String?) {
        self.phone = phone
        self.username = username
        self.actualName = actualName
    }
    
    struct FindRelated: Decodable {
        var contactsMatched: [Person]
        var friendRequests: [PersonRequest]
        
        enum CodingKeys: String, CodingKey {
            case contactsMatched = "contacts_matched"
            case friendRequests = "friend_requests"
        }
    }
    
    struct PersonRequest: Decodable {
        var fromPerson: Person
        var toPerson: Person
        var dateAsked: Date
        var id: Int
        var message: String?
        
        enum CodingKeys: String, CodingKey {
            case fromPerson = "from_account"
            case toPerson = "to_account"
            case dateAsked = "date_asked"
            case id
            case message
        }
        
        var notUser: Person? {
            guard let userId = Network.shared.account?.username else { return nil }
            if fromPerson.username == userId {
                return toPerson
            } else if toPerson.username == userId {
                return fromPerson
            } else {
                return nil
            }
        }
    }
    
    struct Profile: Decodable {
        var account: Person
        var establishments: [Establishment]?
        var visits: [Visit]?
        var receivedRequestId: Int?
        var sentRequestId: Int?
        var isOwnProfile: Bool
        var friendshipId: Int?
        
        var hasPendingReceivedRequest: Bool {
            return receivedRequestId != nil
        }
        
        var hasPendingSentRequest: Bool {
            return sentRequestId != nil
        }
        
        var areFriends: Bool {
            return friendshipId != nil
        }
        
        enum CodingKeys: String, CodingKey {
            case account
            case establishments
            case visits
            case receivedRequestId = "received_request_from_user"
            case sentRequestId = "sent_request_to_user"
            case isOwnProfile = "is_own_profile"
            case friendshipId = "friend_id"
        }
    }
    
    struct Friend: Decodable {
        var friend: Person
        var date: Date
        var friendID: Int
        
        enum CodingKeys: String, CodingKey {
            case friend
            case date
            case friendID = "id"
        }
    }
    
    static func getUserContacts() -> [Person] {
        let contactStore = CNContactStore()
        let phoneNumberKit = PhoneNumberKit()
        var people: [Person] = []

        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                if let number = contact.phoneNumbers.first?.value.stringValue {
                    do {
                        let phoneNumber = try phoneNumberKit.parse(number, withRegion: "US", ignoreType: true)
                        let formatted = phoneNumberKit.format(phoneNumber, toType: .e164)
                        let name = "\(contact.givenName) \(contact.familyName)"
                        people.append(Person(phone: formatted, username: nil, actualName: name))

                    } catch {
                        print("Phone Number kit parse error")
                    }
                }
                
            }
        } catch {
            print("unable to fetch contacts")
        }
        
        return people
        
    }
    
}
