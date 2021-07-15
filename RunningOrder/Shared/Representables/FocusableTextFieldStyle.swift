//
//  FocusableTextFieldStyle.swift
//  RunningOrder
//
//  Created by Clément Nonn on 15/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

extension View {
    func focusableTextFieldFormStyle(isFocused: Bool) -> some View {
        self.padding(.horizontal, 8)
            .padding(.vertical, 4)
            // on focus background
            .background(RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(NSColor.textBackgroundColor))
            )
            // on focus border
            .overlay(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isFocused ? Color.accentColor : Color(NSColor.placeholderTextColor), lineWidth: 1.0, antialiased: true)
            )
    }

    func focusableTextFieldSearchFieldStyle(isFocused: Bool) -> some View {
        self.padding(8)
            // on focus background
            .background(RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(NSColor.textBackgroundColor))
            )
            // on focus border
            .overlay(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isFocused ? Color.accentColor : Color(NSColor.placeholderTextColor), lineWidth: 1.0, antialiased: true)
            )
    }

    func focusableTextFieldDefaultStyle(isFocused: Bool) -> some View {
        let borderOpacity: Double = isFocused ? 1 : 0

        return self.padding(5)
            // on focus background
            .background(RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(NSColor.textBackgroundColor).opacity(borderOpacity))
                            .animation(.linear)
            )
            // on focus border
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.accentColor, lineWidth: 1.0, antialiased: true)
                        .opacity(borderOpacity)
                        .animation(.easeInOut)
            )
            .focusable()
    }
}

//extension View {
//    func focusableTextfieldStyle<Style>(_ style: Style) -> some View where Style: FocusableTextfieldStyle {
//        return style.makeBody(
//            configuration: FocusableTextfieldStyleConfiguration(
//                label: .init(inner: AnyView(self)), /* shouldn't be wrapped into AnyView */
//                isFocused: /* should be inferred somehow */
//            )
//        )
//    }
//}
//
//protocol FocusableTextfieldStyle {
//    associatedtype Body: View
//    typealias Configuration = FocusableTextfieldStyleConfiguration
//
//    func makeBody(configuration: Self.Configuration) -> Self.Body
//}
//
//struct FocusableTextfieldStyleConfiguration {
//    let label: FocusableTextfieldStyleConfiguration.Label
//    let isFocused: Bool
//
//    struct Label: View {
//        var inner: AnyView
//
//        var body: some View {
//            inner
//        }
//    }
//}
//
//struct FocusableTextfieldFormStyle: FocusableTextfieldStyle {
//    func makeBody(configuration: Self.Configuration) -> some View {
//        configuration.label
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            // on focus background
//            .background(RoundedRectangle(cornerRadius: 8)
//                            .foregroundColor(Color(NSColor.textBackgroundColor))
//            )
//            // on focus border
//            .overlay(RoundedRectangle(cornerRadius: 8)
//                        .strokeBorder(configuration.isFocused ? Color.accentColor : Color(NSColor.placeholderTextColor), lineWidth: 1.0, antialiased: true)
//            )
//    }
//}
//
//struct FocusableTextfieldSearchFieldStyle: FocusableTextfieldStyle {
//    func makeBody(configuration: Self.Configuration) -> some View {
//        configuration.label
//            .padding(8)
//            // on focus background
//            .background(RoundedRectangle(cornerRadius: 8)
//                            .foregroundColor(Color(NSColor.textBackgroundColor))
//            )
//            // on focus border
//            .overlay(RoundedRectangle(cornerRadius: 8)
//                        .strokeBorder(configuration.isFocused ? Color.accentColor : Color(NSColor.placeholderTextColor), lineWidth: 1.0, antialiased: true)
//            )
//    }
//}
