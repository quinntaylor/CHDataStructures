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

/* Two way single rotation */
#define singleRotation(root,dir) {             \
CHTreeNode *save = root->link[!dir]; \
root->link[!dir] = save->link[dir];      \
save->link[dir] = root;                  \
root = save;                             \
}

/* Two way double rotation */
#define doubleRotation(root,dir) {                        \
CHTreeNode *save = root->link[!dir]->link[dir]; \
root->link[!dir]->link[dir] = save->link[!dir];     \
save->link[!dir] = root->link[!dir];                \
root->link[!dir] = save;                            \
save = root->link[!dir];                            \
root->link[!dir] = save->link[dir];                 \
save->link[dir] = root;                             \
root = save;                                        \
}

/* Adjust balance before double rotation */
#define adjustBalance(root,dir,bal) { \
	CHTreeNode *n = root->link[dir];     \
	CHTreeNode *nn = n->link[!dir];      \
	if ( nn->balance == 0 )                  \
		root->balance = n->balance = 0;        \
		else if ( nn->balance == bal ) {         \
		root->balance = -bal;                  \
		n->balance = 0;                        \
	}                                        \
	else { /* nn->balance == -bal */         \
		root->balance = 0;                     \
		n->balance = bal;                      \
	}                                        \
	nn->balance = 0;                         \
}

/* Rebalance after insertion */
#define insertBalance(root,dir) {     \
	CHTreeNode *n = root->link[dir];     \
	int bal = dir == 0 ? -1 : +1;            \
	if ( n->balance == bal ) {               \
		root->balance = n->balance = 0;        \
		singleRotation( root, !dir );             \
	}                                        \
	else { /* n->balance == -bal */          \
		adjustBalance( root, dir, bal ); \
		doubleRotation( root, !dir );             \
	}                                        \
}

@implementation CHAVLTree

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHTreeNode *parent, *save, *current = header;
	CHTreeListNode *stack = NULL, *tmp;
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		CHTreeList_PUSH(current);
		if(current != header)
		{
			if(current->balance != 0)
				save = current;
		}
		else
			save = current->right;
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
		current->balance  = 0;
		++count;
		// Link from parent as the proper child, based on last comparison
		parent = CHTreeList_TOP;
		CHTreeList_POP;
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rebalancing as we go
	BOOL isRightChild;
	BOOL stopBalancing = 0;
	//depending on what header is, it might need to be the break point
	//for this while loop so that it will not try to rebalance it because it
	//will be horribly unbalanced
	while (parent != header) {
		isRightChild = (parent->right == current);
		//determine the balance modification
		
		if(!stopBalancing)
		{
			if(isRightChild)
				parent->balance++;
			else
				parent->balance--;
		}
		if(parent == save)
			
		
		//terminate or rebalance as necessary
		//if the balance factor is out of wack
			if(parent == save) {
				if(parent->balance > 1 || parent->balance < -1) {
					insertBalance(parent, isRightChild);
				}
				stopBalancing = 1;
			}
		// Move to the next node up the path to the root
		current = parent;
		parent = CHTreeList_TOP;
		CHTreeList_POP;
		
		//need to link the parent to the current
		comparison = [parent->object compare:current->object];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	//as long as the headers object value is always less than the middle of the
	//tree this will work, what is teh default value?
	//parent->right = current
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);

	CHUnsupportedOperationException([self class], _cmd); // TODO: Remove this
}

@end
