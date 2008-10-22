//  CHMutableArrayHeap.m
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

#import "CHMutableArrayHeap.h"

@implementation CHMutableArrayHeap

- (void) _heapifyFromIndex:(NSUInteger)parentIndex {
	// Bubble node at the given index down until the heap property is again satisfied
	id parent, leftChild, rightChild;
	NSUInteger leftIndex, rightIndex;
	
	NSUInteger arraySize = [array count];
	while (parentIndex < arraySize / 2) {
		leftIndex = parentIndex * 2 + 1;
		rightIndex = parentIndex * 2 + 2;
		
		// Since a binary heap is always a complete tree, the left will never be nil.
		parent = [array objectAtIndex:parentIndex];
		leftChild = [array objectAtIndex:leftIndex];
		rightChild = (rightIndex < arraySize) ? [array objectAtIndex:rightIndex] : nil;
		if (rightChild == nil || [leftChild compare:rightChild] == sortOrder) {
			if ([parent compare:leftChild] != sortOrder) {
				[array exchangeObjectAtIndex:parentIndex withObjectAtIndex:leftIndex];
				parentIndex = leftIndex;
			}
			else
				return;	
		}
		else {
			if ([parent compare:rightChild] != sortOrder) {
				[array exchangeObjectAtIndex:parentIndex withObjectAtIndex:rightIndex];
				parentIndex = rightIndex;
			}
			else
				return;
		}
	}
}

#pragma mark -

- (void) dealloc {
	[sortDescriptor release];
	[super dealloc];
}

- (id) init {
	return [self initWithOrdering:NSOrderedAscending array:nil];
}

/**
 Initialize a heap with ascending ordering and objects from an array.
 */
- (id) initWithArray:(NSArray*)anArray {
	return [self initWithOrdering:NSOrderedAscending array:anArray];
}

- (id) initWithOrdering:(NSComparisonResult)order {
	return [self initWithOrdering:order array:nil];
}

- (id) initWithOrdering:(NSComparisonResult)order array:(NSArray*)anArray {
	if ([super init] == nil) // Parent's initializer allocates the actual array
		return nil;
	if (order != NSOrderedAscending && order != NSOrderedDescending)
		[NSException raise:NSInvalidArgumentException
		            format:@"Must provide a valid sort ordering."];
	sortOrder = order;
	sortDescriptor = [[NSSortDescriptor alloc]
                       initWithKey:nil
                         ascending:(sortOrder == NSOrderedAscending)];
	[self addObjectsFromArray:anArray];
	return self;
}

#pragma mark <NSCoding> methods

- (id) initWithCoder:(NSCoder *)decoder {
	if ([super initWithCoder:decoder] == nil)
		return nil;
	sortOrder = [decoder decodeIntForKey:@"sortOrder"];
	sortDescriptor = [[NSSortDescriptor alloc]
                       initWithKey:nil
                         ascending:(sortOrder == NSOrderedAscending)];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeInt:sortOrder forKey:@"sortOrder"];
}

#pragma mark <NSCopying> Methods

- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithOrdering:sortOrder array:array];
}

#pragma mark <NSFastEnumeration>

// This overridden method returns the heap contents in fully-sorted order.
// Just as -objectEnumerator above, the first call incurs a hidden sorting cost.
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	// Currently (in Leopard) the NSEnumerators from NSArray only return 1 each time
	if (state->state == 0) {
		// Create a sorted array to use for enumeration, and store it in the state.
		state->extra[4] = (unsigned long) [self allObjects];
	}
	NSArray *sorted = (NSArray*) state->extra[4];
	NSUInteger count = [sorted countByEnumeratingWithState:state objects:stackbuf count:len];
	state->mutationsPtr = &mutations; // point state to mutations for heap array
	return count;
}

#pragma mark -

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	++mutations;
	[array addObject:anObject];
	// Bubble the new object (added at the end of the array) up the heap as necessary
	NSUInteger parent;
	NSUInteger i = [array count] - 1;
	while (i > 0) {
		parent = (i-1) / 2;
		if ([[array objectAtIndex:parent] compare:[array objectAtIndex:i]] != sortOrder)
		{
			[array exchangeObjectAtIndex:parent withObjectAtIndex:i];
			i = parent;
		}
		else
			break;
	}
}

- (void) addObjectsFromArray:(NSArray*)anArray {
	if (anArray == nil)
		return;
	++mutations;
	[array addObjectsFromArray:anArray];
	// heapify
	NSUInteger index = [array count]/2;
	while (0 < index--)
		[self _heapifyFromIndex:index];
}

- (id) firstObject {
	@try {
		return [array objectAtIndex:0];
	}
	@catch (NSException *exception) {}
	return nil;
}
		
- (void) removeFirstObject {
	@try {
		[array exchangeObjectAtIndex:0 withObjectAtIndex:([array count]-1)];
		[array removeLastObject];
		++mutations;
		// Bubble the swapped node down until the heap property is again satisfied
		[self _heapifyFromIndex:0];
	}
	@catch (NSException *exception) {}
}

- (void) removeObject:(id)anObject {
	NSUInteger index = [array indexOfObject:anObject];
	if (index != NSNotFound) {
		[array exchangeObjectAtIndex:index withObjectAtIndex:([array count]-1)];
		[array removeLastObject];
		++mutations;
		// Bubble the swapped node down until the heap property is again satisfied
		[self _heapifyFromIndex:index];
	}
}

- (void) removeAllObjects {
	[array removeAllObjects];
	++mutations;
}

- (NSArray*) sortedObjects {
	return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (NSEnumerator*) sortedObjectEnumerator {
	return [[self allObjects] objectEnumerator];
}

@end
