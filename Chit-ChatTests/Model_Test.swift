//
//  Model_Test.swift
//  Chit-ChatTests
//
//  Created by Phát Nguyễn on 26/01/2022.
//

import XCTest
@testable import Chit_Chat

class Model_Test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testingModel() throws {
        try testUser()
        try testConversation()
        try testUserNetwork()
    }
    
    func testUser() throws {
        let latestMessage = LatestMessage(date: Date(), text: "Hello World", isRead: false)
        
        let conversations = MessagesCollection(id: "fir5tM3ss4g35", name: "Doctor", otherUserEmail: "yds@gm.yds.edu.vn", latestMessage: latestMessage)
        
        let instance = User(id: "hash123",
                            firstName: "Khoi",
                            lastName: "Le",
                            bio: "This is bio",
                            email: "uit@gm.uit.edu.vn",
                            password: "SwiftyHash",
                            dob: Date(),
                            isMale: true,
                            conversations: [conversations])
        
        XCTAssertNotNil(instance, "Sorry, user model test case failed.")
        
    }
    
    func testConversation() throws {
        let conversation = Conversation(id: "fir5tM3ss4g35", type: "text", content: "Hello World", sender_email: "yds@gm.yds.edu.vn", name: "Doctor")
        let instance = Conversations(messages: [conversation])
        
        XCTAssertNotNil(instance, "Sorry, conversation model test case failed.")
    }
    
    func testUserNetwork() throws {
        let instance = UserNetwork(id: "hash123",
                                   firstName: "Khoi",
                                   lastName: "Le",
                                   bio: "This is my bio",
                                   email: "uit@gm.uit.edu.vn",
                                   dob: Date(),
                                   isMale: true)
        
        XCTAssertNotNil(instance, "Sorry, user network model test case failed.")
    }

}
