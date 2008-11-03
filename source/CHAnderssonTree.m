/*
 CHAnderssonTree.m
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

#import "CHAnderssonTree.h"

// Remove left horizontal links
#define skew(node) { \
	if ( node->left->level == node->level && node->level != 0 ) { \
		CHTreeNode *save = node->left; \
		node->left = save->right; \
		save->right = node; \
		node = save; \
	} }

// Remove consecutive horizontal links
#define split(node) { \
	if ( node->right->right->level == node->level && node->level != 0 ) { \
		CHTreeNode *save = node->right; \
		node->right = save->left; \
		save->left = node; \
		node = save; \
		++(node->level); \
	} }

/**
 Skew primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
CHTreeNode* _skew(CHTreeNode *node) {
	if (node->left->level == node->level) {
		CHTreeNode *other = node->left;
		node->left = other->right;
		other->right = node;
		return other;
	}
	return node;
}

/**
 Split primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
CHTreeNode* _split(CHTreeNode *node) {
	if (node->right->right->level == node->level)
	{
		CHTreeNode *other = node->right;
		node->right = other->left;
		other->left = node;
		other->level++;
		return other;
	}
	return node;
}

#pragma mark -

@implementation CHAnderssonTree

- (id) init {
	if ([super init] == nil) return nil;
	sentinel->level = 0;
	header->level = 0;
	return self;
}

- (void) addObject:(id)anObject {
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
			CHTreeList_POP();  // deallocate wrappers for nodes pushed to the stack		
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
		CHTreeList_POP();
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rebalancing as we go
	BOOL isRightChild;
	while (parent != NULL) {
		isRightChild = (parent->right == current);
		skew(current);
		split(current);
		parent->link[isRightChild] = current;
		// Move to the next node up the path to the root
		current = parent;
		parent = CHTreeList_TOP;
		CHTreeList_POP();
	}
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	/*
	sentinel->object = anObject;
	
	CHTreeNode *current = header->right;
	CHTreeNode *nodeToDelete = NULL;
	CHTreeListNode *stack = NULL;
	CHTreeListNode *tmp;
	NSComparisonResult comparison;
	
	while (current != sentinel) {
		CHTreeList_PUSH(current);
		comparison = [(current->object) compare:anObject];
		if (comparison == NSOrderedDescending)
			current = current->left;
		else  {
			if (comparison == NSOrderedSame)
				nodeToDelete = current;
			current = current->right;
		}
	}
	if (nodeToDelete == sentinel) {  // the specified object was not found
		while (stack != NULL)
			CHTreeList_POP();  // deallocate wrappers for nodes pushed to the stack
		return;
	}

	current = CHTreeList_TOP;
	CHTreeList_POP();
	nodeToDelete->object = current->object;
	nodeToDelete->level = current->level;
	// TODO: Is this where the malloced struct for the node needs to be freed?
	current = current->right;
			
	CHTreeNode *previous = NULL;
	while (stack != NULL)  {
		current = CHTreeList_TOP;
		CHTreeList_POP();
		if (previous != sentinel) {
			if ([current->object compare:previous->object] == NSOrderedAscending)
				current->right = previous;
			else
				current->left = previous;
		}
		if ((current->left != sentinel && current->left->level < current->level - 1) || 
			(current->right != sentinel && current->right->level < current->level - 1)) 
		{
			--(current->level);
			if (current->right->level > current->level)
				current->right->level = current->level;
			current               = _skew(current);
			current->right        = _skew(current->right);
			current->right->right = _skew(current->right->right);
			current               = _split(current);
			current->right        = _split(current->right);
		}
		previous = current;
	}
	header->right = current;
	--count;
	++mutations;
	*/
}

- (NSString*) debugDescription {
	NSMutableString *description = [NSMutableString stringWithFormat:
	                                @"<%@: 0x%x> = {\n", [self class], self];
	CHTreeNode *current;
	CHTreeListNode *queue = NULL, *queueTail = NULL, *tmp;
	CHTreeList_ENQUEUE(header->right);
	
	while (current != sentinel && queue != NULL) {
		current = CHTreeList_FRONT;
		CHTreeList_DEQUEUE();
		if (current->left != sentinel)
			CHTreeList_ENQUEUE(current->left);
		if (current->right != sentinel)
			CHTreeList_ENQUEUE(current->right);
		// Append entry for the current node, including color and children
		[description appendFormat:@"\t%d : %@ -> %@ and %@\n",
		 current->level, current->object,
		 current->left->object, current->right->object];
	}
	[description appendString:@"}"];
	return description;
}

@end
