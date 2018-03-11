//
// Created by neo on 2017/12/8.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeLayerLayout.h"
#import "TreeLayerGridCell.h"
#import "TreeLayerCollectionView.h"
#import "TreeLayerCollectionViewLayoutAttributes.h"

@interface TreeLayerLayout ()

@property(nonatomic, strong) NSArray *columnPosition;
@property(nonatomic, strong) NSArray *rowPosition;

@property(nonatomic, strong) NSArray *heights;

@property(nonatomic, assign) CGFloat fixedRowHeight;
@property(nonatomic, assign) CGFloat fixedColumnWidth;

@property(nonatomic, assign) NSUInteger fixedRowCount;
@property(nonatomic, assign) NSUInteger fixedColumnCount;

@end

#define CORNER_HEADER_ZINDEX    99
#define TOP_HEADER_ZINDEX       98
#define LEFT_HEADER_ZINDEX      98
#define MAIN_GRID_ZINDEX        1

@implementation TreeLayerLayout {

}

+ (Class)layoutAttributesClass {
    return [TreeLayerCollectionViewLayoutAttributes class];
}


- (void)prepareLayout {
    [super prepareLayout];
    _heights = self.collectionView.delegate.cellHeights;
    _columnPosition = self.collectionView.delegate.columnPositions;
    _rowPosition = self.collectionView.delegate.rowPositions;

    _fixedRowCount = self.collectionView.delegate.fixRowCount;
    _fixedRowHeight = self.collectionView.delegate.fixRowsHeight;
    _fixedColumnCount = self.collectionView.delegate.fixColumnCount;
    _fixedColumnWidth = self.collectionView.delegate.fixColumnsWidth;
}


- (CGSize)collectionViewContentSize {
    return self.collectionView.contentSize;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO iOS10会随机加载一个不在屏幕内的cell, 一种可能是和下边的visibleContentOffset限制太小的原因. 如果重写并返回有效的layoutAttributes会闪退, 先这么简单处理, 后边有时间再看根本原因
    return [TreeLayerCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
}


- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributesArray = [NSMutableArray array];
    NSInteger numberOfRow = self.collectionView.dataSource.numberOfRow;
    NSInteger numberOfColumn = self.collectionView.dataSource.numberOfColumn;
    if (!numberOfRow || !numberOfColumn) {
        return attributesArray;
    }
    CGPoint visibleContentOffset = self.collectionView.contentOffset;
    if (@available(iOS 11.0, *)) {
        visibleContentOffset = CGPointMake(visibleContentOffset.x + self.collectionView.adjustedContentInset.left, visibleContentOffset.y + self.collectionView.adjustedContentInset.top);
    }
    CGRect viewPort;
    viewPort.origin = visibleContentOffset;
    viewPort.size = self.collectionView.bounds.size;
    //corner
    if (_fixedRowCount && _fixedColumnCount) {
        [attributesArray addObjectsFromArray:[self layoutAttributesInRect:CGRectMake(0, 0, _fixedColumnWidth - 1, _fixedRowHeight - 1)
                                                              visibleRect:CGRectMake(visibleContentOffset.x, visibleContentOffset.y, _fixedColumnWidth, _fixedRowHeight)
                                                               edgeInsets:UIEdgeInsetsMake(visibleContentOffset.y, visibleContentOffset.x, -visibleContentOffset.y, -visibleContentOffset.x)
                                                            fixLeveledRow:NO
                                                                   zIndex:CORNER_HEADER_ZINDEX
                                                              columnRange:NSMakeRange(0, _fixedColumnCount)
                                                                 rowRange:NSMakeRange(0, _fixedRowCount)]];
    }

    //top
    if (_fixedRowCount) {
        [attributesArray addObjectsFromArray:[self layoutAttributesInRect:CGRectMake(visibleContentOffset.x + _fixedColumnWidth, 0, rect.size.width - _fixedColumnWidth, _fixedRowHeight - 1)
                                                              visibleRect:CGRectMake(visibleContentOffset.x + _fixedColumnWidth, visibleContentOffset.y, viewPort.size.width - _fixedColumnWidth, _fixedRowHeight)
                                                               edgeInsets:UIEdgeInsetsMake(visibleContentOffset.y, 0, -visibleContentOffset.y, 0)
                                                            fixLeveledRow:NO
                                                                   zIndex:TOP_HEADER_ZINDEX
                                                              columnRange:NSMakeRange(_fixedColumnCount, numberOfColumn - _fixedColumnCount)
                                                                 rowRange:NSMakeRange(0, _fixedRowCount)]];
    }

    //left
    if (_fixedColumnCount) {
        [attributesArray addObjectsFromArray:[self layoutAttributesInRect:CGRectMake(0, visibleContentOffset.y + _fixedRowHeight, _fixedColumnWidth - 1, rect.size.height - _fixedRowHeight)
                                                              visibleRect:CGRectMake(visibleContentOffset.x, visibleContentOffset.y + _fixedRowHeight, _fixedColumnWidth, viewPort.size.height - _fixedRowHeight)
                                                               edgeInsets:UIEdgeInsetsMake(0, visibleContentOffset.x, 0, -visibleContentOffset.x)
                                                            fixLeveledRow:_fixLeveledRowHeader
                                                                   zIndex:LEFT_HEADER_ZINDEX
                                                              columnRange:NSMakeRange(0, _fixedColumnCount)
                                                                 rowRange:NSMakeRange(_fixedRowCount, numberOfRow - _fixedRowCount)]];
    }

    //main
    [attributesArray addObjectsFromArray:[self layoutAttributesInRect:CGRectMake(visibleContentOffset.x + _fixedColumnWidth, visibleContentOffset.y + _fixedRowHeight, rect.size.width - _fixedColumnWidth, rect.size.height - _fixedRowHeight)
                                                          visibleRect:CGRectMake(visibleContentOffset.x + _fixedColumnWidth, visibleContentOffset.y + _fixedRowHeight, viewPort.size.width - _fixedColumnWidth, viewPort.size.height - _fixedRowHeight)
                                                           edgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)
                                                        fixLeveledRow:_fixLeveledRowHeader
                                                               zIndex:MAIN_GRID_ZINDEX
                                                          columnRange:NSMakeRange(_fixedColumnCount, numberOfColumn - _fixedColumnCount)
                                                             rowRange:NSMakeRange(_fixedRowCount, numberOfRow - _fixedRowCount)]];

    return attributesArray;
}


- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesInRect:(CGRect)rect
                                                                              visibleRect:(CGRect)visibleRect
                                                                               edgeInsets:(UIEdgeInsets)edgeInsets
                                                                            fixLeveledRow:(BOOL)fixedLevelRow
                                                                                   zIndex:(NSInteger)zIndex
                                                                              columnRange:(NSRange)columnRange
                                                                                 rowRange:(NSRange)rowRange {
    if (rect.size.height == 0 || rect.size.width == 0) {
        return @[];
    }
    NSUInteger rowStart = [self searchValue:rect.origin.y atArray:_rowPosition from:rowRange.location to:NSMaxRange(rowRange) - 1];
    NSUInteger rowEnd = [self searchValue:rect.origin.y + rect.size.height atArray:_rowPosition from:rowStart to:NSMaxRange(rowRange) - 1];

    NSUInteger columnStart = [self searchValue:rect.origin.x atArray:_columnPosition from:columnRange.location to:NSMaxRange(columnRange) - 1];
    NSUInteger columnEnd = [self searchValue:rect.origin.x + rect.size.width atArray:_columnPosition from:columnStart to:NSMaxRange(columnRange) - 1];

    NSMutableArray *attrArray = [NSMutableArray array];
    NSUInteger topRowIndex = rowStart;
    if (fixedLevelRow) {
        [attrArray addObjectsFromArray:[self layoutAttributesForBodyFixedLevelRowFromRow:rowStart columnStart:columnStart columnEnd:columnEnd inRect:rect edgeInsets:edgeInsets topRowIndex:&topRowIndex zIndex:zIndex visibleRect:visibleRect]];
    }

    NSMutableSet *cellSet = [NSMutableSet set];
    for (NSUInteger rowIndex = topRowIndex; rowIndex <= rowEnd; rowIndex++) {
        for (NSUInteger columnIndex = columnStart; columnIndex <= columnEnd; columnIndex++) {
            TreeLayerGridCell *cell = [self.collectionView.dataSource cellAtRow:rowIndex column:columnIndex];
            if (cell) {
                [cellSet addObject:cell];
            }
        }
    }

    for (TreeLayerGridCell *cell in cellSet) {
        TreeLayerCollectionViewLayoutAttributes *attributes = [TreeLayerCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cell.indexPath];
        attributes.frame = UIEdgeInsetsInsetRect(cell.frame, edgeInsets);
        attributes.zIndex = zIndex;
        CGFloat maskX = visibleRect.origin.x - attributes.frame.origin.x;
        maskX = MAX(0, maskX);
        attributes.maskRect = CGRectMake(maskX, 0, attributes.frame.size.width - maskX, attributes.frame.size.height);
        [attrArray addObject:attributes];
    }

    return attrArray;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForBodyFixedLevelRowFromRow:(NSUInteger)rowIndex columnStart:(NSUInteger)columnStart columnEnd:(NSUInteger)columnEnd inRect:(CGRect)rect edgeInsets:(UIEdgeInsets)edgeInsets topRowIndex:(NSUInteger *)topRowIndex zIndex:(NSInteger)zIndex visibleRect:(CGRect)visibleRect {
    NSMutableArray *attributesArray = [NSMutableArray array];

    NSUInteger bottomRowIndex;
    BOOL popUp = NO;
    NSMutableArray *fixedHeaderIndexes = [NSMutableArray array];
    [self fixedLeveledRowHeaderIndexes:fixedHeaderIndexes fromRow:rowIndex yOffset:rect.origin.y bottomRowIndex:&bottomRowIndex popUp:&popUp];

    *topRowIndex = bottomRowIndex;

    CGFloat yOffset = rect.origin.y;
    NSUInteger headerRowCount = fixedHeaderIndexes.count;
    NSUInteger lastHeaderRowIndex;
    if (headerRowCount) {
        lastHeaderRowIndex = [fixedHeaderIndexes.lastObject unsignedIntegerValue];
        for (NSUInteger index = 0, length = headerRowCount - 1; index < length; index++) {
            CGFloat rowHeight = 0;
            for (NSUInteger columnIndex = columnStart; columnIndex <= columnEnd; columnIndex++) {
                TreeLayerGridCell *cell = [self.collectionView.dataSource cellAtRow:[fixedHeaderIndexes[index] unsignedIntegerValue] column:columnIndex];
                CGRect attrFrame = cell.frame;
                TreeLayerCollectionViewLayoutAttributes *attributes = [TreeLayerCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cell.indexPath];
                attrFrame.origin.y = yOffset;
                attributes.frame = UIEdgeInsetsInsetRect(attrFrame, edgeInsets);

                CGFloat maskX = visibleRect.origin.x - attributes.frame.origin.x;
                maskX = MAX(0, maskX);
                attributes.maskRect = CGRectMake(maskX, 0, attributes.frame.size.width - maskX, attributes.frame.size.height);

                attributes.zIndex = headerRowCount - index + zIndex;
                [attributesArray addObject:attributes];
                rowHeight = attrFrame.size.height;
            }
            yOffset += rowHeight;
        }
    } else {
        lastHeaderRowIndex = rowIndex;
    }

    CGFloat yPosition;

    if (popUp) {
        yPosition = [_rowPosition[bottomRowIndex] floatValue] - [_heights[lastHeaderRowIndex] floatValue];
    } else {
        yPosition = yOffset;
    }

    for (NSUInteger columnIndex = columnStart; columnIndex <= columnEnd; columnIndex++) {
        TreeLayerGridCell *cell = [self.collectionView.dataSource cellAtRow:lastHeaderRowIndex column:columnIndex];
        CGRect attrFrame = cell.frame;
        TreeLayerCollectionViewLayoutAttributes *attributes = [TreeLayerCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cell.indexPath];
        attrFrame.origin.y = yPosition;
        attributes.frame = UIEdgeInsetsInsetRect(attrFrame, edgeInsets);
        attributes.zIndex = zIndex;

        CGFloat maskY = yOffset - yPosition;
        CGFloat maskX = visibleRect.origin.x - attributes.frame.origin.x;
        maskX = MAX(0, maskX);
        attributes.maskRect = CGRectMake(maskX, maskY, attributes.frame.size.width - maskX, attributes.frame.size.height - maskY);

        [attributesArray addObject:attributes];
    }

    return attributesArray;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    NSUInteger oldLeftRow = [self searchValue:self.collectionView.contentOffset.y atArray:_rowPosition from:0 to:_rowPosition.count - 1];
//    NSUInteger newLeftRow = [self searchValue:newBounds.origin.y atArray:_rowPosition from:0 to:_rowPosition.count - 1];
//
//    if (oldLeftRow != newLeftRow) {
//        return YES;
//    }
//
//    NSUInteger oldRightRow = [self searchValue:self.collectionView.contentOffset.y + self.collectionView.contentSize.width atArray:_rowPosition from:oldLeftRow to:_rowPosition.count - 1];
//    NSUInteger newRightRow = [self searchValue:newBounds.origin.y + newBounds.size.width atArray:_rowPosition from:newLeftRow to:_rowPosition.count - 1];
//
//    if (oldRightRow != newRightRow) {
//        return YES;
//    }
//
//    NSUInteger oldTopColumn = [self searchValue:self.collectionView.contentOffset.x atArray:_columnPosition from:0 to:_columnPosition.count - 1];
//    NSUInteger newTopColumn = [self searchValue:newBounds.origin.x atArray:_columnPosition from:0 to:_columnPosition.count - 1];
//
//
//    if (oldTopColumn != newTopColumn) {
//        return YES;
//    }
//
//    NSUInteger oldBottomColumn = [self searchValue:self.collectionView.contentOffset.x + self.collectionView.contentSize.height atArray:_columnPosition from:oldTopColumn to:_columnPosition.count - 1];
//    NSUInteger newBottomColumn = [self searchValue:newBounds.origin.x + newBounds.size.height atArray:_columnPosition from:newTopColumn to:_columnPosition.count - 1];
//
//
//    return oldBottomColumn != newBottomColumn;
    return YES;
}

- (NSUInteger)searchValue:(CGFloat)value atArray:(NSArray *)array from:(NSUInteger)startIndex to:(NSUInteger)endIndex {
    if (endIndex == startIndex) {
        return startIndex;
    } else if (endIndex - 1 == startIndex) {
        if ([array[endIndex] floatValue] <= value) {
            return endIndex;
        }
        return startIndex;
    }

    NSUInteger centerIndex = (startIndex + endIndex) / 2;
    CGFloat centerValue = [array[centerIndex] floatValue];
    if (centerValue > value) {
        return [self searchValue:value atArray:array from:startIndex to:centerIndex];
    } else if (centerValue < value) {
        return [self searchValue:value atArray:array from:centerIndex to:endIndex];
    }

    return centerIndex;

}

- (void)fixedLeveledRowHeaderIndexes:(NSMutableArray *)headerIndexes fromRow:(NSUInteger)rowIndex yOffset:(CGFloat)yOffset bottomRowIndex:(NSUInteger *)buttonRowIndex popUp:(BOOL *)popUp {
    NSInteger rowCount = [self.collectionView.dataSource numberOfRow];
    NSUInteger currentRowLevel = [self levelOfRow:rowIndex];
    NSUInteger currentRowIndex = rowIndex;
    CGFloat headerOffset = yOffset;
    BOOL pop = NO;
    while (headerIndexes.count <= currentRowLevel && currentRowIndex < rowCount - 1) {
        CGFloat nextRowPosition = [_rowPosition[currentRowIndex + 1] floatValue];
        NSUInteger headerCount = headerIndexes.count;
        NSUInteger headerRowIndex = [self getSuperRowIndexOfRow:currentRowIndex atLevel:headerCount];
        CGFloat currentHeaderHeight = [_heights[headerRowIndex] floatValue];
        CGFloat headerPosition = headerOffset + currentHeaderHeight;

        if (headerPosition >= nextRowPosition) {
            currentRowIndex++;
            pop = YES;
        } else {
            pop = NO;
        }

        if ([self setHeaderIndex:headerRowIndex atLevel:headerCount ofHeaderIndexes:headerIndexes]) {
            headerOffset = headerPosition;
        }

        currentRowLevel = [self levelOfRow:currentRowIndex];
    }

    if (popUp != NULL) {
        *popUp = pop;
    }

    if (buttonRowIndex != NULL) {
        *buttonRowIndex = currentRowIndex;
    }
}


- (BOOL)setHeaderIndex:(NSUInteger)index atLevel:(NSUInteger)level ofHeaderIndexes:(NSMutableArray *)headerIndexes {
    BOOL changed = NO;
    if (headerIndexes.count <= level) {
        [headerIndexes addObject:@(index)];
        changed = YES;
    } else if ([headerIndexes[level] unsignedIntegerValue] != index) {
        headerIndexes[level] = @(index);
        changed = YES;
    }

    return changed;
}

- (NSUInteger)getSuperRowIndexOfRow:(NSUInteger)rowIndex atLevel:(NSUInteger)level {
    NSUInteger superRowIndex = [self.collectionView.dataSource superRowIndexOfRowAt:rowIndex];
    NSUInteger superRowLevel = [self.collectionView.delegate levelOfRow:superRowIndex];
    if (superRowLevel > level) {
        return [self getSuperRowIndexOfRow:superRowIndex atLevel:level];
    } else if (superRowLevel < level) {
        return rowIndex;
    } else {
        return superRowIndex;
    }
}

- (NSUInteger)levelOfRow:(NSUInteger)rowIndex {
    return [self.collectionView.delegate levelOfRow:rowIndex];
}

@end