//
//  SampleDataSource.swift
//  Kamishibai
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import Foundation
import UIKit

class SampleDataSource: NSObject, UITableViewDataSource {
    var data = [
        "Kamishibai helps you to create a long tutorial to guide new users.\n\nKamishibai has following features.\n- Highlight a specific view\n- Transition screen\n- Tap a specific view, then go to next\n\nTap this cell after read above.",
        "Available adding custom UI"
    ]

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SampleTableViewCell", for: indexPath)
        if let cell = cell as? SampleTableViewCell {
            cell.label.text = data[indexPath.row]
        }
        return cell
    }
}
