//
//  ContentView.swift
//
//  Created by Gendler, Bob (Fed) on 4/16/25.
//

import SwiftUI


struct PlainGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Display the label with any desired padding
            configuration.label
                .padding(.bottom, 2)
            // Then show the content exactly as it is
            configuration.content
        }
        .background(Color.clear)
    }
}

struct JamfComputer: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let status: String
}

struct ContentView: View {
    
    @State private var TwentyFourHours = true
    @State private var search: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var jamf: JamfClass
    
    @State private var disableEnableButtonText = "Disable"
    
    @State private var selectedComputerID: String?
    @State private var infoField = try! AttributedString(markdown: "")
    @State var shouldPresentSheet = false
    @State private var loginInfo: LoginInfo?
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    VStack {
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 205, height: 75, alignment: .topLeading)
                            .padding(.bottom, -20)
                        
                        HStack {
                            Text("Search:")
                            TextField("", text: self.$search)
                                .frame(minWidth: 160)
                        }
                        
                    }
                    
                    VStack {
                        Text("Jamf Pro Username:")
                            .font(.system(size: 10))
                        
                        TextField("", text: self.$username)
                        
                        Text("Jamf Pro Password:")
                            .font(.system(size: 10))
                            .padding(.bottom, -5)
                        
                        SecureField("", text: self.$password)
                        
                    }
                }
                
                Table(jamf.jamfSearchResults, selection: $selectedComputerID) {
                    
                    TableColumn("Computer") { result in
                        Text(result.general.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                    TapGesture().onEnded {
                                      selectedComputerID = result.id
                                    }
                                  )
//                            .onTapGesture {
//                                selectedComputerID = result.id
//                            }
                    }
                    TableColumn("EA") { result in
                        
                        if let topLevelEA = result.extensionAttributes.first(where: { $0.definitionId == preferences().readPreferences().ID1 }) {
                            Text(topLevelEA.values.first ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .simultaneousGesture(
                                        TapGesture().onEnded {
                                          selectedComputerID = result.id
                                        }
                                      )
//                                .onTapGesture {
//                                    selectedComputerID = result.id
//
//                                }
                        }
                        
                    }
                }
                
                .onChange(of: selectedComputerID) {
                    
                    selectedRow(selectedComputerID: selectedComputerID)
                    
                }
                .frame(maxWidth: 330, maxHeight: 200)
                
            }
            
            VStack {
                Button(action: {
                    jamf.username = self.username
                    jamf.password = self.password
                    jamf.getData(apiURL: "api/v1/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(self.search)*,userAndLocation.realname==*\(self.search)*,general.assetTag==*\(self.search)*,general.name==*\(self.search)*,hardware.serialNumber==*\(self.search)*")
                }, label:  {
                    Text("Look Up")
                        .frame(maxWidth: 85)
                })
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                
                Button(action: {
                    guard let selectedComputerID = self.selectedComputerID else { return }
                    if disableEnableButtonText == "Disable" {
                        
                        let daysToAdd = 1
                        let currentDate = Date()
                        var dateComponent = DateComponents()
                        dateComponent.day = daysToAdd
                        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat =  "MM-dd-YY"
                        let date = dateFormatter.string(from: futureDate!)
                        
                        let xmldata = "<computer><extension_attributes><extension_attribute><id>" + preferences().readPreferences().ID1 + "</id><value>Disabled</value></extension_attribute><extension_attribute><id>\(preferences().readPreferences().ID2)</id><value>\(date)</value></extension_attribute></extension_attributes></computer>"
                        jamf.putData(apiURL: "JSSResource/computers/id/\(selectedComputerID)", xmlData: xmldata){
                            
                            switch jamf.jamfResponseCode {
                            case 200, 201:
                                jamf.getData(apiURL: "api/v1/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(self.search)*,userAndLocation.realname==*\(self.search)*,general.assetTag==*\(self.search)*,general.name==*\(self.search)*,hardware.serialNumber==*\(self.search)*")
                                disableEnableButtonText = "Enable"
                            default:
                                print("BAD THINGS")
                            }
                        }
                        
                    } else {
                        let xmldata = "<computer><extension_attributes><extension_attribute><id>" + preferences().readPreferences().ID1 + "</id><value>Enabled</value></extension_attribute><extension_attribute><id>\(preferences().readPreferences().ID2)</id><value></value></extension_attribute></extension_attributes></computer>"
                        jamf.putData(apiURL: "JSSResource/computers/id/\(selectedComputerID)", xmlData: xmldata){
                            
                            switch jamf.jamfResponseCode {
                            case 200,201:
                                jamf.getData(apiURL: "api/v1/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(self.search)*,userAndLocation.realname==*\(self.search)*,general.assetTag==*\(self.search)*,general.name==*\(self.search)*,hardware.serialNumber==*\(self.search)*")
                                disableEnableButtonText = "Disable"
                            default:
                                print("BAD THINGS")
                            }
                        }
                        
                    }
                    
                }, label: {
                    Text(disableEnableButtonText)
                        .frame(maxWidth: 85)
                })
                Button(action: {
                    if let selectedComputer = jamf.jamfSearchResults.first(where: { $0.id == selectedComputerID }), let selectedComputerID = selectedComputerID {
                        let key = ComputerKey(name: selectedComputer.general.name,
                                              id:   selectedComputerID)
                        openWindow(id: "information", value: key)
                    }
                    
                }, label: {
                    Text("Information")
                        .frame(maxWidth: 85)
                })
                Button(action: {
                    shouldPresentSheet.toggle()
                    loginInfo = LoginInfo(username: username, password: password)
                }, label: {
                    Text("Preferences")
                        .frame(maxWidth: 85)
                }).sheet(isPresented: $shouldPresentSheet) {
                    print("sheet dismissed")
                } content: {
                    PreferenceView(loginInfo: $loginInfo)
                }
                .padding(.bottom, 3)
                
//                Toggle(isOn: $TwentyFourHours) {
//                    Text("Disable for only 24 Hours")
//                }
//                .toggleStyle(.checkbox)
                
                
                GroupBox(label: Text("User Information")
                    .font(.system(size: 15))
                    .frame(maxWidth: 185, alignment: .center)) {
                        Text(infoField)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 5)
                        
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .frame(width: 185, height: 125)
                            .border(Color.gray, width: 1)
                    }
                
            }.groupBoxStyle(PlainGroupBoxStyle())
            
        }
        .padding(.top, 0)
        .padding(.leading, 0)
        .onAppear() {

            if jamf.server != "" {
                let keychainVar =  try? KeychainService.kc_retrieve(service: jamf.server)
                if keychainVar != nil {
                    username = keychainVar!.KCaccount
                    password = keychainVar!.KCpasswd
                    
                }
            }

        }
        
    }
    func selectedRow(selectedComputerID: String?) {
        guard let selectedComputerID = selectedComputerID else { return }
        if let selectedComputer = jamf.jamfSearchResults.first(where: { $0.id == selectedComputerID }) {
            
            if let EA = selectedComputer.extensionAttributes.first(where: { $0.definitionId == preferences().readPreferences().ID1 }) {
                if EA.values.first == "Enabled" {
                    disableEnableButtonText = "Disable"
                } else {
                    disableEnableButtonText = "Enable"
                }
            }
            let checkindateString = selectedComputer.general.lastContactTime
            var checkinlocalTimeString: String {
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                if let date = isoFormatter.date(from: checkindateString) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm:ss"
                    timeFormatter.timeZone = .current
                    let formattedString = "\(dateFormatter.string(from: date)) \(timeFormatter.string(from: date))"
                    return formattedString
                } else {
                    return ""
                }
            }
            var processorInfo = ""
            if let appleSilicon = selectedComputer.hardware?.appleSilicon {
                if appleSilicon {
                    processorInfo = "Apple Silicon: \(selectedComputer.hardware!.processorType)"
                } else {
                    processorInfo = "Intel: \(selectedComputer.hardware!.processorType)"
                }
                
            }else {
                processorInfo = ""
            }
            
            infoField = try! AttributedString(markdown:
"""
[\(selectedComputer.general.name)](\(preferences().readPreferences().Server)/computers.html?id=\(selectedComputer.id))
\(selectedComputer.userAndLocation.realname)
[\(selectedComputer.userAndLocation.email)](mailto:\(selectedComputer.userAndLocation.email))
Property Tag: \(selectedComputer.general.assetTag ?? "")
Last Check-In: \(checkinlocalTimeString)
\(processorInfo)
""", options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } else {
            infoField = ""
        }
    }
}

#Preview {
    ContentView()
}
