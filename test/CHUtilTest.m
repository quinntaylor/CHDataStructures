/*
 CHDataStructures.framework -- CHUtilTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHUtil.h>

@interface CHUtilTest : XCTestCase {
	Class aClass;
	SEL aMethod;
	NSMutableString *reason;
	BOOL raisedException;
}

@end

@implementation CHUtilTest

- (void)setUp {
	aClass = [NSObject class];
	aMethod = @selector(foo:bar:);
	reason = [NSMutableString stringWithString:@"[NSObject foo:bar:] -- "];
	raisedException = NO;
}

- (void)testCollectionsAreEqual {
	NSArray *array = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:array forKeys:array];
	NSSet *set = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	
	XCTAssertTrue(collectionsAreEqual(nil, nil));
	
	XCTAssertTrue(collectionsAreEqual(array, array));
	XCTAssertTrue(collectionsAreEqual(dict, dict));
	XCTAssertTrue(collectionsAreEqual(set, set));

	XCTAssertTrue(collectionsAreEqual(array, [array copy]));
	XCTAssertTrue(collectionsAreEqual(dict, [dict copy]));
	XCTAssertTrue(collectionsAreEqual(set, [set copy]));
	
	XCTAssertFalse(collectionsAreEqual(array, nil));
	XCTAssertFalse(collectionsAreEqual(dict, nil));
	XCTAssertFalse(collectionsAreEqual(set, nil));

	id obj = [NSString string];
	XCTAssertThrowsSpecificNamed(collectionsAreEqual(array, obj), NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed(collectionsAreEqual(dict, obj), NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed(collectionsAreEqual(set, obj), NSException, NSInvalidArgumentException);
}

- (void)testIndexOutOfRangeException {
	@try {
		CHIndexOutOfRangeException(aClass, aMethod, 4, 4);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSRangeException);
		[reason appendString:@"Index (4) beyond bounds for count (4)"];
		XCTAssertEqualObjects([e reason], reason);
	}
	XCTAssertTrue(raisedException);
}

- (void)testInvalidArgumentException {
	@try {
		CHInvalidArgumentException(aClass, aMethod, @"Some silly reason.");
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInvalidArgumentException);
		[reason appendString:@"Some silly reason."];
		XCTAssertEqualObjects([e reason], reason);
	}
	XCTAssertTrue(raisedException);
}

- (void)testNilArgumentException {
	@try {
		CHNilArgumentException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInvalidArgumentException);
		[reason appendString:@"Invalid nil argument"];
		XCTAssertEqualObjects([e reason], reason);
	}
	XCTAssertTrue(raisedException);
}

- (void)testMutatedCollectionException {
	@try {
		CHMutatedCollectionException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSGenericException);
		[reason appendString:@"Collection was mutated during enumeration"];
		XCTAssertEqualObjects([e reason], reason);
	}
	XCTAssertTrue(raisedException);
}

- (void)testUnsupportedOperationException {
	@try {
		CHUnsupportedOperationException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInternalInconsistencyException);
		[reason appendString:@"Unsupported operation"];
		XCTAssertEqualObjects([e reason], reason);
	}
	XCTAssertTrue(raisedException);
}

- (void)testCHQuietLog {
	// Can't think of a way to verify stdout, so I'll just exercise all the code
	CHQuietLog(@"Hello, world!");
	CHQuietLog(@"Hello, world! I accept specifiers: %@ instance at 0x%x.",
			   [self class], self);
	CHQuietLog(nil);
}

@end
