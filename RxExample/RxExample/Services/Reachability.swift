/*
Copyright © 2014, Ashley Mills
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*/

import SystemConfiguration
import Foundation

enum ReachabilityError: Swift.Error {
    case failedToCreateWithAddress(sockaddr_in)
    case failedToCreateWithHostname(String)
    case unableToSetCallback
    case unableToSetDispatchQueue
}

public let ReachabilityChangedNotification = "ReachabilityChangedNotification"

func callback(_ reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard  let info = info else { return }
    let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()

    DispatchQueue.main.async {
        reachability.reachabilityChanged(flags)
    }
}


public class Reachability: NSObject {

    public typealias NetworkReachable = (Reachability) -> ()
    public typealias NetworkUnreachable = (Reachability) -> ()

    public enum NetworkStatus: CustomStringConvertible {

        case notReachable, reachableViaWiFi, reachableViaWWAN

        public var description: String {
            switch self {
            case .reachableViaWWAN:
                return "Cellular"
            case .reachableViaWiFi:
                return "WiFi"
            case .notReachable:
                return "No Connection"
            }
        }
    }

    // MARK: - *** Public properties ***

    public var whenReachable: NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?
    public var reachableOnWWAN: Bool
    public var notificationCenter = NotificationCenter.default

    public var currentReachabilityStatus: NetworkStatus {
        if isReachable() {
            if isReachableViaWiFi() {
                return .reachableViaWiFi
            }
            if isRunningOnDevice {
                return .reachableViaWWAN
            }
        }

        return .notReachable
    }

    public var currentReachabilityString: String {
        return "\(currentReachabilityStatus)"
    }

    // MARK: - *** Initialisation methods ***
    
    required public init(reachabilityRef: SCNetworkReachability) {
        reachableOnWWAN = true
        self.reachabilityRef = reachabilityRef
    }
    
    public convenience init(hostname: String) throws {
        
        let nodename = (hostname as NSString).utf8String
        guard let ref = SCNetworkReachabilityCreateWithName(nil, nodename!) else { throw ReachabilityError.failedToCreateWithHostname(hostname) }

        self.init(reachabilityRef: ref)
    }

    public class func reachabilityForInternetConnection() throws -> Reachability {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let ref = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { throw ReachabilityError.failedToCreateWithAddress(zeroAddress) }
        
        return Reachability(reachabilityRef: ref)
    }

    public class func reachabilityForLocalWiFi() throws -> Reachability {

        var localWifiAddress: sockaddr_in = sockaddr_in(sin_len: __uint8_t(0), sin_family: sa_family_t(0), sin_port: in_port_t(0), sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        localWifiAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        localWifiAddress.sin_family = sa_family_t(AF_INET)

        // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
        let address: UInt32 = 0xA9FE0000
        localWifiAddress.sin_addr.s_addr = in_addr_t(address.bigEndian)

        guard let ref = withUnsafePointer(to: &localWifiAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { throw ReachabilityError.failedToCreateWithAddress(localWifiAddress) }
        
        return Reachability(reachabilityRef: ref)
    }

    // MARK: - *** Notifier methods ***
    public func startNotifier() throws {

        if notifierRunning { return }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        
        context.info = Unmanaged.passUnretained(self).toOpaque()
        
        if !SCNetworkReachabilitySetCallback(reachabilityRef!, callback, &context) {
            stopNotifier()
            throw ReachabilityError.unableToSetCallback
        }

        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef!, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.unableToSetDispatchQueue
        }

        notifierRunning = true
    }
    

    public func stopNotifier() {
        if let reachabilityRef = reachabilityRef {
            SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
            SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
        }
        notifierRunning = false
    }

