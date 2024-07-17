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
            AppView(
                store: Store(
                    initialState: AppFeature.State(
                        standupsList: StandupsListFeature.State(
                            standups: [.mock]
                        )
                    )
                ) {
                    AppFeature()
                }
            )
        }
    }
}
