import Foundation

enum UtilitiesMessageChatViewModelType {
    case info, util, pending, back
}

struct UtilitiesMessageChatViewModel {
    let viewModelType: UtilitiesMessageChatViewModelType
    let title: String
    let handler: (() -> Void)?
}
