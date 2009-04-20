/*
 CHDataStructures.framework -- CHMutableArrayStack.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHMutableArrayStack.h"

@implementation CHMutableArrayStack

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil) return nil;
	[array addObjectsFromArray:anArray];
	return self;
}

- (void) pushObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	else
		[array addObject:anObject];
}

- (id) topObject {
	return [array lastObject];
}

- (void) popObject {
	@try {
		[array removeLastObject];	
	}
	@catch (NSException *exception) {}
}

- (NSArray*) allObjects {
	return [[array reverseObjectEnumerator] allObjects];
}

- (NSEnumerator*) objectEnumerator {
	return [array reverseObjectEnumerator];  // top of stack is at the back
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [array objectEnumerator];         // bottom of stack is at the front
}

- (NSString*) description {
	return [[self allObjects] description];
}

#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

// Overrides parent's behavior to return the array contents in reverse order.
/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.

 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 @see NSFastEnumeration protocol

 @attention Since the top of the stack is at the back of the array, rather than passing the call to <code>-countByEnumeratingWithState:objects:count:</code> straight through to the underlying array, we must obtain an NSEnumerator from @c -reverseObjectEnumerator and store it in the fast enumeration @c state struct. Unfortunately for this particular scenario, NSEnumerator objects only return one object per call from the NSFastEnumeration boilerplate, so it's actually slower than using an NSEnumerator directly. (CHCircularBufferStack is significantly more performant.)
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	if (state->state == 0)
		state->extra[4] = (unsigned long) [array reverseObjectEnumerator];
	NSEnumerator *enumerator = (NSEnumerator*) state->extra[4];
	
	// This hackish crap captures the mutation pointer for the underlying array.
	// (rdar://6730928 -- Problem with mutation and -reverseObjectEnumerator)
	if (state->state == 0) {
		[array countByEnumeratingWithState:state objects:stackbuf count:1];
		unsigned long *mutationsPtr = state->mutationsPtr;
		state->state = 0;
		NSUInteger count = [enumerator countByEnumeratingWithState:state objects:stackbuf count:len];
		state->mutationsPtr = mutationsPtr;
		return count;
	}
	return [enumerator countByEnumeratingWithState:state objects:stackbuf count:len];
}

// @}
@end
