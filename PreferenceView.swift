//
//  PreferenceView.swift
//
//  Created by Gendler, Bob (Fed) on 4/18/25.
//

import SwiftUI

struct PreferenceView: View {
    @Environment(\.dismiss) var dismiss
    @State private var serverURL = preferences().readPreferences().Server
    @State private var eaID1 = preferences().readPreferences().ID1
    @State private var eaID2 = preferences().readPreferences().ID2
    @Binding var loginInfo: LoginInfo?
    @State private var keychainUse = preferences().readKeychainPref()
    var body: some View {
        VStack {
            HStack {
                //jamf serverURL
                
                Text("Jamf Server URL:")
                if serverURL.isEmpty {
                    TextField("https://yourjamfserver.jamfcloud.com", text: self.$serverURL)
                        .frame(width: 180)
                } else {
                    TextField(serverURL, text: self.$serverURL)
                        .frame(width: 180)
                }
                //text box
            }
            HStack {
                //EA ID 1
                Text("EA1 ID Number:")
                TextField(eaID1, text: self.$eaID1)
                    .frame(width: 180)
                //text box
            }.padding(.leading, -47)
            HStack {
                Text("EA2 ID Number:")
                TextField(eaID2, text: self.$eaID2)
                    .frame(width: 180)
                //text box
            }.padding(.leading, -10)
            Toggle(isOn: $keychainUse) {
                Text("Save Login to Keychain")
            }
                .toggleStyle(.checkbox)
            Button(action: {
                
                keychain(inUse: keychainUse)
                
                preferences().writePreferences(Server: serverURL, ID1: eaID1, ID2: eaID2)
                dismiss()
            }, label: {
                Text("Save Settings")
                    .frame(maxWidth: 85)
            })
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }.frame(width: 400, height: 200)
    }

    func keychain(inUse: Bool) {
        print("something?")
        if inUse {
            if let loginInfo = loginInfo {
                do {
                    
                    try KeychainService.kc_add(service: serverURL, account: loginInfo.username, password: loginInfo.password)
                    preferences().setKeychainPref(Status: inUse)
                } catch {
                    print("Error adding")
                }
            } else {
                print("no login info?")
            }
            
        } else {
            if let loginInfo = loginInfo {
                do {
                    try KeychainService.kc_remove(service: serverURL, account: loginInfo.username)
                    preferences().setKeychainPref(Status: inUse)
                } catch {
                    print("Error removing item from the key")
                }
            } else {
                print("no login info?")
            }
        }
    }
    
}

