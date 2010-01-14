/*
 CHDataStructures.framework -- CHLockableSet.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHLockableSet.h
 
 A mutable set class with simple built-in locking capabilities.
 */

/**
 A mutable set class with simple built-in locking capabilities.

 Since this class extends NSMutableSet, it or any of its children may be used anywhere an NSSet or NSMutableSet is required. It is designed to behave virtually identically to a standard NSMutableSet, but with the addition of built-in locking.
 
 An NSLock is used internally to coordinate the operation of multiple threads of execution within the same application, and methods are exposed to allow clients to manipulate the lock in simple ways. Since not all clients will use the lock, it is created lazily the first time a client attempts to acquire the lock.
 
 A CFMutableSetRef is used internally to store the key-value pairs. Subclasses may choose to add other instance variables to enable a specific ordering of keys, override methods to modify behavior, and add methods to extend existing behaviors. However, all subclasses should behave like a standard Cocoa dictionary as much as possible, and document clearly when they do not.
 
 @note Any method inherited from NSSet or NSMutableSet is supported, but only overridden methods are listed here.
 */ 
@interface CHLockableSet : NSMutableSet <CHLockable> {
	NSLock* lock; /**< A lock for synchronizing interaction between threads. */
	__strong CFMutableSetRef set; /**< A Core Foundation mutable set. */
}

/**
 Initialize an ordered set with a given initial capacity. Mutable sets allocate additional memory as needed, so @a numItems simply establishes the object's initial capacity.
 
 @param numItems The initial capacity of the set. A value of @c 0 indicates that the default capacity should be used.
 
 @return An initialized mutable set with initial capacity to hold @a numItems members.
 
 @see initWithArray:
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
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @since Mac OS X v10.5 and later.
 
 @see NSFastEnumeration protocol
 @see allObjects
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
 Adds a given object to the receiver, if it is not already a member. If @a anObject is already present in the set, this method has no effect on either the set or @a anObject.
 
 @param anObject The object to add to the receiver.
 
 @see addObjectsFromArray:
 @see unionSet:
 */
- (void) addObject:(id)anObject;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns one of the objects in the receiver, or @c nil if the receiver contains no objects.
 
 @return One of the objects in the receiver, or @c nil if the receiver contains no objects. The object returned is chosen at the receiver's convenience; the selection is not guaranteed to be random.
 
 @see allObjects
 */
- (id) anyObject;

/**
 Determine whether a given object is present in the receiver.
 
 @param anObject The object to test for membership in the receiver.
 @return @c YES if the receiver contains @a anObject (as determined by \link NSObject#isEqual: -isEqual:\endlink), @c NO if @a anObject is @c nil or not present.
 
 @attention To test whether the matching object is identical to @a anObject, compare @a anObject with the value returned from #member: using the == operator.
 
 @see member:
 */
- (BOOL) containsObject:(id)anObject;

/**
 Returns the number of members in the receiver.
 
 @return The number of members in the receiver.
 
 @see allObjects
 */
- (NSUInteger) count;

/**
 Returns a string that represents the contents of the receiver.
 
 @return A string that represents the contents of the receiver.
 
 @see allObjects
 @see objectEnumerator
 */
- (NSString*) description;

/**
 Determine whether the receiver contains a given object, and returns the object if present.
 
 @param anObject The object to test for membership in the receiver.
 @return If the receiver contains an object equal to @a anObject (as determined by \link NSObject#isEqual: -isEqual:\endlink) then that object (typically this will be @a anObject) is returned, otherwise @c nil.
 
 @attention If you override \link NSObject#isEqual: -isEqual:\endlink for a custom class, you must also override \link NSObject#hash -hash\endlink in order for #member: to work correctly on objects of your class.
 
 @see containsObject:
 */
- (id) member:(id)anObject;

/**
 Returns an enumerator object that lets you access each object in the receiver.
 
 @return An enumerator object that lets you access each object in the receiver.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 If you need to modify the entries concurrently, you can enumerate over a "snapshot" of the set's values obtained from #allObjects.
 
 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 */
- (NSEnumerator*) objectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Empty the receiver of all of its members.
 
 @see allObjects
 @see intersectSet:
 @see minusSet:
 @see removeObject:
 */
- (void) removeAllObjects;

/**
 Remove a given object from the receiver if it is present.
 
 @param anObject The object to remove from the receiver.
 
 @see minusSet:
 @see removeAllObjects
 */
- (void) removeObject:(id)anObject;

// @}
@end
