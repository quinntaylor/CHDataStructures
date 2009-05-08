/*
 CHDataStructures.framework -- CHLinkedSet.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"
#import "CHDoublyLinkedList.h"

/**
 @file CHLinkedSet.h
 A set structure that also maintains order of insertion using a doubly-linked list.
 */

/**
 A set structure that also maintains order of insertion using a doubly-linked list.
 
 A <strong>linked set</strong> is a composite data structure which combines a <a href="http://en.wikipedia.org/wiki/Set_(computer_science)">set</a> and a <a href="http://en.wikipedia.org/wiki/Linked_list">linked list</a>. It blends the uniqueness aspect of sets with the ability to recall the order in which items were added to the set. While this is possible with only a linked list, the speedy test for membership is a set means  that many basic operations (such as add, remove, and contains) that take linear time for a list can be accomplished in constant time (i.e. O(1) instead of O(n) complexity. Compared to these gains, the time overhead required for maintaining the list is negligible, although it does increase memory requirements significantly.
 
 One of the most common implementations of a linked set is Java's <a href="http://java.sun.com/javase/6/docs/api/java/util/LinkedHashSet.html">LinkedHashSet</a>. This implementation wraps an NSMutableSet and a CHDoublyLinkedList to maintain insertion order. (A singly-linked list could also be used. This would reduce memory usage, but also makes removing the youngest item expensive.) The API is designed to be as consistent as possible with that of NSSet and NSMutableSet.
 
 The default behavior is that inserting an object that already exists in the linked set does not affect insertion order. The alternate behavior is that whenever an object is added, even if it is a duplicate, that it becomes the last-inserted item. This is configurable via the \link #setRepeatObjectsMoveToBack: -setRepeatObjectsMoveToBack:\endlink method. However, be aware that the "always move to the back" behavior incurs additional bookkeeping overhead for maintaining the insertion order list.
 
 @todo Allow setting a maximum size, and either reject additions or evict the "oldest" item when the limit is reached? (Perhaps this would be better done by the user...)
 */
@interface CHLinkedSet : CHLockable {
	NSMutableSet *objects; /**< A mutable set for maintaining item uniquenes. */
	CHDoublyLinkedList *ordering; /**< A list for maintaining insert order. */
	BOOL repeatObjectsShouldMoveToBack; /**< If duplicate move to the back. */
}

/**
 Initialize a linked set with no objects.
 
 @return An initialized object.
 
 @see initWithArray:
 @see initWithCapacity:
 */
- (id) init;

/**
 Initialize a linked set with the objects from in a given array.
 
 @param array An array of objects to add to the new set. If the same object appears more than once in @a array, it is represented only once in the returned set. Each object receives a retain message as it is added to the set.
 
 @return An initialized object.

 @see init
 @see initWithCapacity:
 */
- (id) initWithArray:(NSArray *)array;

/**
 Initialize a linked set with a given initial capacity. Mutable sets allocate additional memory as needed, so @a numItems simply establishes the object's initial capacity.
 
 @param numItems The initial capacity of the set. A value of @c 0 indicates that the default capacity should be used.
 
 @return An initialized mutable set with initial capacity to hold @a numItems members.
  
 @see init
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
- (id) copyWithZone:(NSZone*)zone;

// @}
#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 For this class, the objects are enumerated in the order in which they were inserted.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see NSFastEnumeration protocol
 @see objectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @}
#pragma mark Insertion Order
/** @name Insertion Order */
// @{

/**
 Whether adding an object that already exists in the receiver causes it to become the "youngest" object. The default for a new linked set is @c NO.
 
 @see addObject:
 @see addObjectsFromArray:
 @see setRepeatObjectsMoveToBack:
 @see unionSet:
 */
- (BOOL) repeatObjectsMoveToBack;

/**
 Set whether adding an object that already exists in the receiver causes it to become the "youngest" object.
 
 @param flag Whether adding an object that already exists in the receiver will cause that object to become the "youngest" object.
 
 @attention Setting @a flag to @c YES will incur additional overhead (for searching the linked list and moving the object to the end) whenever a duplicate object is added.
 
 @note Changing whether reinsertion changes ordering does not affect the order of object that have already been added, only for subsequent additions. If desired, this value can safely be changed at any time to toggle the behavior.
  
 @see repeatObjectsMoveToBack
 */
- (void) setRepeatObjectsMoveToBack:(BOOL)flag;

// @}
#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Adds a given object to the receiver, if the object is not already a member.
 
 The insertion order for duplicates is only changed if #repeatObjectsMoveToBack returns @a YES.
 
 @param anObject The object to add to the receiver.
 
 @see addObjectsFromArray:
 @see lastObject
 @see repeatObjectsMoveToBack
 @see unionSet:
 */
- (void) addObject:(id)anObject;

/**
 Adds to the receiver each object contained in a given array that is not already a member.
 
 The insertion order for duplicates is only changed if #repeatObjectsMoveToBack returns @c YES.
 
 @param anArray An array of objects to add to the receiver.
 
 @see addObject:
 @see lastObject
 @see repeatObjectsMoveToBack
 @see unionSet:
 */
- (void) addObjectsFromArray:(NSArray*)anArray;

