//
// Created by neo on 2017/12/1.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeMapGridLayout.h"
#import "TreeNode.h"
#import "TreeMapGridCollectionView.h"

@interface TreeMapGridLayout ()

@property(nonatomic, strong) NSMutableArray *cellWidths;
@property(nonatomic, strong) NSMutableArray *cellHeights;
@property(nonatomic, strong) NSMutableArray *cellLeftPosition;
@property(nonatomic, strong) NSMutableArray *cellTopPosition;

@end


@implementation TreeMapGridLayout {

}

- (void)prepareLayout {
    [super prepareLayout];
    [self updateNodeLayoutInfo];
}

- (void)updateNodeLayoutInfo {
    NSMutableArray *cellWidths = [NSMutableArray array];
    NSMutableArray *cellHeights = [NSMutableArray array];
    NSMutableArray *leftPositions = [NSMutableArray array];
    NSMutableArray *topPositions = [NSMutableArray array];
    _cellWidths = cellWidths;
    _cellHeights = cellHeights;
    _cellLeftPosition = leftPositions;
    _cellTopPosition = topPositions;

    NSArray *allNodes = [self.collectionView.dataSource orderedTreeNodes];

    for (NSUInteger index = 0; index < allNodes.count; index++) {
        [cellWidths addObject:@(0)];
        [leftPositions addObject:@(0)];
    }

    [self recursiveUpdateNodeLayout:[self.collectionView.dataSource rootNodes]];
}

- (void)recursiveUpdateNodeLayout:(NSArray *)nodes {
    if (nodes.count == 0) {
        return;
    }
    TreeNode *firstChildNode = nodes.firstObject;
    for (NSUInteger level = _cellHeights.count; level <= firstChildNode.level; level++) {
        CGFloat height = [[[self collectionView] delegate] heightAtLevel:level];
        [_cellTopPosition addObject:[_cellHeights valueForKeyPath:@"@sum.floatValue"]];
        [_cellHeights addObject:@(height)];
    }

    NSUInteger firstChildIndex = [self.collectionView.dataSource indexOfTreeNode:firstChildNode].item;
    TreeNode *parentNode = [firstChildNode parentNode];
    CGFloat parentLeft = 0;
    if (parentNode) {
        parentLeft = [_cellLeftPosition[[self.collectionView.dataSource indexOfTreeNode:parentNode].item] floatValue];
    }
    CGFloat leftOffset = 0;

    for (NSUInteger index = 0; index < nodes.count; index++) {
        TreeNode *node = nodes[index];
        CGFloat nodeWidth = [self cellWidthForNode:node];
        _cellLeftPosition[firstChildIndex + index] = @(parentLeft + leftOffset);
        _cellWidths[firstChildIndex + index] = @(nodeWidth);
        leftOffset += nodeWidth;
        if (node.expand) {
            [self recursiveUpdateNodeLayout:node.childNodes];
        }
    }
}


- (CGFloat)cellWidthForNode:(TreeNode *)node {
    NSArray *brotherNodes;
    CGFloat parentWidth;
    if (!node.parentNode && node.level == 0) {
        parentWidth = self.collectionViewContentSize.width;
        brotherNodes = self.collectionView.dataSource.rootNodes;
    } else {
        NSIndexPath *parentIndex = [self.collectionView.dataSource indexOfTreeNode:node.parentNode];
        parentWidth = [_cellWidths[parentIndex.item] floatValue];
        brotherNodes = node.parentNode.childNodes;
    }

    CGFloat allWeight = 0;

    for (TreeNode *brotherNode in brotherNodes) {
        allWeight += [self.collectionView.delegate cellWeightForNode:brotherNode];
    }

    if (allWeight == 0) {
        return 0;
    } else {
        return parentWidth * [self.collectionView.delegate cellWeightForNode:node] / allWeight;
    }
}

- (CGSize)collectionViewContentSize {
    return [self collectionView].frame.size;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    TreeNode *node = [self.collectionView.dataSource treeNodeAtIndexPath:path];
    attributes.frame = [self rectForNode:node];
    return attributes;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    NSArray *indexes = [self indexesInRect:rect];
    for (NSIndexPath *indexPath in indexes) {
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}


- (NSArray<NSIndexPath *> *)indexesInRect:(CGRect)rect {
    NSMutableArray *indexes = [NSMutableArray array];
    NSArray *nodes = [self.collectionView.dataSource orderedTreeNodes];
    for (TreeNode *node in nodes) {
        CGRect cellRect = [self rectForNode:node];
        if (CGRectIntersectsRect(cellRect, rect)) {
            [indexes addObject:[self.collectionView.dataSource indexOfTreeNode:node]];
        }
    }

    return indexes;
}

- (CGRect)rectForNode:(TreeNode *)node {
    NSIndexPath *indexPath = [self.collectionView.dataSource indexOfTreeNode:node];
    NSUInteger nodeIndex = indexPath.item;
    CGFloat x = [_cellLeftPosition[nodeIndex] floatValue];
    CGFloat y = [_cellTopPosition[node.level] floatValue];
    CGFloat width = [_cellWidths[nodeIndex] floatValue];
    CGFloat height = 0;
    if (!node.childNodes || !node.expand) {
        for (NSUInteger level = node.level; level < _cellHeights.count; level++) {
            height += [_cellHeights[node.level] floatValue];
        }
    } else {
        height = [_cellHeights[node.level] floatValue];
    }

    return CGRectMake(x, y, width, height);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end