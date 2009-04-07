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

// Overrides parent's behavior to return the array contents in reverse order.
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

@end
