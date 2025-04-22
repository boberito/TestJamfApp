//
//  File.swift
//  
//
//  Created by Gendler, Bob (Fed) on 4/15/22.
//

import Foundation


struct preferences {
    
    func writePreferences(Server: String, ID1: String, ID2: String) {

        UserDefaults.standard.set(Server, forKey: "jss_URL")
        UserDefaults.standard.set(ID1, forKey: "EA_ID")
        UserDefaults.standard.set(ID2, forKey: "EA2_ID")

    }

    func readKeychainPref() -> Bool {
    return UserDefaults.standard.bool(forKey: "Keychain")
    }
    func setKeychainPref(Status: Bool) {
        UserDefaults.standard.set(Status, forKey: "Keychain")
    }

    func readPreferences() -> (Server: String, ID1: String, ID2: String) {
        let bundlePLIST = UserDefaults.standard
        if let jamfserver = bundlePLIST.string(forKey: "jss_URL"), let eaID = bundlePLIST.string(forKey: "EA_ID"), let eaID2 = bundlePLIST.string(forKey: "EA2_ID") {
            return(Server: jamfserver, ID1: eaID, ID2: eaID2)
        }
        return(Server: "",ID1: "",ID2: "")
        
        
    }
}


