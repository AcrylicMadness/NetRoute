//
//  NetRequest.swift
//  NetRoute
//
//  Created by Kirill Averkiev on 15.04.16.
//  Copyright © 2016 Kirill Averkiev. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

/// Basic network request to work with HTTP method.
/// The request can be put into a request queue.
/// To sort the queue, every  request has a priority.
/// It is recommended to use `Default` priority when request is executed withot any queue.
/// Priority:
/// - `Low`:        User-initiated not important request, that can not be done in background.
/// - `Default`:    The standart user-initiated request.
/// - `High`:       Important UI-request.
/// - `Backound`:   The request is a background task.

public class NetRequest: NetRouteObject {
    
    
    
    // MARK: Constants
    
    
    
    /// URL to the HTTP method.
    public let url: URL
    
    /// Priority of the request.
    public let priority: NetRequestPriority
    
    /// Type of the request.
    public let type: NetRequestType
    
    /// Parametes for the request.
    public let parameters: NetRequestParameters?
    
    
    
    // MARK: - Variables
    
    
    
    // MARK: Public
    
    
    
    /// Response of the HTTP method.
    public var response: NetResponse?
    
    /// Description.
    public override var description: String {
        return "\(url) (\(type.rawValue)) with priority: \(priority.rawValue)"
    }
    
    
    
    // MARK: Internal
    
    
    
    /// State of the request.
    internal var state: NetRequestState = .unset
    
    
    
    // MARK: Private
    
    
    
    /// Array of media data that can be uploaded with request.
    private var uploadData: Data?
    
    /// Field name for the upload file.
    private var uploadFieldname: String = "field"
    
    /// Name of the file to upload.
    private var uploadFilename: String = "file"
    
    /// MimeType of the upload data.
    private var mimetype: String = "application/octet-stream";
    
