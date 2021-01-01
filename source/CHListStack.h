/*
 CHDataStructures.framework -- CHListStack.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 */

#import <CHDataStructures/CHStack.h>
#import <CHDataStructures/CHAbstractListCollection.h>

/**
 @file CHListStack.h
 A simple CHStack implemented using a CHSinglyLinkedList.
 */

/**
 A simple CHStack implemented using a CHSinglyLinkedList. A singly-linked list is a natural choice since objects are only inserted and removed at the top of the stack, which is easily modeled as the head of a linked list. Enumerating from the top of the stack to the bottom also follows the natural ordering of a linked list.
 */
@interface CHListStack : CHAbstractListCollection <CHStack>

@end
