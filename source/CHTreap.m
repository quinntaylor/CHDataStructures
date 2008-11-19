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

// Two-way single rotation; 'dir' is the side to which the root should rotate.
#define singleRotation(node,dir,parent) {       \
	CHTreeNode *save = node->link[!dir]; \
	node->link[!dir] = save->link[dir];  \
	save->link[dir] = node;              \
	parent->link[(parent->right == node)] = save; \
}

- (id) init {
	if ([super init] == nil) return nil;
	header->priority = NSIntegerMax;
	sentinel->priority = NSIntegerMin;
	return self;
}

- (void) addObject:(id)anObject {
	[self addObject:anObject withPriority:(arc4random() % NSNotFound)];
}

- (void) addObject:(id)anObject withPriority:(NSInteger)priority {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (priority == NSNotFound)
		CHInvalidArgumentException([self class], _cmd,
		                           @"Invalid priority: cannot be NSNotFound.");
	CHTreeNode *parent, *current = header;
	CHTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	CHTreeStack_INIT(stack);
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		CHTreeStack_PUSH(current);
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	parent = CHTreeStack_POP;

	++mutations;
	[anObject retain]; // Must retain whether replacing value or adding new node
	int direction;
	if (current != sentinel) {
		// Replace the existing object with the new object.
		[current->object release];
		current->object = anObject;
		// Assign new priority; bubble down if needed, or just wait to bubble up
		current->priority = priority;
		while (current->left != current->right) { // sentinel check
			direction = (current->right->priority > current->left->priority);
			if (current->priority >= current->link[direction]->priority)
				break;
			singleRotation(current, !direction, parent);
			parent = current;
			current = current->link[!direction];
		}
	} else {
		current = malloc(kCHTreeNodeSize);
		current->object = anObject;
		current->left   = sentinel;
		current->right  = sentinel;
		current->priority = priority;
		++count;
		// Link from parent as the correct child, based on the last comparison
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rotating as we go to satisfy the heap property.
	// Loop exits once the heap property is satisfied, even after bubble down.
	while (parent != header && current->priority > parent->priority) {
		// Rotate current node up, push parent down to opposite subtree.
		direction = (parent->left == current);
		singleRotation(parent, direction, CHTreeStack_TOP);
		parent = CHTreeStack_POP;
	}
	free(stack);
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHTreeNode *parent, *current = header;
	NSComparisonResult comparison;
	int direction;
	
	// First, we must locate the object to be removed, or we exit if not found
	sentinel->object = anObject; // Assure that we stop at a sentinel leaf node
	while (comparison = [current->object compare:anObject]) {
		parent = current;
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	
	if (current != sentinel) {
		// Percolate node down the tree, always rotating towards lower priority
		BOOL isRightChild;
		while (current->left != current->right) { // sentinel check
			direction = (current->right->priority > current->left->priority);
			isRightChild = (parent->right == current);
			singleRotation(current, !direction, parent);
			parent = parent->link[isRightChild];
		}
		parent->link[parent->right == current] = sentinel;
		[current->object release];
		free(current);
		--count;
	}
	++mutations;
}

- (NSInteger) priorityForObject:(id)anObject {
	if (anObject == nil)
		return NSNotFound;
	sentinel->object = anObject; // Make sure the target value is always "found"
	CHTreeNode *current = header->right;
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) // while not equal
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	return (current != sentinel) ? current->priority : NSNotFound;
}

- (NSString*) debugDescriptionForNode:(CHTreeNode*)node {
	return [NSString stringWithFormat:@"\t[%11d]\t\"%@\" -> \"%@\" and \"%@\"\n",
			node->priority, node->object, node->left->object, node->right->object];
}

- (NSString*) dotStringForNode:(CHTreeNode*)node {
	return [NSString stringWithFormat:@"  \"%@\" [label=\"%@\\n%d\"];\n",
			node->object, node->object, node->priority];
}

@end
