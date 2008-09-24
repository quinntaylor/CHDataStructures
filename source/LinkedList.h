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
//
//  LinkedList.h
//  DataStructuresFramework
//

/////
//Just defines the interface a linked list should have.
//I am trying to remove methods from the protocols to be more "bare bones."
//I received some very good criticism that I was making a hack job of these protocols.
///////

/////SEE LICENSE FILE FOR LICENSE INFORMATION///////

#import <Foundation/Foundation.h>

@protocol LinkedList <NSObject>

-(id)init;

-(unsigned int) count;
-(BOOL) containsObject:(id)obj;
-(BOOL) containsObjectIdenticalTo:(id)obj;
-(void) removeAllObjects;

//These BOOLS are all success / no success ... can safely be ignored
//basically if you try to insert nil or if your index is out of bounds,
//these will return NO.
-(BOOL) insertObject:(id)obj atIndex:(unsigned int)index;
-(BOOL) addFirst:(id)obj;
-(BOOL) addLast:(id)obj;

-(BOOL) isEmpty;

-(id) first;
-(id) last;
-(id) objectAtIndex:(unsigned int)index;

//These BOOLS are all success / no success
-(BOOL)removeFirst;
-(BOOL)removeLast;
-(BOOL)removeObjectAtIndex:(unsigned int)index;

//See NSMutableArray for the difference between these two methods.
//basically removeObject uses isEqual, removeObjectIdenticalTo uses ==
-(BOOL)removeObject:(id)obj;
-(BOOL)removeObjectIdenticalTo:(id)obj;


//see NSEnumerator abstract class
-(NSEnumerator *)objectEnumerator;


/**
 * Returns an autoreleased Linked List with the contents of your 
 * array in the specified order.
 * YES means that the linked list will be indexed (0...n) like your array.
 * whereas NO means that the list will be ordered (n...0).
 * Your array will not be changed, released, etc.  The list will retain,
 * not copy, your references.  If you retain this list, your array will
 * be safe to release.
 */
+(id <LinkedList>)listFromArray:(NSArray *)array 
                        ofOrder:(BOOL)direction;

@end