    // MARK: - *** Connection test methods ***
    public func isReachable() -> Bool {
        return isReachableWithTest({ (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isReachableWithFlags(flags)
        })
    }

    public func isReachableViaWWAN() -> Bool {

        if isRunningOnDevice {
            return isReachableWithTest() { flags -> Bool in
                // Check we're REACHABLE
                if self.isReachable(flags) {

                    // Now, check we're on WWAN
                    if self.isOnWWAN(flags) {
                        return true
                    }
                }
                return false
            }
        }
        return false
    }

    public func isReachableViaWiFi() -> Bool {

        return isReachableWithTest() { flags -> Bool in

            // Check we're reachable
            if self.isReachable(flags) {

                if self.isRunningOnDevice {
                    // Check we're NOT on WWAN
                    if self.isOnWWAN(flags) {
                        return false
                    }
                }
                return true
            }

            return false
        }
    }

    // MARK: - *** Private methods ***
    private var isRunningOnDevice: Bool = {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
            #else
            return true
        #endif
        }()

    private var notifierRunning = false
    private var reachabilityRef: SCNetworkReachability?
    private let reachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.reachability")

    fileprivate func reachabilityChanged(_ flags: SCNetworkReachabilityFlags) {
        if isReachableWithFlags(flags) {
            if let block = whenReachable {
                block(self)
            }
        } else {
            if let block = whenUnreachable {
                block(self)
            }
        }

        notificationCenter.post(name: Notification.Name(rawValue: ReachabilityChangedNotification), object:self)
    }

    private func isReachableWithFlags(_ flags: SCNetworkReachabilityFlags) -> Bool {

        let reachable = isReachable(flags)

        if !reachable {
            return false
        }

        if isConnectionRequiredOrTransient(flags) {
            return false
        }

        if isRunningOnDevice {
            if isOnWWAN(flags) && !reachableOnWWAN {
                // We don't want to connect when on 3G.
                return false
            }
        }

        return true
    }

    private func isReachableWithTest(_ test: (SCNetworkReachabilityFlags) -> (Bool)) -> Bool {

        if let reachabilityRef = reachabilityRef {
            
            var flags = SCNetworkReachabilityFlags(rawValue: 0)
            let gotFlags = withUnsafeMutablePointer(to: &flags) {
                SCNetworkReachabilityGetFlags(reachabilityRef, $0)
            }
            
            if gotFlags {
                return test(flags)
            }
        }

        return false
    }

    // WWAN may be available, but not active until a connection has been established.
    // WiFi may require a connection for VPN on Demand.
    private func isConnectionRequired() -> Bool {
        return connectionRequired()
    }

    private func connectionRequired() -> Bool {
        return isReachableWithTest({ (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isConnectionRequired(flags)
        })
    }

    // Dynamic, on demand connection?
    private func isConnectionOnDemand() -> Bool {
        return isReachableWithTest({ (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isConnectionRequired(flags) && self.isConnectionOnTrafficOrDemand(flags)
        })
    }

    // Is user intervention required?
    private func isInterventionRequired() -> Bool {
        return isReachableWithTest({ (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isConnectionRequired(flags) && self.isInterventionRequired(flags)
        })
    }

    private func isOnWWAN(_ flags: SCNetworkReachabilityFlags) -> Bool {
        #if os(iOS)
            return flags.contains(.isWWAN)
        #else
            return false
        #endif
    }
    private func isReachable(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.reachable)
    }
    private func isConnectionRequired(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.connectionRequired)
    }
    private func isInterventionRequired(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.interventionRequired)
    }
    private func isConnectionOnTraffic(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.connectionOnTraffic)
    }
    private func isConnectionOnDemand(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.connectionOnDemand)
    }
    func isConnectionOnTrafficOrDemand(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return !flags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    private func isTransientConnection(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.transientConnection)
    }
    private func isLocalAddress(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.isLocalAddress)
    }
    private func isDirect(_ flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.isDirect)
    }
    private func isConnectionRequiredOrTransient(_ flags: SCNetworkReachabilityFlags) -> Bool {
        let testcase:SCNetworkReachabilityFlags = [.connectionRequired, .transientConnection]
        return flags.intersection(testcase) == testcase
    }

    private var reachabilityFlags: SCNetworkReachabilityFlags {
        if let reachabilityRef = reachabilityRef {
            
            var flags = SCNetworkReachabilityFlags(rawValue: 0)
            let gotFlags = withUnsafeMutablePointer(to: &flags) {
                SCNetworkReachabilityGetFlags(reachabilityRef, $0)
            }
            
            if gotFlags {
                return flags
            }
        }

        return []
    }

    override public var description: String {

        var W: String
        if isRunningOnDevice {
            W = isOnWWAN(reachabilityFlags) ? "W" : "-"
        } else {
            W = "X"
        }
        let R = isReachable(reachabilityFlags) ? "R" : "-"
        let c = isConnectionRequired(reachabilityFlags) ? "c" : "-"
        let t = isTransientConnection(reachabilityFlags) ? "t" : "-"
        let i = isInterventionRequired(reachabilityFlags) ? "i" : "-"
        let C = isConnectionOnTraffic(reachabilityFlags) ? "C" : "-"
        let D = isConnectionOnDemand(reachabilityFlags) ? "D" : "-"
        let l = isLocalAddress(reachabilityFlags) ? "l" : "-"
        let d = isDirect(reachabilityFlags) ? "d" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }

    deinit {
        stopNotifier()

        reachabilityRef = nil
        whenReachable = nil
        whenUnreachable = nil
    }
}
