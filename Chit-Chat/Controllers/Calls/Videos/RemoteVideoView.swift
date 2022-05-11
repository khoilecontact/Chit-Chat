import UIKit
import NVActivityIndicatorView

class RemoteVideoView: UIView {
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 180, y: 370, width: 40, height: 40), type: .circleStrokeSpin, color: .white, padding: 0)
    
    public var isRemoteVideoRender: Bool = true {
        didSet {
            self.isHidden = !isRemoteVideoRender
            activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = !isRemoteVideoRender
        }
    }
                    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        self.layer.zPosition = -1
        self.isUserInteractionEnabled = false
        
        self.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if aDecoder == .none {
            fatalError("init(coder:) has not been implemented")
        } else {
            super.init(coder: aDecoder)
        }
    }
}
