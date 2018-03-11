//
// Created by neo on 2017/11/30.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeMapGridView.h"
#import "TreeMapGridCollectionView.h"
#import "TreeMapGridLayout.h"
#import "TreeNode.h"

@interface TreeMapGridView () <TreeGridCollectionViewDelegate, TreeGridCollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray<TreeNode *> *treeNodeList;

@end


@implementation TreeMapGridView {
    NSArray<TreeNode *> *_rootNodes;
}

- (void)reloadData {
    if (![_dataSource respondsToSelector:@selector(gridViewRootCells:)]) {
        return;
    }
    NSMutableArray *treeNodeList = [NSMutableArray array];
    NSArray *rootNodes = [_dataSource gridViewRootCells:self];
    _rootNodes = rootNodes;
    [self updateLevelForNodes:rootNodes fromLevel:0];
    NSMutableArray *levelNodes = [NSMutableArray array];
    [self travelsChildNodes:_rootNodes intoLevelNodes:levelNodes];
    for (NSArray *nodes in levelNodes) {
        [treeNodeList addObjectsFromArray:nodes];
    }
    _treeNodeList = treeNodeList;
    [self.collectionView reloadData];
}

- (void)updateLevelForNodes:(NSArray *)nodes fromLevel:(NSUInteger)level {
    for (TreeNode *node in nodes) {
        node.level = level;
        [self updateLevelForNodes:node.childNodes fromLevel:level + 1];
    }
}


- (void)travelsChildNodes:(NSArray *)childNodes intoLevelNodes:(NSMutableArray *)levelNodes {
    if (childNodes.count == 0) {
        return;
    }

    TreeNode *firstNode = childNodes.firstObject;
    if (firstNode.level >= levelNodes.count) {
        for (NSUInteger index = levelNodes.count; index <= firstNode.level; index++) {
            [levelNodes addObject:[NSMutableArray array]];
        }
    }
    NSMutableArray *nodesInCurrentLevel = levelNodes[firstNode.level];

    for (TreeNode *node in childNodes) {
        [nodesInCurrentLevel addObject:node];
        if (node.expand) {
            [self travelsChildNodes:node.childNodes intoLevelNodes:levelNodes];
        }
    }
}

- (NSArray *)getNodesAtLevel:(NSUInteger)level formNodes:(NSArray *)nodes {
    NSMutableArray *targetNodes = [NSMutableArray array];
    for (TreeNode *node in nodes) {
        if (node.level == level) {
            [targetNodes addObject:node];
        } else if (node.level < level) {
            [targetNodes addObjectsFromArray:[self getNodesAtLevel:level formNodes:node.childNodes]];
        }
    }

    return targetNodes;
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forTreeNode:(TreeNode *)treeNode {
    return [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:[_treeNodeList indexOfObject:treeNode] inSection:0]];
}


#pragma mark - TreeGridCollectionViewDelegate Methods

- (CGFloat)cellWeightForNode:(TreeNode *)treeNode {
    if ([_delegate respondsToSelector:@selector(gridView:cellWeightForNode:)]) {
        return [_delegate gridView:self cellWeightForNode:treeNode];
    }
    return 0;
}

- (CGFloat)heightAtLevel:(NSUInteger)level {
    if ([_delegate respondsToSelector:@selector(gridView:heightAtLevel:)]) {
        return [_delegate gridView:self heightAtLevel:level];
    }

    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(gridView:didSelectCell:)]) {
        [_delegate gridView:self didSelectCell:_treeNodeList[indexPath.item]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(gridViewDidScroll:)]) {
        [_delegate gridViewDidScroll:self];
    }
}


#pragma mark - TreeGridViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _treeNodeList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource gridView:self cellForRowAtTreeNode:_treeNodeList[indexPath.item]];
}


- (TreeNode *)treeNodeAtIndexPath:(NSIndexPath *)indexPath {
    return _treeNodeList[indexPath.item];
}

- (NSIndexPath *)indexOfTreeNode:(TreeNode *)treeNode {
    return [NSIndexPath indexPathForItem:[_treeNodeList indexOfObject:treeNode] inSection:0];
}

- (NSArray<TreeNode *> *)orderedTreeNodes {
    return _treeNodeList;
}

- (NSArray<TreeNode *> *)rootNodes {
    return _rootNodes;
}


#pragma mark - Getters & Setters


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[TreeMapGridCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[TreeMapGridLayout new]];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_collectionView];
    }

    return _collectionView;
}

- (void)setDataSource:(id <TreeMapGridViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}


@end