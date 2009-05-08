/*
 CHDataStructures.framework -- CHSortedSet.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "Util.h"

/**
 @file CHSortedSet.h
 
 A protocol which specifes an interface for sorted sets.
 */

/**
 A protocol which specifes an interface for sorted sets.
 
 A <strong>sorted set</strong> is a <a href="http://en.wikipedia.org/wiki/Set_(computer_science)">set</a> that further provides a <em>total ordering</em> on its elements. This protocol defines sorted set methods for insertion, removal, search, and object enumeration. Though any conforming class must implement all these methods, they may document that certain of them are unsupported, and/or raise exceptions when they are called.
 
 In a sorted set, objects are inserted according to their sorted order, so they must respond to the @c -compare: selector, which accepts another object and returns @c NSOrderedAscending, @c NSOrderedSame, or @c NSOrderedDescending (constants in <a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_DataTypes/Reference/reference.html#//apple_ref/c/tdef/NSComparisonResult">NSComparisonResult</a>) as the receiver is less than, equal to, or greater than the argument, respectively. (Several Cocoa classes already implement the @c -compare: method, including NSString, NSDate, NSNumber, NSDecimalNumber, and NSCell.)
 
 Java includes a <a href="http://java.sun.com/javase/6/docs/api/java/util/SortedSet.html">SortedSet</a> interface as part of the <a href="http://java.sun.com/javase/6/docs/technotes/guides/collections/">Java Collections Framework</a>. Many other programming languages also have sorted sets, most commonly implemented as <a href="http://en.wikipedia.org/wiki/Binary_search_tree">binary search trees</a>.
 
 @see CHSearchTree
 
 @todo Add more operations similar to those supported by NSSet and NSMutableSet, such as:
	- <code>- (NSArray*) allObjectsFilteredUsingPredicate:</code>
	- <code>- (void) filterUsingPredicate:</code>
	- <code>- (BOOL) isEqualToSortedSet:</code>
	- <code>- (BOOL) isSubsetOfSortedSet:</code>
	- <code>- (BOOL) intersectsSet:</code>
	- <code>- (void) intersectSet:</code>
	- <code>- (void) minusSet:</code>
	- <code>- (void) unionSet:</code>
 
 @todo Add <code>-subsetFromObject:toObject:</code> to return a new subset instance with new nodes pointing to the same objects. If an object matches one of the parameters, it is included. (Neither parameter must be a member of the set. Either parameter may be nil to designate the first/last element in the set. If the first object is greater than the second, should the result include elements sliced from both ends?) See Java's <a href="http://java.sun.com/javase/6/docs/api/java/util/SortedSet.html">SortedSet</a> for ideas.
 
 @todo Consider adding other possible sorted set implementations, such as <a href="http://en.wikipedia.org/wiki/Skip_list">skip lists</a>, <a href="http://www.concentric.net/~Ttwang/tech/sorthash.htm">sorted linear hash sets</a>, and <a href="http://code.activestate.com/recipes/230113/">sorted lists</a>.

 */
#if MAC_OS_X_VERSION_10_5_AND_LATER
@protocol CHSortedSet <NSObject, NSCoding, NSCopying, NSFastEnumeration>
#else
@protocol CHSortedSet <NSObject, NSCoding, NSCopying>
#endif

/**
 Initialize a sorted set with no objects.
 
 @see initWithArray:
 */
- (id) init;

/**
 Initialize a sorted set with the contents of an array. Objects are added to the set in the order they occur in the array.
 
 @param anArray An array containing objects with which to populate a new sorted set.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Adds a given object to the receiver, if the object is not already a member.
 
 Ordering is based on an object's response to the @c -compare: message. Since no duplicates are allowed, if the receiver already contains an object for which a @c -compare: message returns @c NSOrderedSame, that object is released and replaced by @a anObject.
 
 @param anObject The object to add to the receiver.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 
 @see addObjectsFromArray:
 */
- (void) addObject:(id)anObject;

/**
 Adds to the receiver each object in a given array, if the object is not already a member.
 
 Ordering is based on an object's response to the @c -compare: message. Since no duplicates are allowed, if the receiver already contains an object for which a @c -compare: message returns @c NSOrderedSame, that object is released and replaced by the matching object from @a anArray.
 
 @param anArray An array of objects to add to the receiver.
 
 @see addObject:
 @see lastObject
 */
