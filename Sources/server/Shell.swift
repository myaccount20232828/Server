import Foundation
import Darwin

func runCommand(_ command: String, _ args: [String], _ uid: uid_t, _ rootPath: String = "") -> Int {
    let task = Process()
    let pipe = Pipe()    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = args
    task.launchPath = command
    task.standardInput = nil
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!    
    return task.terminationStatus
}


/*// Define C functions
@_silgen_name("posix_spawnattr_set_persona_np")
@discardableResult func posix_spawnattr_set_persona_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t, _ flags: UInt32) -> Int32
@_silgen_name("posix_spawnattr_set_persona_uid_np")
@discardableResult func posix_spawnattr_set_persona_uid_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t) -> Int32
@_silgen_name("posix_spawnattr_set_persona_gid_np")
@discardableResult func posix_spawnattr_set_persona_gid_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t) -> Int32

func runCommand(_ command: String, _ args: [String], _ uid: uid_t, _ rootPath: String = "") -> Int {
    var pid: pid_t = 0
    let args: [String] = [String(command.split(separator: "/").last!)] + args
    let argv: [UnsafeMutablePointer<CChar>?] = args.map { $0.withCString(strdup) }
    let env = ["PATH=/usr/local/sbin:\(rootPath)/usr/local/sbin:/usr/local/bin:\(rootPath)/usr/local/bin:/usr/sbin:\(rootPath)/usr/sbin:/usr/bin:\(rootPath)/usr/bin:/sbin:\(rootPath)/sbin:/bin:\(rootPath)/bin:/usr/bin/X11:\(rootPath)/usr/bin/X11:/usr/games:\(rootPath)/usr/games"]
    let proenv: [UnsafeMutablePointer<CChar>?] = env.map { $0.withCString(strdup) }
    defer { for case let pro? in proenv { free(pro) } }
    var attr: posix_spawnattr_t?
    posix_spawnattr_init(&attr)
    posix_spawnattr_set_persona_np(&attr, 99, 1)
    posix_spawnattr_set_persona_uid_np(&attr, uid)
    posix_spawnattr_set_persona_gid_np(&attr, uid)
    guard posix_spawn(&pid, rootPath + command, nil, nil, argv + [nil], proenv + [nil]) == 0 else {
        print("Failed to spawn process \(rootPath + command)")
        return -1
    }
    var status: Int32 = 0
    waitpid(pid, &status, 0)
    return Int(status)
}*/
