//
//  ViewController.swift
//  Kamishibai
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import UIKit
import Kamishibai

class ViewController: UIViewController {

    var dataSource = SampleDataSource()
    lazy var kamishibai: Kamishibai = {
        let kamishibai = Kamishibai(initialViewController: self)
        return kamishibai
    }()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 40
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "About Kamishibai"
        tableView.dataSource = dataSource
        tableView.reloadData()

        DispatchQueue.main.asyncAfter(timeInterval: 0.1) {
            self.setupStory()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !(isMovingFromParentViewController || isMovingToParentViewController) else {
            assertionFailure("Don't call push(fromVC:toVC:animated:) dualing isMovingFromParentViewController or isMovingFromParentViewController ")
            return
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setupStory() {
        setupTest(identifier: "start kamishibai", scene: nil)

        kamishibai.append(KamishibaiScene(scene: { (scene) in
            self.setupTest(identifier: "scene 1", scene: scene)

            guard let vc = scene.kamishibai?.currentViewController as? ViewController else { return }
            let cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
            let frame = cell.convert(cell.bounds, to: vc.view)

            scene.kamishibai?.focus.on(view: vc.navigationController?.view, focus: Focus.Rect(frame: frame))
            scene.fulfillWhenTapFocus()
        }))
        kamishibai.append(KamishibaiScene(scene: { (scene) in
            self.setupTest(identifier: "scene 2", scene: scene)

            guard let vc = scene.kamishibai?.currentViewController as? ViewController else { return }
            let cell = vc.tableView.cellForRow(at: IndexPath(row: 1, section: 0))!
            let frame = cell.convert(cell.bounds, to: vc.view)
            scene.kamishibai?.focus.on(view: vc.navigationController?.view, focus: Focus.Rect(frame: frame))

            let guide = SampleGuideView.create()
            scene.kamishibai?.focus.addCustomView(view: guide, position: .bottomRight(CGPoint.zero))
            scene.fulfillWhenTap(view: guide.button)
        }))
        kamishibai.append(KamishibaiScene(transition: .push(SecondViewController.create()), scene: { (scene) in
            self.setupTest(identifier: "scene 3", scene: scene)

            guard let vc = scene.kamishibai?.currentViewController as? SecondViewController else { return }
            scene.kamishibai?.focus.on(view: vc.navigationController?.view, focus: Focus.Rect(frame: vc.button.frame))

            let guide = SampleGuideLabel("Available screen transition\n- pushViewController\n- presentViewController\n- custom")
            scene.kamishibai?.focus.addCustomView(view: guide, position: .bottomRight(CGPoint(x: -20, y: 10)))
            scene.fulfillWhenTapFocus()
        }))
        kamishibai.append(KamishibaiScene(transition: .present(SecondViewController.create()), scene: { (scene) in
            self.setupTest(identifier: "scene 4", scene: scene)

            guard let vc = scene.kamishibai?.currentViewController as? SecondViewController else { return }
            scene.kamishibai?.focus.on(view: vc.navigationController?.view, focus: Focus.Rect(frame: vc.button.frame))

            let guide = SampleGuideLabel("Also available\n- popViewController\n- dismissViewController\n- custom")
            scene.kamishibai?.focus.addCustomView(view: guide, position: .bottomRight(CGPoint(x: -20, y: 10)))
            scene.fulfillWhenTapFocus()
        }))
        kamishibai.append(KamishibaiScene(transition: .dismiss, scene: { (scene) in
            self.setupTest(identifier: "scene 5", scene: scene)

            scene.fulfill()
        }))
        kamishibai.append(KamishibaiScene(transition: .popToRoot, scene: { (scene) in
            self.setupTest(identifier: "scene 6", scene: scene)

            guard let vc = scene.kamishibai?.currentViewController else { return }
            let alert = UIAlertController(title: "Congraturations!",
                                          message: "You have successfully finished this tutorial.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { (alert) in
                scene.fulfill()
            }))
            vc.present(alert, animated: true, completion: nil)
        }))

        kamishibai.completion = {
            self.setupTest(identifier: "complete kamishibai", scene: nil)
        }

        kamishibai.startStory()
    }

    func setupTest(identifier: String, scene: KamishibaiScene?) {
        print(identifier)
        guard let vc = scene?.kamishibai?.currentViewController else { return }
        vc.title = identifier

        scene?.kamishibai?.focus.view.accessibilityIdentifier = "focus"
        vc.view.accessibilityIdentifier = identifier
    }
}


public extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        let onesec = DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + UInt64(timeInterval * 1_000_000_000))
        DispatchQueue.main.asyncAfter(deadline: onesec) {
            execute()
        }

//        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
//            execute()
//        }
    }
}
