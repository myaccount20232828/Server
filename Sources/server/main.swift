import Foundation
import GCDWebServer

setuid(0)
setgid(0)
print("UID: \(getuid())")

let WebServer = GCDWebServer()

func HandleRequest(_ Request: NSDictionary) -> NSDictionary {
    guard let Action = Request["action"] as? String else {
        return Error("No action")
    }
    switch Action {
        case "posix_spawn": return HandlePosixSpawn(Request)
        case "directory_list": return HandleDirectoryList(Request)
        case "file_exists": return HandleFileExists(Request)
        case "is_directory": return HandleIsDirectory(Request)
        default: return Error("Unknown action")
    }
}

func HandleIsDirectory(_ Request: NSDictionary) -> NSDictionary {
    guard let Path = Request["path"] as? String else {
        return Error("No path")
    }
    return ["isDirectory": IsDirectory(Path)]
}

func HandleFileExists(_ Request: NSDictionary) -> NSDictionary {
    guard let Path = Request["path"] as? String else {
        return Error("No path")
    }
    return ["exists": FileManager.default.fileExists(atPath: Path)]
}

func HandleDirectoryList(_ Request: NSDictionary) -> NSDictionary {
    do {
        guard let Directory = Request["directory"] as? String else {
            return Error("No directory")
        }
        var Contents: [NSDictionary] = []
        for Name in try FileManager.default.contentsOfDirectory(atPath: Directory) {
            Contents.append(["name": Name, "isDirectory": IsDirectory("\(Directory)/\(Name)")])
        }
        return ["contents": Contents]
    } catch {
        return Error(error.localizedDescription)
    }
}

func HandlePosixSpawn(_ Request: NSDictionary) -> NSDictionary {
    guard let Command = Request["command"] as? String else {
        return Error("No command")
    }
    let Arguments = Request["arguments"] as? [String] ?? []
    let UID = Request["uid"] as? Int ?? 501
    let (Status, Output) = runCommand(Command, Arguments, uid_t(UID))
    return ["status": Status, "output": Output]
}

func Error(_ ErrorString: String) -> NSDictionary {
    print("Error: \(ErrorString)")
    return ["error": ErrorString]
}

WebServer.addDefaultHandler(forMethod: "POST", request: GCDWebServerFileRequest.self, processBlock: { Request in
    if let FilePath = (Request as? GCDWebServerFileRequest)?.temporaryPath, let Request = NSDictionary(contentsOfFile: FilePath) {
        try? FileManager.default.removeItem(atPath: FilePath)
        return GCDWebServerDataResponse(data: (try? PropertyListSerialization.data(fromPropertyList: HandleRequest(Request), format: .xml, options: 0)) ?? Data(), contentType: "application/octet-stream")
    } else {
        return GCDWebServerDataResponse(data: Data(), contentType: "application/octet-stream")
    }
})

WebServer.start(withPort: 8080, bonjourName: "GCD Web Server")
RunLoop.main.run()

func IsDirectory(_ Path: String) -> Bool {
    var IsDirectory: ObjCBool = false
    FileManager.default.fileExists(atPath: Path, isDirectory: &IsDirectory)
    return IsDirectory.boolValue
}