    /// URLRequest property created with the given properties.
    public var request: URLRequest {
        
        get {
            
            // Create URLRequest.
            var request: URLRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 120.0)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = type.rawValue
            
            // Prepare request dependong on its contents.
            switch type {
                
            case .GET:
                
                if parameters != nil {
                    
                    // Add paraeters as a string to the HTTP URL.
                    request.url = URL(string: url.absoluteString + "?" + parameters!.description)
                }
                
            case .POST, .PUT:
                
                if uploadData == nil {
                    
                    if parameters != nil {
                        
                        print("parameters: \(parameters!)")
                        // Add parameters to the body of HTTP method.
                        request.httpBody = parameters!.description.data(using: String.Encoding.utf8)
                    }
                    
                } else {
                    
                    // Create boundary string and set it to request header.
                    let boundary = generateBoundaryString()
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    
                    
                    // Set the Multipart/Form Data and append it to httpBody.
                    var body = Data()
                    
                    if parameters != nil {
                        for (key, value) in parameters!.dictionary {
                            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                            body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
                        }
                    }
                    
                    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                    body.append("Content-Disposition: form-data; name=\"\(uploadFieldname)\"; filename=\"\(uploadFilename)\"\r\n".data(using: String.Encoding.utf8)!)
                    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                    body.append(uploadData!)
                    body.append("\r\n".data(using: String.Encoding.utf8)!)
                    body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
                    
                    
                    
                    request.httpBody = body
                    
                }
                
            }
            
            return request
        }
    }
    
    
    
    // MARK: - Lyfecycle
    
    
    
    /// Creates new request.
    ///
    /// - Parameter URL:        URL to the HTTP method.
    /// - Parameter type:       Type of the HTTP method.
    /// - Parameter parameters: Parameters for the request.
    /// - Parameter priority:   Priority of the request. If priority is not specified `.Defaut` is used.
    ///
    /// Priority:
    /// - `Low`:                User-initiated not important request, that can not be done in background.
    /// - `Default`:            The standart user-initiated request.
    /// - `High`:               Important UI-request.
    /// - `Backound`:           The request is a background task.
    
    public init(url: URL, type: NetRequestType, parameters: Dictionary<String, String>?, priority: NetRequestPriority = .medium) {
        
        // Set the URL.
        self.url = url
        
        // Set the parameters from the given dictionary.
        self.parameters = parameters != nil ? NetRequestParameters(dictionary: parameters!) : nil
        
        // Set the priority.
        self.priority = priority
        
        // Set the method type.
        self.type = type
    }
    
    /// Creates new request using `NRURLManager`.
    ///
    /// - Parameter name:       Name of the method.
    /// - Parameter type:       Type of the HTTP method.
    /// - Parameter parameters: Parameters for the request.
    /// - Parameter priority:   Priority of the request. If priority is not specified `.Defaut` is used.
    ///
    /// Priority:
    /// - `Low`:                User-initiated not important request, that can not be done in background.
    /// - `Default`:            The standart user-initiated request.
    /// - `High`:               Important UI-request.
    /// - `Backound`:           The request is a background task.
    
    public init(name: String, type: NetRequestType, parameters: Dictionary<String, String>?, priority: NetRequestPriority = .medium) {
        
        // Set the URL by apending the method name to the deaful URL.
        self.url = URL(string: (NetManager.shared.primaryURL?.absoluteString)! + name)!
        
        // Set the parameters from the given dictionary.
        self.parameters = parameters != nil ? NetRequestParameters(dictionary: parameters!) : nil
        
        // Set the priority.
        self.priority = priority
        
        // Set the method type.
        self.type = type
    }
    
    /// Creates new request using `NRURLManager`.
    ///
    /// - Parameter name:       Name of the method.
    /// - Parameter type:       Type of the HTTP method.
    /// - Parameter parameters: Parameters for the request converted to `NRRequestParameters`
    /// - Parameter priority:   Priority of the request. If priority is not specified `.Defaut` is used.
    ///
    /// Priority:
    /// - `Low`:                User-initiated not important request, that can not be done in background.
    /// - `Default`:            The standart user-initiated request.
    /// - `High`:               Important UI-request.
    /// - `Backound`:           The request is a background task.
    
    public init(name: String, type: NetRequestType, parameters: NetRequestParameters, priority: NetRequestPriority = .medium) {
        
        // Set the URL by apending the method name to the deaful URL.
        self.url = URL(string: (NetManager.shared.primaryURL?.absoluteString)! + name)!
        
        // Set the parameters from the given dictionary.
        self.parameters = parameters
        
        // Set the priority.
        self.priority = priority
        
        // Set the method type.
        self.type = type
    }
    
    
    
    // MARK: - Direct execution
    
    
    
    /// Executes request.
    ///
    /// - Parameter completion: Callback that is called after request returned response.
    
    public func run(completionHandler: ((_ response: NetResponse) -> Void)?) {
        
        // Switch to prevent request execution when it is not on any queue.
        switch state {
            
        // Check if the request is on queue.
        case .unset:
            
            // Set state to avoid simultaneous requests.
            state = .executing
            
            // Run the request with the provided callback is exists.
            URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if completionHandler != nil {
                    completionHandler?(NetResponse(data: data, response: response, error: error))
                }
            }).resume()
            
            // Change the state of request.
            state = .done
            
        // Prevent execution of the request if it is not on the queue, unset or completed.
        case .queuing:
            print("'\(description)' is already on the queue waiting for execution.")
            
        case .executing:
            print("'\(description)' is already running.")
            
        case .done:
            print("'\(description)' is done and has to be deinitialized.")
        }
        
    }
    
    
    
    // MARK: - Queuing execution
    
    
    
    /// Passes the request to a given queue.
    /// Blocks the request from direct execution.
    ///
    /// - Parameter queue: A queue to add the request.
    
    public func pass(queue: NetRequestQueue) {
        
        // Prevent passing if the request is already on queue.
        if state != .queuing {
            
            // Add request.
            state = .queuing
            queue.add(request: self)
            
        } else {
            
            // Notify about the eroor.
            print("'\(description)' is already on execution queue.")
        }
        
    }
    
    
    
    // MARK: - Multipart/Form-Data
    
    
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - Returns: The boundary string.
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    /// Adds an image to upload.
    ///
    /// - Parameter image: An image to add.
    /// - Parameter filename: Filename of the image.
    
    public func add(data: Data, forField field: String, filename: String, mimetype type: String) {
        
        /// Set the data and info.
        uploadData = data
        uploadFilename = filename
        uploadFieldname = field
        mimetype = type
    }
    
}
