//
//  CourseCategory.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation

// MARK: - 科目カテゴリ
enum CourseCategory: String, CaseIterable {
    // 必修科目
    case requiredGeneral = "総合科目-必修"
    case requiredBasic = "基礎教育-必修"
    case requiredMajor = "専門科目-必修"

    // 選択科目
    case electiveGeneral = "総合科目-選択"
    case electiveBasic = "基礎教育-選択"
    case electiveMajor = "専門科目-選択"

    var isRequired: Bool {
        switch self {
        case .requiredGeneral, .requiredBasic, .requiredMajor:
            return true
        case .electiveGeneral, .electiveBasic, .electiveMajor:
            return false
        }
    }

    var displayName: String {
        switch self {
        case .requiredGeneral: return "総合科目"
        case .requiredBasic: return "基礎教育"
        case .requiredMajor: return "専門科目"
        case .electiveGeneral: return "総合科目"
        case .electiveBasic: return "基礎教育"
        case .electiveMajor: return "専門科目"
        }
    }
}
