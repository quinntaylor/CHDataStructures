/*
 CHDataStructures.framework -- CHUnbalancedTree.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 */

#import <CHDataStructures/CHAbstractBinarySearchTree.h>

/**
 @file CHUnbalancedTree.h
 A generic, unbalanced implementation of CHSearchTree.
 */

/**
 A simple unbalanced binary tree that <b>does not</b> guarantee O(log n) access. The algorithms for insertion and removal have been adapted from code in the <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_bst1.aspx"> Binary Search Trees tutorial</a>, which is in the public domain, courtesy of <a href="http://eternallyconfuzzled.com/">Julienne Walker</a>. Method names have been changed to match the APIs of existing Cocoa collections provided by Apple.
 
 Even though the tree is not balanced when items are added or removed, access is <b>at worst</b> linear if the tree essentially degenerates into a linked list. This class is fast, and without stack risk because it works without recursion.
 */
@interface CHUnbalancedTree : CHAbstractBinarySearchTree

@end
