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

//  CHMutableArrayHeap.m
//  CHDataStructures.framework

//  Copyright (c) 2002 Gordon Worley redbird@rbisland.cx
//  Contributions by Phillip Morelock for purposes of integration with the library.
//  Many thanks to Gordon for the very first outside contribution to the library!

//  Additions by Phillip Morelock Apr 03 2002
//  - fine-tuned memory management / object releases, etc.
//  - replaced some internal method calls with the "straight call" so as
//  - to reduce obj_c multiple messaging
//  - converted bubbleup and bubbledown from Obj-C methods to static C functions.

#import "CHMutableArrayHeap.h"

#pragma mark C Functions for Optimized Operations

static void _bubbleup(NSMutableArray *heap) {
	NSUInteger i, parent;
	 
	//get the last index...
	i = [heap count] - 1;
	
	while (i > 0) {
		parent = i / 2;
		if ([[heap objectAtIndex:i] compare: [heap objectAtIndex:parent]] > 0) {
			[heap exchangeObjectAtIndex:i withObjectAtIndex:parent];
			i = parent;
		}
		else
			i = 0;
	}
}

static void _bubbledown(NSMutableArray *heap) {
	NSUInteger parent = 0, lchild, rchild;
	
	while (parent < [heap count] / 2) {
		lchild = parent * 2;
		rchild = parent * 2 + 1;
	
		if ([heap objectAtIndex: lchild] != nil && [heap objectAtIndex: rchild] != nil) {
			if ([[heap objectAtIndex: lchild] compare: [heap objectAtIndex: rchild]] > 0) {
				if ([[heap objectAtIndex: lchild] compare: [heap objectAtIndex: parent]] > 0) {
					[heap exchangeObjectAtIndex: lchild withObjectAtIndex: parent];
					parent = lchild;
				}
				else
					parent = [heap count];
			}
			else {
				if ([[heap objectAtIndex: rchild] compare: [heap objectAtIndex: parent]] > 0) {
					[heap exchangeObjectAtIndex: rchild withObjectAtIndex: parent];
					parent = rchild;
				}
				else
					parent = [heap count];
			}
		}
		else if ([heap objectAtIndex: lchild]) {
			if ([[heap objectAtIndex: lchild] compare: [heap objectAtIndex: parent]] > 0) {
				[heap exchangeObjectAtIndex: lchild withObjectAtIndex: parent];
				parent = lchild;
			}
			else
				parent = [heap count];
		}
		else if ([heap objectAtIndex: rchild]) {
			if ([[heap objectAtIndex: rchild] compare: [heap objectAtIndex: parent]] > 0) {
				[heap exchangeObjectAtIndex: rchild withObjectAtIndex: parent];
				parent = rchild;
			}
			else
				parent = [heap count];
		}
		else
			parent = [heap count];
	}
	
}

#pragma mark -

@implementation CHMutableArrayHeap

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	irep = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc {
	[irep release];
	[super dealloc];
}

- (void) addObject:(id)anObject {
	if (anObject == nil) {
		[NSException raise:NSInvalidArgumentException
					format:@"Object to be added cannot be nil."];
	}
	else {
		[irep addObject: anObject];
		_bubbleup(irep);
	}	
}
		
- (id) removeRoot {
	if ([irep count] == 0)
		return nil;

	id obj = [[irep objectAtIndex: 0] retain];
	[irep exchangeObjectAtIndex: 0 withObjectAtIndex: [irep count] - 1];
	[irep removeLastObject];

	_bubbledown(irep);
	
	return [obj autorelease];
}

- (id) removeLast {
	if ([irep count] == 0)
		return nil;
	
	id obj = [[irep lastObject] retain];
	[irep removeLastObject];

	return [obj autorelease];
}

- (NSUInteger) count {
	return [irep count];
}

@end
