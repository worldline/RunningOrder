//
//  FocusableNSTextField.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 23/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//
import AppKit
import SwiftUI

class FocusableNSTextField: NSTextField {
    var onFocusChange: (Bool) -> Void = { _ in }

    override func becomeFirstResponder() -> Bool {
        let textView = window?.fieldEditor(true, for: nil) as? NSTextView
        textView?.insertionPointColor = NSColor(named: "AccentColor")!
        onFocusChange(true)
        return super.becomeFirstResponder()
    }
}

struct FocusableNSTextFieldRepresentable: NSViewRepresentable {

    let placeholder: String

    @Binding var value: String
    @Binding var isFocused: Bool

    let onCommit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = FocusableNSTextField()
        textField.delegate = context.coordinator
        textField.placeholderString = placeholder
        textField.backgroundColor = NSColor.clear
        textField.focusRingType = .none
        textField.isBordered = false
        textField.onFocusChange = { isFocused in
            self.isFocused = isFocused
        }
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = value
    }

    func makeCoordinator() -> FocusableNSTextFieldRepresentable.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: FocusableNSTextFieldRepresentable

        init(_ textFieldContainer: FocusableNSTextFieldRepresentable) {
            self.parent = textFieldContainer
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            self.parent.value = textField.stringValue
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            self.parent.isFocused = false
            self.parent.onCommit()
        }
    }
}
