//  VAChatView+LocationService.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit
import MapKit

extension VAChatViewController {

    func configureMapView() {
        self.locationContainerView.backgroundColor = .black.withAlphaComponent(0.35)
        self.locationBackgroundView.layer.borderWidth = 1
        self.locationBackgroundView.layer.borderColor = isNewGenAITheme ? VAColorUtility.borderColor_NT.cgColor : UIColor.systemGroupedBackground.cgColor
        self.locationBackgroundView.layer.cornerRadius = 6.0
        self.mapViewContainer.layer.cornerRadius = 6.0
        self.locationContainerTitle.textColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.senderBubbleColor
        self.locationCloseImageView.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.senderBubbleColor
        self.sendLocationButtonContainer.layer.cornerRadius = 20.0
        self.mapView.showsUserLocation = true
        self.locationContainerTitle.font = isNewGenAITheme ? GenAIFonts().bold() : UIFont.systemFont(ofSize: textFontSize, weight: .medium)
        self.sendLocationButton.titleLabel?.font = isNewGenAITheme ? GenAIFonts().bold() : UIFont.systemFont(ofSize: 15, weight: .medium)

        let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTapGesture(gestureRecognizer:)))
        mapView.addGestureRecognizer(mapTapGesture)
        
    }

    @objc func handleMapTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
        debugPrint(locationCoordinate)
        self.userLocation = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        self.userLocation!.lookUpLocationName { (name) in
            self.updateLocationOnMap(to: self.userLocation!, with: name)
        }
    }

    func requestLocationPermissions() {
        if #available(iOS 14.0, *) {
            if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                self.locationManager.startUpdatingLocation()
                self.addLocationView()
            } else if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else {
                self.requestLocationPermissionFromSettings()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func requestLocationPermissionFromSettings() {
        let alert = UIAlertController(title: "", message: LanguageManager.shared.localizedString(forKey: "Please allow location access to fetch your current location."), preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Open Settings"), style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        let declineAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Not Now"), style: .cancel) { (_) in
        }
        alert.addAction(declineAction)
        present(alert, animated: true, completion: nil)
    }

    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }

    func updateLocationOnMap(to location: CLLocation, with title: String?) {
        let point = MKPointAnnotation()
        point.title = title
        point.coordinate = location.coordinate
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(point)

        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
        self.mapView.setRegion(viewRegion, animated: true)
        self.sendLocationButtonContainer.backgroundColor = isNewGenAITheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor
    }

    func addLocationView() {
        self.sendLocationButtonContainer.backgroundColor = isNewGenAITheme ? VAColorUtility.borderColor_NT : VAColorUtility.lightGray
        self.sendLocationButton.isUserInteractionEnabled = true
        self.locationContainerView.frame = self.view.bounds
        self.view.addSubview(self.locationContainerView)
        self.mapViewContainer.layoutIfNeeded()
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.view.bringSubviewToFront(self.locationContainerView)
        })
    }

    func removeLocationView() {
        self.userLocation = nil
        self.mapView.removeAnnotations(self.mapView.annotations)
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.locationContainerView.removeFromSuperview()
        })
    }
    // MARK: Button Actions
    @IBAction func closeLocationViewTapped(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.removeLocationView()
        }
    }
    @IBAction func sendSelectedUserLocationTapped(_ sender: UIButton) {
        if self.userLocation == nil {
            let alertController = UIAlertController(title: "", message: LanguageManager.shared.localizedString(forKey: "Please select location on the map"), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default, handler: { (_) in
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        self.sendLocationButton.isUserInteractionEnabled = false
        let mapImage = UIImage(named: "locationIcon", in: Bundle.module, compatibleWith: nil)
        let location = "\(self.userLocation!.coordinate.latitude),\(self.userLocation!.coordinate.longitude)"
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.sendImageMessageToBot(image: mapImage!, messageStr: location, messageType: SenderMessageType.location)
            self.removeLocationView()
        }
    }
}

// MARK: CLLocationManagerDelegate
extension VAChatViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locationManager.location
        else { return }
        self.userLocation = currentLocation
        currentLocation.lookUpLocationName { (name) in
            self.updateLocationOnMap(to: currentLocation, with: name)
        }
        self.locationManager.stopUpdatingLocation()
    }
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            self.addLocationView()
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            self.requestLocationPermissionFromSettings()
        default:
            break
        }
    }
}

/// Get location name
extension CLLocation {
    func lookUpPlaceMark(_ handler: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                handler(firstLocation)
            } else {
                // An error occurred during geocoding.
                handler(nil)
            }
        }
    }

    func lookUpLocationName(_ handler: @escaping (String?) -> Void) {
        lookUpPlaceMark { (placemark) in
            let placeName = "\(placemark?.name ?? ""),\(placemark?.subAdministrativeArea ?? "")"
            handler(placeName)
        }
    }
}
