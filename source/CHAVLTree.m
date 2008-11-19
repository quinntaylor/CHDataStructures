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

// Two-way single rotation
static inline CHTreeNode* singleRotation(CHTreeNode *node, int dir) {
    CHTreeNode *save = node->link[!dir];
    node->link[!dir] = save->link[dir];
    save->link[dir] = node;
	return save;
}

// Two-way double rotation
static inline CHTreeNode* doubleRotation(CHTreeNode *node, int dir) {
    CHTreeNode *save = node->link[!dir]->link[dir];
    node->link[!dir]->link[dir] = save->link[!dir];
    save->link[!dir] = node->link[!dir];
    node->link[!dir] = save;
	
    save = node->link[!dir];
    node->link[!dir] = save->link[dir];
    save->link[dir] = node;
    return save;
}

static inline void adjustBalance(CHTreeNode *root, int dir, int bal) {
    CHTreeNode *n = root->link[dir];
    CHTreeNode *nn = n->link[!dir];
    if (nn->balance == 0)
        root->balance = n->balance = 0;
    else if (nn->balance == bal) {
        root->balance = -bal;
        n->balance = 0;
    } else { // nn->balance == -bal
        root->balance = 0;
        n->balance = bal;
    }
    nn->balance = 0;
}

@implementation CHAVLTree

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHTreeNode *parent, *save, *current = header;
	CHTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	CHTreeStack_INIT(stack);
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		CHTreeStack_PUSH(current);
		if (current == header)
			save = current->right;
		else if (current->balance != 0)
			save = current;
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	
	++mutations;
	[anObject retain]; // Must retain whether replacing value or adding new node
	if (current != sentinel) {
		// Replace the existing object with the new object.
		[current->object release];
		current->object = anObject;
		// No need to rebalance up the path since we didn't modify the structure
		free(stack);		
		return;
	} else {
		current = malloc(kCHTreeNodeSize);
		current->object = anObject;
		current->left   = sentinel;
		current->right  = sentinel;
		current->balance  = 0;
		++count;
		// Link from parent as the proper child, based on last comparison
		parent = CHTreeStack_POP;
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rebalancing as we go
	BOOL isRightChild;
	BOOL keepBalancing = YES;
	//depending on what header is, it might need to be the break point
	//for this while loop so that it will not try to rebalance it because it
	//will be horribly unbalanced
	while (keepBalancing && parent != header) {
		isRightChild = (parent->right == current);
		// Update the balance factor
		if (isRightChild)
			parent->balance++;
		else
			parent->balance--;
		
		if (parent == save) {
			// Rebalance if the balance factor is out of whack, then terminate
			if (abs(parent->balance) > 1) {
				CHTreeNode *node = parent->link[isRightChild];
				int bal = (isRightChild) ? +1 : -1;
				if (node->balance == bal) {
					parent->balance = node->balance = 0;
					parent = singleRotation(parent, !isRightChild);
				} else { // node->balance == -bal
					adjustBalance(parent, isRightChild, bal);
					parent = doubleRotation(parent, !isRightChild);
				}
			}
			keepBalancing = NO;
		}
		// Move to the next node up the path to the root
		current = parent;
		parent = CHTreeStack_POP;
		// Link from parent as the proper child, based on last comparison
		comparison = [parent->object compare:current->object];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	free(stack);
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (count == 0)
		return;

	CHTreeNode *parent, *current = header;
	CHTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	CHTreeStack_INIT(stack);

	sentinel->object = anObject; // Assure that we stop at a leaf if not found.
	NSComparisonResult comparison;
	// Search down the node for the tree and save the path
	while (comparison = [current->object compare:anObject]) {
		CHTreeStack_PUSH(current);
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	// Exit if the specified node was not found in the tree.
	if (current == sentinel) {
		free(stack);
		return;
	}
	
	[current->object release]; // Object must be released in any case
	--count;
	++mutations;
	CHTreeNode *replacement;
	BOOL isRightChild;
	if (current->left == sentinel || current->right == sentinel) {
		// Single/zero child case -- replace node with non-nil child (if exists)
		replacement = current->link[current->left == sentinel];
		parent = CHTreeStack_POP;
		isRightChild = (parent->right == current);
		parent->link[isRightChild] = replacement;
		free(current);
		current = replacement;
	} else {
		// Two child case -- replace with minimum object in right subtree
		CHTreeStack_PUSH(current); // Need to start here when rebalancing
		replacement = current->right;
		while (replacement->left != sentinel) {
			CHTreeStack_PUSH(replacement);
			replacement = replacement->left;
		}
		// Grab object from replacement node, steal its right child, deallocate
		current->object = replacement->object;
		parent = CHTreeStack_POP;
		isRightChild = (parent->right == replacement);
		parent->link[isRightChild] = replacement->right;
		current = replacement->right;
		free(replacement);
	}
	
	// Trace back up the search path, rebalancing as we go until we're done
	BOOL done = NO;
	while (!done && elementsInStack > 0) {
		// Update the balance factor
		if (isRightChild)
			parent->balance--;
		else
			parent->balance++;
		// If the subtree heights differ by more than 1, rebalance them
		if (parent->balance > 1 || parent->balance < -1) {
			CHTreeNode *node = parent->link[!isRightChild];
			int bal = (isRightChild) ? +1 : -1;
			if (node->balance == -bal) {
				parent->balance = node->balance = 0;
				parent = singleRotation(parent, isRightChild);
			}
			else if (node->balance == bal) {
				adjustBalance(parent, !isRightChild, -bal);
				parent = doubleRotation(parent, isRightChild);
			}
			else { // node->balance == 0
				parent->balance = -bal;
				node->balance = bal;
				parent = singleRotation(parent, isRightChild);
				done = YES;
			}
			comparison = [CHTreeStack_TOP->object compare:parent->object];
			CHTreeStack_TOP->link[comparison == NSOrderedAscending] = parent;
		}
		else if (parent->balance != 0)
			break;

		current = parent;
		parent = CHTreeStack_POP;
		isRightChild = (parent->right == current);
	}
	free(stack);
}

- (NSString*) debugDescriptionForNode:(CHTreeNode*)node {
	return [NSString stringWithFormat:@"[%2d]\t\"%@\"",
			node->balance, node->object];
}

- (NSString*) dotStringForNode:(CHTreeNode*)node {
	return [NSString stringWithFormat:@"  \"%@\" [label=\"%@\\n%d\"];\n",
			node->object, node->object, node->balance];
}

@end
