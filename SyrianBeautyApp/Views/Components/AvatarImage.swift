//
//  AvatarImage.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//
import SwiftUI

struct AvatarImage: View {
    var url: String? // لن نستخدمه حاليًا

    var body: some View {
        // صورة افتراضية ثابتة بدون محاولة تحميل من الإنترنت
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
    }
}

