//  CHMutableArrayStack.m
//  CHDataStructures.framework

/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

#import "CHMutableArrayStack.h"

@implementation CHMutableArrayStack

- (void) pushObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	else
		[array addObject:anObject];
}

- (id) topObject {
	@try {
		return [array lastObject];
	}
	@catch (NSException *exception) {}
	return nil;
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

/**
 This overridden method returns the array contents in reverse order, like a stack.
 */
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
