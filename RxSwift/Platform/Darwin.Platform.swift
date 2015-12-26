#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin

let AtomicInt = Int32

let AtomicCompareAndSwap = OSAtomicCompareAndSwap32
let AtomicIncrement = OSAtomicIncrement32
let AtomicDecrement = OSAtomicDecrement32

extension NSThread {
    static func setThreadLocalStorageValue<T: AnyObject>(value: T?, forKey key: AnyObject) {
        let currentThread = NSThread.currentThread()
        var threadDictionary = currentThread.threadDictionary

        if let newValue = value {
            threadDictionary[key] = newValue
        }
        else {
            threadDictionary.removeObjectForKey(key)
        }

    }
    static func getThreadLocalStorageValueForKey<T>(key: String) -> T? {
        let currentThread = NSThread.currentThread()
        let threadDictionary = currentThread.threadDictionary

        return threadDictionary[key] as? T
    }
}

#endif
