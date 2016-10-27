//
//  CaptureImageViewController.swift
//  CaptureIt
//
//  Created by Tushar Sharma on 29/08/16.
//  Copyright © 2016 Edbinx. All rights reserved.
//

import UIKit

class CaptureImageViewController: UIViewController {
    
    private let photoView = UIImageView()
    var imageData = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(imageData)
        setImageView()
        photoView.image = imageData
        if photoView.image != nil {
            self.thankYou()
        }
        // Do any additional setup after loading the view.
    }
    
    private func setImageView() {
        photoView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        photoView.contentMode = .ScaleAspectFit
        self.view.addSubview(photoView)
    }
    
    private func thankYou() {
            let errorView = UIAlertController(title: "Thank You", message: "Thank You for using CaptureIt app! ❤️😁👍", preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            errorView.addAction(defaultAction)
            self.presentViewController(errorView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
