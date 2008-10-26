/*
 CHMutableArrayStack.m
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

#import "CHMutableArrayStack.h"

@implementation CHMutableArrayStack

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil)
		return nil;
	for (id anObject in anArray)
		[array addObject:anObject];
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

// This overridden method returns the array contents in reverse order, like a stack.
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	if (state->state == 0)
		state->extra[4] = (unsigned long) [array reverseObjectEnumerator];
	NSEnumerator *enumerator = (NSEnumerator*) state->extra[4];
	// Currently (in Leopard) the NSEnumerators from NSArray only return 1 each time
	return [enumerator countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
