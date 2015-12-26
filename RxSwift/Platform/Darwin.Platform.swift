#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)

    import Darwin
    import Foundation

    typealias AtomicInt = Int32

    let AtomicCompareAndSwap = OSAtomicCompareAndSwap32
    let AtomicIncrement = OSAtomicIncrement32
    let AtomicDecrement = OSAtomicDecrement32

    extension NSThread {
        static func setThreadLocalStorageValue<T: AnyObject>(value: T?, forKey key: protocol<AnyObject, NSCopying>) {
            let currentThread = NSThread.currentThread()
            let threadDictionary = currentThread.threadDictionary

            if let newValue = value {
                threadDictionary.setObject(newValue, forKey: key)
            }
            else {
                threadDictionary.removeObjectForKey(key)
            }

        }
        static func getThreadLocalStorageValueForKey<T>(key: protocol<AnyObject, NSCopying>) -> T? {
            let currentThread = NSThread.currentThread()
            let threadDictionary = currentThread.threadDictionary
            
            return threadDictionary[key] as? T
        }
    }
    
#endif
