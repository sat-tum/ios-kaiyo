//
//  RemainingCreditsView.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import SwiftUI

/// 左タブ: 残り習得すべき単位
struct RemainingCreditsView: View {
    @Bindable var viewModel: AppViewModel
    @State private var showingCompositeDetails = false
    @State private var showingWarning = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 進級条件切り替えトグル
                requirementTypePicker
                    .padding()
                    .background(Color(.systemGroupedBackground))
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 必修セクション
                        requiredSection
                        
                        // 選択セクション
                        electiveSection
                    }
                    .padding()
                }
            }
            .navigationTitle("残り習得すべき単位")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCompositeDetails) {
                CompositeSubjectDetailsView(viewModel: viewModel)
            }
            .alert("⚠️ 未修得の指定科目", isPresented: $showingWarning) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(warningMessage)
            }
        }
    }
    
    // MARK: - 進級条件切り替えピッカー
    private var requirementTypePicker: some View {
        Picker("進級条件", selection: $viewModel.selectedRequirementType) {
            ForEach(RequirementType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedRequirementType) { _, newValue in
            if newValue == .grade3 {
                checkGrade3Requirements()
            }
        }
    }
    
    // MARK: - 必修セクション
    private var requiredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("必修")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                // 総合科目（タップ可能）
                Button {
                    showingCompositeDetails = true
                } label: {
                    creditRow(
                        title: "総合科目",
                        remaining: calculateRemaining(category: "総合科目"),
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)
                
                // その他の必修科目
                creditRow(title: "基礎教育", remaining: calculateRemaining(category: "基礎教育-必修"))
                creditRow(title: "専門科目", remaining: calculateRemaining(category: "専門科目-必修"))
            }
            
            // 進級基準不足単位数
            if let shortfall = calculateTotalShortfall(), shortfall > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("進級基準まであと \(shortfall) 単位")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - 選択セクション
    private var electiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("選択")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                creditRow(title: "専門科目（選択）", remaining: calculateRemaining(category: "専門科目-選択"))
                creditRow(title: "外国語系（選択）", remaining: calculateRemaining(category: "外国語系-選択"))
                creditRow(title: "その他選択科目", remaining: calculateRemaining(category: "その他選択"))
            }
        }
    }
    
    // MARK: - 単位行のUI
    private func creditRow(title: String, remaining: Int, showChevron: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text("あと \(remaining) 単位")
                .font(.headline)
                .foregroundStyle(remaining > 0 ? .primary : .green)
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    // MARK: - 計算ロジック
    private func calculateRemaining(category: String) -> Int {
        guard let rules = viewModel.getCurrentRules() else { return 0 }
        
        let required = rules.categoryRequiredCredits[category] ?? 0
        let acquired = viewModel.acquiredCredits
            .filter { $0.category == category && !$0.isOverCredit }
            .reduce(0) { $0 + $1.credits }
        
        return max(0, required - acquired)
    }
    
    private func calculateTotalShortfall() -> Int? {
        guard let rules = viewModel.getCurrentRules() else { return nil }
        
        // 進級基準に算入される総単位数を計算
        var totalSaninCredits = 0
        var categoryCredits: [String: Int] = [:]
        
        // カテゴリごとの累計
        for credit in viewModel.acquiredCredits.filter({ !$0.isOverCredit }) {
            categoryCredits[credit.category, default: 0] += credit.credits
        }
        
        // オーバー単位を除外して算入単位数を計算
        for (category, acquired) in categoryCredits {
            let limit = rules.categoryRequiredCredits[category] ?? 999
            let sanin = min(acquired, limit)
            totalSaninCredits += sanin
        }
        
        return max(0, rules.totalRequiredCredits - totalSaninCredits)
    }
    
    // MARK: - 3年次進級の指定科目チェック
    private func checkGrade3Requirements() {
        guard let rules = viewModel.getCurrentRules(),
              let requiredCourses = rules.requiredCourses3rd else { return }
        
        let acquiredCourseNames = Set(viewModel.acquiredCredits.map { $0.courseName })
        let missingCourses = requiredCourses.filter { !acquiredCourseNames.contains($0) }
        
        if !missingCourses.isEmpty {
            showingWarning = true
        }
    }
    
    private var warningMessage: String {
        guard let rules = viewModel.getCurrentRules(),
              let requiredCourses = rules.requiredCourses3rd else { return "" }
        
        let acquiredCourseNames = Set(viewModel.acquiredCredits.map { $0.courseName })
        let missingCourses = requiredCourses.filter { !acquiredCourseNames.contains($0) }
        
        return "以下の指定科目が未修得です:\n" + missingCourses.joined(separator: "\n")
    }
}

/// 総合科目の内訳を表示するシート
struct CompositeSubjectDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if let details = viewModel.getCurrentRules()?.compositeSubjectDetails {
                    ForEach(details.sorted(by: { $0.key < $1.key }), id: \.key) { category, required in
                        HStack {
                            Text(category)
                            Spacer()
                            Text("あと \(calculateRemaining(category: "総合科目-\(category)", required: required)) 単位")
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "データなし",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("総合科目の内訳情報がありません")
                    )
                }
            }
            .navigationTitle("総合科目内訳")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func calculateRemaining(category: String, required: Int) -> Int {
        let acquired = viewModel.acquiredCredits
            .filter { $0.category == category && !$0.isOverCredit }
            .reduce(0) { $0 + $1.credits }
        
        return max(0, required - acquired)
    }
}

#Preview {
    RemainingCreditsView(viewModel: AppViewModel())
}
