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

/**
 Convenience function for raising an exception for an invalid range (index).
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 @param index The offending index passed to the receiver.
 @param elements The number of elements present in the receiver.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHIndexOutOfRangeException(Class theClass, SEL method,
                                       NSUInteger index, NSUInteger elements);

/**
 Convenience function for raising an exception on an invalid nil object argument.
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHNilArgumentException(Class theClass, SEL method);

/**
 Convenience function for raising an exception when a collection is mutated.
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHMutatedCollectionException(Class theClass, SEL method);

/**
 Convenience function for raising an exception for un-implemented functionality.
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
extern int CHUnsupportedOperationException(Class theClass, SEL method);

/**
 
 */
extern void CHQuietLog(NSString *format, ...);
