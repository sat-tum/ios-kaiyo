//
//  AcquiredCreditsView.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import SwiftUI

/// 右タブ: 習得済み単位
struct AcquiredCreditsView: View {
    @Bindable var viewModel: AppViewModel
    @State private var selectedCategory: String?
    @State private var showingCategoryDetails = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
            .navigationTitle("習得済み単位")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCategoryDetails) {
                if let category = selectedCategory {
                    CategoryDetailsView(
                        viewModel: viewModel,
                        category: category
                    )
                }
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
                categoryButton(title: "総合科目", category: "総合科目")
                categoryButton(title: "基礎教育", category: "基礎教育-必修")
                categoryButton(title: "専門科目", category: "専門科目-必修")
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
                categoryButton(title: "専門科目（選択）", category: "専門科目-選択")
                categoryButton(title: "外国語系（選択）", category: "外国語系-選択")
                categoryButton(title: "その他選択科目", category: "その他選択")
            }
        }
    }
    
    // MARK: - カテゴリボタン
    private func categoryButton(title: String, category: String) -> some View {
        Button {
            selectedCategory = category
            showingCategoryDetails = true
        } label: {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(calculateAcquired(category: category)) 単位")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
    }
    
    // MARK: - 計算ロジック
    private func calculateAcquired(category: String) -> Int {
        // カテゴリに部分一致する単位を合計
        viewModel.acquiredCredits
            .filter { $0.category.hasPrefix(category) }
            .reduce(0) { $0 + $1.credits }
    }
}

/// カテゴリ詳細を表示するシート
struct CategoryDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AppViewModel
    let category: String
    
    private var credits: [AcquiredCredit] {
        viewModel.acquiredCredits
            .filter { $0.category.hasPrefix(category) }
            .sorted { $0.semester > $1.semester } // 新しい学期順
    }
    
    private var totalCredits: Int {
        credits.reduce(0) { $0 + $1.credits }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // サマリー
                VStack(spacing: 8) {
                    Text("\(totalCredits)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.blue)
                    Text("単位")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))
                
                // 科目リスト
                if credits.isEmpty {
                    ContentUnavailableView(
                        "履修済み科目なし",
                        systemImage: "book.closed",
                        description: Text("このカテゴリの履修済み科目はありません")
                    )
                } else {
                    List {
                        ForEach(groupedBySemester.keys.sorted(by: >), id: \.self) { semester in
                            Section(header: Text(semester)) {
                                ForEach(groupedBySemester[semester] ?? []) { credit in
                                    courseRow(credit: credit)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(categoryDisplayName)
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
    
    // MARK: - 科目行のUI
    private func courseRow(credit: AcquiredCredit) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(credit.courseName)
                    .font(.body)
                
                HStack(spacing: 4) {
                    // 難易度バッジ
                    difficultyBadge(credit.difficulty)
                    
                    // オーバー単位の表示
                    if credit.isOverCredit {
                        Text("超過")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundStyle(.orange)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Text("\(credit.credits)")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("単位")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 難易度バッジ
    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        Text(difficulty.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(difficultyColor(difficulty).opacity(0.2))
            .foregroundStyle(difficultyColor(difficulty))
            .cornerRadius(4)
    }
    
    private func difficultyColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .hard: return .red
        case .medium: return .orange
        case .easy: return .green
        }
    }
    
    // MARK: - 学期でグループ化
    private var groupedBySemester: [String: [AcquiredCredit]] {
        Dictionary(grouping: credits, by: { $0.semester })
    }
    
    // MARK: - カテゴリ表示名
    private var categoryDisplayName: String {
        category
            .replacingOccurrences(of: "-必修", with: "（必修）")
            .replacingOccurrences(of: "-選択", with: "（選択）")
    }
}

#Preview {
    AcquiredCreditsView(viewModel: AppViewModel())
}
