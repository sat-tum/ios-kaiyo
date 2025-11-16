//
//  ContentView.swift
//  ios-kaiyo
//
//  Created by shion suzuki on 2025/11/17.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    
    var body: some View {
        Group {
            if viewModel.isFirstLaunch {
                OnboardingView(viewModel: viewModel)
            } else {
                MainTabView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
