//
//  Friends_Test.swift
//  Chit-ChatTests
//
//  Created by Phát Nguyễn on 09/02/2022.
//

import XCTest
@testable import Chit_Chat

class Friends_Test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //    func testDatabaseReference() throws {
    //
    //    }
    
    //    func testApiFetchFriendsList() throws {
    //
    //    }
    
    func testApiFetchNewFriends() throws {
        let expectation = expectation(description: "friends")
        var instance: [User]?
        
        DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
            switch result {
            case .success(let userCollection):
                instance = userCollection
                
                expectation.fulfill()
            case .failure(let error):
                print("Failed to get user: \(error)")
            }
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(instance, "Database return have error")
    }

}
