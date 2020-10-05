//
//  MainView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/06/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var spaceManager: SpaceManager

    let disposeBag = DisposeBag()

    var createdSpaceBinding: Binding<Space?> {
        return Binding<Space?>(
            get: { return nil },
            set: { newValue in
                if let space = newValue {
                    addSpace(space)
                }
            }
        )
    }

    private func addSpace(_ space: Space) {
        spaceManager.create(space: space)
            .ignoreOutput()
            .sink(receiveFailure: { failure in
                Logger.error.log(failure) // TODO error Handling
            })
            .store(in: &disposeBag.cancellables)
    }

    @ViewBuilder var body: some View {
        switch spaceManager.state {
        case .loading:
            ProgressIndicator()
                .onAppear { spaceManager.initialSetup() }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
        case .error(let error):
            Text("error : \(error)" as String)
                .padding()

        case .noSpace:
            WelcomeView(space: createdSpaceBinding)

        case .spaceFound(let space):
            NavigationView {
                SprintList(space: space)
                    .listStyle(SidebarListStyle())
                    .frame(minWidth: 160)

                Text("Select a Sprint")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
            }
            .frame(
                minWidth: 800,
                maxWidth: .infinity,
                minHeight: 400,
                maxHeight: .infinity,
                alignment: .leading
            )
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
