//
//  FeedHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Contacts
import CoreTelephony

class FeedHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Feed"
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.main
        self.setNavigationBarColor()
        
        setUpFindPeople()
    }
    
    private func setUpFindPeople() {
        let addPerson = UIBarButtonItem(image: .personBadgeImage, style: .plain, target: self, action: #selector(addPersonAction))
        self.navigationItem.rightBarButtonItem = addPerson
    }
    

    
    @objc private func addPersonAction() {
        let contactStore = CNContactStore()
        var contacts: [CNContact] = []

        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
            }
        } catch {
            print("unable to fetch contacts")
        }
        
        let networkInfo = CTTelephonyNetworkInfo()
        guard let carrier = networkInfo.serviceSubscriberCellularProviders else { return }
        
        guard let value = carrier.values.first else { return }
        
        print(value.isoCountryCode)
        
        for contact in contacts {
            let rawPhone = contact.phoneNumbers.first?.value.stringValue
            let cleanedPhone = rawPhone?.phoneNumberFound()
            print(cleanedPhone)
        }

    }
}


extension String {
    
    func phoneNumberFound() -> String? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let match = matches.first {
                let number = match.phoneNumber
                number
                return number
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
}
