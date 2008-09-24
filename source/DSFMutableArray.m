//
//  DSFMutableArray.m
//  DataStructuresFramework
//
//  Created by Phillip Morelock on Mon Apr 15 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "DSFMutableArray.h"

#define IDSIZE sizeof(id)

/**
 * Rounds to a multiple of 32.  Rounds up.
 */
static int roundUpToMultOf32(int toBeRounded)
{
    if (toBeRounded > 0x00000040)
    {
        toBeRounded = (toBeRounded / 32);
        return ( (toBeRounded * 32) + 32 );
    }
    else if (toBeRounded < 32)
        return 0x00000020;
    else
        return 0x00000040;
}

/** 
 * Returns the new array base pointer.  Checks for stupid conditions.
 * Warning: this will free the *base pointer.  Watch out.
 */
static id * doubleArray(id *base, int presentCapacity, int top, int *newCapacityRetval)
{
    id *newBase = NULL;
    int i = 0;

    if (base == NULL || presentCapacity < 32 || newCapacityRetval == nil || top > presentCapacity)
        exit(8);
    else if (presentCapacity == 0x00000020)
        *newCapacityRetval = 0x00000040;
    else if (presentCapacity == 0x00000040)
        *newCapacityRetval = 0x00000080;
    else
        *newCapacityRetval = 2 * presentCapacity;
    
    if ( (newBase = calloc(*newCapacityRetval, IDSIZE)) == NULL )
        exit(8);
    
    while (i <= top)
    {
        *(newBase + i) = *(base + (i + 1));
        ++i;
    }
    
    free(base);
    return newBase;
}


/****************
@interface DSFMutableArray : NSObject
{
    id *arrayBase;
    int upperBound;
    int currentTop;
}
************/

@implementation DSFMutableArray

-init
{
    return [self initWithCapacity:32];
}

//will be rounded to a multiple of 32
-initWithCapacity: (unsigned)capacity
{
    [super init];
    
    currentTop = -1;
    upperBound = roundUpToMultOf32(capacity) - 1;
    
    if ( (arrayBase = calloc( (upperBound + 1), IDSIZE )) == NULL)
        [NSException raise:@"Notenoughmemory" format:@"Notenoughmemory"];
    
    return self;
}

-(void)dealloc
{
    int i = 0;
    
    while (i <= currentTop)
    {
        [*(arrayBase + i) release];
        ++i;
    }

    free(arrayBase);
    [super dealloc];
}

-(void)insertObject: (id)anObject
            atIndex: (int)index
{
    int tmpCapac = upperBound + 1;
    int i = 0;
    
    //sanity check
    if ( index < 0 || index > (currentTop + 1) || anObject == nil )
        [NSException raise:@"Yourebeingstupid" format:@"Yourebeingstupid"];
    
    [anObject retain];
    
    //upper bound check -- if we're going to overflow, then increase arraysize.
    if ( (currentTop + 2) > upperBound)
        arrayBase = doubleArray(arrayBase, upperBound + 1, currentTop, &tmpCapac);
    
    //now we set our upper bound to the value of the pointer we put in there
    //subtract one because the upperBound of an array == size - 1.
    upperBound = tmpCapac - 1;
    ++currentTop;
    
    for (i = currentTop; i > index; --i)
        *(arrayBase + i) = *(arrayBase + i - 1);
    
    //now i should be == index
    *(arrayBase + index) = anObject;
    
}

-(void)addObject: (id)anObject
{
    //repeating the insert method here to avoid message overhead
    int tmpCapac = upperBound + 1;
    //sanity check
    if ( anObject == nil )
        [NSException raise:@"Yourebeingstupid" format:@"Yourebeingstupid"];
    
    [anObject retain];
    
    //upper bound check -- if we're going to overflow, then increase arraysize.
    if ( (currentTop + 2) > upperBound)
        arrayBase = doubleArray(arrayBase, upperBound + 1, currentTop, &tmpCapac);
    
    //now we set our upper bound to the value of the pointer we put in there
    //subtract one because the upperBound of an array == size - 1.
    upperBound = tmpCapac - 1;
    ++currentTop;
    
    *(arrayBase + currentTop) = anObject;
}

- objectAtIndex: (int)index
{
    if (index < 0 || index > currentTop)
        [NSException raise:@"Yourebeingstupid" format:@"Yourebeingstupid"];
    
    return *(arrayBase + index);
}

-(void)removeObjectatIndex: (int)index
{
    if (index < 0 || index > currentTop)
        [NSException raise:@"Yourebeingstupid" format:@"Yourebeingstupid"];
    
    [*(arrayBase + index) release];
    
    while (index < currentTop)
    {
        *(arrayBase + index) = *(arrayBase + index + 1);
        ++index;
    }
    
    --currentTop; //finally, decrement the topper
}

-(void)replaceObjectAtIndex: (int)index
            withObject: (id)anObject
{
    if (anObject == nil || index < 0 || index > currentTop)
        [NSException raise:@"Yourebeingstupid" format:@"Yourebeingstupid"];
    
    [anObject retain];
    [*(arrayBase + index) release];
    
    *(arrayBase + index) = anObject;
}

-(void)nilObjectAtIndex: (int)index
{    
    if (index < 0 || index > currentTop)
        [NSException raise:@"Yourebeingstupid" format:@"Yourebeingstupid"];

    [*(arrayBase + index) release];
    *(arrayBase + index) = nil;
}

@end
