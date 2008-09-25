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

//  LLStack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Stack.h"

@class DoublyLinkedList;

/**
 A simple Stack implemented using a linked list. Nice! Fast!
 The linked list (also in this library) is partially implemented in
 straight C, so it's pretty fast.
 */
@interface LLStack : NSObject <Stack>
{
    DoublyLinkedList *list;
}

/**
 Provided simply because the linked list implementation provides it, so why shouldn't
 I let you access it? It would be pretty weird to use a stack like this, but who knows?
 **/
- (NSEnumerator *) objectEnumerator;

#pragma mark Inherited Methods
- (BOOL) push:(id)object;
- (id) pop;
- (id) peek;
- (unsigned int) count;

#pragma mark Redefined Methods
+ (LLStack *) stackWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
