/*
 CHTreap.m
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

#import "CHTreap.h"

@implementation CHTreap

/* Two way single rotation */
#define singleRotation(root,dir) {       \
	CHTreeNode *save = root->link[!dir]; \
	root->link[!dir] = save->link[dir];  \
	save->link[dir] = root;              \
	root = save;                         \
}

- (void) addObject:(id)anObject {
	[self addObject:anObject withPriority:(NSUInteger)arc4random()];
}

- (void) addObject:(id)anObject withPriority:(NSUInteger)priority {
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
			CHTreeList_POP; // Deallocate wrappers for nodes pushed to the stack		
		return;
	} else {
		current = malloc(kCHTreeNodeSize);
		current->object = anObject;
		current->left   = sentinel;
		current->right  = sentinel;
		current->priority = priority;
		++count;
		// Link from parent as the proper child, based on last comparison
		parent = CHTreeList_TOP;
		CHTreeList_POP;
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rotating as we go to satisfy the heap property
	BOOL isRightChild;
	int direction;
	while (parent != header) {
		isRightChild = (CHTreeList_TOP->right == parent);
		if (current->priority > parent->priority) {
			// Rotate child up, and parent down to opposite subtree
			direction = (parent->left == current);
			parent->link[!direction] = current->link[direction];
			current->link[direction] = parent;
			CHTreeList_TOP->link[isRightChild] = current;
		}
		else
			break; // We can stop once the heap property has been satisfied.
		
		// Move to the next node up the path to the root
		parent = CHTreeList_TOP;
		CHTreeList_POP;
	}
	while (stack != NULL)
		CHTreeList_POP;
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (header->right == sentinel)
		return;
	
	// TODO: Implement remove
	CHUnsupportedOperationException([self class], _cmd);
}

- (NSString*) debugDescription {
	NSMutableString *description = [NSMutableString stringWithFormat:
	                                @"<%@: 0x%x> = {\n", [self class], self];
	CHTreeNode *currentNode;
	CHTreeListNode *queue = NULL, *queueTail = NULL, *tmp;
	CHTreeList_ENQUEUE(header->right);
	sentinel->object = nil;
	while (currentNode != sentinel && queue != NULL) {
		currentNode = CHTreeList_FRONT;
		CHTreeList_DEQUEUE;
		if (currentNode->left != sentinel)
			CHTreeList_ENQUEUE(currentNode->left);
		if (currentNode->right != sentinel)
			CHTreeList_ENQUEUE(currentNode->right);
		// Append entry for the current node, including color and children
		[description appendFormat:@"\t%10d : %@ -> %@ and %@\n",
		 currentNode->priority, currentNode->object,
		 currentNode->left->object, currentNode->right->object];
	}
	[description appendString:@"}"];
	return description;
}

@end
