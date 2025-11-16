//
//  OnboardingView.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import SwiftUI

/// 初回起動時のオンボーディング画面
struct OnboardingView: View {
    @Bindable var viewModel: AppViewModel
    
    @State private var selectedDepartment: String = ""
    @State private var selectedGrade: Int = 1
    @State private var enrollmentYear: Int = 2024
    @State private var navigateToCreditRegistration = false
    
    private let departments = [
        "海事システム工学科",
        "海洋電子機械工学科",
        "流通情報工学科"
    ]
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private var yearOptions: [Int] {
        Array((currentYear - 4)...(currentYear + 1))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("学科", selection: $selectedDepartment) {
                        Text("選択してください").tag("")
                        ForEach(departments, id: \.self) { department in
                            Text(department).tag(department)
                        }
                    }
                    
                    Picker("入学年度", selection: $enrollmentYear) {
                        ForEach(yearOptions, id: \.self) { year in
                            Text("\(String(year))年度").tag(year)
                        }
                    }
                    
                    Picker("現在の学年", selection: $selectedGrade) {
                        ForEach(1...4, id: \.self) { grade in
                            Text("\(grade)年生").tag(grade)
                        }
                    }
                } header: {
                    Text("基本情報")
                } footer: {
                    Text("入学年度と現在の学年を選択してください")
                }
            }
            .navigationTitle("🎓 初期設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("次へ") {
                        saveProfile()
                    }
                    .disabled(selectedDepartment.isEmpty)
                }
            }
            .navigationDestination(isPresented: $navigateToCreditRegistration) {
                CreditRegistrationView(viewModel: viewModel)
            }
        }
    }
    
    private func saveProfile() {
        viewModel.saveUserProfile(
            enrollmentYear: enrollmentYear,
            currentGrade: selectedGrade,
            department: selectedDepartment
        )
        navigateToCreditRegistration = true
    }
}

#Preview {
    OnboardingView(viewModel: AppViewModel())
}
