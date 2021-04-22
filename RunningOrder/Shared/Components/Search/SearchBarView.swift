//
//  SearchBarView.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 21/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var inputText: String
    @State private var isFocused = false
    @State private var showSelectedView = false
    @State private var disableTextField = false

    @EnvironmentObject var searchManager: SearchManager

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                if let selected = searchManager.selectedSearchItem?.name {
                    Tag("\(selected)", color: Color(identifier: .gray).opacity(0.25), foregroundTextColor: Color.black)
                        .padding(.trailing, 18)
                        .onAppear(perform: {
                            inputText = ""
                            disableTextField = true
                        })
                }
                TextField(searchManager.isItemSelected ? "" : "Search", text: $inputText).disabled(disableTextField)
            }

            .overlay(
                HStack {
                    Spacer()
                    if !inputText.isEmpty || disableTextField {
                        Button(action: {
                            self.inputText = ""
                            searchManager.selectedSearchItem = nil
                            disableTextField = false
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .popover(isPresented: Binding(get: { !inputText.isEmpty && !(searchManager.isItemSelected)},
                                      set: { _ in})) {
            SearchBarSuggestions(searchText: $inputText)
        }
    }
}
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(inputText: .constant(""))
    }
}
