//
//  MainTabView.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import SwiftUI

/// メインページ（2タブ構成）
struct MainTabView: View {
    @Bindable var viewModel: AppViewModel
    
    var body: some View {
        TabView {
            RemainingCreditsView(viewModel: viewModel)
                .tabItem {
                    Label("残り単位", systemImage: "list.bullet.clipboard")
                }
            
            AcquiredCreditsView(viewModel: viewModel)
                .tabItem {
                    Label("習得済み", systemImage: "checkmark.circle")
                }
        }
    }
}

#Preview {
    MainTabView(viewModel: AppViewModel())
}