- (void) addObjectsFromArray:(NSArray*)anArray;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an NSArray containing the objects in the receiver in ascending order.
 
 @return An array containing the objects in the receiver. If the receiver is empty, the array is also empty.
 
 @see anyObject
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see removeAllObjects
 */
- (NSArray*) allObjects;

/**
 Returns one of the objects in the receiver, or @c nil if the receiver contains no objects. The object returned is chosen at the receiver's convenience; the selection is not guaranteed to be random.
 
 @return An arbitrarily-selected object from the receiver, or @c nil if the receiver is empty.
 
 @see allObjects
 @see firstObject
 @see lastObject
 */
- (id) anyObject;

/**
 Returns the number of objects currently in the receiver.
 
 @return The number of objects currently in the receiver.
 
 @see allObjects
 */
- (NSUInteger) count;

/**
 Determine whether a given object is present in the receiver.
 
 @param anObject The object to test for membership in the receiver.
 @return @c YES if the receiver contains @a anObject (as determined by \link NSObject#isEqual: -isEqual:\endlink), @c NO if @a anObject is @c nil or not present.
 
 @attention To test whether the matching object is identical to @a anObject, compare @a anObject with the value returned from #member: using the == operator.
 
 @see member:
 */
- (BOOL) containsObject:(id)anObject;

/**
 Returns the minimum object in the receiver, according to natural sorted order.
 
 @return The minimum object in the receiver, or @c nil if the receiver is empty.
 
 @see anyObject
 @see lastObject
 @see removeFirstObject
 */
- (id) firstObject;

/**
 Returns the maximum object in the receiver, according to natural sorted order.
 
 @return The maximum object in the receiver, or @c nil if the receiver is empty.
 
 @see addObject:
 @see anyObject
 @see firstObject
 @see removeLastObject
 */
- (id) lastObject;

/**
 Determine whether the receiver contains a given object, and returns the object if present.
 
 @param anObject The object to test for membership in the receiver.
 @return If the receiver contains an object equal to @a anObject (as determined by \link NSObject#isEqual: -isEqual:\endlink) then that object (typically this will be @a anObject) is returned, otherwise @c nil.
 
 @attention If you override \link NSObject#isEqual: -isEqual:\endlink for a custom class, you must also override \link NSObject#hash -hash\endlink for #member: to work correctly on objects of your class.

 @see containsObject:
 */
- (id) member:(id)anObject;

/**
 Returns an enumerator that accesses each object in the receiver in ascending order.
 
 @return An enumerator that accesses each object in the receiver in ascending order. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 @see reverseObjectEnumerator
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the receiver in descending order.
 
 @return An enumerator that accesses each object in the receiver in descending order. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see objectEnumerator
 */
- (NSEnumerator*) reverseObjectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove all objects from the receiver; if the receiver is already empty, there is no effect.
 
 @see allObjects
 @see removeFirstObject
 @see removeLastObject
 @see removeObject:
 */
- (void) removeAllObjects;

/**
 Remove the minimum object from the receiver, according to natural sorted order.
 
 @see firstObject
 @see removeLastObject
 @see removeObject:
 */
- (void) removeFirstObject;

/**
 Remove the maximum object from the receiver, according to natural sorted order.
 
 @see lastObject
 @see removeFirstObject
 @see removeObject:
 */
- (void) removeLastObject;

/**
 Remove the object for which @c -compare: returns @c NSOrderedSame from the receiver. If no matching object exists, there is no effect.
 
 @param anObject The object to be removed from the receiver.
 
 If the receiver is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @see containsObject:
 @see removeAllObjects
 */
- (void) removeObject:(id)anObject;

// @}
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
 Returns a new instance that is a mutable copy of the receiver. If garbage collection is @b not enabled, the copy is retained before being returned, but the sender is responsible for releasing it.
 
 @param zone An area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. 
 
 @note The default \link NSObject#copy -copy\endlink method invokes this method with a @c nil argument.
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone *)zone;

// @}
#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

#if MAC_OS_X_VERSION_10_5_AND_LATER
/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see NSFastEnumeration protocol
 @see allObjects
 @see objectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;
#endif

// @}
@end
