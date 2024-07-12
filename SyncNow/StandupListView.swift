//
//  StandupListView.swift
//  SyncNow
//
//  Created by Ayren King on 7/12/24.
//

import SwiftUI

struct StandupListView: View {
    var body: some View {
        List {
            
        }
        .navigationTitle("Daily Standups")
        .toolbar {
            ToolbarItem {
                Button("Add") {}
            }
        }
    }
}

#Preview {
    MainActor.assumeIsolated {
        NavigationStack {
            StandupListView()
        }
    }
}
