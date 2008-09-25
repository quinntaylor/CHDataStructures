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

//retains the inserted object.
//if you try to push nil, it will return false
- (BOOL) push:(id)object;

//return and autoreleases the return value.
//returns nil if the stack is empty.
- (id) pop;

//simple BOOL for whether the stack is empty or not.
- (unsigned int) count;

/**
 * Returns an autoreleased stack with the contents of your 
 * array in the specified order.
 * YES means that the stack will pop items in the order indexed (0...n)
 * whereas NO means that the stack will pop items (n...0).
 * Your array will not be changed, released, etc.  The stack will retain,
 * not copy, your references.  If you retain this stack, your array will
 * be safe to release.
 */
+ (id <Stack>) stackWithArray:(NSArray *)array
					  ofOrder:(BOOL)direction;

@end