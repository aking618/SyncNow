//
//  SyncNowApp.swift
//  SyncNow
//
//  Created by Ayren King on 7/12/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct SyncNowApp: App {
    var body: some Scene {
        WindowGroup {
            var standup = Standup.mock
            let _ = standup.duration = .seconds(6)

            AppView(
                store: Store(
                    initialState: AppFeature.State(
                        path: StackState([
//                            .detail(.init(standup: .mock)),
//                            .recordMeeting(.init(standup: standup))
                        ]),
                        standupsList: StandupsListFeature.State(
//                            standups: [.mock]
                        )
                    )
                ) {
                    AppFeature()
                }
            )
        }
    }
}
