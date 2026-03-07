//
//  UserInformationScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 07/03/26.
//

import SwiftUI

struct UserInformationScreenView: View {
    
    enum ActivePicker: Identifiable {
        case gender, birth, height, weight
        var id: Int { hashValue }
    }
    
    @State private var gender = "Male"
    @State private var birthDate = Date()
    @State private var height = 173
    @State private var weight = 80
    @Environment(\.dismiss) var dismiss
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    @State private var activePicker: ActivePicker?
    
    var birthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: birthDate)
    }
    
    var body: some View {
        VStack {
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(spacing: 0) {
                        
                        ProfileRow(title: "Gender", value: gender)
                            .onTapGesture { activePicker = .gender }
                        
                        Divider()
                        
                        ProfileRow(title: "Birth", value: birthString)
                            .onTapGesture { activePicker = .birth }
                        
                        Divider()
                        
                        ProfileRow(title: "Height", value: "\(height) cm")
                            .onTapGesture { activePicker = .height }
                        
                        Divider()
                        
                        ProfileRow(title: "Weight", value: "\(weight).0 kg")
                            .onTapGesture { activePicker = .weight }
                        
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            
            Spacer()
            
            Button("Save") {

                let profile = UserProfile(
                    gender: gender == "Male" ? 1 : 0,
                    birthDate: birthDate,
                    height: height,
                    weight: weight
                )

//                ringManager.saveProfile(profile)
                UserProfileStorage.save(profile)

                print("User profile saved")
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black)
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .navigationTitle("Profile Card")
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(item: $activePicker) { picker in
            switch picker {
            case .gender:
                GenderPickerView(selectedGender: $gender)
            case .birth:
                BirthPickerView(date: $birthDate)
            case .height:
                HeightPickerView(height: $height)
            case .weight:
                WeightPickerView(weight: $weight)
            }
        }
    }
}

struct ProfileRow: View {
    
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct GenderPickerView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedGender: String
    
    let genders = ["Male","Female","Other"]
    
    var body: some View {
        NavigationStack {
            Picker("Gender", selection: $selectedGender) {
                ForEach(genders, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Gender")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct BirthPickerView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var date: Date
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "Birthdate",
                selection: $date,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .navigationTitle("Birthdate")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HeightPickerView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var height: Int
    
    var body: some View {
        NavigationStack {
            Picker("Height", selection: $height) {
                ForEach(100...220, id: \.self) {
                    Text("\($0) cm")
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Height")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct WeightPickerView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var weight: Int
    
    var body: some View {
        NavigationStack {
            Picker("Weight", selection: $weight) {
                ForEach(30...200, id: \.self) {
                    Text("\($0) kg")
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
