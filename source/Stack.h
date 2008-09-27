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
 A <a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a> protocol
 with methods for <a href="http://en.wikipedia.org/wiki/LIFO">LIFO</a> operations.
 */
@protocol Stack <NSObject>

/**
 Add an object to the top of the stack.
 
 @param anObject The object to add to the stack; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) push:(id)anObject;

/**
 Remove and return the topmost object, or <code>nil</code> if the stack is empty.
 
 @return The topmost object from the stack.
 */
- (id) pop;

/**
 Return the topmost object, but do not remove it from the stack.

 @return The topmost object from the stack.
*/
- (id) top;

/**
 Returns the number of objects currently on the stack.
 
 @return The number of objects currently on the stack.
 */
- (NSUInteger) count;

/**
 Returns an autoreleased Stack with the contents of the array in the specified order.
 
 @param array An array of objects to add to the stack.
 @param direction The order in which to insert objects from the array. YES means the 
        natural index order (0...n), NO means reverse index order (n...0).
 */
+ (id <Stack>) stackWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end