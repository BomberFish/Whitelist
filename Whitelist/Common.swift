//
//  Common.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import Foundation

let blankplist = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdC8+CjwvcGxpc3Q+Cg=="

func overwriteFileWithDataImpl(originPath: String, replacementData: Data) -> Bool {
#if false
    let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].path
    
    let pathToRealTarget = originPath
    let originPath = documentDirectory + originPath
    let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
    try! origData.write(to: URL(fileURLWithPath: originPath))
#endif
    
    // open and map original font
    let fd = open(originPath, O_RDONLY | O_CLOEXEC)
    if fd == -1 {
        print("Could not open target file")
        return false
    }
    defer { close(fd) }
    // check size of font
    let originalFileSize = lseek(fd, 0, SEEK_END)
    guard originalFileSize >= replacementData.count else {
        print("Original file: \(originalFileSize)")
        print("Replacement file: \(replacementData.count)")
        print("File too big!")
        return false
    }
    lseek(fd, 0, SEEK_SET)
    
    // Map the font we want to overwrite so we can mlock it
    let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
    if fileMap == MAP_FAILED {
        print("Failed to map")
        return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, replacementData.count) == 0 else {
        print("Failed to mlock")
        return true
    }
    
    // for every 16k chunk, rewrite
    print(Date())
    for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
        print(String(format: "%lx", chunkOff))
        let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
        var overwroteOne = false
        for _ in 0..<2 {
            let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                return unaligned_copy_switch_race(
                    fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
            }
            if overwriteSucceeded {
                overwroteOne = true
                print("Successfully overwrote!")
                break
            }
            print("try again?!")
        }
        guard overwroteOne else {
            print("Failed to overwrite")
            return false
        }
    }
    print(Date())
    print("Successfully overwrote!")
    return true
}

func overwriteBlacklist() -> Bool {
    return overwriteFileWithDataImpl(originPath: "/private/var/db/MobileIdentityData/Rejections.plist", replacementData: try! Data(base64Encoded: blankplist)!)
}

func overwriteBannedApps() -> Bool {
    return overwriteFileWithDataImpl(originPath: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist", replacementData: try! Data(base64Encoded: blankplist)!)
}

func overwriteCdHashes() -> Bool {
    return overwriteFileWithDataImpl(originPath: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist", replacementData: try! Data(base64Encoded: blankplist)!)
}

func readFile(path: String) -> String? {
    return (try? String?(String(contentsOfFile: path)) ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?")
}

