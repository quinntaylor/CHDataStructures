/*
 CHAbstractTree.m
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

#import "CHAbstractTree.h"

// Definitions of variables declared as 'extern' in CHAbstractTree.h
NSUInteger kCHTreeNodeSize = sizeof(CHTreeNode);
NSUInteger kPointerSize = sizeof(void*);

@implementation CHAbstractTree

- (void) dealloc {
	[self removeAllObjects];
	free(header);
	free(sentinel);
	[super dealloc];
}

- (void) finalize {
	[self removeAllObjects];
	free(header);
	free(sentinel);
	[super finalize];
}

/**
 Only to be called from concrete child classes to initialize shared variables.
 */
- (id) init {
	if ([super init] == nil) return nil;
	count = 0;
	mutations = 0;
	
	sentinel = malloc(kCHTreeNodeSize);
	sentinel->object = nil;
	sentinel->right = sentinel;
	sentinel->left = sentinel;
	
	header = malloc(kCHTreeNodeSize);
	header->object = [CHTreeHeaderObject headerObject];
	header->left = sentinel;
	header->right = sentinel;
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	// Allow concrete child class to have a chance to initialize its own state
	// Calls the concrete subclass' -init, which calls [super init] declared here
	if ([self init] == nil) return nil;
	for (id anObject in anArray)
		[self addObject:anObject];
	return self;
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given keyed unarchiver.
 
 @param decoder An keyed unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	// Allow concrete child class to have a chance to initialize its own state
	// Calls the concrete subclass' -init, which calls [super init] declared here
	if ([self init] == nil) return nil;
	for (id anObject in [decoder decodeObjectForKey:@"objects"])
		[self addObject:anObject];
	return self;
}

/**
 Encodes the receiver using a given keyed archiver.
 
 @param encoder An keyed archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	NSEnumerator *e = [self objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	[encoder encodeObject:[e allObjects] forKey:@"objects"];
}

#pragma mark <NSCopying> methods

/**
 Returns a new instance that's a copy of the receiver. Invoked automatically by
 the default <code>-copy</code> method inherited from NSObject.
 
 @param zone Identifies an area of memory from which to allocate the new
        instance. If zone is <code>NULL</code>, the new instance is allocated
        from the default zone. (<code>-copy</code> invokes with a NULL param.)
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. Since the nature of storing data in trees is always the same,
 copies returned by this method are always mutable.
 */
- (id) copyWithZone:(NSZone *)zone {
	id<CHTree> newTree = [[[self class] alloc] init];
	NSEnumerator *e = [self objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	for (id anObject in e)
		[newTree addObject:anObject];
	return newTree;
}

#pragma mark <NSFastEnumeration> Methods

/**
 A method for NSFastEnumeration, called by <code><b>for</b> (type variable
 <b>in</b> collection)</code> constructs.
 
 @param state Context information that is used in the enumeration to ensure that
        the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHTreeNode *current;
	CHTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	
	// For the first call, start at leftmost node, otherwise the last saved node
	if (state->state == 0) {
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
		current = header->right;
		CHTreeStack_INIT(stack);
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		current = (CHTreeNode*) state->state;
		stack = (CHTreeNode**) state->extra[0];
		stackSize = (NSUInteger) state->extra[1];
		elementsInStack = (NSUInteger) state->extra[2];
	}
	
	// Accumulate objects from the tree until we reach all nodes or the maximum
	NSUInteger batchCount = 0;
	while ( (current != sentinel || elementsInStack > 0) && batchCount < len) {
		while (current != sentinel) {
			CHTreeStack_PUSH(current);
			current = current->left;
			// TODO: How to not push/pop leaf nodes unnecessarily?
		}
		current = CHTreeStack_POP; // Save top node for return value
		stackbuf[batchCount] = current->object;
		current = current->right;
		batchCount++;
	}
	
	if (current == sentinel && elementsInStack == 0) {
		free(stack);
		state->state = 1; // used as a termination flag
	}
	else {
		state->state = (unsigned long) current;
		state->extra[0] = (unsigned long) stack;
		state->extra[1] = (unsigned long) stackSize;
		state->extra[2] = (unsigned long) elementsInStack;
	}
	return batchCount;
}

#pragma mark Concrete Implementations

- (NSArray*) allObjects {
	return [self allObjectsWithTraversalOrder:CHTraverseAscending];
}

- (NSArray*) allObjectsWithTraversalOrder:(CHTraversalOrder)order {
	return [[self objectEnumeratorWithTraversalOrder:order] allObjects];
}

- (BOOL) containsObject:(id)anObject {
	return ([self findObject:anObject] != nil);
}

- (NSUInteger) count {
	return count;
}

- (NSString*) description {
	return [[self allObjectsWithTraversalOrder:CHTraverseAscending] description];
}

- (id) findMax {
	sentinel->object = nil;
	CHTreeNode *current = header->right;
	while (current->right != sentinel)
		current = current->right;
	return current->object;
}

- (id) findMin {
	sentinel->object = nil;
	CHTreeNode *current = header->right;
	while (current->left != sentinel)
		current = current->left;
	return current->object;
}

- (id) findObject:(id)anObject {
	if (anObject == nil)
		return nil;
	sentinel->object = anObject; // Make sure the target value is always "found"
	CHTreeNode *current = header->right;
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) // while not equal
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	return (current != sentinel) ? current->object : nil;
}

/**
 Frees all nodes in the tree and releases the objects they point to. The pointer
 to the root node is reset to the sentinel, and element count is reset to zero.
 This method deletes nodes using a pre-order traversal by pushing child nodes on
 a stack. This approach generally requires less space than level-order traversal
 since it is depth-first rather than breadth-first, and should be faster, too.
 */
- (void) removeAllObjects {
	if (count == 0)
		return;
	
	CHTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	CHTreeStack_INIT(stack);
	CHTreeStack_PUSH(header->right);

	CHTreeNode *current;
	while (current = CHTreeStack_POP) {
		if (current->right != sentinel)
			CHTreeStack_PUSH(current->right);
		if (current->left != sentinel)
			CHTreeStack_PUSH(current->left);
		[current->object release];
		free(current);
	}
	free(stack);

	header->right = sentinel;
	count = 0;
	++mutations;
}

- (NSEnumerator*) objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseAscending];
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHTreeEnumerator alloc] initWithTree:self
	                                          root:header->right
	                                      sentinel:sentinel
	                                traversalOrder:order
	                               mutationPointer:&mutations] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseDescending];
}