/**
 Adds to the receiver each object in another given set that is not yet present in the receiver. If all members of @a otherSet are already present in the receiver, and if #repeatObjectsMoveToBack returns @c NO, there is no effect on the receiver. In no case is @a otherSet directly modified.
 
 @param otherSet The set of objects to add to the receiver.
 
 @note The insertion order of objects from @a otherSet is undefined.
 
 @attention The bookkeeping for tracking insertion order adds O(n) cost (worst-case) of searching the list if #repeatObjectsMoveToBack returns @c YES.
 
 @see addObjectsFromArray:
 @see intersectSet:
 @see minusSet:
 @see repeatObjectsMoveToBack
 */
- (void) unionSet:(NSSet*)otherSet;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array of the objects in the set, in the order in which they were inserted.
 
 @return An array of the objects in the set, in the order in which they were inserted.
 
 @see anyObject
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see set
 */
- (NSArray*) allObjects;

/**
 Returns one of the objects in the receiver, or @c nil if the receiver contains no objects.
 
 @return One of the objects in the receiver, or @c nil if the receiver contains no objects. The object returned is chosen at the receiver's convenience—the selection is not guaranteed to be random.
 
 @see allObjects
 @see firstObject
 @see lastObject
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
 @see set
 */
- (NSUInteger) count;

/**
 Returns a string that represents the contents of the receiver, formatted as a property list. The objects are represented in the order in which they were (re)inserted, depending on the value returned by #repeatObjectsMoveToBack.
 
 @return A string that represents the contents of the receiver, formatted as a property list.
 
 @see allObjects
 @see objectEnumerator
 */
- (NSString*) description;

/**
 Returns the "oldest" member of the receiver.
 
 @return The "oldest" member of the receiver.
 
 @attention If #repeatObjectsMoveToBack returns @c YES, this is the least recently (re)inserted object, otherwise it is the first-inserted member of the receiver
 
 @see addObject:
 @see anyObject
 @see removeFirstObject
 */
- (id) firstObject;

/**
 Returns whether at least one object in the receiver is also present in another given set.
 
 @param otherSet The set with which to compare the receiver.
 
 @return @c YES if at least one object in the receiver is also present in @a otherSet, otherwise @c NO.
 */
- (BOOL) intersectsSet:(NSSet*)otherSet;

/**
 Compares the receiver to another set, without regard for insertion order. Two sets have equal contents if they each have the same number of members and if each member of one set is present in the other.
 
 @param otherSet
 The set with which to compare the receiver.
 
 @return @c YES if the contents of @a otherSet are equal to the contents of the receiver, otherwise @c NO.
 
 @attention This method does not regard insertion order. To see whether two linked sets contain the same objects in the same order, compare the results of #allObjects.
 */
- (BOOL) isEqualToSet:(NSSet*)otherSet;

/**
 Checks whether every object in the receiver is also present in another given set.
 
 @param otherSet The set with which to compare the receiver.
 
 @return @c YES if every object in the receiver is also present in @a otherSet, otherwise @c NO.
 */
- (BOOL) isSubsetOfSet:(NSSet*)otherSet;

/**
 Returns the "youngest" member of the receiver.

 @attention If #repeatObjectsMoveToBack returns @c YES, this is the most recently (re)inserted object, otherwise it is the last object inserted that did not already exist in the receiver.
 
 @see addObject:
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
 Returns an enumerator object that lets you access each object in the receiver in order.
 
 @return An enumerator object that lets you access each object in the receiver in order.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 If you need to modify the entries concurrently, you can enumerate over a "snapshot" of the set's values obtained from #allObjects.
 
 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 @see set
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an (autoreleased) immutable copy of the underlying set, without maintaining insertion order.

 @return An (autoreleased) immutable copy of the underlying set.
 
 @see allObjects
 */
- (NSSet*) set;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove from the receiver each object that isn't a member of another given set. If @a otherSet is empty, all objects are removed from the receiver, since the intersection is the empty set. In no case is @a otherSet direclty modified.
 
 @param otherSet The set with which to perform the intersection.
 
 @attention The bookkeeping for tracking insertion order adds O(n) cost (worst-case) of searching the list for any items to be removed from the receiver.
 
 @see intersectsSet:
 @see minusSet:
 @see removeObject:
 @see removeAllObjects
 @see unionSet:
 */
- (void) intersectSet:(NSSet*)otherSet;

/**
 Remove from the receiver each object in another given set that is present in the receiver. If no members of @a otherSet are present in the receiving set, this method has no effect on the receiver. In no case is @a otherSet direclty modified.
 
 @param otherSet The set of objects to remove from the receiver.
 
 @attention The bookkeeping for tracking insertion order adds O(n) cost (worst-case) of searching the list for any items to be removed from the receiver.
 
 @see intersectSet:
 @see removeObject:
 @see removeAllObjects
 @see unionSet:
 */
- (void) minusSet:(NSSet*)otherSet;

/**
 Empty the receiver of all of its members.
 
 @see allObjects
 @see intersectSet:
 @see minusSet:
 @see removeFirstObject
 @see removeLastObject
 @see removeObject:
 */
- (void) removeAllObjects;

/**
 Remove the "oldest" member of the receiver.
 
 @see firstObject
 */
- (void) removeFirstObject;

/**
 Remove the "youngest" member of the receiver. 

 @see lastObject
 */
- (void) removeLastObject;

/**
 Remove a given object from the receiver.
 
 @param anObject The object to remove from the receiver.
 
 @see minusSet:
 @see removeAllObjects
 @see removeFirstObject
 @see removeLastObject
 */
- (void) removeObject:(id)anObject;

// @}
@end
