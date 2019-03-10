//
//  LanguageFile.swift
//  Bitcoin
//
//  Created by kcg on 2/20/19.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit

class LanguageFile: NSObject {
    final func localizedString(str: String) -> String {
        if let lang = UserDefaults.standard.string(forKey: "Language") {
            return str.localized(lang: lang)
        }
        return str.localized(lang: "en")
    }
}

extension String{
    func localized(lang: String) -> String{
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
