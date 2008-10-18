//  CHStack.h
//  CHDataStructures.framework

/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

/**
 @file CHStack.h
 
 A <a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a> protocol
 with methods for <a href="http://en.wikipedia.org/wiki/LIFO">LIFO</a> ("Last In,
 First Out") operations. 
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 A <a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a> protocol
 with methods for <a href="http://en.wikipedia.org/wiki/LIFO">LIFO</a> ("Last In,
 First Out") operations. 
 
 A stack is commonly compared to a stack of plates. Objects may be added in any order
 (@link #pushObject: -pushObject:\endlink) and the most recently added object may be
 removed (@link #popObject -popObject\endlink) or returned without removing it (@link
 #topObject -topObject\endlink).
 */
@protocol CHStack <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a stack with no objects.
 */
- (id) init;

/**
 Add an object to the top of the stack.
 
 @param anObject The object to add to the stack; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) pushObject:(id)anObject;

/**
 Examine the object on the top of the stack without removing it.
 
 @return The topmost object from the stack.
 */
- (id) topObject;

/**
 Remove the topmost object on the stack; if it is already empty, there is no effect.
 */
- (void) popObject;

/**
 Remove all objects from the stack; if it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an array containing the objects in this stack, ordered from top to bottom.
 
 @return An array containing the objects in this stack. If the stack is empty, the
         array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently on the stack.
 
 @return The number of objects currently on the stack.
 */
- (NSUInteger) count;

/**
 Determines if a stack contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the stack.
 @return <code>YES</code> if <i>anObject</i> is present in the stack, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a stack contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the stack.
 @return <code>YES</code> if <i>anObject</i> is present in the stack, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns an enumerator that accesses each object in the stack from top to bottom.
 
 NOTE: When you use an enumerator, you must not modify the stack during enumeration.
 */
- (NSEnumerator*) objectEnumerator;

@end
