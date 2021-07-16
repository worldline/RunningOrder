//
//  AppStateIndicator.swift
//  RunningOrder
//
//  Created by Clément Nonn on 16/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

extension ErrorTrace: Identifiable {
    var id: Date { self.date }
}

extension ErrorTrace: Equatable {
    static func == (lhs: ErrorTrace, rhs: ErrorTrace) -> Bool {
        lhs.date == rhs.date
    }
}

struct AppStateIndicator: View {
    @EnvironmentObject var appStateManager: AppStateManager

    let ratio: CGFloat = 1/32
    let size: CGFloat = 10

    @State private var isTapped = false

    var presentErrorList: Binding<Bool> {
        Binding {
            isTapped && !appStateManager.errors.isEmpty
        } set: { value in
            isTapped = value
        }
    }

    var body: some View {
        if appStateManager.currentLoading != nil {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(ratio * size)
                .frame(width: size, height: size)
        } else {
            Circle()
                .fill(appStateManager.errors.isEmpty ? Color.green : .red)
                .frame(width: size, height: size)
                .popover(isPresented: presentErrorList, arrowEdge: .top) {
                    errorList
                }
                .onTapGesture {
                    isTapped = true
                }
        }
    }

    @ViewBuilder var errorList: some View {
        VStack {
            Text("Errors")
                .font(.headline)
            ForEach(appStateManager.errors, id: \.date) { trace in
                HStack {
                    Text(trace.lineDescription)

                    Spacer()

                    Button(action: {
                        appStateManager.errors.removeAll {
                            $0 == trace
                        }
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    }).buttonStyle(PlainButtonStyle())
                }
            }
        }.padding()
    }
}

struct AppStateIndicator_Previews: PreviewProvider {
    static var previews: some View {
        AppStateIndicator()
            .environmentObject(AppStateManager.preview())

        AppStateIndicator()
            .environmentObject(AppStateManager.preview(currentLoading: Progress()))
    }
}
