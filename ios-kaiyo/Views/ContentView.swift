//
//  ContentView.swift
//  ios-kaiyo
//
//  Created by shion suzuki on 2025/11/17.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @State private var showingOnboarding = false
    @State private var showingCreditRegistration = false
    
    var body: some View {
        Group {
            if viewModel.isFirstLaunch {
                Color.clear
                    .onAppear {
                        showingOnboarding = true
                    }
            } else {
                MainTabView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView(viewModel: viewModel)
                .interactiveDismissDisabled()
                .onDisappear {
                    if !viewModel.isFirstLaunch {
                        showingCreditRegistration = true
                    }
                }
        }
        .sheet(isPresented: $showingCreditRegistration) {
            CreditRegistrationView(viewModel: viewModel)
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    ContentView()
}
