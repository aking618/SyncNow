//
//  StandupListView.swift
//  SyncNow
//
//  Created by Ayren King on 7/12/24.
//

import ComposableArchitecture
import SwiftUI

struct StandupsListFeature: Reducer {
    struct State {
        var standups: IdentifiedArrayOf<Standup> = []
    }

    enum Action {
        case addButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.standups.append(
                    Standup(id: UUID(), theme: .allCases.randomElement()!)
                )
                return .none
            }
        }
    }
}

struct StandupListView: View {
    let store: StoreOf<StandupsListFeature>

    var body: some View {
        WithViewStore(store, observe: \.standups) { viewStore in
            List {
                ForEach(viewStore.state) { standup in
                    CardView(standup: standup)
                        .listRowBackground(standup.theme.mainColor)
                }
            }
            .navigationTitle("Daily Standups")
            .toolbar {
                ToolbarItem {
                    Button("Add") {
                        viewStore.send(.addButtonTapped)
                    }
                }
            }
        }
    }
}

struct CardView: View {
    let standup: Standup
    var body: some View {
        VStack(alignment: .leading) {
            Text(standup.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack {
                Label("\(standup.attendees.count)", systemImage: "person.3")
                    .accessibilityLabel("\(standup.attendees.count) attendees")
                Spacer()
                Label("\(standup.duration)", systemImage: "clock")
                    .accessibilityLabel("\(standup.duration) minute meeting")
                    .labelStyle(.iconOnly)
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(standup.theme.accentColor)
    }
}


#Preview {
    MainActor.assumeIsolated {
        NavigationStack {
            StandupListView(
                store: Store(initialState: StandupsListFeature.State(standups: [.mock])) {
                    StandupsListFeature()
                }
            )
        }
    }
}
