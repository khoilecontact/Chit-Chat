import Foundation

enum UtilitiesMessageChatViewModelType {
    case info, util, dangerous, pending, back
}

struct UtilitiesMessageChatViewModel {
    let viewModelType: UtilitiesMessageChatViewModelType
    let title: String
    let handler: (() -> Void)?
}
