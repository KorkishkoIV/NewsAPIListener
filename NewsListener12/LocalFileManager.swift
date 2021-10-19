import Foundation
import UIKit.UIImage

class LocalFileManager {
    
    static let instance = LocalFileManager()
    private let folderName = "NewAPIListener"
    private let queue = DispatchQueue(label: "fileManagerQueue")
    
    init(){
        createFolderIfNeeded()
    }
    
    private func createFolderIfNeeded(){
        guard let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .path
        else {
            return
        }
        if !FileManager.default.fileExists(atPath: path){
            do {
                try  FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error  {
                NSLog("[LocalFileManager] Error creating files storage path: \(error)")
            }
        }
    }

/// Return full path for file at local directory
    func getPathFor(name: String) -> URL? {
        guard let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent(name) else {
            NSLog("[LocalFileManager] Can't get path for: \(name)")
            return nil
        }
        return path
    }
    
/// Save data in local directory with indicated name
    func saveToFile(data: Data?, name: String){
        guard let path = getPathFor(name: name),
            let data = data else {
            return
        }
        DispatchQueue.global(qos: .background).async {
            do{
                try data.write(to: path)
            }catch let error {
                NSLog("[LocalFileManager] Error writing data to path: \(path) (Error: \(error))")
            }
        }
    }
    
/// Async lodaing data from file
    func asyncGetDataFromFile(name: String, completion: @escaping (Data?)->Swift.Void){
        guard let path = getPathFor(name: name),
              FileManager.default.fileExists(atPath: path.path)
              else {
            NSLog("[LocalFileManager] Error opening file named: \(name)")
            completion(nil)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do{
                let data = try Data(contentsOf: path)
                completion (data)
            } catch let error {
               NSLog("[LocalFileManager] Error reading data from path: \(path) (Error: \(error))")
               completion(nil)
            }
        }        
    }
    
/// Sync loading data from file
    func getDataFromFile(name:String) -> Data? {
        guard let path = getPathFor(name: name),
              FileManager.default.fileExists(atPath: path.path)
              else {
            NSLog("[LocalFileManager] Error opening file named: \(name)")
            return nil
        }
        do{
            let data = try Data(contentsOf: path)
            return data
        } catch let error {
            NSLog("[LocalFileManager] Error reading data from path: \(path) (Error: \(error))")
            return nil
        }
    }
/// Delete file from local directory
    func deleteFile(name: String) {
        guard let path = getPathFor(name: name),
              FileManager.default.fileExists(atPath: path.path)
              else {
            NSLog("[LocalFileManager] Error deleting file named: \(name)")
            return
        }
        DispatchQueue.global(qos: .background).async {
            do {
                try FileManager.default.removeItem(at: path)
            } catch let error {
                NSLog ("[LocalFileManager] Error deleting file with path: \(path) (Error: \(error))")
            }
        }
    }
    
/// Returns true if file exist in local directory, false otherwise
    func fileExist(name: String) -> Bool {
        guard let path = getPathFor(name: name) else {
            return false
        }
        return FileManager.default.fileExists(atPath: path.path)
    }
}

extension LocalFileManager: ImageProvider {
    func asyncGetImage(id: String, completion: @escaping (UIImage?) -> Void) {
        self.asyncGetDataFromFile(name: "\(id).png") { data in
            guard let unwrapedData = data else{
                completion (nil)
                return
            }
            completion(UIImage(data: unwrapedData))
        }
    }
    
    func setImage(id: String, image: UIImage) {
        self.saveToFile(data: image.pngData(), name: "\(id).png")
    }
    
    func containsImage(forId id: String) -> Bool {
        return self.fileExist(name: "\(id).png")
    }
}


