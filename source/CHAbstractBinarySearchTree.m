//
//  CHAbstractBinarySearchTree.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import "CHAbstractBinarySearchTree_Internal.h"

// Definitions of extern variables from CHAbstractBinarySearchTree_Internal.h
size_t kCHBinaryTreeNodeSize = sizeof(CHBinaryTreeNode);

/**
 A dummy object that resides in the header node for a tree. Using a header node can simplify insertion logic by eliminating the need to check whether the root is null. The actual root of the tree is generally stored as the right child of the header node. In order to always proceed to the actual root node when traversing down the tree, instances of this class always return @c NSOrderedAscending when called as the receiver of the @c -compare: method.
 
 Since all header objects behave the same way, all search tree instances can share the same dummy header object. The singleton instance can be obtained via the \link #object +object\endlink method. The singleton is created once and persists for the duration of the program. Any calls to @c -retain, @c -release, or @c -autorelease will raise an exception. (Note: If garbage collection is enabled, any such calls are likely to be ignored or "optimized out" by the compiler before the object can respond anyway.)
 */
@interface CHSearchTreeHeaderObject : NSObject

@end

@implementation CHSearchTreeHeaderObject

/**
 Returns the singleton instance of this class. The singleton variable is defined in this file and is initialized only once.
 
 @return The singleton instance of this class.
 */
+ (instancetype)object {
	static CHSearchTreeHeaderObject *headerObject = nil;
	// Protecting the @synchronized block prevents unnecessary lock contention.
	if (headerObject == nil) {
		@synchronized([CHSearchTreeHeaderObject class]) {
			// Make sure the object wasn't created since we blocked on the lock.
			if (headerObject == nil) {
				headerObject = [[CHSearchTreeHeaderObject alloc] init];
			}
		}
	}
	return headerObject;
}

/**
 Always indicate that another given object should appear to the right side.
 
 @param otherObject The object to be compared to the receiver.
 @return @c NSOrderedAscending, indicating that traversal should go to the right child of the containing tree node.
 
 @warning The header object @b must be the receiver of the message (e.g. <code>[headerObject compare:anObject]</code>) in order to work correctly. Calling <code>[anObject compare:headerObject]</code> instead will almost certainly result in a crash.
 */
- (NSComparisonResult)compare:(id)otherObject {
	return NSOrderedAscending;
}

- (instancetype)retain {
	CHRaiseUnsupportedOperationException();
	return nil;
}

- (oneway void)release {
	CHRaiseUnsupportedOperationException();
}

- (instancetype)autorelease {
	CHRaiseUnsupportedOperationException();
	return nil;
}

@end

#pragma mark -

/**
 An NSEnumerator for traversing any CHAbstractBinarySearchTree subclass in a specified order.
 
 This enumerator implements only iterative (non-recursive) tree traversal algorithms for two main reasons:
 <ol>
 <li>Recursive algorithms cannot easily be stopped and resumed in the middle of a traversal.</li>
 <li>Iterative algorithms are usually faster since they reduce overhead from function calls.</li>
 </ol>
 
 Traversal state is stored in either a stack or queue using dynamically-allocated C structs and @c \#define pseudo-functions to increase performance and reduce the required memory footprint.
 
 Enumerators encapsulate their own state, and more than one enumerator may be active at once. However, if a collection is modified, any existing enumerators for that collection become invalid and will raise a mutation exception if any further objects are requested from it.
 */
@interface CHBinarySearchTreeEnumerator : NSEnumerator

@end

@implementation CHBinarySearchTreeEnumerator
{
	__strong id<CHSearchTree> searchTree; // The tree being enumerated.
	__strong CHBinaryTreeNode *current; // The next node to be enumerated.
	__strong CHBinaryTreeNode *sentinelNode; // Sentinel node in the tree.
	CHTraversalOrder traversalOrder; // Order in which to traverse the tree.
	NSUInteger remainingCount; ///< Number of elements in @a searchTree remaining to be enumerated.
	unsigned long mutationCount; // Stores the collection's initial mutation.
	unsigned long *mutationPtr; // Pointer for checking changes in mutation.
	
@private
	// Pointers and counters that are used for various tree traveral orderings.
	CHBinaryTreeStack_DECLARE();
	CHBinaryTreeQueue_DECLARE();
	// These macros are defined in CHAbstractBinarySearchTree_Internal.h
}

