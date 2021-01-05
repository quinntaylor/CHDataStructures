//
//  CHUtilTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHUtil.h>

@interface CHUtilTest : XCTestCase

@end

@implementation CHUtilTest

#define expectedReason(message) \
([NSString stringWithFormat:@"%s -- %@", __PRETTY_FUNCTION__, message])

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
	BOOL raisedException;
	@try {
		int idx = 5;
		int count = 4;
		CHRaiseIndexOutOfRangeExceptionIf(idx, >, count);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSRangeException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Index out of range: idx (5) > count (4)"));
	}
	XCTAssertTrue(raisedException);
}

- (void)testInvalidArgumentException {
	BOOL raisedException;
	@try {
		CHRaiseInvalidArgumentException(@"Some silly reason.");
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInvalidArgumentException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Some silly reason."));
	}
	XCTAssertTrue(raisedException);
}

- (void)testNilArgumentException {
	BOOL raisedException;
	id object = nil;
	@try {
		CHRaiseInvalidArgumentExceptionIfNil(object);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInvalidArgumentException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Invalid nil value: object"));
	}
	XCTAssertTrue(raisedException);
}

- (void)testMutatedCollectionException {
	BOOL raisedException;
	@try {
		CHRaiseMutatedCollectionException();
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSGenericException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Collection was mutated during enumeration"));
	}
	XCTAssertTrue(raisedException);
}

- (void)testUnsupportedOperationException {
	BOOL raisedException;
	@try {
		CHRaiseUnsupportedOperationException();
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInternalInconsistencyException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Unsupported operation"));
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
