
//
//  Created by Gendler, Bob (Fed) on 4/16/25.
//

import SwiftUI

@main
struct TestJamfApp: App {
    // Create a shared instance of JamfClass
    @StateObject private var jamf = JamfClass()

    
    var body: some Scene {
        WindowGroup("Test Jamf App", id: "main") {
            ContentView()
                .environmentObject(jamf) // Pass jamf to ContentView
                .fixedSize()
                .frame(minWidth: 535, minHeight: 325)
        }
        .windowResizability(.contentSize)
        

        WindowGroup(id: "information", for: ComputerKey.self) { $computerKey in
              InfoView(computerKey: $computerKey)
                .environmentObject(jamf)
                .fixedSize()
                .frame(minWidth: 340, minHeight: 400)
                .navigationTitle(computerKey?.name ?? "Computer Info")
                
            }
//        .windowStyle(.hiddenTitleBar)
        

            .windowResizability(.contentSize)
    }
    
}

