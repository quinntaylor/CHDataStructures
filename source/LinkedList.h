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

//  LinkedList.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>

/**
 A basic linked list interface.
 I am trying to remove methods from the protocols to be more "bare bones."
 I received some very good criticism that I was making a hack job of these protocols.
 */ 
@protocol LinkedList <NSObject>

- (id) init;

/**
 Returns the number of objects currently in the list.
 */
- (unsigned int) count;
/**
 Determines if the list contains a given object (or one identical to it). Matches
 based on an object's response to the <code>isEqual:</code> message.
 */
- (BOOL) containsObject:(id)obj;
//See NSMutableArray for the difference between these two methods.
//basically removeObject uses isEqual, removeObjectIdenticalTo uses ==
/**
 Removes all occurrences of a given object in the list. Matches based on an object's
 response to the <code>isEqual:</code> message.
 */
- (BOOL) removeObject:(id)obj;
/**
 Removes all occurrences of a given object in the list. Matches based on object
 addresses, using the == operator.
 */
- (BOOL) removeObjectIdenticalTo:(id)obj;
/**
 Remove all objects from the list. If the list is already empty, there is no effect.
 */
- (void) removeAllObjects;

//These BOOLS are all success / no success ... can safely be ignored
//basically if you try to insert nil or if your index is out of bounds,
//these will return NO.
- (BOOL) insertObject:(id)obj atIndex:(unsigned int)index;
- (BOOL) addFirst:(id)obj;
- (BOOL) addLast:(id)obj;

- (id) first;
- (id) last;
- (id) objectAtIndex:(unsigned int)index;

//These BOOLS are all success / no success
- (BOOL) removeFirst;
- (BOOL) removeLast;
/**
 Removes the object at <i>index</i>.
 */
- (BOOL) removeObjectAtIndex:(unsigned int)index;



//see NSEnumerator abstract class
- (NSEnumerator *) objectEnumerator;


/**
 * Returns an autoreleased Linked List with the contents of your 
 * array in the specified order.
 * YES means that the linked list will be indexed (0...n) like your array.
 * whereas NO means that the list will be ordered (n...0).
 * Your array will not be changed, released, etc.  The list will retain,
 * not copy, your references.  If you retain this list, your array will
 * be safe to release.
 */
+ (id <LinkedList>) listFromArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
