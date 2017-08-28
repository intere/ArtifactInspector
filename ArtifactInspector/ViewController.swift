//
//  ViewController.swift
//  ArtifactInspector
//
//  Created by Eric Internicola on 8/25/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction
    func dumpDefaultKeys(_ sender: Any) {
        dumpDefaults()
    }

    @IBAction
    func dumpKeychainKeys(_ sender: Any) {
        listKeychainKeys()
    }

    @IBAction
    func listFileSystem(_ sender: Any) {
        listFiles(urls: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        listFiles(urls: FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask))
    }

}

// MARK: - Dump Defaults Implementation

extension ViewController {

    func dumpDefaults() {
        let defaults = UserDefaults.standard

        for (key, _) in defaults.dictionaryRepresentation() {
            print("Default Key: \(key)")
        }
    }
}

// MARK: - Dump Keychain Implementation

extension ViewController {

    func listKeychainKeys() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecReturnData as String: kCFBooleanTrue,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnRef as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        var result: AnyObject?

        let lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        guard lastResultCode == noErr else {
            return
        }
        guard let array = result as? Array<Dictionary<String, Any>> else {
            print("No results")
            return
        }

        for i in 0..<array.count {
            let item = array[i]
            for (key, _) in item {
                print("Keychain Index \(i): Keychain Key: \(key)")
            }
        }
    }

}

// MARK: - File List Implementation

extension ViewController {

    typealias FileList = (folders: [URL], files: [URL])

    /// Iterates through all of the provided URLs (which should be `file` URLs) and lists the files within each path.
    ///
    /// - Parameter urls: The URLs to list files within
    func listFiles(urls: [URL]) {
        for url in urls {
            guard let path = url.pathStringDecoded else {
                continue
            }
            listFiles(path: path)
        }
    }

    /// Lists out the files (recursively) under the provided path
    ///
    /// - Parameters:
    ///   - path: The path to list all files within
    func listFiles(path: String) {
        let filemgr = FileManager.default
        let fileURL = URL(fileURLWithPath: path)

        guard let contents = try? filemgr.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: nil, options: []) else {
            return
        }

        // break the contents into folders and files
        let split = splitDirectory(contents)

        // list out all of the files (not folders)
        for file in split.files {
            guard let path = file.pathStringDecoded else {
                continue
            }
            print("File: \(path)")
        }

        // traverse into each subfolder:
        for file in split.folders {
            guard let path = file.pathStringDecoded else {
                continue
            }
            listFiles(path: path)
        }
    }

    /// Takes the provided array of (file) URLs and splits them into a tuple of folders and files to give you back.
    ///
    /// - Parameter contents: The array of file URL objects to be converted into a tuple
    /// - Returns: A tuple of folders and files
    func splitDirectory(_ contents: [URL]) -> FileList {

        var folders = [URL]()
        var files = [URL]()

        contents.forEach { (fileURL) in
            var isDir: ObjCBool = false

            guard let path = fileURL.pathStringDecoded else {
                print("Couldn't decode URL: \(fileURL.absoluteString)")
                return
            }

            guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir) else {
                print("File doesn't exist: \(path)")
                return
            }
            if isDir.boolValue {
                folders.append(fileURL)
            } else {
                files.append(fileURL)
            }
        }


        return (folders: folders, files: files)
    }
}

// MARK: - URL Helpers

extension URL {

    /// Constants for URL helpers
    struct Constants {
        static let filePrefix = "file://"
    }

    /// Takes the absolute string, rips out the file prefix, then decodes the URL (e.g. replace '%20' with a space ' ').
    var pathStringDecoded: String? {
        return absoluteString.remove(prefix: Constants.filePrefix).removingPercentEncoding
    }
}

// MARK: - String Helpers

extension String {

    /// Removes the profided prefix string from this string (if it is the prefix of this string)
    ///
    /// - Parameter prefix: The prefix to be removed
    /// - Returns: This string without the provided prefix, or this string (if it doesn't have the provided prefix)
    func remove(prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }

        let startIndex = prefix.endIndex

        return substring(from: startIndex)
    }

}
