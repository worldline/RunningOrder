//
//  SearchBarView.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 21/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct SearchBarView: View {
    @EnvironmentObject var searchManager: SearchManager

    @State private var isFocused: Bool = false

    var shouldDisplayPopover: Binding<String?> {
        Binding {
            if !searchManager.currentSearchText.isEmpty && isFocused {
                return searchManager.currentSearchText
            } else {
                return nil
            }
        } set: { _ in }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            FocusableTextField(
                placeholder: searchManager.isItemSelected ? "" : NSLocalizedString("Search", comment: ""),
                value: $searchManager.currentSearchText,
                isFocused: $isFocused,
                onCommit: {}
            )
            .padding(8)
            // on focus background
            .background(RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(NSColor.textBackgroundColor))
            )
            // on focus border
            .overlay(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isFocused ? Color.accentColor : Color(NSColor.placeholderTextColor), lineWidth: 1.0, antialiased: true)
            )
            .disabled(searchManager.isItemSelected)

            if let selected = searchManager.selectedSearchItem?.name {
                Tag(selected, color: Color(identifier: .gray).opacity(0.25), foregroundTextColor: Color.black)
                    .padding(.trailing, 22)
                    .padding(.leading, 5)
            }
        }
        .overlay(
            HStack {
                Spacer()
                if !searchManager.currentSearchText.isEmpty || searchManager.isItemSelected {
                    Button(action: searchManager.resetSearch) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        )
        .popover(item: shouldDisplayPopover, content: { searchText in
            SearchBarSuggestions(searchText: searchText)
        })
    }
}
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
            .environmentObject(SearchManager())
    }
}

extension String: Identifiable {
    public var id: String { self }
}
