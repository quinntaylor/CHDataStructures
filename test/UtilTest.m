/*
 CHDataStructures.framework -- UtilTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "Util.h"

@interface UtilTest : SenTestCase {
	Class aClass;
	SEL aMethod;
	NSMutableString *reason;
	BOOL raisedException;
}

@end

@implementation UtilTest

- (void) setUp {
	aClass = [NSObject class];
	aMethod = @selector(foo:bar:);
	reason = [NSMutableString stringWithString:@"[NSObject foo:bar:] -- "];
	raisedException = NO;
}

- (void) testCollectionsAreEqual {
	NSArray *array = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:array forKeys:array];
	NSSet *set = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	
	STAssertTrue(collectionsAreEqual(nil, nil), nil);
	
	STAssertTrue(collectionsAreEqual(array, array), nil);
	STAssertTrue(collectionsAreEqual(dict, dict), nil);
	STAssertTrue(collectionsAreEqual(set, set), nil);

	STAssertTrue(collectionsAreEqual(array, [array copy]), nil);
	STAssertTrue(collectionsAreEqual(dict, [dict copy]), nil);
	STAssertTrue(collectionsAreEqual(set, [set copy]), nil);
	
	STAssertFalse(collectionsAreEqual(array, nil), nil);
	STAssertFalse(collectionsAreEqual(dict, nil), nil);
	STAssertFalse(collectionsAreEqual(set, nil), nil);

	id obj = [NSString string];
	STAssertThrowsSpecificNamed(collectionsAreEqual(array, obj),
	                            NSException, NSInvalidArgumentException, nil);
	STAssertThrowsSpecificNamed(collectionsAreEqual(dict, obj),
	                            NSException, NSInvalidArgumentException, nil);
	STAssertThrowsSpecificNamed(collectionsAreEqual(set, obj),
	                            NSException, NSInvalidArgumentException, nil);
}

- (void) testIndexOutOfRangeException {
	@try {
		CHIndexOutOfRangeException(aClass, aMethod, 4, 4);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSRangeException, nil);
		[reason appendString:@"Index (4) beyond bounds for count (4)"];
		STAssertEqualObjects([e reason], reason,  nil);
	}
	STAssertTrue(raisedException, nil);
}

- (void) testInvalidArgumentException {
	@try {
		CHInvalidArgumentException(aClass, aMethod, @"Some silly reason.");
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSInvalidArgumentException, nil);
		[reason appendString:@"Some silly reason."];
		STAssertEqualObjects([e reason], reason, nil);
	}
	STAssertTrue(raisedException, nil);
}

- (void) testNilArgumentException {
	@try {
		CHNilArgumentException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSInvalidArgumentException, nil);
		[reason appendString:@"Invalid nil argument"];
		STAssertEqualObjects([e reason], reason, nil);
	}
	STAssertTrue(raisedException, nil);
}

- (void) testMutatedCollectionException {
	@try {
		CHMutatedCollectionException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSGenericException, nil);
		[reason appendString:@"Collection was mutated during enumeration"];
		STAssertEqualObjects([e reason], reason, nil);
	}
	STAssertTrue(raisedException, nil);
}

- (void) testUnsupportedOperationException {
	@try {
		CHUnsupportedOperationException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSInternalInconsistencyException, nil);
		[reason appendString:@"Unsupported operation"];
		STAssertEqualObjects([e reason], reason, nil);
	}
	STAssertTrue(raisedException, nil);
}

- (void) testCHQuietLog {
	// Can't think of a way to verify stdout, so I'll just exercise all the code
	CHQuietLog(@"Hello, world!");
	CHQuietLog(@"Hello, world! I accept specifiers: %@ instance at 0x%x.",
			   [self class], self);
	CHQuietLog(nil);
}

@end
