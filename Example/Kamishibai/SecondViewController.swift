//
//  SecondViewController.swift
//  Kamishibai
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a kamishibaiboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    static func create() -> SecondViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: SecondViewController.self)) as! SecondViewController
        return vc
    }

}
