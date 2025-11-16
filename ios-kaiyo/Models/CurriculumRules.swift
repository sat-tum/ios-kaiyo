//
//  CurriculumRules.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation

// MARK: - 静的履修条件データ
struct CurriculumRules: Codable {
    let year: Int                                   // 適用される入学年度
    let department: String                          // 適用される学科名
    let reqType: RequirementType                    // 進級・卒業要件タイプ
    let totalRequiredCredits: Int                   // 進級基準に算入される総単位数の基準値
    let categoryRequiredCredits: [String: Int]      // 各科目区分の卒業要件単位数
    let compositeSubjectDetails: [String: Int]?     // 総合科目の内訳条件
    let requiredCourses3rd: [String]?               // 3年次進級に必須の指定科目名リスト
}

// MARK: - 進級・卒業要件タイプ
enum RequirementType: String, Codable, CaseIterable {
    case grade2 = "Grade2"          // 2年次進級
    case grade3 = "Grade3"          // 3年次進級
    case grade4 = "Grade4"          // 4年次進級
    case graduation = "Graduation"  // 卒業条件

    var displayName: String {
        switch self {
        case .grade2: return "2年進級"
        case .grade3: return "3年進級"
        case .grade4: return "4年進級"
        case .graduation: return "卒業条件"
        }
    }
}
