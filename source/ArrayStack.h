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

//  ArrayStack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "AbstractStack.h"

/**
 A fairly basic Stack implementation that uses an NSMutableArray to store objects.
 */
@interface ArrayStack : AbstractStack
{
	/** The array used for storing the contents of the stack. */
	NSMutableArray *array;
}

/**
 Create a new stack starting with an NSMutableArray of the specified capacity.
 */
- (id) initWithCapacity:(NSUInteger)capacity;

/**
 Returns an enumerator that accesses each object in the stack from top to bottom.
 
 The mutable array implementation provides it, so why shouldn't I let you access it?
 It would be pretty weird to use a stack like this, but who knows?
 **/
- (NSEnumerator *) objectEnumerator;

#pragma mark Inherited Methods
- (void) push:(id)anObject;
- (id) pop;
- (id) top;
- (NSUInteger) count;

@end
