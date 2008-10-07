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

//  ArrayStack.m
//  DataStructuresFramework

#import "ArrayStack.h"

@implementation ArrayStack

- (void) dealloc {
	[array release];
	[super dealloc];
}

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[NSMutableArray alloc] init];
	return self;
}

/**
 Private initializer for NSCopying; makes a mutable copy of the array
 */
- (id) initWithArray:(NSArray*)anArray {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [anArray mutableCopy];
	return self;
}

// Additional method in this implementation
- (id) initWithCapacity:(NSUInteger)capacity {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[NSMutableArray alloc] initWithCapacity:capacity];
	return self;
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[decoder decodeObjectForKey:@"ArrayStack"] retain];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:array forKey:@"ArrayStack"];
}

#pragma mark Stack Implementation

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

- (void) removeAllObjects {
	[array removeAllObjects];
}

- (NSArray*) allObjects {
	return [array copy];
}

- (NSUInteger) count {
	return [array count];
}

- (BOOL) containsObject:(id)anObject {
	return [array containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([array indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSEnumerator*) objectEnumerator {
	return [array reverseObjectEnumerator];  // top of stack is at the back
}

// Additional method in this implementation
- (NSEnumerator*) reverseObjectEnumerator {
	return [array objectEnumerator];         // bottom of stack is at the front
}

#pragma mark <NSCopying> Methods

- (id) copyWithZone:(NSZone *)zone {
	return [[ArrayStack alloc] initWithArray:array];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(id*)stackbuf
                                    count:(NSUInteger)len
{
	return [array countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
