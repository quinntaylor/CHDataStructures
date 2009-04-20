/*
 CHDataStructures.framework -- CHMultiMap.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHMultiMap.h
 
 A <a href="http://en.wikipedia.org/wiki/Multimap_(data_structure)">multimap</a> in which multiple values may be associated with a given key.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Multimap_(data_structure)">multimap</a> implementation, in which multiple values may be associated with a given key.
 
 A map is the same as a "dictionary", "associative array", etc. and consists of a unique set of keys and a collection of values. In a standard map, each key is associated with one value; in a multimap, more than one value may be associated with a given key. A multimap is appropriate for any situation in which one item may correspond to (map to) multiple values, such as a term in an book index and occurrences of that term, courses for which a student is registered, etc.
 
 The values for a key may or may not be ordered. This implementation does not maintain an ordering for objects associated with a key, nor does it allow for multiple occurrences of an object associated with the same key. Internally, this class uses an NSMutableDictionary, and the associated values for each key are stored in distinct NSMutableSet instances. (Just as with NSDictionary, each key added to a CHMultiMap is copied using \link NSCopying#copyWithZone: -copyWithZone:\endlink and all keys must conform to the NSCopying protocol.) Objects are retained on insertion and released on removal or deallocation.
 
 Since NSDictionary and NSSet conform to the NSCoding protocol, any internal data can be serialized. However, NSSet cannot automatically be written to or read from a property list, since it has no specified order. Thus, instances of CHMultiMap must be encoded as an NSData object before saving to disk.
 
 Currently, this multimap implementation does not support key-value coding, observing, or binding like NSDictionary does. Consequently, the distinction between "object" and "value" is blurrier, although hopefully consistent with the Cocoa APIs in general....
 
 Unlike NSDictionary and other Cocoa collections, CHMultiMap has not been designed with mutable and immutable variants. A multimap is not any more useful if it is immutable, so any copies made of this class are mutable by definition.
 */
@interface CHMultiMap : CHLockable <NSCoding, NSCopying>
{
	NSMutableDictionary *dictionary; /**< Dictionary for key-value entries. */
	NSUInteger count; /**< The number of objects currently in the multimap. */
	unsigned long mutations; /**< Used to track mutations for enumeration. */
}

/**
 Initializes a newly allocated multi-dictionary with no key-value entries.
 */
- (id) init;

/**
 Initializes a newly allocated multi-dictionary with entries constructed from arrays of objects and keys.
 
 @param keyArray An array containing the keys for the new dictionary. 
 @param objectsArray An array containing the values for the new dictionary.
 @throw NSInvalidArgumentException If the array counts are not equal.
 
 Each element in @a objects can be either an object or an NSArray or NSSet of objects to be associated with the corresponding key in @a keys.
 */
- (id) initWithObjects:(NSArray*)objectsArray forKeys:(NSArray*)keyArray;

/**
 Initializes a newly allocated multi-dictionary with entries constructed from pairs of objects and keys.
 
 @param firstObject The first object or set of objects to add to the dictionary.
 @param ... First the key for @a firstObject, then a null-terminated list of alternating values and keys.
 @throw NSInvalidArgumentException If any non-terminating parameter is @c nil.
 
 Each value parameter may be an object or an NSArray or NSSet of objects to be associated with the corresponding key parameter.
 
 This method is similar to #initWithObjects:forKeys: and differs only in the way in which the key-value pairs are specified.
 */
- (id) initWithObjectsAndKeys:(id)firstObject, ...;

#pragma mark <NSCoding>
/** @name <NSCoding> */
// @{

/**
 Initialize the receiver using data from a given keyed unarchiver.
 
 @param decoder A keyed unarchiver object.
 
 @see NSCoding protocol
 */
- (id) initWithCoder:(NSCoder *)decoder;

/**
 Encodes data from the receiver using a given keyed archiver.
 
 @param encoder A keyed archiver object.
 
 @see NSCoding protocol
 */
- (void) encodeWithCoder:(NSCoder *)encoder;

// @}
#pragma mark <NSCopying>
/** @name <NSCopying> */
// @{

/**
 Returns a new instance that is a copy of the receiver. The returned object is implicitly retained by the sender, who is responsible for releasing it. Copies returned by this method are mutable. 
 
 @param zone Identifies an area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. (The \link NSObject#copy -copy\endlink method in NSObject invokes this method with a @c nil argument.)
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone*)zone;

// @}
#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

 /**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 For this class, as is the case with NSDictionary, this method enumerates only the keys. The value(s) for each key may be found using the \link #objectsForKey: -objectsForKey:\endlink method, which returns an NSSet with 1 or more objects associated with a given key, provided the key is in the multimap.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 @see NSFastEnumeration protocol
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @}
#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Adds to the receiver the entries from another multimap.
 
 @param otherMultiMap The multimap from which to add entries.
 
 Each value object from @a otherMultiMap is sent a retain message before being added to the receiver. Each key object is copied using -copyWithZone: and must conform to the NSCopying protocol.
 
 If a key from @a otherMultiMap already exists in the receiver, the objects associated with the key are combined using -[NSMutableSet unionSet:]. If the key does not yet exist in the receiver, an entry is created with the set of objects in @a otherMultiMap.
 */
- (void) addEntriesFromMultiMap:(CHMultiMap*)otherMultiMap;

/**
 Adds a given object to an entry for a given key in the receiver.
 
 @param aKey The key with which to associate @a anObject.
 @param anObject An object to add to an entry for @a aKey in the receiver. If an entry for @a aKey already exists in the receiver, @a anObject is added using \link NSMutableSet#addObject: -[NSMutableSet addObject:]\endlink, otherwise a new entry is created.
 @throw NSInvalidArgumentException If @a aKey or @a anObject is @c nil.
 */
