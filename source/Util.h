/*
 Util.h
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

#import <Foundation/Foundation.h>

/**
 @file Util.h
 
 A group of utility C functions for simplifying common exceptions and logging.
 */

// Macro for reducing visibility of symbol names not indended to be exported.
#define HIDDEN __attribute__((visibility("hidden")))

// Macro for marking symbols a (potentially) unused to supress compile warnings.
#define UNUSED __attribute__((unused))

// Used for indicating that an object is not found when returning an NSUInteger.
#define CHNotFound NSUIntegerMax

/**
 Convenience function for raising an exception for an invalid range (index).
 
 @param aClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 @param index The offending index passed to the receiver.
 @param elements The number of elements present in the receiver.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHIndexOutOfRangeException(Class aClass, SEL method,
                                       NSUInteger index, NSUInteger elements);

/**
 Convenience function for raising an exception on an invalid argument.

 @param aClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 @param str An NSString describing the offending invalid argument.
 */
extern void CHInvalidArgumentException(Class aClass, SEL method, NSString *str);

/**
 Convenience function for raising an exception on an invalid nil object argument.
 
 @param aClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 
 @see CHInvalidArgumentException
 */
extern void CHNilArgumentException(Class aClass, SEL method);

/**
 Convenience function for raising an exception when a collection is mutated.
 
 @param aClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHMutatedCollectionException(Class aClass, SEL method);

/**
 Convenience function for raising an exception for un-implemented functionality.
 
 @param aClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHUnsupportedOperationException(Class aClass, SEL method);

/**
 Provides a more terse alternative to NSLog() which accepts the same parameters.
 The output is made shorter by excluding the date stamp and process information
 which NSLog prints before the actual specified output.
 
 @param format A format string, which must not be nil.
 @param ... A comma-separated list of arguments to substitute into @a format.
 
 Read <b>Formatting String Objects</b> and <b>String Format Specifiers</b> on
 <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/Strings/">
 this webpage</a> for details about using format strings. Look for examples that
 use <code>NSLog()</code>, since the parameters and syntax are idential.
 */
extern void CHQuietLog(NSString *format, ...);

/**
 A macro for including the source file and line number where a log occurred.

 @param format A format string, which must not be nil.
 @param ... A comma-separated list of arguments to substitute into @a format.
 
 This is defined as a compiler macro so it can automatically fill in the file
 name and line number where the call was made. After printing these values in
 brackets, this macro calls #CHQuietLog with @a format and any other arguments
 supplied afterward.
 */
#ifndef CHLocationLog
#define CHLocationLog(format,...) { \
	NSString *file = [[NSString alloc] initWithUTF8String:__FILE__]; \
	printf("[%s:%d] ", [[file lastPathComponent] UTF8String], __LINE__); \
	[file release]; \
	CHQuietLog((format),##__VA_ARGS__); \
}
#endif
