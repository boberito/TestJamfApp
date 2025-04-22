//
//  jamfData.swift
//
//  Created by Gendler, Bob (Fed) on 4/1/22.
//

import Foundation


struct ComputerKey: Hashable, Decodable, Encodable {
  let name: String
  let id: String
}

struct LoginInfo: Hashable, Decodable, Encodable {
    var username: String
    var password: String
}

struct JamfSearchInfo: Decodable {
    let totalCount: Int
    let results: [ComputerResult]
    
    struct ComputerResult: Decodable, Identifiable {
        let id: String
        let udid: String
        let general: General
        let userAndLocation: UserAndLocation
        let hardware: Hardware?  // Make optional since it could be null
        let operatingSystem: OperatingSystem
        let extensionAttributes: [ExtensionAttribute]
        
        // Add CodingKeys if needed to handle missing fields in your struct
        private enum CodingKeys: String, CodingKey {
            case id, udid, general, userAndLocation, hardware, operatingSystem
            case extensionAttributes = "extensionAttributes"
        }
        
        struct General: Decodable {
            let name: String
            let lastIpAddress: String
            let lastReportedIp: String
            let assetTag: String?
            let reportDate: String
            let lastContactTime: String
            let lastEnrolledDate: String
            let mdmProfileExpiration: String
            let managementId: String
            let extensionAttributes: [ExtensionAttribute]
        }
        
        struct UserAndLocation: Decodable {
            let username: String
            let realname: String
            let email: String
            let position: String
            let phone: String
            let departmentId: String
            let buildingId: String
            let room: String
            let extensionAttributes: [ExtensionAttribute]
        }
        
        struct Hardware: Decodable {
            let make: String
            let model: String
            let modelIdentifier: String
            let serialNumber: String
            let processorType: String
            let processorArchitecture: String
            let appleSilicon: Bool
            let extensionAttributes: [ExtensionAttribute]
        }
        
        struct OperatingSystem: Decodable {
            let version: String
            let activeDirectoryStatus: String
            let extensionAttributes: [ExtensionAttribute]
        }
        
        struct ExtensionAttribute: Decodable {
            let definitionId: String
            let name: String
            let description: String?
            let values: [String]
            
            // Add CodingKeys to ignore fields you don't need
            private enum CodingKeys: String, CodingKey {
                case definitionId, name, description, values
            }
        }
    }
}



struct userGroupInfo: Decodable {
    let user_group: usergroup
    
    struct usergroup: Decodable {
        let users:[entries]
        
        struct entries: Decodable {
            let username: String
        }
    }
}

struct extensionAttribute: Decodable {
    let computer: computerEA
    
    struct computerEA: Decodable {
        let extension_attributes: [EA]
        
        struct EA: Decodable {
            let id: Int
            let name: String
            let value: String
        }
        
    }
    
}

struct jamfauth: Decodable {
    let token: String
    let expires: String?
    let httpStatus: Int?
}

struct computerInfo: Decodable {
    let computer: computer
    
    struct computer: Decodable {
        let general: General
        var hardware: Hardware
        let extension_attributes: [EAs]
        
        struct General: Decodable {
            let name: String
            let ip_address: String
            let asset_tag: String
            let last_contact_time: String
            let report_date: String
        }
        struct Hardware: Decodable {
            let os_version: String
            let active_directory_status: String
            let is_apple_silicon: Bool
            let processor_type: String
        }
        struct EAs: Decodable {
            let id: Int
            let value: String
        }
    }
    
}

struct permissionInfo: Decodable {
    let user: User
    struct User: Decodable {
        let privileges: [String]
    }
}
