//
//  CreditCalculator.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation

/// 進級判定・単位計算のコアロジックを提供するクラス
class CreditCalculator {
    
    /// 進級基準に算入される単位数を計算する
    /// - Parameters:
    ///   - acquiredCredits: 履修済み単位のリスト
    ///   - rules: 適用するカリキュラムルール
    /// - Returns: 算入される総単位数
    static func calculateSaninCredits(
        acquiredCredits: [AcquiredCredit],
        rules: CurriculumRules
    ) -> Int {
        var totalSaninCredits = 0
        var acquiredCreditsByCategory: [String: Int] = [:]
        
        // 1. 各区分で修得した単位を累計する（オーバー単位は除外）
        for credit in acquiredCredits where !credit.isOverCredit {
            acquiredCreditsByCategory[credit.category, default: 0] += credit.credits
        }
        
        // 2. 区分ごとにオーバー単位をチェックし、算入単位数を計算する
        for (category, acquired) in acquiredCreditsByCategory {
            let limit = rules.categoryRequiredCredits[category] ?? 999
            
            // '進級基準に算入される単位' = min(修得単位, 卒業要件単位数)
            let saninCredits = min(acquired, limit)
            totalSaninCredits += saninCredits
        }
        
        return totalSaninCredits
    }
    
    /// カテゴリごとの残り単位数を計算する
    /// - Parameters:
    ///   - acquiredCredits: 履修済み単位のリスト
    ///   - rules: 適用するカリキュラムルール
    /// - Returns: カテゴリごとの残り単位数の辞書
    static func calculateRemainingCredits(
        acquiredCredits: [AcquiredCredit],
        rules: CurriculumRules
    ) -> [String: Int] {
        var remainingCredits: [String: Int] = [:]
        var acquiredCreditsByCategory: [String: Int] = [:]
        
        // 各区分で修得した単位を累計する
        for credit in acquiredCredits where !credit.isOverCredit {
            acquiredCreditsByCategory[credit.category, default: 0] += credit.credits
        }
        
        // 各区分の残り単位数を計算
        for (category, required) in rules.categoryRequiredCredits {
            let acquired = acquiredCreditsByCategory[category] ?? 0
            remainingCredits[category] = max(0, required - acquired)
        }
        
        return remainingCredits
    }
    
    /// 総合科目の内訳ごとの残り単位数を計算する
    /// - Parameters:
    ///   - acquiredCredits: 履修済み単位のリスト
    ///   - rules: 適用するカリキュラムルール
    /// - Returns: 総合科目内訳ごとの残り単位数の辞書
    static func calculateCompositeSubjectRemaining(
        acquiredCredits: [AcquiredCredit],
        rules: CurriculumRules
    ) -> [String: Int] {
        guard let compositeDetails = rules.compositeSubjectDetails else {
            return [:]
        }
        
        var remainingCredits: [String: Int] = [:]
        var acquiredBySubcategory: [String: Int] = [:]
        
        // 総合科目の各内訳で修得した単位を累計
        for credit in acquiredCredits where !credit.isOverCredit {
            // カテゴリが総合科目関連の場合
            if credit.category.contains("総合科目") {
                acquiredBySubcategory[credit.category, default: 0] += credit.credits
            }
        }
        
        // 各内訳の残り単位数を計算
        for (subcategory, required) in compositeDetails {
            let acquired = acquiredBySubcategory[subcategory] ?? 0
            remainingCredits[subcategory] = max(0, required - acquired)
        }
        
        return remainingCredits
    }
    
    /// 3年次進級に必要な指定科目の未修得リストを取得
    /// - Parameters:
    ///   - acquiredCredits: 履修済み単位のリスト
    ///   - rules: 適用するカリキュラムルール
    /// - Returns: 未修得の指定科目名のリスト
    static func getMissingRequiredCourses(
        acquiredCredits: [AcquiredCredit],
        rules: CurriculumRules
    ) -> [String] {
        guard let requiredCourses = rules.requiredCourses3rd else {
            return []
        }
        
        let acquiredCourseNames = Set(acquiredCredits.map { $0.courseName })
        return requiredCourses.filter { !acquiredCourseNames.contains($0) }
    }
    
    /// オーバー単位かどうかを判定して更新
    /// - Parameters:
    ///   - credit: 判定対象の履修済み単位
    ///   - allCredits: すべての履修済み単位
    ///   - rules: 適用するカリキュラムルール
    /// - Returns: オーバー単位かどうか
    static func isOverCredit(
        credit: AcquiredCredit,
        allCredits: [AcquiredCredit],
        rules: CurriculumRules
    ) -> Bool {
        let categoryLimit = rules.categoryRequiredCredits[credit.category] ?? 999
        
        // 同じカテゴリの累計単位数を計算
        let categoryTotal = allCredits
            .filter { $0.category == credit.category && !$0.isOverCredit }
            .reduce(0) { $0 + $1.credits }
        
        return categoryTotal > categoryLimit
    }
}
