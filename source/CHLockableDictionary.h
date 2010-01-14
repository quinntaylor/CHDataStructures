/*
 CHDataStructures.framework -- CHLockableDictionary.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHLockableDictionary.h
 
 A mutable dictionary class with simple built-in locking capabilities.
 */

/**
 A mutable dictionary class with simple built-in locking capabilities.
 
 Since this class extends NSMutableDictionary, it or any of its children may be used anywhere an NSDictionary or NSMutableDictionary is required. It is designed to behave virtually identically to a standard NSMutableDictionary, but with the addition of built-in locking.
 
 An NSLock is used internally to coordinate the operation of multiple threads of execution within the same application, and methods are exposed to allow clients to manipulate the lock in simple ways. Since not all clients will use the lock, it is created lazily the first time a client attempts to acquire the lock.
 
 A CFMutableDictionaryRef is used internally to store the key-value pairs. Subclasses may choose to add other instance variables to enable a specific ordering of keys, override methods to modify behavior, and add methods to extend existing behaviors. However, all subclasses should behave like a standard Cocoa dictionary as much as possible, and document clearly when they do not.
 
 @note Any method inherited from NSDictionary or NSMutableDictionary is supported, but only overridden methods are listed here.
 
 @todo Implement @c -copy and @c -mutableCopy differently (so users can actually obtain an immutable copy) and make mutation methods aware of immutability?
 */
@interface CHLockableDictionary : NSMutableDictionary <CHLockable> {
	NSLock* lock; /**< A lock for synchronizing interaction between threads. */
	__strong CFMutableDictionaryRef dictionary; /**< A Core Foundation dictionary. */
}

/**
 Initializes the receiver, allocating enough memory to hold @a numItems entries.
 
 @param numItems The initial capacity of the initialized dictionary. This parameter is provided as a hint to the underlying implementation, but is not necessarily binding.
 
 Mutable dictionaries allocate additional memory as needed, so @a numItems simply establishes the object's initial capacity.
 
 @attention This is the designated initializer for NSMutableDictionary, and also for CHLockableDictionary and its subclasses.
 
 @see \link NSMutableDictionary#initWithCapacity: -[NSMutableDictionary initWithCapacity:]\endlink
 */
- (id) initWithCapacity:(NSUInteger)numItems;

#pragma mark <NSCoding>
/** @name <NSCoding> */
// @{

/**
 Initialize the receiver using data from a given keyed unarchiver.
 
 @param decoder A keyed unarchiver object.
 
 @see NSCoding protocol
 */
- (id) initWithCoder:(NSCoder*)decoder;

/**
 Encodes data from the receiver using a given keyed archiver.
 
 @param encoder A keyed archiver object.
 
 @see NSCoding protocol
 */
- (void) encodeWithCoder:(NSCoder*)encoder;

// @}
#pragma mark <NSCopying>
/** @name <NSCopying> */
// @{

/**
 Returns a new instance that is a mutable copy of the receiver. If garbage collection is @b not enabled, the copy is retained before being returned, but the sender is responsible for releasing it.
 
 @param zone An area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. 
 
 @note The default \link NSObject#copy -copy\endlink method invokes this method with a @c nil argument.
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone*)zone;

// @}
#pragma mark <NSFastEnumeration>
#if OBJC_API_2
/** @name <NSFastEnumeration> */
// @{

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 For this class, as is the case with NSDictionary, this method enumerates only the keys. The value(s) for each key may be found using the \link #objectForKey: -objectForKey:\endlink method.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @since Mac OS X v10.5 and later.
 
 @see NSFastEnumeration protocol
 @see NSDictionary#allKeys
 @see keyEnumerator
 @see NSDictionary#objectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @}
#endif
#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Adds a given key-value pair to the receiver.
 
 @param anObject The value for @a aKey. The object receives a @c -retain message before being added to the receiver. Must not be @c nil.
 @param aKey The key for @a anObject. The key is copied using @c -copyWithZone: so keys must conform to the NSCopying protocol. Must not be @c nil.
 @throw NSInvalidArgumentException If @a aKey or @a anObject is @c nil. If you need to represent a @c nil value in the dictionary, use NSNull.
 
 @see objectForKey:
 @see removeObjectForKey:
 */
- (void) setObject:(id)anObject forKey:(id)aKey;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns the number of keys in the receiver.
 
 @return The number of keys in the receiver, regardless of how many objects are associated with any given key in the dictionary.
 
 @see NSDictionary#allKeys
 */
- (NSUInteger) count;

/**
 Returns an enumerator that lets you access each key in the receiver.
 
 @return An enumerator that lets you access each key in the receiver. The enumerator returned is never @c nil; if the dictionary is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @note If you need to modify the entries concurrently, use \link NSDictionary#allKeys -allKeys\endlink to create a "snapshot" of the dictionary's keys and work from this snapshot to modify the entries.
 
 @see \link NSDictionary#allKeys - allKeys\endlink
 @see \link NSDictionary#allKeysForObject: - allKeysForObject:\endlink
 @see NSFastEnumeration protocol
 */
- (NSEnumerator*) keyEnumerator;

/**
 Returns the value associated with a given key.
 
 @param aKey The key for which to return the corresponding value.
 @return The value associated with @a aKey, or @c nil if no value is associated with @a aKey.
 
 @see \link NSDictionary#containsKey: - containsKey:\endlink
 @see removeObjectForKey:
 @see setObject:forKey:
 */
- (id) objectForKey:(id)aKey;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove all objects from the receiver; if the receiver is already empty, there is no effect.
 
 @see removeObjectForKey:
 */
- (void) removeAllObjects;

/**
 Remove a given key and its associated value from the receiver.
 
 @param aKey The key to remove.
 
 @see \link NSDictionary#containsKey: - containsKey:\endlink
 @see objectForKey:
 */
- (void) removeObjectForKey:(id)aKey;

// @}
@end
