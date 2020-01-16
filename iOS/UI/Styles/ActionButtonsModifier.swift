//
//  ActionButtonsModifier.swift
//  Jotts
//
//  Created by Hank Brekke on 12/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct ActionButtonsModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: Text
    let buttons: [Button]

    func body(content: Content) -> some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                content.popover(isPresented: $isPresented) {
                    List {
                        ForEach(self.buttons, id: \.type) { button in
                            SwiftUI.Button(action: {
                                button.action?()
                                self.isPresented = false
                            }) {
                                return HStack {
                                    Spacer()
                                    button.title
                                    Spacer()
                                }
                                .foregroundColor(button.type == .destructive ? Color.red : Color.accentColor)
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .introspectTableView { (tableView) in
                        tableView.backgroundColor = .white
                    }
                    .introspectViewController { (controller) in
                        controller.preferredContentSize = CGSize(width: 240, height: 180)
                    }
                }
            } else {
                content.actionSheet(isPresented: $isPresented) {
                    ActionSheet(title: title, buttons: buttons.map({ $0.toActionSheet() }))
                }
            }
        }
    }

    struct Button {
        let type: ButtonType
        let title: Text?
        let action: (() -> Void)?

        enum ButtonType {
            case standard;
            case cancel;
            case destructive;
        }

        func toActionSheet() -> ActionSheet.Button {
            switch type {
            case .standard:
                return .default(title!, action: action)
            case .cancel:
                if let cancelText = title {
                    return .cancel(cancelText, action: action)
                } else {
                    return .cancel(action)
                }
            case .destructive:
                return .destructive(title!, action: action)
            }
        }

        static func `default`(_ title: Text, _ action: (() -> Void)? = nil) -> Button {
            return self.init(type: .standard, title: title, action: action)
        }
        static func cancel(_ title: Text = Text("Cancel"), _ action: (() -> Void)? = nil) -> Button {
            return self.init(type: .cancel, title: title, action: action)
        }
        static func destructive(_ title: Text, _ action: (() -> Void)? = nil) -> Button {
            return self.init(type: .destructive, title: title, action: action)
        }
    }
}
