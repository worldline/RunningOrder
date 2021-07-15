//
//  FocusableNSTextField.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 23/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//
import AppKit
import SwiftUI

/// The NSViewRepresentable of an NSFocusableTextField
struct FocusableTextField: NSViewRepresentable {
    let placeholder: String

    @Binding var value: String
    @Binding var isFocused: Bool

    let onCommit: () -> Void

    func makeNSView(context: Context) -> FocusableNSTextField {
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

    func updateNSView(_ nsView: FocusableNSTextField, context: Context) {
        nsView.stringValue = value
        nsView.placeholderString = placeholder
        if !isFocused && context.coordinator.oldFocused == true {
            if context.coordinator.preventFocus {
                context.coordinator.preventFocus = false
            } else {
                nsView.window?.makeFirstResponder(nil)
            }
        }

        context.coordinator.oldFocused = isFocused
    }

    func makeCoordinator() -> FocusableTextField.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: FocusableTextField
        var oldFocused: Bool?
        var preventFocus = false

        init(_ textFieldContainer: FocusableTextField) {
            self.parent = textFieldContainer
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            self.parent.value = textField.stringValue
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            if self.parent.isFocused {
                preventFocus = true
                self.parent.isFocused = false
            }

            self.parent.onCommit()
        }
    }
}

extension FocusableTextField {
    /// A focusable version of a NSTextField
    class FocusableNSTextField: NSTextField {
        var onFocusChange: (Bool) -> Void = { _ in }

        override func becomeFirstResponder() -> Bool {
            let textView = window?.fieldEditor(true, for: nil) as? NSTextView
            textView?.insertionPointColor = NSColor.controlAccentColor
            onFocusChange(true)

            return super.becomeFirstResponder()
        }
    }
}
