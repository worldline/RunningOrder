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

        // There are 2 ways to loose focus on the textfield :
        // - We unfocus programmatically
        // - The textfield unfocus itself
        //
        // Here we implement the unfocus programmatic, e.g. when isFocused binding is set to false
        // We check the old status of isFocused, kept in memory by the coordinator, to not unfocus multiple times
        // We may pass in `controlTextDidEndEditing` when textfield is unfocused by the system. but this way, the textfield is already unfocused itself, so we have to prevent to resign focus ouselves
        // In case of unfocus by focusing another textfield, this would unfocus after the new textfield ar focused and so unfocus it...
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
        // We keep in memory the focus state to check it later. Useful to resign the first responder only once
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
