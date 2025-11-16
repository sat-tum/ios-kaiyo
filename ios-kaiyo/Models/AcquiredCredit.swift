//
//  AcquiredCredit.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation
import SwiftData

// MARK: - 履修済み単位モデル
@Model
final class AcquiredCredit {
    @Attribute(.unique) var id: UUID
    var courseName: String      // 授業科目名
    var credits: Int            // 単位数
    var difficulty: Difficulty  // 習得難易度
    var category: String        // 科目分類（例: "総合科目-文化学系", "基礎教育-必修"など）
    var semester: String        // 履修学期（例: "2024-前期"）
    var isOverCredit: Bool      // 進級/卒業要件単位数を超過した単位か

    init(id: UUID = UUID(), courseName: String, credits: Int, difficulty: Difficulty, category: String, semester: String, isOverCredit: Bool = false) {
        self.id = id
        self.courseName = courseName
        self.credits = credits
        self.difficulty = difficulty
        self.category = category
        self.semester = semester
        self.isOverCredit = isOverCredit
    }
}

// MARK: - 習得難易度
enum Difficulty: String, Codable, CaseIterable {
    case hard = "H"     // Hard
    case medium = "M"   // Medium
    case easy = "E"     // Easy

    var displayName: String {
        switch self {
        case .hard: return "難"
        case .medium: return "中"
        case .easy: return "易"
        }
    }
}
