import Foundation

enum UtilitiesMessageChatViewModelType {
    case info, util
}

struct UtilitiesMessageChatViewModel {
    let viewModelType: UtilitiesMessageChatViewModelType
    let title: String
    let handler: (() -> Void)?
}
