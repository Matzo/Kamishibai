//
//  Kamishibai.swift
//  Hello
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import Foundation

public protocol KamishibaiSceneIdentifierType {
    var intValue: Int { get }
//    static var count: Int { get }
}

public extension KamishibaiSceneIdentifierType where Self: RawRepresentable, Self.RawValue == Int {
    var intValue: Int {
        return rawValue
    }
}

public protocol KamishibaiCustomViewAnimation: class {
    func show(animated: Bool, fulfill: @escaping () -> Void)
    func hide(animated: Bool, fulfill: @escaping () -> Void)
}

public func == (l: KamishibaiSceneIdentifierType?, r: KamishibaiSceneIdentifierType?) -> Bool {
    guard let l = l, let r = r else { return false }
    return l.intValue == r.intValue
}

public class Kamishibai {

    // MARK: Properties
    public weak var currentViewController: UIViewController?
    public var userInfo = [AnyHashable: Any]()
    public weak var currentTodo: KamishibaiScene?
    public var scenes = [KamishibaiScene]()
    public var completion: (() -> Void)?
    public let transition = KamishibaiTransitioning()
    public var focus = KamishibaiFocusViewController.create()

    // MARK: Initialization
    public init(initialViewController: UIViewController) {
        currentViewController = initialViewController
        focus.kamishibai = self
    }

    // MARK: Private Methods
    func nextTodo() -> KamishibaiScene? {
        guard let current = currentTodo else { return nil }
        guard let startIndex = scenes.index(where: { $0 == current }) else { return nil }
        guard scenes.count > startIndex + 1 else { return nil }

        for i in (startIndex + 1)..<scenes.count {
            if scenes[i].isFinished {
                continue
            }
            return scenes[i]
        }

        return nil
    }

    // MARK: Public Methods
    /**
     sceneを開始する
     */
    public func startStory() {
        guard let scene = scenes.first else {
            finish()
            return
        }

        invoke(scene)
    }

    /**
     scenes の中にある sceneItentifier が一致する scene を終了させる
     その後、現在実行中の scene であれば、次のまだ終了していない scene を実行する
     */
    public func fulfill(identifier: KamishibaiSceneIdentifierType) {
        guard self.currentTodo?.identifier == identifier else { return }
    }

    /**
     渡された scene を終了させる
     その後、現在実行中の scene であれば、次のまだ終了していない scene を実行する
     */
    public func fulfill(scene: KamishibaiScene) {
        if scene.isFinished { return }
        
        // scene を終了させる
        scene.isFinished = true

        // 現在の scene なら次へ
        if let current = currentTodo, current == scene {
            self.next()
        }
    }

    /**
     現在実行中の scene を終了させる
     その後、次のまだ終了していない scene を実行する
     */
    public func fulfill() {
    }

    /**
     全てのsceneが完了した際に呼ばれます
     */
    public func finish() {
        completion?()
    }

    public func skip(identifier: KamishibaiSceneIdentifierType) {
        guard self.currentTodo?.identifier == identifier else { return }
    }

    /**
     終了処理を呼び出します
     */
    public func skipAll() {
        completion?()
    }

    /**
     Go back to previous ToDo
     */
    public func back() {
    }

    /**
     Go to next ToDo
     */
    public func next() {
        // 全部終了していれば finish()
        if scenes.filter({ !$0.isFinished }).count == 0 {
            finish()
            return
        }

        // 次があれば scene を選択して実行する
        if let scene = nextTodo() {
            invoke(scene)
        }
    }

    public func invoke(_ scene: KamishibaiScene) {
        currentTodo = scene

        if let transition = scene.transition, let vc = currentViewController {
            focus.dismiss(animated: true) {
                self.transition.transision(fromVC: vc, type: transition, animated: true) { [weak self] (nextVC) in
                    self?.currentViewController = nextVC
                    scene.sceneBlock(scene)
                }
            }
        } else {
            scene.sceneBlock(scene)
        }

    }

    public func append(_ scene: KamishibaiScene) {
        if scenes.contains(where: { $0.identifier == scene.identifier }) {
            assertionFailure("Can't use same Identifier")
        }
        scene.kamishibai = self
        self.scenes.append(scene)
    }

    /**
     */
    public func insertNext(_ scene: KamishibaiScene) {
        if scenes.contains(where: { $0.identifier == scene.identifier }) {
            assertionFailure("Can't use same Identifier")
        }
        scene.kamishibai = self

        if let current = currentTodo, let index = scenes.index(where: { $0 == current }), scenes.count > index + 1 {
            self.scenes.insert(scene, at: index + 1)
        } else {
            self.scenes.append(scene)
        }
    }

    public func clean() {
        completion = nil
        userInfo.removeAll()
        currentTodo = nil
        scenes.removeAll()
        focus.dismiss(animated: true, completion: { [weak self] in
            self?.focus.clean()
            self?.focus = KamishibaiFocusViewController.create()
        })
    }
}

