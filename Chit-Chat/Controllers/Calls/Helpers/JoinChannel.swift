import AgoraRtcKit

class JoinChannel {
    
    private var agoraKit: AgoraRtcEngineKit!
    
    func connect() {
        self.agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        self.agoraKit.joinChannel(
            byToken: "006cf8f308e1fb3430e8dd8a4bbf0dcbf6eIACYvJbS8hw9EFILInW+MSoxxf0fPxMZz6OdNq/8CghqcJhPb+QAAAAAEACjPQT8nv+QYgEAAQCe/5Bi",
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