- (NSString*) debugDescription {
	NSMutableString *description = [NSMutableString stringWithFormat:
	                                @"<%@: 0x%x> = {\n", [self class], self];
	CHTreeNode *current;
	CHTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	CHTreeStack_INIT(stack);
	
	sentinel->object = nil;
	CHTreeStack_PUSH(header->right);	
	while (current = CHTreeStack_POP) {
		if (current->right != sentinel)
			CHTreeStack_PUSH(current->right);
		if (current->left != sentinel)
			CHTreeStack_PUSH(current->left);
		// Append entry for the current node, including children
		[description appendFormat:@"\t%@ -> %@ and %@\n",
		 current->object, current->left->object, current->right->object];
	}
	free(stack);
	[description appendString:@"}"];
	return description;
}

#pragma mark Unsupported Implementations

- (void) addObject:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
}

- (void) removeObject:(id)element {
	CHUnsupportedOperationException([self class], _cmd);
}

@end


#pragma mark -

@implementation CHTreeEnumerator

- (id) initWithTree:(id<CHTree>)tree
               root:(CHTreeNode*)root
           sentinel:(CHTreeNode*)sentinel
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order)) return nil;
	traversalOrder = order;
	collection = (root != sentinel) ? [tree retain] : nil;
	CHTreeStack_INIT(stack);
	CHTreeQueue_INIT(queue);
	if (traversalOrder == CHTraverseLevelOrder) {
		CHTreeQueue_ENQUEUE(root);
	} else if (traversalOrder == CHTraversePreOrder) {
		CHTreeStack_PUSH(root);
	} else {
		current = root;
	}
	sentinel->object = nil;
	sentinelNode = sentinel;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void) dealloc {
	[collection release];
	free(stack);
	free(queue);
	[super dealloc];
}

- (void) finalize {
	free(stack);	
	free(queue);
	[super finalize];
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	id object;
	while ((object = [self nextObject]))
		[array addObject:object];
	[collection release];
	collection = nil;
	return [array autorelease];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	
	switch (traversalOrder) {
		case CHTraverseAscending: {
			if (elementsInStack == 0 && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (current != sentinelNode) {
				CHTreeStack_PUSH(current);
				current = current->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHTreeStack_POP; // Save top node for return value
			id tempObject = current->object;
			current = current->right;
			return tempObject;
		}
			
		case CHTraverseDescending: {
			if (elementsInStack == 0 && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (current != sentinelNode) {
				CHTreeStack_PUSH(current);
				current = current->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHTreeStack_POP; // Save top node for return value
			id tempObject = current->object;
			current = current->left;
			return tempObject;
		}
			
		case CHTraversePreOrder: {
			current = CHTreeStack_POP;
			if (current == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			if (current->right != sentinelNode)
				CHTreeStack_PUSH(current->right);
			if (current->left != sentinelNode)
				CHTreeStack_PUSH(current->left);
			return current->object;
		}
			
		case CHTraversePostOrder: {
			// This algorithm from: http://www.johny.ca/blog/archives/05/03/04/
			if (elementsInStack == 0 && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (1) {
				while (current != sentinelNode) {
					CHTreeStack_PUSH(current);
					current = current->left;
				}
				// A null entry indicates that we've traversed the right subtree
				if (CHTreeStack_TOP != NULL) {
					current = CHTreeStack_TOP->right;
					CHTreeStack_PUSH(NULL);
					// TODO: How to not push a null pad for leaf nodes?
				}
				else {
					CHTreeStack_POP; // ignore the null pad
					return CHTreeStack_POP->object;
				}				
			}
		}
			
		case CHTraverseLevelOrder: {
			current = CHTreeQueue_FRONT;
			CHTreeQueue_DEQUEUE;
			if (current == NULL) {
				[collection release];
				collection = nil;
				free(queue);
				return nil;
			}
			if (current->left != sentinelNode)
				CHTreeQueue_ENQUEUE(current->left);
			if (current->right != sentinelNode)
				CHTreeQueue_ENQUEUE(current->right);
			return current->object;
		}
	}
	return nil;
}

@end

#pragma mark -

static CHTreeHeaderObject *headerObject = nil;

@implementation CHTreeHeaderObject

+ (id) headerObject {
	if (headerObject == nil)
		headerObject = [[CHTreeHeaderObject alloc] init];
	return headerObject;
}

- (NSComparisonResult) compare:(id)otherObject {
	return NSOrderedAscending;
}

@end
