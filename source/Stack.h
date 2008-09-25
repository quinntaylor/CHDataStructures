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

//  Stack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>

/**
 A basic stack interface.
 */
@protocol Stack <NSObject>

/**
 Add an object to the top of the stack. Returns NO if the object is <code>nil</code>.
 */
- (BOOL) push:(id)object;

/**
 Remove and return the topmost object, or <code>nil</code> if the stack is empty.
 */
- (id) pop;

/**
 Return the topmost object, but do not remove it from the stack.
 */
- (id) peek;

/**
 Returns the number of objects currently on the stack
 */
- (unsigned int) count;

/**
 Returns an autoreleased stack with the contents of the array in the same order.
 For direction, YES means that objects will dequeue in the order indexed (0...n),
 whereas NO means that objects will dequeue (n...0).
 */
+ (id <Stack>) stackWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end