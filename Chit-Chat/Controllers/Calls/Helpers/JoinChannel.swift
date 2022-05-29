import AgoraRtcKit

class JoinChannel {
    
    private var agoraKit: AgoraRtcEngineKit!
    
    func connect() {
        self.agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        self.agoraKit.joinChannel(
            byToken: "006cf8f308e1fb3430e8dd8a4bbf0dcbf6eIABoi0qhKrLA92sMFawdGW1KU01K8qZajudxD22SSNCKkJhPb+QAAAAAEACjPQT8J3aTYgEAAQAmdpNi",
//            byToken: AgoraChannel.token,
            channelId: AgoraChannel.channelId,
            info: nil,
            uid: 0
        ) { (channel, uid, elapsed) in

        }
        UIApplication.shared.isIdleTimerDisabled = true
        
        
    }
        
    init(_ agoraKit: AgoraRtcEngineKit, agoraChannel: AgoraChannel, completion: () -> Void) {
        self.agoraKit = agoraKit
        self.connect()
        completion()
    }
}
