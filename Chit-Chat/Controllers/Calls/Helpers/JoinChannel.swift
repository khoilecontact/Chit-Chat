import AgoraRtcKit

class JoinChannel {
    
    private var agoraKit: AgoraRtcEngineKit!
    
    func connect() {
        self.agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        self.agoraKit.joinChannel(
            byToken: API.token,
            channelId: API.channelId,
            info: nil,
            uid: 0
        ) { (channel, uid, elapsed) in
            // ...
        }
        UIApplication.shared.isIdleTimerDisabled = true
    }
        
    init(_ agoraKit: AgoraRtcEngineKit, completion: () -> Void) {
        self.agoraKit = agoraKit
        self.connect()
        completion()
    }
}