- (void) addObject:(id)anObject forKey:(id)aKey;

/**
 Adds the given object(s) to a key entry in the receiver.
 
 @param aKey The key with which to associate @a anObject.
 @param objectSet A set of objects to add to an entry for @a aKey in the receiver. If an entry for @a aKey already exists in the receiver, @a anObject is added using \link NSMutableSet#unionSet: -[NSMutableSet unionSet:]\endlink, otherwise a new entry is created.
 @throw NSInvalidArgumentException If @a aKey or @a objectSet is @c nil.
 */
- (void) addObjects:(NSSet*)objectSet forKey:(id)aKey;

/**
 Sets the object(s) associated with a key entry in the receiver.
 
 @param aKey The key with which to associate the objects in @a objectSet.
 @param objectSet A set of objects to associate with @a key. If @a objectSet is empty, the contents of the receiver are not modified. If an entry for @a key already exists in the receiver, @a objectSet is added using \link NSMutableSet#setSet: -[NSMutableSet setSet:]\endlink, otherwise a new entry is created.
 @throw NSInvalidArgumentException If @a aKey or @a objectSet is @c nil.
 */
- (void) setObjects:(NSSet*)objectSet forKey:(id)aKey;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array containing the receiver's keys.
 
 @return An array containing the receiver's keys. The array is empty if the receiver has no entries. The order of the keys is undefined.
 */
- (NSArray*) allKeys;

/**
 Returns an array containing the receiver's values. This is effectively a concatenation of the sets of objects associated with the keys in the receiver. (Unlike a set union, objects associated with multiple keys appear once for each key which which they are associated.)
 
 @return An array containing the receiver's values. The array is empty if the receiver has no entries. The order of the values is undefined.
 */
- (NSArray*) allObjects;

/**
 Returns the number of keys in the receiver.
 
 @return The number of keys in the receiver, regardless of how many objects are
 associated with any given key in the dictionary.
 */
- (NSUInteger) count;

/**
 Returns the number of objects in the receiver, associated with any key.
 
 @return The number of objects in the receiver. This is the sum total of objects associated with each key in the dictonary.
 */
- (NSUInteger) countForAllKeys;

/**
 Returns the number of objects associated with a given key.
 
 @param aKey The key for which to return the object count.
 @return The number of objects associated with a given key in the dictionary.
 */
- (NSUInteger) countForKey:(id)aKey;

/**
 Returns a Boolean that tells whether a given key is present in the receiver.
 
 @param aKey The key to check for membership in the receiver.
 @return @c YES if an entry for @a aKey exists in the receiver.
 */
- (BOOL) containsKey:(id)aKey;

/**
 Returns a Boolean that tells whether a given object is present in the receiver.
 
 @param anObject An object to check for membership in the receiver.
 @return @c YES if @a anObject is associated with 1 or more keys in the receiver.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Returns an enumerator that lets you access each key in the multimap.
 
 @return An enumerator that lets you access each key in the multimap. The enumerator returned is never @c nil; if the multimap is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Requesting objects from an enumerator whose underlying collection has been modified is unsafe, and may cause a mutation exception to be raised.
 @warning If you need to modify the entries concurrently, use #allKeys to create a "snapshot" of the dictionary's keys and work from this snapshot to modify the entries.
 */
- (NSEnumerator*) keyEnumerator;

/**
 Returns an enumerator that lets you access each value in the multimap.
 
 @return An enumerator that lets you access each value in the multimap. The enumerator returned is never @c nil; if the multimap is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Requesting objects from an enumerator whose underlying collection has been modified is unsafe, and may cause a mutation exception to be raised.
 @warning If you need to modify the entries concurrently, use #allObjects to create a "snapshot" of the dictionary's values and work from this snapshot to modify the values.
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an array of objects associated with a given key.
 
 @param aKey The key for which to return the corresponding objects.
 @return An NSSet of objects associated with a given key, or nil if the key is not in the receiver.
 */
- (NSSet*) objectsForKey:(id)aKey;

/**
 Returns a property list representation of the receiver's contents.
 
 @return A property list representation of the receiver's contents.
 
 If each key in the receiver is an NSString, the entries are listed in ascending order by key, otherwise the order in which the entries are listed is undefined. This method is intended to produce readable output for debugging purposes, not for serializing data. To store a multi-dictionary for later retrieval, see the <a href="http://developer.apple.com/DOCUMENTATION/Cocoa/Conceptual/Archiving/"> Archives and Serializations Programming Guide for Cocoa</a>.
 */
- (NSString*) description;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Empties the receiver of its entries. Each key and all corresponding objects are sent a release message.
 */
- (void) removeAllObjects;

/**
 Remove @b all occurrences of @a anObject associated with a given key.
 
 @param aKey The key for which to remove an entry.
 @param anObject An object (possibly) associated with @a aKey in the receiver. Objects are considered to be equal if -compare: returns NSOrderedSame.
 @throw NSInvalidArgumentException If @a aKey or @a anObject is @c nil.
 
 If @a aKey does not exist in the receiver, or if @a anObject is not associated with @a aKey, the contents of the receiver are not modified.
 */
- (void) removeObject:(id)anObject forKey:(id)aKey;

/**
 Removes a given key and its associated value(s) from the receiver.
 
 @param aKey The key for which to remove an entry.
 
 If @a aKey does not exist in the receiver, there is no effect on the receiver.
 */
- (void) removeObjectsForKey:(id)aKey;

// @}
@end
