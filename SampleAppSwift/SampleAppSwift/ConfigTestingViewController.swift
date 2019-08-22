//
//  ConfigTestingViewController.swift
//  SampleAppSwift
//
//  Created by ani on 6/19/19.
//  Copyright © 2019 LaunchKey. All rights reserved.
//

import Foundation
import CoreLocation

class ConfigTestViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    let authMethodsArray = ["PIN Code", "Circle Code", "Wearables", "Locations", "Fingerprint Scan", "Face Scan"]
    var enablePIN = UISwitch()
    var enableCircle = UISwitch()
    var enableWearables = UISwitch()
    var enableLocations = UISwitch()
    var enableFingerprint = UISwitch()
    var enableFace = UISwitch()
    var allowSecurityChangesUnlinked = UISwitch()
    var tfActivationDelayWearbale = UITextField()
    var tfActivationDelayLocations = UITextField()
    var tfAuthFailureThreshold = UITextField()
    var tfAutoUnlinkThreshold = UITextField()
    var tfAutoUnlinkWarningThreshold = UITextField()
    
    @IBOutlet weak var tblConfigTesting: UITableView!
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tblConfigTesting.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tblConfigTesting.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Config Testing"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        locationManager.delegate = self
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        let pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to:tblConfigTesting)
        var contentOffset:CGPoint = tblConfigTesting.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textField.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        tblConfigTesting.contentOffset = contentOffset
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let cell = textField.superview?.superview as! UITableViewCell
        let indexPath = tblConfigTesting.indexPath(for: cell)
        tblConfigTesting.scrollToRow(at: indexPath!, at: .middle, animated: true)
        
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return authMethodsArray.count + 9
    }
    
    @objc func btnReinitializePressed(sender:UIButton!)
    {
        let config = AuthenticatorConfig.make {builder in
            builder?.sdkKey = UserDefaults.standard.string(forKey: "sdkKey")
            builder?.enablePINCode = self.enablePIN.isOn
            builder?.enableCircleCode = self.enableCircle.isOn
            builder?.enableGeofencing = self.enableLocations.isOn
            builder?.enableWearable = self.enableWearables.isOn
            builder?.enableFingerprint = self.enableFingerprint.isOn
            builder?.enableFace = self.enableFace.isOn
            builder?.activationDelayGeofence = Int32(self.tfActivationDelayLocations.text!)!
            builder?.activationDelayWearable = Int32(self.tfActivationDelayWearbale.text!)!
            builder?.thresholdAuthFailure = Int32(self.tfAuthFailureThreshold.text!)!
            builder?.thresholdAutoUnlink = Int32(self.tfAutoUnlinkThreshold.text!)!
            builder?.thresholdAutoUnlinkWarning = Int32(self.tfAutoUnlinkWarningThreshold.text!)!
            builder?.enableSecurityChangesWhenUnlinked = self.allowSecurityChangesUnlinked.isOn
        }
        
        AuthenticatorManager.sharedClient().initialize(config)
        
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func btnGetDeviceLocationPressed(sender: UIButton!) {
        guard (CLLocationManager.authorizationStatus() == .authorizedAlways ||
              CLLocationManager.authorizationStatus() == .authorizedWhenInUse) else {
                locationManager.requestWhenInUseAuthorization()
                return
        }
        self.awaitingLocationDisplay = true
        locationManager.requestLocation()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if(indexPath.row >= 0 && indexPath.row < authMethodsArray.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AuthMethodCell", for: indexPath) as UITableViewCell
            
            if let labelAuthMethod = cell.contentView.viewWithTag(1) as? UILabel
            {
                labelAuthMethod.text = authMethodsArray[indexPath.row]
            }
            
            if(indexPath.row == 0)
            {
                enablePIN = cell.contentView.viewWithTag(2) as! UISwitch
                enablePIN .setOn((AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.enablePINCode)!, animated: false)
                enablePIN.accessibilityIdentifier = "pin_code_switch"
            }
            else if(indexPath.row == 1)
            {
                enableCircle = cell.contentView.viewWithTag(2) as! UISwitch
                enableCircle .setOn((AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.enableCircleCode)!, animated: false)
                enableCircle.accessibilityIdentifier = "circle_code_switch"
            }
            else if(indexPath.row == 2)
            {
                enableWearables = cell.contentView.viewWithTag(2) as! UISwitch
                enableWearables .setOn((AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.enableWearable)!, animated: false)
                enableWearables.accessibilityIdentifier = "wearables_switch"
            }
            else if(indexPath.row == 3)
            {
                enableLocations = cell.contentView.viewWithTag(2) as! UISwitch
                enableLocations .setOn((AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.enableGeofencing)!, animated: false)
                enableLocations.accessibilityIdentifier = "locations_switch"
            }
            else if(indexPath.row == 4)
            {
                enableFingerprint = cell.contentView.viewWithTag(2) as! UISwitch
                enableFingerprint .setOn((AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.enableFingerprint)!, animated: false)
                enableFingerprint.accessibilityIdentifier = "fingerprint_switch"
            }
            else if(indexPath.row == 5)
            {
                enableFace = cell.contentView.viewWithTag(2) as! UISwitch
                enableFace .setOn((AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.enableFace)!, animated: false)
                enableFace.accessibilityIdentifier = "face_scan_switch"
            }
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        if(indexPath.row == 6)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivationDelayWearablesCell", for: indexPath) as UITableViewCell
            tfActivationDelayWearbale = cell.contentView.viewWithTag(3) as! UITextField
            tfActivationDelayWearbale.text = (AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.activationDelayWearable)?.description
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            tfActivationDelayWearbale.accessibilityIdentifier = "delay_wearbles_text_field"
            return cell
        }
        if(indexPath.row == 7)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivationDelayLocationsCell", for: indexPath) as UITableViewCell
            tfActivationDelayLocations = cell.contentView.viewWithTag(4) as! UITextField
            tfActivationDelayLocations.text = (AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.activationDelayGeofence)?.description
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            tfActivationDelayLocations.accessibilityIdentifier = "delay_location_text_field"
            return cell
        }
        if(indexPath.row == 8)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AuthFailureThresholdCell", for: indexPath) as UITableViewCell
            tfAuthFailureThreshold = cell.contentView.viewWithTag(5) as! UITextField
            tfAuthFailureThreshold.text = (AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.thresholdAuthFailure)?.description
            tfAuthFailureThreshold.accessibilityIdentifier = "auth_failure_threshold_text_field"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        if(indexPath.row == 9)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoUnlinkThresholdCell", for: indexPath) as UITableViewCell
            tfAutoUnlinkThreshold = cell.contentView.viewWithTag(6) as! UITextField
            tfAutoUnlinkThreshold.text = (AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.thresholdAutoUnlink)?.description
            tfAutoUnlinkThreshold.accessibilityIdentifier = "auto_unlink_threshold_text_field"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        if(indexPath.row == 10)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoUnlinkWarningThresholdCell", for: indexPath) as UITableViewCell
            tfAutoUnlinkWarningThreshold = cell.contentView.viewWithTag(7) as! UITextField
            tfAutoUnlinkWarningThreshold.text = (AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.thresholdAutoUnlinkWarning)?.description
            tfAutoUnlinkWarningThreshold.accessibilityIdentifier = "auto_unlink_warning_threshold"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        if(indexPath.row == 11)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecurityChangesUnlinkedCell", for: indexPath) as UITableViewCell
            allowSecurityChangesUnlinked = cell.contentView.viewWithTag(8) as! UISwitch
            allowSecurityChangesUnlinked .setOn((AuthenticatorManager.sharedClient()?.getAuthenticatorConfigInstance()!.enableSecurityChangesWhenUnlinked)!, animated: false)
            allowSecurityChangesUnlinked.accessibilityIdentifier = "allow_changes_unlinked_switch"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        if(indexPath.row == 12)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EndpointCell", for: indexPath) as UITableViewCell
            if let labelEndpoint = cell.contentView.viewWithTag(9) as? UILabel
            {
                let endpoint = Bundle.main.object(forInfoDictionaryKey: "LKEndpoint")
                labelEndpoint.text = String(format: "Endpoint : %@", endpoint as! CVarArg)
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        if(indexPath.row == 13)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as UITableViewCell
            
            if let btnGetLocation = cell.contentView.viewWithTag(10) as? UIButton
            {
                btnGetLocation.tintColor = UIColor(red: 0.0, green: 122.0/255, blue: 1.0, alpha: 1.0)
                btnGetLocation.addTarget(self, action:#selector(btnGetDeviceLocationPressed), for:.touchUpInside)
                btnGetLocation.accessibilityIdentifier = "getLocation_button"
            }
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReinitializeCell", for: indexPath) as UITableViewCell
            
            if let btnReinitialize = cell.contentView.viewWithTag(11) as? UIButton
            {
                btnReinitialize.tintColor = UIColor(red: 0.0, green: 122.0/255, blue: 1.0, alpha: 1.0)
                btnReinitialize.addTarget(self, action:#selector(btnReinitializePressed), for:.touchUpInside)
                btnReinitialize.accessibilityIdentifier = "reinitialize_button"
            }
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
    
    // MARK: Location Services
    
    let locationManager = CLLocationManager.init()
    
    var awaitingLocationDisplay : Bool = false

    func displayLocation(location : CLLocation) {
        let latitude = String(format: "%f", location.coordinate.latitude)
        let longitude = String(format: "%f", location.coordinate.longitude)
        let title = "Current Location"
        let message = "Latitude: \(latitude),\nLongitude: \(longitude)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if awaitingLocationDisplay {
            awaitingLocationDisplay = false
            displayLocation(location: locations.last!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR RETRIEVING LOCATION")
    }
}
