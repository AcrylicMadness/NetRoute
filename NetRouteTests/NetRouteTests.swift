//
//  NetRouteTests.swift
//  NetRouteTests
//
//  Created by Kirill Averkiev on 25.04.16.
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

import XCTest
import UIKit
@testable import NetRoute

class NetRouteTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let primaryUrlString = "http://ucmas.goforit.pro/"
        
        NetManager.shared.primaryURL = URL(string: primaryUrlString)!
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    

    
    func testExampleRequest() {
        
        let expectation = self.expectation(description: "Asyncronious operation")
    
        let request = NetRequest(name: "Test/TaskCompleted", type: .post, parameters: ["token": "megatoken", "id": "2", "dev_key": "testdevkey", "server_name": "UCMAS", "level": "1"])
        
        request.run() { response in
            
            print(response.stringValue!)
            
            if response.error != nil {
                print("-------")
                print(response.stringValue)
                
            } else {
                XCTAssertNil((response.error! as NSError).localizedDescription)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 30.0) { (error: Error?) in
            XCTAssert(error != nil, "Request time exceeded.")
        }
    }
    
}
