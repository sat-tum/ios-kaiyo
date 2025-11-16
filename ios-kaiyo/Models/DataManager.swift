//
//  DataManager.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation
import SwiftData

/// SwiftDataのモデルコンテナとコンテキストを管理するクラス
@MainActor
class DataManager {
    static let shared = DataManager()
    
    let container: ModelContainer
    var context: ModelContext {
        container.mainContext
    }
    
    private init() {
        do {
            let schema = Schema([
                UserProfile.self,
                AcquiredCredit.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("SwiftDataのコンテナ初期化に失敗しました: \(error)")
        }
    }
}
