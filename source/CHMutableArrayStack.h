/*
 CHDataStructures.framework -- CHMutableArrayStack.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHStack.h"
#import "CHAbstractMutableArrayCollection.h"

/**
 @file CHMutableArrayStack.h
 A simple CHStack implemented using an NSMutableArray.
 */

/**
 A simple CHStack implemented using an NSMutableArray. This stack is modeled with the top being the last element in the array, since insertion and removal in an array are much faster at the back than the front. Accordingly, most operations are mirror-image of those in the parent class but just as fast, with the notable exception of NSFastEnumeration.
 
 Rather than passing the call to <code>-countByEnumeratingWithState:objects:count:</code> straight through to the underlying array, we must obtain an NSEnumerator from @c -reverseObjectEnumerator and store it in the fast enumeration @c state struct. Unfortunately for this particular scenario, NSEnumerator objects only return one object per call from the NSFastEnumeration boilerplate, so it's actually slower than using an NSEnumerator directly.
 
 Most users will prefer the performance improvements in CHCircularBufferStack.
 */
@interface CHMutableArrayStack : CHAbstractMutableArrayCollection <CHStack>

@end
