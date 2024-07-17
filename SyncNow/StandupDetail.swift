//
//  StandupDetail.swift
//  SyncNow
//
//  Created by Ayren King on 7/15/24.
//

import ComposableArchitecture
import SwiftUI

struct StandupDetailFeature: Reducer {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
        var standup: Standup
    }

    enum Action: Equatable {
        case cancelEditStandupButtonTapped
        case delegate(Delegate)
        case deleteButtonTapped
        case deleteMettings(atOffsets: IndexSet)
        case destination(PresentationAction<Destination.Action>)
        case editButtonTapped
        case saveStandupButtonTapped
    }

    enum Delegate: Equatable {
        case deleteStandup(id: Standup.ID)
        case standupUpdated(Standup)
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelEditStandupButtonTapped:
                state.destination = nil
                return .none
            case .delegate:
                return .none
            case .deleteButtonTapped:
                state.destination = .alert(
                    AlertState {
                        TextState("Are you sure you want to delete?")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmDeletion) {
                            TextState("Delete")
                        }
                    }
                )
                return .none
            case .deleteMettings(atOffsets: let offsets):
                state.standup.meetings.remove(atOffsets: offsets)
                return .none
            case .destination(.presented(.alert(.confirmDeletion))):
                return .run { [id = state.standup.id] send  in
                    await send(.delegate(.deleteStandup(id: id)))
                    await dismiss()
                }
            case .destination(.dismiss):
                return .none
            case .destination:
                return .none
            case .editButtonTapped:
                state.destination = .editStandup(StandupFormFeature.State(standup: state.standup))
                return .none
            case .saveStandupButtonTapped:
                guard case let .editStandup(standupForm) = state.destination else { return .none }
                state.standup = standupForm.standup
                state.destination = nil
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
        .onChange(of: \.standup) { oldValue, newStandup in
            Reduce { state, action in
                    .send(.delegate(.standupUpdated(newStandup)))
            }
        }
    }

    struct Destination: Reducer {
        enum State: Equatable {
            case alert(AlertState<Action.Alert>)
            case editStandup(StandupFormFeature.State)
        }

        enum Action: Equatable {
            case alert(Alert)
            case editStandup(StandupFormFeature.Action)

            enum Alert {
                case confirmDeletion
            }
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.editStandup, action: /Action.editStandup) {
                StandupFormFeature()
            }
        }
    }
}

struct StandupDetailView: View {
    let store: StoreOf<StandupDetailFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section(header: Text("Standup Info")) {
                    NavigationLink(
                        state: AppFeature.Path.State.recordMeeting(
                            RecordMeeting.State(standup: viewStore.standup)
                        )
                    ) {
                        Label("Start Meeting", systemImage: "timer")
                            .font(.headline)
                    }
                    HStack {
                        Label("Length", systemImage: "clock")
                        Spacer()
                        Text(viewStore.standup.duration.formatted(.units()))
                    }
                    .accessibilityElement(children: .combine)

                    HStack {
                        Label("Theme", systemImage: "paintpalette")
                        Spacer()
                        Text(viewStore.standup.theme.name)
                            .padding(4)
                            .foregroundColor(viewStore.standup.theme.accentColor)
                            .background(viewStore.standup.theme.mainColor)
                            .cornerRadius(4)
                    }
                    .accessibilityElement(children: .combine)
                }

                if !viewStore.standup.meetings.isEmpty {
                    Section {
                        ForEach(viewStore.standup.meetings) { meeting in
                            NavigationLink {

                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(meeting.date, style: .date)
                                    Text(meeting.date, style: .time)
                                }
                            }
                        }
                        .onDelete { indices in
                            viewStore.send(.deleteMettings(atOffsets: indices))
                        }
                    }
                }

                Section(header: Text("Attendees")) {
                    ForEach(viewStore.standup.attendees) { attendee in
                        Label(attendee.name, systemImage: "person")
                    }
                }

                Section {
                    Button("Delete", role: .destructive) {
                        viewStore.send(.deleteButtonTapped)
                    }
                    .frame(maxWidth: .infinity)
                }

            }
            .navigationTitle(viewStore.standup.title)
            .toolbar {
                Button("Edit") {
                    viewStore.send(.editButtonTapped)
                }
            }
            .alert(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /StandupDetailFeature.Destination.State.alert,
                action: StandupDetailFeature.Destination.Action.alert
            )
            .sheet(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /StandupDetailFeature.Destination.State.editStandup,
                action: StandupDetailFeature.Destination.Action.editStandup
            ) { store in
                NavigationStack {
                    StandupFormView(store: store)
                        .navigationTitle("Edit standup")
                        .toolbar {
                            ToolbarItem {
                                Button("Save") { viewStore.send(.saveStandupButtonTapped) }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { viewStore.send(.cancelEditStandupButtonTapped) }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StandupDetailView(
            store: Store(initialState: StandupDetailFeature.State(standup: .mock)) {
                StandupDetailFeature()
            }
        )
    }
}
