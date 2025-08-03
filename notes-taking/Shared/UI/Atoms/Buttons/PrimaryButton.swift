//
//  PrimaryButton.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    private let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57) // #819A91
    private let cream = Color(red: 0.93, green: 0.94, blue: 0.88) // #EEEFE0
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(cream)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isEnabled ? sageGreen : Color.gray)
                .cornerRadius(8)
        }
        .disabled(!isEnabled)
    }
}