/**
 Create an enumerator which traverses a given (sub)tree in the specified order.
 
 @param tree The tree collection that is being enumerated. This collection is to be retained while the enumerator has not exhausted all its objects.
 @param root The root node of the @a tree whose elements are to be enumerated.
 @param sentinel The sentinel value used at the leaves of the specified @a tree.
 @param order The traversal order to use for enumerating the given @a tree.
 @param mutations A pointer to the collection's mutation count for invalidation.
 @return An initialized CHBinarySearchTreeEnumerator which will enumerate objects in @a tree in the order specified by @a order.
 */
- (instancetype)initWithTree:(id<CHSearchTree>)tree
						root:(CHBinaryTreeNode *)root
					sentinel:(CHBinaryTreeNode *)sentinel
			  traversalOrder:(CHTraversalOrder)order
			 mutationPointer:(unsigned long *)mutations
{
	if (!isValidTraversalOrder(order)) {
		CHRaiseInvalidArgumentException(@"Invalid traversal order");
	}
	self = [super init];
	if (self) {
		traversalOrder = order;
		searchTree = (root != sentinel) ? [tree retain] : nil;
		remainingCount = [searchTree count];
		if (traversalOrder == CHTraversalOrderLevelOrder) {
			CHBinaryTreeQueue_INIT();
			CHBinaryTreeQueue_ENQUEUE(root);
		} else {
			CHBinaryTreeStack_INIT();
			if (traversalOrder == CHTraversalOrderPreOrder) {
				CHBinaryTreeStack_PUSH(root);
			} else {
				current = root;
			}
		}
		sentinel->object = nil;
		sentinelNode = sentinel;
		mutationCount = *mutations;
		mutationPtr = mutations;
	}
	return self;
}

- (void)dealloc {
	[self _collectionExhausted];
	[super dealloc];
}

- (void)_collectionExhausted {
	if (searchTree != nil) {
		[searchTree release];
		searchTree = nil;
		current = nil;
		sentinelNode = nil;
		CHBinaryTreeStack_FREE(stack);
		CHBinaryTreeQueue_FREE(queue);
	}
}

- (NSArray *)allObjects {
	if (mutationCount != *mutationPtr) {
		CHRaiseMutatedCollectionException();
	}
	if (remainingCount == 0) {
		return @[];
	}
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:remainingCount];
	id anObject;
	while ((anObject = [self nextObject])) {
		[array addObject:anObject];
	}
	[searchTree release];
	searchTree = nil;
	return [array autorelease];
}

