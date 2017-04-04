//
// Created by neo on 2017/3/2.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TreeNode : NSObject


/**
 * parent node
 */

@property(nonatomic, strong) TreeNode *parentNode;

/**
 * sub nodes
 */
@property(nonatomic, strong) NSArray<TreeNode *> *childNodes;

/**
 * deep of tree
 */
@property(nonatomic, assign) NSUInteger level;


@property(nonatomic, assign) BOOL expand;

/**
 *
 */
@property(nonatomic, strong) id customData;

@end