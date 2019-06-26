//
//  PhotoViewController.swift
//  VirtualTouristNew
//
//  Created by bdoor on 1/25/19.
//  Copyright © 2019 UdacityHS. All rights reserved.
//


import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    var pin: Pin?
    var managedContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var focusedRegion: MKCoordinateRegion?
    
    var insertedImages: [IndexPath]!
    var updatedImages: [IndexPath]!
    var selectedImages = [IndexPath]()
    var deletedImages: [IndexPath]!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var getImagesLabel: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImageLabel: UILabel!
    
    @IBAction func getImagesButton(_ sender: Any) {
        
        if selectedImages.isEmpty {
            deleteAllPhotos()
        } else {
            deleteSelectedPhotos()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.setRegion(focusedRegion!, animated: true)
        
        let latitude = focusedRegion!.center.latitude
        let longitude = focusedRegion!.center.longitude
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        mapView.addAnnotation(annotation)
        
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let width = floor(view.frame.width/4)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
        
        collectionView.prefetchDataSource = self
        collectionView.isPrefetchingEnabled = true
        
        tabBarController?.tabBar.isHidden = true
        getImagesLabel.isEnabled = false
        if selectedImages.isEmpty {
            getImagesLabel.title = "New Collection Of photos"
        } else {
            getImagesLabel.title = "Remove selected photos"
        }
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.fetchBatchSize = 15
        
        
        let sortById = NSSortDescriptor(key: #keyPath(Photo.photoID), ascending: true)
        fetchRequest.sortDescriptors = [sortById]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin!)
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("error \(error)")
        }
        
        
        if let photos = fetchedResultsController.fetchedObjects {
            if photos.count == 0 {
                getPhotos(pin: pin!)
            } else {
                tabBarController?.tabBar.isHidden = false
                getImagesLabel.isEnabled = true
            }
        } else {
            
            getPhotos(pin: pin!)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func getPhotos(pin: Pin) {
        
        Client.sendRequest(pin) { (photosDictionary, error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(viewController: self, title: "ERROR", message: error!, actionTitle: "ERROR")
                    return
                }
                self.managedContext.performAndWait() {
                    if let photosDictionary = photosDictionary {
                        if photosDictionary.count == 0 {
                            
                            self.noImageLabel.isHidden = false
                            self.getImagesLabel.isEnabled = false
                            self.tabBarController?.tabBar.isHidden = true
                        } else {
                            
                            self.noImageLabel.isHidden = true
                        }
                        
                        for photoP in photosDictionary {
                            let photo = Photo(context: self.managedContext)
                            photo.photoTitle = photoP[APIConstants.Title] as? String
                            photo.imageURL = photoP[APIConstants.ImagePath] as? String
                            photo.pin = pin
                        }
                    }
                    
                    do {
                        try self.managedContext.save()
                    } catch let error as NSError {
                        print("error")
                    }
                    
                }
                
                if (self.fetchedResultsController.fetchedObjects?.count)! > 0 {
                    self.tabBarController?.tabBar.isHidden = false
                    self.getImagesLabel.isEnabled = true
                    
                }
                
            }
            
        }
    }
    
    func deleteSelectedPhotos() {
        
        var allSelectedPhotos = [Photo]()
        
        for indexPath in selectedImages {
            allSelectedPhotos.append(fetchedResultsController.object(at: indexPath))
        }
        
        for photo in allSelectedPhotos {
            managedContext.delete(photo)
        }
        
        
        selectedImages.removeAll()
        getImagesLabel.title = "New Collection Of photos"
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("error")
        }
        
    }
    
    func deleteAllPhotos() {
        
        getImagesLabel.isEnabled = false
        tabBarController?.tabBar.isHidden = true
        
        for photo in fetchedResultsController.fetchedObjects! {
            managedContext.delete(photo)
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("error \(error)")
        }
        
        getPhotos(pin: pin!)
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard let results = fetchedResultsController.sections else { return 1 }
        
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        prepareCell(cell, for: indexPath)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let itemsInSection = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return itemsInSection.numberOfObjects
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        if let index = selectedImages.index(of: indexPath) {
            selectedImages.remove(at: index)
        } else {
            selectedImages.append(indexPath)
        }
        
        
        prepareCell(cell, for: indexPath)
        
        if selectedImages.isEmpty {
            getImagesLabel.title = "New Collection Of photos"
        } else {
            getImagesLabel.title = "Remove selected photos"
        }
    }
    func prepareCell(_ cell: UICollectionViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? PhotoCollectionViewCell else {
            return
            
        }
        
        var image: UIImage
        
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        image = UIImage(named: "emptyImage")!
        
        if photo.image != nil {
            
            cell.activityIndicator.stopAnimating()
            image = UIImage(data: photo.image!)!
        } else {
            
            if let imagePath = photo.imageURL {
                Client.requestPhotoData(photoURL: imagePath) { (result, error) in
                    guard error == nil else {
                        print("error \(error)")
                        return
                    }
                    guard let result = result else {
                        print("error")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                        photo.image = result as Data
                        cell.imageView.image = UIImage(data: result as Data)
                    }
                }
            }
        }
        cell.imageView.image = image
    }
    func showAlert(viewController: UIViewController, title: String, message: String?, actionTitle: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedImages = [IndexPath]()
        deletedImages = [IndexPath]()
        updatedImages = [IndexPath]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({
            for indexPath in self.insertedImages {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedImages {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedImages {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        if type == .insert{
            insertedImages.append(newIndexPath!)
        }
        if type == .delete{
            deletedImages.append(indexPath!)
        }
        if type == .move{
            deletedImages.append(indexPath!)
            insertedImages.append(newIndexPath!)
        }
        if type == .update{
            updatedImages.append(indexPath!)
        }
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
            
            prepareCell(cell, for: indexPath)
        }
    }
}