- (id)nextObject {
	if (mutationCount != *mutationPtr) {
		CHRaiseMutatedCollectionException();
	}
	if (searchTree == nil) {
		return nil;
	}
	
	switch (traversalOrder) {
		case CHTraversalOrderAscending: {
			if (stackSize == 0 && current == sentinelNode) {
				[self _collectionExhausted];
				return nil;
			} else {
				remainingCount--;
			}
			while (current != sentinelNode) {
				CHBinaryTreeStack_PUSH(current);
				current = current->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHBinaryTreeStack_POP(); // Save top node for return value
			NSAssert(current != nil, @"Illegal state, current should never be nil!");
			id tempObject = current->object;
			current = current->right;
			return tempObject;
		}
			
		case CHTraversalOrderDescending: {
			if (stackSize == 0 && current == sentinelNode) {
				[self _collectionExhausted];
				return nil;
			} else {
				remainingCount--;
			}
			while (current != sentinelNode) {
				CHBinaryTreeStack_PUSH(current);
				current = current->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHBinaryTreeStack_POP(); // Save top node for return value
			NSAssert(current != nil, @"Illegal state, current should never be nil!");
			id tempObject = current->object;
			current = current->left;
			remainingCount--;
			return tempObject;
		}
			
		case CHTraversalOrderPreOrder: {
			current = CHBinaryTreeStack_POP();
			if (current == NULL) {
				[self _collectionExhausted];
				return nil;
			} else {
				remainingCount--;
			}
			if (current->right != sentinelNode) {
				CHBinaryTreeStack_PUSH(current->right);
			}
			if (current->left != sentinelNode) {
				CHBinaryTreeStack_PUSH(current->left);
			}
			return current->object;
		}
			
		case CHTraversalOrderPostOrder: {
			// This algorithm from: http://www.johny.ca/blog/archives/05/03/04/
			if (stackSize == 0 && current == sentinelNode) {
				[self _collectionExhausted];
				return nil;
			} else {
				remainingCount--;
			}
			while (1) {
				while (current != sentinelNode) {
					CHBinaryTreeStack_PUSH(current);
					current = current->left;
				}
				NSAssert(stackSize > 0, @"Stack should never be empty!");
				// A null entry indicates that we've traversed the left subtree
				if (CHBinaryTreeStack_TOP != NULL) {
					current = CHBinaryTreeStack_TOP->right;
					CHBinaryTreeStack_PUSH(NULL);
					// TODO: How to not push a null pad for leaf nodes?
				} else {
					(void)CHBinaryTreeStack_POP(); // ignore the null pad
					CHBinaryTreeNode *temp = CHBinaryTreeStack_POP();
					return temp ? temp->object : nil;
				}
			}
		}
			
		case CHTraversalOrderLevelOrder: {
			current = CHBinaryTreeQueue_FRONT;
			CHBinaryTreeQueue_DEQUEUE();
			if (current == NULL) {
				[self _collectionExhausted];
				return nil;
			} else {
				remainingCount--;
			}
			if (current->left != sentinelNode) {
				CHBinaryTreeQueue_ENQUEUE(current->left);
			}
			if (current->right != sentinelNode) {
				CHBinaryTreeQueue_ENQUEUE(current->right);
			}
			return current->object;
		}
	}
}

@end

#pragma mark -

@implementation CHAbstractBinarySearchTree

- (void)dealloc {
	[self removeAllObjects];
	free(header);
	free(sentinel);
	[super dealloc];
}

- (instancetype)init {
	return [self initWithArray:@[]];
}

// This is the designated initializer for CHAbstractBinarySearchTree.
- (instancetype)initWithArray:(NSArray *)anArray {
	self = [super init];
	if (self) {
		count = 0;
		mutations = 0;
		sentinel = [self _createNodeWithObject:nil];
		sentinel->right = sentinel;
		sentinel->left = sentinel;
		header = [self _createNodeWithObject:[CHSearchTreeHeaderObject object]];
		[self _subclassSetup];
		[self addObjectsFromArray:anArray];
	}
	return self;
}

- (void)_subclassSetup {
	// This allows child classes to initialize their specific state on init.
}

- (CHBinaryTreeNode *)_createNodeWithObject:(nullable id)object {
	CHBinaryTreeNode *node = malloc(kCHBinaryTreeNodeSize);
	node->object = object;
	node->left = sentinel;
	node->right = sentinel;
	node->balance = 0; // Affects balancing info for any subclass (anonymous union)
	return node;
}

#pragma mark <NSCoding>

- (instancetype)initWithCoder:(NSCoder *)decoder {
	// Decode the array of objects and use it to initialize the tree's contents.
	return [self initWithArray:[decoder decodeObjectForKey:@"objects"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:[self allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder]
	               forKey:@"objects"];
}

#pragma mark <NSCopying> methods

- (instancetype)copyWithZone:(NSZone *)zone {
	id<CHSearchTree> newTree = [[[self class] allocWithZone:zone] init];
	for (id anObject in [self objectEnumeratorWithTraversalOrder:CHTraversalOrderLevelOrder]) {
		[newTree addObject:anObject];
	}
	return newTree;
}

#pragma mark <NSFastEnumeration>

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	CHBinaryTreeNode *current;
	CHBinaryTreeStack_DECLARE();
	
	// For the first call, start at leftmost node, otherwise the last saved node
	if (state->state == 0) {
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
		current = header->right;
		CHBinaryTreeStack_INIT();
	} else if (state->state == 1) {
		return 0;
	} else {
		current = (CHBinaryTreeNode *) state->state;
		stack = (CHBinaryTreeNode **) state->extra[0];
		stackCapacity = (NSUInteger) state->extra[1];
		stackSize = (NSUInteger) state->extra[2];
	}
	NSAssert(current != nil, @"Illegal state, current should never be nil!");
	
	// Accumulate objects from the tree until we reach all nodes or the maximum
	NSUInteger batchCount = 0;
	while ((current != sentinel || stackSize > 0) && batchCount < len) {
		while (current != sentinel) {
			CHBinaryTreeStack_PUSH(current);
			current = current->left;
		}
		current = CHBinaryTreeStack_POP(); // Save top node for return value
		NSAssert(current != nil, @"Illegal state, current should never be nil!");
		stackbuf[batchCount] = current->object;
		current = current->right;
		batchCount++;
	}
	
	if (current == sentinel && stackSize == 0) {
		CHBinaryTreeStack_FREE(stack);
		state->state = 1; // used as a termination flag
	} else {
		state->state    = (unsigned long) current;
		state->extra[0] = (unsigned long) stack;
		state->extra[1] = (unsigned long) stackCapacity;
		state->extra[2] = (unsigned long) stackSize;
	}
	return batchCount;
}

#pragma mark Concrete Implementations

- (void)addObjectsFromArray:(NSArray *)anArray {
	for (id anObject in anArray) {
		[self addObject:anObject];
	}
}

- (NSArray *)allObjects {
	return [self allObjectsWithTraversalOrder:CHTraversalOrderAscending];
}

- (NSArray *)allObjectsWithTraversalOrder:(CHTraversalOrder)order {
	return [[self objectEnumeratorWithTraversalOrder:order] allObjects];
}

- (id)anyObject {
	return (count > 0) ? header->right->object : nil;
	// In an empty tree, sentinel's object may be nil, but let's not chance it.
	// (Our -removeAllObjects nils the pointer, child's -removeObject: may not.)
}

- (BOOL)containsObject:(id)anObject {
	return ([self member:anObject] != nil);
}

- (NSUInteger)count {
	return count;
}

- (NSString *)description {
	return [[self allObjectsWithTraversalOrder:CHTraversalOrderAscending] description];
}

- (id)firstObject {
	sentinel->object = nil;
	CHBinaryTreeNode *current = header->right;
	while (current->left != sentinel) {
		current = current->left;
	}
	return current->object;
}

- (NSUInteger)hash {
	return CHHashOfCountAndObjects(count, [self firstObject], [self lastObject]);
}

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHSortedSet)]) {
		return [self isEqualToSortedSet:otherObject];
	} else {
		return NO;
	}
}

