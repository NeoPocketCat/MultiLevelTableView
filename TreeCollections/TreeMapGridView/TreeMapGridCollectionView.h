//
// Created by neo on 2017/12/3.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TreeGridCollectionViewDelegate, TreeGridCollectionViewDataSource;
@class TreeNode;


@interface TreeMapGridCollectionView : UICollectionView

@property(nonatomic, weak, nullable) id <TreeGridCollectionViewDelegate> delegate;
@property(nonatomic, weak, nullable) id <TreeGridCollectionViewDataSource> dataSource;

@end

@protocol TreeGridCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)cellWeightForNode:(TreeNode *)treeNode;

- (CGFloat)heightAtLevel:(NSUInteger)level;

@end

@protocol TreeGridCollectionViewDataSource <UICollectionViewDataSource>

- (NSArray<TreeNode *> *)orderedTreeNodes;

- (NSArray<TreeNode *> *)rootNodes;

- (TreeNode *)treeNodeAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexOfTreeNode:(TreeNode *)treeNode;

@end