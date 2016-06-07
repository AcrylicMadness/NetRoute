//
//  NRRequest.swift
//  NRKit
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
import MobileCoreServices

/// Basic network request to work with HTTP method.
/// The request can be put into a request queue.
/// To sort the queue, every  request has a priority.
/// It is recommended to use `Default` priority when request is executed withot any queue.
/// Priority:
/// - `Low`:        User-initiated not important request, that can not be done in background.
/// - `Default`:    The standart user-initiated request.
/// - `High`:       Important UI-request.
/// - `Backound`:   The request is a background task.

public class NRRequest: NRObject {
    
    
    
    // MARK: - Constants
    
    
    
    /// URL to the HTTP method.
    public let URL: NSURL
    
    /// Priority of the request.
    public let priority: NRRequestPriority
    
    /// Type of the request.
    public let type: NRRequestType
    
    /// Parametes for the request.
    public let parameters: NRRequestParameters?
    
    
    
    // MARK: Variables
    
    
    
    /// Response of the HTTP method.
    public var response: NRResponse?
    
    /// State of the request.
    internal var state = NRRequestState.Unset
    
    /// Description.
    public override var description: String {
        return "\(URL) (\(type.rawValue)) with priority: \(priority.rawValue)"
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
    
    public init(URL: NSURL, type: NRRequestType, parameters: Dictionary<String, String>?, priority: NRRequestPriority = .Default) {
        
        // Set the URL
        self.URL = URL
        
        // Set the parameters fro the given dictionary
        self.parameters = parameters != nil ? NRRequestParameters(dictionary: parameters!) : nil
        
        // Set the priority
        self.priority = priority
        
        // Set the method type
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
    
    public init(name: String, type: NRRequestType, parameters: Dictionary<String, String>?, priority: NRRequestPriority = .Default) {
        
        // Set the URL by apending the method name to the deaful URL
        self.URL = NSURL(string: (NRURLManager.sharedManager.primaryURL?.absoluteString)! + name)!
        
        // Initialize other properties
        self.parameters = parameters != nil ? NRRequestParameters(dictionary: parameters!) : nil
        self.priority = priority
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
    
    public init(name: String, type: NRRequestType, parameters: NRRequestParameters, priority: NRRequestPriority = .Default) {
        self.URL = NSURL(string: (NRURLManager.sharedManager.primaryURL?.absoluteString)! + name)!
        self.parameters = parameters
        self.priority = priority
        self.type = type
    }
    
    
    // MARK: - Direct execution
    
    
    
    /// Executes request.
    ///
    /// - Parameter completion: Callback that is called after request returned response.
    
    public func runWithCompletion(completion: ((response: NRResponse) -> Void)?) {
        
        // Switch to prevent request execution when it is not on any queue.
        switch state {
            
        // Check if the request is on queue.
        case .Unset:
            
            // Set state to avoid simultaneous requests.
            state = .Executing
            
            // Create NSMutableRequest and set it up.
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: URL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 120.0)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = type.rawValue
            
            // Apply parameters to either to URL or to Body depending on type.
            if parameters != nil {
                switch type {
                    
                case .GET:
                    
                    // Add paraeters as a string to the HTTP URL.
                    request.URL = NSURL(string: URL.absoluteString + "?" + parameters!.description)
                    
                case .POST:
                    
                    // Add parameters to the body of HTTP method.
                    request.HTTPBody = parameters!.description.dataUsingEncoding(NSUTF8StringEncoding)
                }
            }
            
            // Check if the callback is nil.
                
            // Run the request with the provided callback.
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                completion?(response: NRResponse(data: data, response: response, error: error))
            }).resume()
            
            // Change the state of request.
            state = .Done
            
        // Prevent execution of the request if it is not on the queue, unset or completed.
        case .OnQueue:
            print("'\(description)' is already on the queue waiting for execution.")
            
        case .Executing:
            print("'\(description)' is already running.")
            
        case .Done:
            print("'\(description)' is done and has to be deinitialized.")
        }
        
    }
    
    
    
    // MARK: - Queuing execution
    
    
    
    /// Passes the request to a given queue.
    /// Blocks the request from direct execution.
    ///
    /// - Parameter queue: A queue to add the request.
    
    public func passToQueue(queue: NRRequestQueue) {
        
        // Prevent passing if the request is already on queue.
        if state != .OnQueue {
            
            // Set the state.
            state = .OnQueue
            
            // Add the request.
            queue.addRequest(self)
            
        } else {
            
            // Notify about the eroor.
            print("'\(description)' is already on execution queue.")
        }
        
    }
    

    
    // MARK: - Multipart/Form-Data
    
    // TODO: Add Multipart/Form Data
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - Returns: The boundary string.
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// - Parameter path:   The path of the file for which mime type should be determined.
    ///
    /// - Returns:          Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    
    private func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let identifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(identifier, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        
        return "application/octet-stream";
    }
    
}