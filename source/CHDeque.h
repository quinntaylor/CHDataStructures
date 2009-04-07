/*
 CHDataStructures.framework -- CHDeque.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHDeque.h
 
 A <a href="http://en.wikipedia.org/wiki/Deque">deque</a> protocol with methods for
 insertion and removal on both ends.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Deque">deque</a> protocol with methods for
 insertion and removal on both ends of a queue.
 */
@protocol CHDeque <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a deque with no objects.
 */
- (id) init;

/**
 Initialize a deque with the contents of an array. Objects are appended in the
 order they occur in the array.
 
 @param anArray An array containing object with which to populate a new deque.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Add an object to the front of the deque.
 
 @param anObject The object to add to the deque; must not be <code>nil</code>,
        or an <code>NSInvalidArgumentException</code> is raised.
 */
- (void) prependObject:(id)anObject;

/**
 Add an object to the back of the deque.
 
 @param anObject The object to add to the deque; must not be <code>nil</code>,
        or an <code>NSInvalidArgumentException</code> is raised.
 */
- (void) appendObject:(id)anObject;

/**
 Examine the first object in the deque without removing it.
 
 @return The first object in the deque, or <code>nil</code> if it is empty.
 */
- (id) firstObject;

/**
 Examine the last object in the deque without removing it.
 
 @return The last object in the deque, or <code>nil</code> if it is empty.
 */
- (id) lastObject;

/**
 Remove the first object in the deque; no effect if it is empty.
 */
- (void) removeFirstObject;

/**
 Remove the last object in the deque; no effect if it is empty.
 */
- (void) removeLastObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be removed from the deque.
 
 If the deque does not contain <i>anObject</i>, there is no effect, although it
 does incur the overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to be removed from the deque.
 
 If the deque does not contain <i>anObject</i>, there is no effect, although it
 does incur the overhead of searching the contents.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the deque; no effect if it is empty.
 */
- (void) removeAllObjects;

/**
 Returns an array with the objects in this deque, ordered from front to back.
 
 @return An array with the objects in this deque. If the deque is empty, the
         array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently in the deque.
 
 @return The number of objects currently in the deque.
 */
- (NSUInteger) count;

/**
 Determines if a deque contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the deque. 
 @return <code>YES</code> if <i>anObject</i> is present in the deque, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a deque contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the deque.
 @return <code>YES</code> if <i>anObject</i> is present in the deque, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns an enumerator that accesses each object in the deque from front to back.
 
 NOTE: When using an enumerator, you must not modify the deque during enumeration. 
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the deque from back to front.
 
 NOTE: When using an enumerator, you must not modify the deque during enumeration. 
 */
- (NSEnumerator*) reverseObjectEnumerator;

@end
