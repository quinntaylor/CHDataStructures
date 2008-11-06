/*
 CHAVLTree.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import "CHAVLTree.h"

@implementation CHAVLTree

- (void) addObject:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
	
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHTreeNode *parent, *current = header;
	CHTreeListNode *stack = NULL, *tmp;
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		CHTreeList_PUSH(current);
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	
	++mutations;
	[anObject retain]; // Must retain whether replacing value or adding new node
	if (current != sentinel) {
		// Replace the existing object with the new object.
		[current->object release];
		current->object = anObject;
		// No need to rebalance up the path since we didn't modify the structure
		while (stack != NULL)
			CHTreeList_POP; // deallocate wrappers for nodes pushed to the stack		
		return;
	} else {
		current = malloc(kCHTreeNodeSize);
		current->object = anObject;
		current->left   = sentinel;
		current->right  = sentinel;
		current->level  = 1;
		++count;
		// Link from parent as the proper child, based on last comparison
		parent = CHTreeList_TOP;
		CHTreeList_POP;
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rebalancing as we go
	BOOL isRightChild;
	while (parent != NULL) {
		isRightChild = (parent->right == current);
		//update balance factor
		//terminate or rebalance as necessary
		parent->link[isRightChild] = current;
		// Move to the next node up the path to the root
		current = parent;
		parent = CHTreeList_TOP;
		CHTreeList_POP;
	}
}

- (void) removeObject:(id)element {
	CHUnsupportedOperationException([self class], _cmd);
	
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
}

@end