- (BOOL)isEqualToSearchTree:(id<CHSearchTree>)otherTree {
	return CHCollectionsAreEqual(self, otherTree);
}

- (BOOL)isEqualToSortedSet:(id<CHSortedSet>)otherSortedSet {
	return CHCollectionsAreEqual(self, otherSortedSet);
}

- (id)lastObject {
	sentinel->object = nil;
	CHBinaryTreeNode *current = header->right;
	while (current->right != sentinel) {
		current = current->right;
	}
	return current->object;
}

- (id)member:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	sentinel->object = anObject; // Make sure the target value is always "found"
	CHBinaryTreeNode *current = header->right;
	NSComparisonResult comparison;
	while ((comparison = [current->object compare:anObject])) {
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	return (current != sentinel) ? current->object : nil;
}

- (NSEnumerator *)objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraversalOrderAscending];
}

- (NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHBinarySearchTreeEnumerator alloc]
			 initWithTree:self
	                 root:header->right
	             sentinel:sentinel
	       traversalOrder:order
	      mutationPointer:&mutations] autorelease];
}

// Doesn't call -[NSGarbageCollector collectIfNeeded] -- lets the sender choose.
- (void)removeAllObjects {
	if (count == 0) {
		return;
	}
	++mutations;
	count = 0;
	
	// Remove each node from the tree and release the object it points to.
	// Use pre-order (depth-first) traversal for simplicity and performance.
	CHBinaryTreeStack_DECLARE();
	CHBinaryTreeStack_INIT();
	CHBinaryTreeStack_PUSH(header->right);
	
	CHBinaryTreeNode *current;
	while ((current = CHBinaryTreeStack_POP())) {
		if (current->right != sentinel) {
			CHBinaryTreeStack_PUSH(current->right);
		}
		if (current->left != sentinel) {
			CHBinaryTreeStack_PUSH(current->left);
		}
		[current->object release];
		free(current);
	}
	CHBinaryTreeStack_FREE(stack);
	header->right = sentinel; // With GC, this is sufficient to unroot the tree.
	sentinel->object = nil; // Make sure we don't accidentally retain an object.
}

