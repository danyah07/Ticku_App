//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 18/01/1448 AH.
//

import Foundation

// ✅ يجعل NSLocalizedString يقرأ اللغة المختارة فوراً بدون إعادة تشغيل التطبيق
// بدون ObservableObject عشان ما يسبب إعادة تحميل كامل للتطبيق
private var bundleKey: UInt8 = 0

final class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer { object_setClass(Bundle.main, BundleEx.self) }
        let lang = language == "ar" ? "ar" : "en"
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return }
        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // ✅ يطبّق اللغة المحفوظة عند تشغيل التطبيق
    static func applyStoredLanguage() {
        let lang = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        setLanguage(lang)
    }
}
