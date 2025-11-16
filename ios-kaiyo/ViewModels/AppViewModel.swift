//
//  AppViewModel.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation
import SwiftUI

/// アプリ全体の状態を管理するViewModel
@MainActor
@Observable
class AppViewModel {
    // リポジトリ
    private let userProfileRepository: UserProfileRepository
    private let creditRepository: AcquiredCreditRepository
    private let rulesManager = CurriculumRulesManager.shared
    
    // ユーザー情報
    var userProfile: UserProfile?
    var isFirstLaunch: Bool = true
    
    // 履修データ
    var acquiredCredits: [AcquiredCredit] = []
    
    // UI状態
    var selectedRequirementType: RequirementType = .grade2
    
    init(
        userProfileRepository: UserProfileRepository? = nil,
        creditRepository: AcquiredCreditRepository? = nil
    ) {
        self.userProfileRepository = userProfileRepository ?? UserProfileRepository()
        self.creditRepository = creditRepository ?? AcquiredCreditRepository()
        
        loadUserProfile()
        loadAcquiredCredits()
    }

    // MARK: - ユーザープロファイル管理

    /// ユーザープロファイルを読み込む
    func loadUserProfile() {
        userProfile = userProfileRepository.fetch()
        isFirstLaunch = userProfile == nil
    }

    /// ユーザープロファイルを保存
    func saveUserProfile(enrollmentYear: Int, currentGrade: Int, department: String) {
        let profile = UserProfile(
            enrollmentYear: enrollmentYear,
            currentGrade: currentGrade,
            department: department
        )
        userProfileRepository.save(profile)
        userProfile = profile
        isFirstLaunch = false
    }

    /// 現在の学年を更新
    func updateCurrentGrade(_ grade: Int) {
        userProfileRepository.update(currentGrade: grade)
        loadUserProfile()
    }

    // MARK: - 履修済み単位管理

    /// 履修済み単位を読み込む
    func loadAcquiredCredits() {
        acquiredCredits = creditRepository.fetchAll()
    }

    /// 履修済み単位を追加
    func addCredit(_ credit: AcquiredCredit) {
        creditRepository.save(credit)
        loadAcquiredCredits()
    }

    /// 複数の履修済み単位を一括追加
    func addCreditsBatch(_ credits: [AcquiredCredit]) {
        creditRepository.saveBatch(credits)
        loadAcquiredCredits()
    }

    /// 履修済み単位を削除
    func deleteCredit(_ credit: AcquiredCredit) {
        creditRepository.delete(credit)
        loadAcquiredCredits()
    }
    
    // MARK: - 計算ロジック
    
    /// 現在の進級条件に基づいたカリキュラムルールを取得
    func getCurrentRules() -> CurriculumRules? {
        guard let profile = userProfile else { return nil }
        return rulesManager.getRules(
            year: profile.enrollmentYear,
            department: profile.department,
            reqType: selectedRequirementType
        )
    }
    
    /// 進級基準に算入される単位数を計算
    func calculateSaninCredits() -> Int {
        guard let rules = getCurrentRules() else { return 0 }
        return CreditCalculator.calculateSaninCredits(
            acquiredCredits: acquiredCredits,
            rules: rules
        )
    }
    
    /// カテゴリごとの残り単位数を計算
    func calculateRemainingCredits() -> [String: Int] {
        guard let rules = getCurrentRules() else { return [:] }
        return CreditCalculator.calculateRemainingCredits(
            acquiredCredits: acquiredCredits,
            rules: rules
        )
    }
    
    /// 総合科目の内訳ごとの残り単位数を計算
    func calculateCompositeSubjectRemaining() -> [String: Int] {
        guard let rules = getCurrentRules() else { return [:] }
        return CreditCalculator.calculateCompositeSubjectRemaining(
            acquiredCredits: acquiredCredits,
            rules: rules
        )
    }
    
    /// 3年次進級に必要な未修得の指定科目を取得
    func getMissingRequiredCourses() -> [String] {
        guard let rules = getCurrentRules() else { return [] }
        return CreditCalculator.getMissingRequiredCourses(
            acquiredCredits: acquiredCredits,
            rules: rules
        )
    }
    
    /// 特定カテゴリの履修済み単位を取得
    func getCredits(by category: String) -> [AcquiredCredit] {
        return acquiredCredits.filter { $0.category == category }
    }
}
