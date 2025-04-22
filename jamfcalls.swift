//
//  jamfAPICalls.swift
//
//  Created by Gendler, Bob (Fed) on 4/1/22.
//
import Foundation

//
//protocol DataModelDelegate: AnyObject {
//    func didRecieveDataUpdate(jamfData: Data, jamfResponse: HTTPURLResponse)
//}

struct responseObject {
    let jamfData: Data
    let jamfResponse: HTTPURLResponse
}

class JamfClass: ObservableObject {
    
    @Published var jamfSearchResults: [JamfSearchInfo.ComputerResult] = []
    @Published var jamfResponseCode = 0
    var server = String()
    var id = String()
    var id2 = String()
    var username: String = ""
    var password: String = ""
    var token: String?
    var expires: Date?
    var jamfData = Data()
    
    
    init() {
        server = preferences().readPreferences().Server
        id = preferences().readPreferences().ID1
        id2 = preferences().readPreferences().ID2
    }
    
    private func testAuth() -> Bool {
        let now = Date()
        if let expiration = self.expires {
            if now > expiration {
                return false
            }
            return true
        } else {
            return false
        }
        
        
    }
    
    func getData(apiURL: String) {
        let fullURL = self.server + apiURL
        var request = URLRequest(url: URL(string: fullURL)!)
        if let token = self.token {
            request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        if testAuth() {

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response {

                    DispatchQueue.main.async {

                        if let decodedJamf = try? JSONDecoder().decode(JamfSearchInfo.self, from: data) {
                            self.jamfSearchResults = decodedJamf.results
                            self.jamfResponseCode = (response as! HTTPURLResponse).statusCode
                            
                        }

                    }
                }
                

            }
            task.resume()

            
        } else {
            
            authenticate { token, tokendate in
                self.token = token
                self.expires = tokendate
                
                if let token = self.token {
                    request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
                }
                

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data, let response = response {
                        DispatchQueue.main.async {
                            if let decodedJamf = try? JSONDecoder().decode(JamfSearchInfo.self, from: data) {
                                self.jamfSearchResults = decodedJamf.results
                                self.jamfResponseCode = (response as! HTTPURLResponse).statusCode
                                
                                
                            }
                        }
                    }
                    
                }
                task.resume()
                
            }

            
        }
        
    }
    
    func putData(apiURL: String, xmlData: String, then completion: () -> ()) {
        let fullURL = self.server + apiURL
        var request = URLRequest(url: URL(string: fullURL)!)
        if let token = self.token {
            request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        }
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = xmlData.data(using: String.Encoding.utf8)
        request.httpMethod = "PUT"
        
        if testAuth() {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response {
                    DispatchQueue.main.async {
                        self.jamfResponseCode = (response as! HTTPURLResponse).statusCode

                    }
                }
                dispatchGroup.leave()
            }
            task.resume()
            dispatchGroup.wait()
        } else {
            authenticate { token, tokendate in
                self.token = token
                self.expires = tokendate
                
                if let token = self.token {
                    request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
                }
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data, let response = response {
                        DispatchQueue.main.async {
                            self.jamfResponseCode = (response as! HTTPURLResponse).statusCode
                        }
                    }
                    dispatchGroup.leave()
                }
                task.resume()
                dispatchGroup.wait()
            }
        }
        completion()
    }
    
    func invalidate_token(completion: () ->()) {
        
        self.token = nil
        self.expires = nil
        self.password = ""
        let semaphore = DispatchSemaphore (value: 0)
        let fullURL = self.server + "api/v1/auth/invalidate-token"
        var request = URLRequest(url: URL(string: fullURL)!)
        if let token = self.token {
            request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
                print("error")
                semaphore.signal()
                return
            }
            print("Jamf login token destroyed, logout complete.")
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        completion()
    }
    
    
    private func authenticate(completion: (String?, Date?) -> ()) {
        var token: String?
        var tokenDate: Date?
        let concatCreds = self.username + ":" + self.password
        if let utf8Creds = concatCreds.data(using: .utf8) {
            let base64Creds = utf8Creds.base64EncodedString()
            var returnData: Data?
            var returnResponse: HTTPURLResponse?
            var request = URLRequest(url: URL(string: "api/v1/auth/token", relativeTo: URL(string: self.server))!)
            request.setValue("Basic \(base64Creds)", forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                returnData = data
                returnResponse = response as? HTTPURLResponse
                dispatchGroup.leave()
            }
            task.resume()
            dispatchGroup.wait()
            
            print(returnResponse?.statusCode as Any)
            switch returnResponse?.statusCode {
            case 401:
                //                os_log("Unathorized HTTP Response 401", log: loginLog, type: .debug)
                print("401")
            case 403:
                print("403")
            case 404:
                print("404")

            default:
                //                os_log("Everything else, prob good", log: loginLog, type: .debug)
                
                if let returnData = returnData {
                    let decoder = JSONDecoder()
                    do {
                        let authToken = try decoder.decode(jamfauth.self, from: returnData)
                        
                        token = authToken.token
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        if let authTokenExpires = authToken.expires {
                            tokenDate = dateFormatter.date(from:authTokenExpires)
                            
                        }
                    } catch {
                        //
                    }
                } else {
                    //
                }
            }
            
        }
        completion(token,tokenDate)
        
    }
    
}



