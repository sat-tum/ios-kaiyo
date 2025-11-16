//
//  AcquiredCreditRepository.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation
import SwiftData

/// 履修済み単位のCRUD操作を管理するリポジトリ
@MainActor
class AcquiredCreditRepository {
    private let context: ModelContext

    init(context: ModelContext? = nil) {
        self.context = context ?? DataManager.shared.context
    }

    /// すべての履修済み単位を取得
    func fetchAll() -> [AcquiredCredit] {
        let descriptor = FetchDescriptor<AcquiredCredit>(
            sortBy: [SortDescriptor(\.semester), SortDescriptor(\.courseName)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 特定のカテゴリの履修済み単位を取得
    func fetchByCategory(_ category: String) -> [AcquiredCredit] {
        let descriptor = FetchDescriptor<AcquiredCredit>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.semester), SortDescriptor(\.courseName)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 特定の学期の履修済み単位を取得
    func fetchBySemester(_ semester: String) -> [AcquiredCredit] {
        let descriptor = FetchDescriptor<AcquiredCredit>(
            predicate: #Predicate { $0.semester == semester },
            sortBy: [SortDescriptor(\.courseName)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 履修済み単位を保存
    func save(_ credit: AcquiredCredit) {
        context.insert(credit)
        try? context.save()
    }

    /// 複数の履修済み単位を一括保存
    func saveBatch(_ credits: [AcquiredCredit]) {
        for credit in credits {
            context.insert(credit)
        }
        try? context.save()
    }

    /// 履修済み単位を更新
    func update(_ credit: AcquiredCredit) {
        try? context.save()
    }

    /// 履修済み単位を削除
    func delete(_ credit: AcquiredCredit) {
        context.delete(credit)
        try? context.save()
    }

    /// すべての履修済み単位を削除
    func deleteAll() {
        let credits = fetchAll()
        for credit in credits {
            context.delete(credit)
        }
        try? context.save()
    }
}
