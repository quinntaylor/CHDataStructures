/*
 CHDataStructures.framework -- CHLockableDictionary.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHLockableDictionary.h
 
 An abstract mutable dictionary class with simple built-in locking capabilities.
 */

/**
 An abstract mutable dictionary class with simple built-in locking capabilities. An NSLock is used internally to coordinate the operation of multiple threads of execution within the same application, and methods are exposed to allow clients to manipulate the lock in simple ways. Since not all clients will use the lock, it is created lazily the first time a client attempts to acquire the lock.
 */
@interface CHLockableDictionary : NSMutableDictionary <CHLockable>
{
	NSLock* lock; /**< A lock for synchronizing interaction between threads. */
	CFMutableDictionaryRef dictionary;
}

/**
 Initialize the receiver with no key-value entries.
 
 @see initWithObjectsAndKeys:
 @see initWithObjects:forKeys:
 */
- (id) init;

/**
 Initialize the receiver with entries constructed from pairs of objects and keys.
 
 @param firstObject The first object or set of objects to add to the receiver.
 @param ... First the key for @a firstObject, then a null-terminated list of alternating values and keys.
 @throw NSInvalidArgumentException If any non-terminating parameter is @c nil.
 
 @see init
 @see initWithObjects:forKeys:
 */
- (id) initWithObjectsAndKeys:(id)firstObject, ...;

/**
 Initialize the receiver with entries constructed from arrays of objects and keys.
 
 @param keyArray An array containing the keys to add to the receiver. 
 @param objectsArray An array containing the values to add to the receiver.
 @throw NSInvalidArgumentException If the array counts are not equal.
 
 @see init
 @see initWithObjectsAndKeys:
 */
- (id) initWithObjects:(NSArray*)objectsArray forKeys:(NSArray*)keyArray;

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
#if MAC_OS_X_VERSION_10_5_AND_LATER
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
 @see allKeys
 @see objectEnumerator
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
 Add entried from another dictionary to the receiver. If both dictionaries contain the same key, the receiver's previous value object for that key is sent a release message, and the new value object takes its place.
 
 @param otherDictionary The dictionary from which to add entries.
 
 Each value object from @a otherDictionary is sent a @c -retain message before being added to the receiver. In contrast, each key object is copied (using @c -copyWithZone: — keys must conform to the NSCopying protocol), and the copy is added to the receiver.
 
 @see setObject:forKey:
 */
- (void) addEntriesFromDictionary:(NSDictionary*)otherDictionary;

/**
 Adds a given key-value pair to the receiver.
 
 @param anObject The value for @a key. The object receives a @c -retain message before being added to the receiver. This value must not be @c nil.
 @param aKey The key for @a value. The key is copied (using @c -copyWithZone: — keys must conform to the NSCopying protocol). The key must not be @c nil.
 @throws NSInvalidArgumentException If @a aKey or @a anObject is @c nil. If you need to represent a @c nil value in the dictionary, use NSNull.
 
 @see objectForKey:
 @see removeObjectForKey:
 */
- (void) setObject:(id)anObject forKey:(id)aKey;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array containing the receiver's keys in sorted order.
 
 @return An array containing the receiver's keys in sorted order. The array is empty if the receiver has no entries..
 
 @see allValues
 @see count
 @see keyEnumerator
 @see countByEnumeratingWithState:objects:count:
 */
- (NSArray*) allKeys;

/**
 Returns an NSArray containing the values in the receiver in ascending order by key.
 
 @return An array containing the values in the receiver. If the receiver is empty, the array is also empty.
 
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see removeAllObjects
 */
- (NSArray*) allValues;

/**
 Returns the number of keys in the receiver.
 
 @return The number of keys in the receiver, regardless of how many objects are associated with any given key in the dictionary.
 
 @see allKeys
 */
- (NSUInteger) count;

/**
 Determine whether a given key is present in the receiver.
 
 @param aKey The key to check for membership in the receiver.
 @return @c YES if an entry for @a aKey exists in the receiver.
 
 @see objectForKey:
 @see removeObjectForKey:
 */
- (BOOL) containsKey:(id)aKey;

/**
 Returns an enumerator that lets you access each key in the receiver.
 
 @return An enumerator that lets you access each key in the receiver. The enumerator returned is never @c nil; if the map is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @note If you need to modify the entries concurrently, use #allKeys to create a "snapshot" of the dictionary's keys and work from this snapshot to modify the entries.
 
 @see allKeys
 @see countByEnumeratingWithState:objects:count:
 */
- (NSEnumerator*) keyEnumerator;

/**
 Returns an enumerator that accesses each object in the receiver in ascending order.
 
 @return An enumerator that accesses each object in the receiver in ascending order. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns the value associated with a given key.
 
 @param aKey The key for which to return the corresponding value.
 @return The value associated with @a aKey, or @c nil if no value is associated with @a aKey.
 
 @see removeObjectForKey:
 @see setObject:forKey:
 */
- (id) objectForKey:(id)aKey;

/**
 Returns a new dictionary containing the entries for keys delineated by two given objects. The subset is a shallow copy (new memory is allocated for the structure, but the copy points to the same objects) so any changes to the objects in the subset affect the receiver as well. The subset is an instance of the same class as the receiver.
 
 @param start Low endpoint of the subset to be returned; need not be a key in receiver.
 @param end High endpoint of the subset to be returned; need not be a key in receiver.
 @return A new sorted map containing the key-value entries delineated by @a start and @a end. The contents of the returned subset depend on the input parameters as follows:
 - If both @a start and @a end are @c nil, all keys in the receiver are included. (Equivalent to calling @c -copy.)
 - If only @a start is @c nil, keys that match or follow @a start are included.
 - If only @a end is @c nil, keys that match or preceed @a start are included.
 - If @a start comes before @a end in an ordered set, keys between @a start and @a end (or which match either object) are included.
 - Otherwise, all keys @b except those that fall between @a start and @a end are included.
 */
- (NSMutableDictionary*) subsetFromObject:(id)start toObject:(id)end;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove all objects from the receiver; if the receiver is already empty, there is no effect.
 
 @see removeObjectForKey:
 @see removeObjectForFirstKey
 @see removeObjectForLastKey
 */
- (void) removeAllObjects;

/**
 Removes a given key and its associated value from the receiver.
 
 @param aKey The key to remove.
 
 @see objectForKey:
 @see removeObjectForFirstKey
 @see removeObjectForLastKey
 */
- (void) removeObjectForKey:(id)aKey;

// @}
@end
