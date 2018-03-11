//
// Created by neo on 2017/11/30.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TreeMapGridView, TreeNode;
@protocol TreeMapGridViewDelegate, TreeMapGridViewDataSource;

@interface TreeMapGridView : UIView

@property(nonatomic, weak, nullable) id <TreeMapGridViewDelegate> delegate;
@property(nonatomic, weak, nullable) id <TreeMapGridViewDataSource> dataSource;

- (void)reloadData;

- (UICollectionView *)collectionView;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forTreeNode:(TreeNode *)treeNode;

@end

@protocol TreeMapGridViewDelegate <NSObject>

- (void)gridView:(TreeMapGridView *)gridView didSelectCell:(TreeNode *)treeNode;

- (void)gridViewDidScroll:(TreeMapGridView *)gridView;

/**
 * cell position weight
 * e.g. cell A1, A2, A3 under a common ancestor with wight 1, 2, 3, will share 1/6, 2/6, 3/6 of their ancestor's position.
 * @param gridView gridView requesting the cell weight.
 * @param treeNode  treeNode
 * @return cell position weight
 */
- (CGFloat)gridView:(TreeMapGridView *)gridView cellWeightForNode:(TreeNode *)treeNode;


/**
 * height of row in specified level
 * @param gridView gridView requesting the cell height information.
 * @param level    level
 * @return row height
 */
- (CGFloat)gridView:(TreeMapGridView *)gridView heightAtLevel:(NSUInteger)level;

@end

@protocol TreeMapGridViewDataSource <NSObject>

- (NSArray<TreeNode *> *)gridViewRootCells:(TreeMapGridView *)gridView;

- (UICollectionViewCell *)gridView:(TreeMapGridView *)gridView cellForRowAtTreeNode:(TreeNode *)treeNode;

@optional

- (BOOL)gridView:(TreeMapGridView *)gridView node:(TreeNode *)treeNode1 equalToNode:(TreeNode *)treeNode2;

@end

