import Foundation

enum UtilitiesMessageChatViewModelType {
    case info, subinfo, util, empty, dangerous, pending, back
}

struct UtilitiesMessageChatViewModel {
    let viewModelType: UtilitiesMessageChatViewModelType
    let title: String
    let icon: String?
    let handler: (() -> Void)?
}
