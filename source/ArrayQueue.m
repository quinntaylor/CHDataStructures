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

//  ArrayQueue.m
//  Data Structures Framework

#import "ArrayQueue.h"

@implementation ArrayQueue

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
	array = [[decoder decodeObjectForKey:@"ArrayQueue"] retain];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:array forKey:@"ArrayQueue"];
}

#pragma mark Queue Implementation

- (void) addObject: (id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	else
		[array addObject:anObject];
}

- (id) nextObject {
	@try {
		return [array objectAtIndex:0];
	}
	@catch (NSException *exception) {}
	return nil;
}

- (void) removeNextObject {
	@try {
		[array removeObjectAtIndex:0];
	}
	@catch (NSException *exception) {}
}

- (NSArray*) allObjects {
	return [array copy];
}

- (NSUInteger) count {
	return [array count];
}

- (void) removeAllObjects {
	[array removeAllObjects];
}

- (NSEnumerator*) objectEnumerator {
	return [array objectEnumerator];
}

// Additional method in this implementation
- (NSEnumerator*) reverseObjectEnumerator {
	return [array reverseObjectEnumerator];
}

#pragma mark <NSCopying> Methods

- (id) copyWithZone:(NSZone *)zone {
	return [[ArrayQueue alloc] initWithArray:array];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(id*)stackbuf
                                    count:(NSUInteger)len
{
	return [array countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