// Incurs an extra search cost, but we don't know how the child class removes...
- (void)removeFirstObject {
	id object = [self firstObject];
	if (object) { // Avoid removing nil
		[self removeObject:object];
	}
}

// Incurs an extra search cost, but we don't know how the child class removes...
- (void)removeLastObject {
	id object = [self lastObject];
	if (object) { // Avoid removing nil
		[self removeObject:object];
	}
}

- (NSEnumerator *)reverseObjectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraversalOrderDescending];
}

- (NSSet *)set {
	NSMutableSet *set = [NSMutableSet new];
	for (id anObject in [self objectEnumeratorWithTraversalOrder:CHTraversalOrderPreOrder]) {
		[set addObject:anObject];
	}
	return [set autorelease];
}

/*
 \copydoc CHSortedSet::subsetFromObject:toObject:
 
 \see     CHSortedSet#subsetFromObject:toObject:
 
 \link    CHSortedSet#subsetFromObject:toObject: \endlink
 
 \attention This implementation tests objects for membership in the subset according to their sorted order. This worst-case input causes more work for self-balancing trees, and subsets of unbalanced trees will always degenerate to linked lists.
 */
- (id<CHSortedSet>)subsetFromObject:(id)start toObject:(id)end options:(CHSubsetConstructionOptions)options {
	// If both parameters are nil, return a copy containing all the objects.
	if (start == nil && end == nil) {
		return [[self copy] autorelease];
	}
	id<CHSortedSet> subset = [[[[self class] alloc] init] autorelease];
	if (count == 0) {
		return subset;
	}
	
	NSEnumerator *e;
	id anObject;
	
	if (start == nil) {
		// Start from the first object and add until we pass the end parameter.
		e = [self objectEnumeratorWithTraversalOrder:CHTraversalOrderAscending];
		while ((anObject = [e nextObject]) && [anObject compare:end] != NSOrderedDescending) {
			[subset addObject:anObject];
		}
	} else if (end == nil) {
		// Start from the last object and add until we pass the start parameter.
		e = [self objectEnumeratorWithTraversalOrder:CHTraversalOrderDescending];
		while ((anObject = [e nextObject]) && [anObject compare:start] != NSOrderedAscending) {
			[subset addObject:anObject];
		}
	} else {
		if ([start compare:end] == NSOrderedAscending) {
			// Include subset of objects between the range parameters.
			e = [self objectEnumeratorWithTraversalOrder:CHTraversalOrderAscending];
			while ((anObject = [e nextObject]) && [anObject compare:start] == NSOrderedAscending) {
				;
			}
			if (anObject) {
				do {
					[subset addObject:anObject];
				} while ((anObject = [e nextObject]) && [anObject compare:end] != NSOrderedDescending);
			}
		} else {
			// Include subset of objects NOT between the range parameters.
			e = [self objectEnumeratorWithTraversalOrder:CHTraversalOrderDescending];
			while ((anObject = [e nextObject]) && [anObject compare:start] != NSOrderedAscending) {
				[subset addObject:anObject];
			}
			e = [self objectEnumeratorWithTraversalOrder:CHTraversalOrderAscending];
			while ((anObject = [e nextObject]) && [anObject compare:end] != NSOrderedDescending) {
				[subset addObject:anObject];
			}
		}
	}
	// If the start and/or end value is to be excluded, remove before returning.
	if (start && (options & CHSubsetConstructionExcludeLowEndpoint)) {
		[subset removeObject:start];
	}
	if (end && (options & CHSubsetConstructionExcludeHighEndpoint)) {
		[subset removeObject:end];
	}
	return subset;
}


