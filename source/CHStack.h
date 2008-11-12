/*
 CHStack.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHStack.h
 
 A <a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a>
 protocol with methods for <a href="http://en.wikipedia.org/wiki/LIFO">LIFO</a>
 ("Last In, First Out") operations. 
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a>
 protocol with methods for <a href="http://en.wikipedia.org/wiki/LIFO">LIFO</a>
 ("Last In, First Out") operations. 
 
 A stack is commonly compared to a stack of plates. Objects may be added in any
 order (@link #pushObject: -pushObject:\endlink) and the most recently added
 object may be removed (@link #popObject -popObject\endlink) or returned without
 removing it (@link #topObject -topObject\endlink).
 */
@protocol CHStack <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a stack with no objects.
 */
- (id) init;

/**
 Initialize a stack with the contents of an array. Objects are pushed on the
 stack in the order they occur in the array.
 
 @param anArray An array containing object with which to populate a new stack.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Add an object to the top of the stack.
 
 @param anObject The object to add to the stack; must not be <code>nil</code>,
        or an <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) pushObject:(id)anObject;

/**
 Add the objects contained in a given array to the top of the stack.
 
 @param anArray An array of objects to add to the top of the stack. Objects are
        pushed in the order they appear in the array.
 */
- (void) pushObjectsFromArray:(NSArray*)anArray;

/**
 Examine the object on the top of the stack without removing it.
 
 @return The topmost object from the stack.
 */
- (id) topObject;

/**
 Remove the topmost object on the stack; no effect if the stack is already empty.
 */
- (void) popObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be removed from the stack.

 If the stack does not contain <i>anObject</i>, there is no effect, although it
 does incur the overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all objects from the stack; no effect if the stack is already empty.
 */
- (void) removeAllObjects;

/**
 Returns an array of the objects in this stack, ordered from top to bottom.
 
 @return An array of the objects in this stack. If the stack is empty, the array
         is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently on the stack.
 
 @return The number of objects currently on the stack.
 */
- (NSUInteger) count;

/**
 Checks if a stack contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the stack.
 @return <code>YES</code> if @a anObject is present in the stack,
         <code>NO</code> if @a anObject is not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a stack contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the stack.
 @return <code>YES</code> if @a anObject is present in the stack,
         <code>NO</code> if @a anObject is not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns an enumerator that accesses each object in the stack from top to bottom.
 
 NOTE: When using an enumerator, you must not modify the stack during enumeration.
 */
- (NSEnumerator*) objectEnumerator;

@end
