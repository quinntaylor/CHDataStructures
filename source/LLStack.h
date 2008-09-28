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
#import "AbstractStack.h"
#import "DoublyLinkedList.h"

/**
 A simple Stack implemented using a linked list. It's based on DoublyLinkedList which
 is partially implemented in straight C, so it's pretty fast.
 */
@interface LLStack : AbstractStack
{
	DoublyLinkedList *list;
}

/**
 Returns an enumerator that accesses each object in the stack from top to bottom.

 The linked list implementation provides it, so why shouldn't I let you access it?
 It would be pretty weird to use a stack like this, but who knows?
 **/
- (NSEnumerator *) objectEnumerator;

#pragma mark Inherited Methods
- (void) pushObject:(id)anObject;
- (id) popObject;
- (id) topObject;
- (NSUInteger) count;

@end