- (NSString *)debugDescription {
	NSMutableString *description = [NSMutableString stringWithFormat:
	                                @"<%@: 0x%p> = {\n", [self class], self];
	CHBinaryTreeNode *current;
	CHBinaryTreeStack_DECLARE();
	CHBinaryTreeStack_INIT();
	
	sentinel->object = nil;
	if (header->right != sentinel) {
		CHBinaryTreeStack_PUSH(header->right);
	}
	while ((current = CHBinaryTreeStack_POP())) {
		if (current->right != sentinel) {
			CHBinaryTreeStack_PUSH(current->right);
		}
		if (current->left != sentinel) {
			CHBinaryTreeStack_PUSH(current->left);
		}
		// Append entry for the current node, including children
		[description appendFormat:@"\t%@ -> \"%@\" and \"%@\"\n",
		 [self debugDescriptionForNode:current],
		 current->left->object, current->right->object];
	}
	CHBinaryTreeStack_FREE(stack);
	[description appendString:@"}"];
	return description;
}

- (NSString *)debugDescriptionForNode:(CHBinaryTreeNode *)node {
	return [NSString stringWithFormat:@"\"%@\"", node->object];
}

// Uses an iterative reverse pre-order traversal to generate the diagram so that
// DOT tools will render the graph as a binary search tree is expected to look.
- (NSString *)dotGraphString {
	NSMutableString *graph = [NSMutableString stringWithFormat:
							  @"digraph %@\n{\n", NSStringFromClass([self class])];
	if (header->right == sentinel) {
		[graph appendFormat:@"  nil;\n"];
	} else {
		NSString *leftChild, *rightChild;
		NSUInteger sentinelCount = 0;
		sentinel->object = nil;
		
		CHBinaryTreeNode *current;
		CHBinaryTreeStack_DECLARE();
		CHBinaryTreeStack_INIT();
		CHBinaryTreeStack_PUSH(header->right);
		// Uses a reverse pre-order traversal to make the DOT output look right.
		while ((current = CHBinaryTreeStack_POP())) {
			if (current->left != sentinel) {
				CHBinaryTreeStack_PUSH(current->left);
			}
			if (current->right != sentinel) {
				CHBinaryTreeStack_PUSH(current->right);
			}
			// Append entry for node with any subclass-specific customizations.
			[graph appendString:[self dotGraphStringForNode:current]];
			// Append entry for edges from current node to both its children.
			leftChild = (current->left->object == nil)
				? [NSString stringWithFormat:@"nil%lu", ++sentinelCount]
				: [NSString stringWithFormat:@"\"%@\"", current->left->object];
			rightChild = (current->right->object == nil)
				? [NSString stringWithFormat:@"nil%lu", ++sentinelCount]
				: [NSString stringWithFormat:@"\"%@\"", current->right->object];
			[graph appendFormat:@"  \"%@\" -> {%@;%@};\n",
			                    current->object, leftChild, rightChild];
		}
		CHBinaryTreeStack_FREE(stack);
		
		// Create entry for each null leaf node (each nil is modeled separately)
		for (NSUInteger i = 1; i <= sentinelCount; i++) {
			[graph appendFormat:@"  nil%lu [shape=point,fillcolor=black];\n", i];
		}
	}
	// Terminate the graph string, then return it
	[graph appendString:@"}\n"];
	return graph;
}

- (NSString *)dotGraphStringForNode:(CHBinaryTreeNode *)node {
	return [NSString stringWithFormat:@"  \"%@\";\n", node->object];
}

#pragma mark Unsupported Implementations

- (void)addObject:(id)anObject {
	CHRaiseUnsupportedOperationException();
}

- (void)removeObject:(id)element {
	CHRaiseUnsupportedOperationException();
}

@end
