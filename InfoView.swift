//
//  InfoView.swift
//
//  Created by Gendler, Bob (Fed) on 4/17/25.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var jamf: JamfClass
    @Binding var computerKey: ComputerKey?
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            
            let selectedID = computerKey?.id
            
            
            if let selectedComputer = jamf.jamfSearchResults.first(where: { $0.id == selectedID }) {
                
                let checkindateString = selectedComputer.general.lastContactTime
                let checkinlocalTimeString: String = {
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    if let date = isoFormatter.date(from: checkindateString) {
                        // Create formatters for the date and time parts
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
                }()
                
                let recondateString = selectedComputer.general.reportDate
                let reconlocalTimeString: String = {
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    if let date = isoFormatter.date(from: recondateString) {
                        // Create formatters for the date and time parts
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
                }()
                let processorInfo: String = {
                    if let appleSilicon = selectedComputer.hardware?.appleSilicon {
                        if appleSilicon {
                            return "Apple Silicon: **\(selectedComputer.hardware!.processorType)**"
                        } else {
                            return "Intel: **\(selectedComputer.hardware!.processorType)**"
                        }
                    }
                    return ""
                }()
                
                
                let uptimeString: String = {
                    if let uptimeEA = selectedComputer.extensionAttributes.first(where: {$0.definitionId == "478" }) {
                        return uptimeEA.values.first ?? " "
                    } else {
                        return " "
                    }
                }()
                
                
                
                let infoText = """
            Hostname: **\(selectedComputer.general.name)**
            Property Tag: **\(selectedComputer.general.assetTag ?? "")**
            \(processorInfo)
            Last Check-In: **\(checkinlocalTimeString)**
            Last Recon: **\(reconlocalTimeString)**
            IP Address: **\(selectedComputer.general.lastReportedIp)**
            Uptime: **\(uptimeString)**
            """
                
                if let attributedInfoText = try? AttributedString(markdown: infoText, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                    Text(attributedInfoText)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: 330)
                        .lineSpacing(8)
                    
                }
                
            } else {
                Text("No computer selected")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 5)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }.multilineTextAlignment(.leading)
            .frame(width: 330, alignment: .leading)
//            .padding(.leading, 5)
    }
    
}

