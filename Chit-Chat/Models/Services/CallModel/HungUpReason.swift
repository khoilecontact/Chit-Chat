//
//  HungUpReason.swift
//  Chit-Chat
//
//  Created by KhoiLe on 05/05/2022.
//
import UIKit
import AgoraRtmKit
import AudioToolbox

enum HungupReason {
    case remoteReject(String), toVideoChat, normaly(String), error(Error)
    
    fileprivate var rawValue: Int {
        switch self {
        case .remoteReject: return 0
        case .toVideoChat:  return 1
        case .normaly:      return 2
        case .error:        return 3
        }
    }
    
    static func==(left: HungupReason, right: HungupReason) -> Bool {
        return left.rawValue == right.rawValue
    }
    
    var description: String {
        switch self {
        case .remoteReject:     return "remote reject"
        case .toVideoChat:      return "start video chat"
        case .normaly:          return "normally hung up"
        case .error(let error): return error.localizedDescription
        }
    }
}
