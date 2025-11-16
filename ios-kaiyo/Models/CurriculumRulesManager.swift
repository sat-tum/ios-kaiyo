//
//  CurriculumRulesManager.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation

/// カリキュラムルールを管理するクラス（JSONファイルから読み込み）
class CurriculumRulesManager {
    static let shared = CurriculumRulesManager()

    private var rulesCache: [CurriculumRules] = []

    private init() {
        loadRules()
    }

    /// JSONファイルからカリキュラムルールを読み込む
    private func loadRules() {
        // TODO: 実際のJSONファイルから読み込む実装
        // 現在はサンプルデータ
        rulesCache = []
    }

    /// 指定された条件に合致するカリキュラムルールを取得
    func getRules(year: Int, department: String, reqType: RequirementType) -> CurriculumRules? {
        return rulesCache.first {
            $0.year == year && $0.department == department && $0.reqType == reqType
        }
    }

    /// 指定された学科・年度のすべてのカリキュラムルールを取得
    func getAllRules(year: Int, department: String) -> [CurriculumRules] {
        return rulesCache.filter {
            $0.year == year && $0.department == department
        }
    }
}
