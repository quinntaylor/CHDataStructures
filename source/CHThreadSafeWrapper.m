/*
 CHThreadSafeWrapper.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2009, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 
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

#import "CHThreadSafeWrapper.h"

@implementation CHThreadSafeWrapper

- (void) dealloc {
	[object release];
	[lock release];
	[super dealloc];
}

- (id) init {
	return [self initWithObject:nil];
}

- (id) initWithObject:(id)anObject {
	if ([super init] == nil) return nil;
	if (anObject == nil)
		CHInvalidArgumentException([self class], _cmd,
								   @"Must provide a valid (non-nil) object.");
	object = [anObject retain];
	lock = [[NSLock alloc] init];
	return self;
}

- (id) object {
	return object;
}

// See documentation for -[NSObject respondsToSelector:]
- (BOOL) respondsToSelector:(SEL)aSelector {
	return [object respondsToSelector:aSelector];
}

// See documentation for -[NSObject methodSignatureForSelector:]
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [object methodSignatureForSelector:aSelector];
}

// See documentation for -[NSObject forwardInvocation:]
- (void) forwardInvocation:(NSInvocation *)anInvocation {
//	CHQuietLog(@"-forwardInvocation for -[%@ %s]", [object class], [anInvocation selector]);
	[lock lock];
    [anInvocation invokeWithTarget:object];
    [lock unlock];
}

@end
