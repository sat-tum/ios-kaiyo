//
//  UserProfileRepository.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation
import SwiftData

/// ユーザープロファイルのCRUD操作を管理するリポジトリ
@MainActor
class UserProfileRepository {
    private let context: ModelContext

    init(context: ModelContext? = nil) {
        self.context = context ?? DataManager.shared.context
    }

    /// ユーザープロファイルを取得（1件のみ想定）
    func fetch() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return try? context.fetch(descriptor).first
    }

    /// ユーザープロファイルが存在するか確認
    func exists() -> Bool {
        return fetch() != nil
    }

    /// ユーザープロファイルを保存
    func save(_ profile: UserProfile) {
        context.insert(profile)
        try? context.save()
    }

    /// ユーザープロファイルを更新
    func update(enrollmentYear: Int? = nil, currentGrade: Int? = nil, department: String? = nil) {
        guard let profile = fetch() else { return }

        if let enrollmentYear = enrollmentYear {
            profile.enrollmentYear = enrollmentYear
        }
        if let currentGrade = currentGrade {
            profile.currentGrade = currentGrade
        }
        if let department = department {
            profile.department = department
        }

        try? context.save()
    }

    /// ユーザープロファイルを削除
    func delete() {
        guard let profile = fetch() else { return }
        context.delete(profile)
        try? context.save()
    }
}
