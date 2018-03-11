//
// Created by neo on 2017/12/11.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeLayerGridView.h"
#import "TreeLayerGridCell.h"
#import "TreeLayerCollectionView.h"
#import "TreeLayerLayout.h"
#import "TreeLayerCollectionViewCell.h"

@interface TreeLayerGridView () <TreeLayerCollectionViewDelegate, TreeLayerCollectionViewDataSource>

@property(nonatomic, strong) NSArray<NSArray<NSIndexPath *> *> *rows$columnsIndex;
@property(nonatomic, strong) NSArray<TreeLayerGridCell *> *indexedCells;
@property(nonatomic, strong) NSArray *rowLevelInfo;
@property(nonatomic, strong) NSArray *rowSuperRowInfo;

@property(nonatomic, strong) NSArray *heights;
@property(nonatomic, strong) NSArray *widths;

@property(nonatomic, strong) NSArray *rowPosition;
@property(nonatomic, strong) NSArray *columnPosition;

@property(nonatomic, assign) CGFloat fixedRowsHeight;
@property(nonatomic, assign) CGFloat fixedColumnsWidth;

@end

@implementation TreeLayerGridView {
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}


- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forGridCell:(TreeLayerGridCell *)gridCell {
    return [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:[_indexedCells indexOfObject:gridCell] inSection:0]];
}

- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self reloadData];
    }
}


- (void)reloadData {
    if (!_dataSource || !_delegate) {
        return;
    }
    NSMutableArray *indexedCells = [NSMutableArray array];
    NSMutableArray *rowLevels = [NSMutableArray array];
    NSUInteger rowCount = [_dataSource numberOfRowInGridView:self];
    NSUInteger columnCount = [_dataSource numberOfColumnInGridView:self];
    _indexedCells = indexedCells;
    _rowLevelInfo = rowLevels;

    NSIndexPath *cellIndexArray[rowCount][columnCount];

    for (NSUInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        for (NSUInteger columnIndex = 0; columnIndex < columnCount; columnIndex++) {
            if (cellIndexArray[rowIndex][columnIndex] == NULL) {
                TreeLayerGridCell *cell = [self.dataSource gridView:self cellAtRow:rowIndex column:columnIndex];
                NSUInteger rowSpan = cell.rowSpan;
                NSUInteger columnSpan = cell.columnSpan;
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:indexedCells.count inSection:0];
                cell.indexPath = indexPath;
                for (NSUInteger rowOffset = 0; rowOffset < rowSpan; rowOffset++) {
                    for (NSUInteger columnOffset = 0; columnOffset < columnSpan; columnOffset++) {
                        cellIndexArray[rowIndex + rowOffset][columnIndex + columnOffset] = indexPath;
                    }
                }
                [indexedCells addObject:cell];
            }
        }
        NSUInteger currentLevel = [self.delegate gridView:self levelOfRow:rowIndex];
        [rowLevels addObject:@(currentLevel)];
    }

    NSMutableArray *cellIndexes = [NSMutableArray array];
    for (NSUInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        for (NSUInteger colIndex = 0; colIndex < columnCount; colIndex++) {
            NSIndexPath *indexPath = cellIndexArray[rowIndex][colIndex];
            if (indexPath) {
                [cellIndexes addObject:indexPath];
            }
        }
    }
    NSMutableArray *rowAndColumnIndexes = [NSMutableArray array];
    _rows$columnsIndex = rowAndColumnIndexes;
    for (NSUInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        [rowAndColumnIndexes addObject:[cellIndexes subarrayWithRange:NSMakeRange(rowIndex * columnCount, columnCount)]];
    }
    [self updateLayoutInfo];

    [self updateLevelInfo];

    [self.collectionView reloadData];
}

- (void)updateLevelInfo {
    __weak typeof(self) weakSelf = self;
    NSUInteger (^getSuperRowBlock)(NSUInteger) = ^NSUInteger(NSUInteger rowIndex) {
        NSUInteger currentRowLevel = [weakSelf.rowLevelInfo[rowIndex] unsignedIntegerValue];
        if (currentRowLevel == 0) {
            return rowIndex;
        }
        for (NSInteger index = rowIndex - 1; index >= 0; index--) {
            NSUInteger level = [weakSelf.rowLevelInfo[index] unsignedIntegerValue];
            if (level < currentRowLevel) {
                return index;
            }
        }

        return rowIndex;
    };

    NSMutableArray *rowSuperRowInfo = [NSMutableArray array];
    _rowSuperRowInfo = rowSuperRowInfo;

    for (NSUInteger rowIndex = 0, rowCount = _rowLevelInfo.count; rowIndex < rowCount; rowIndex++) {
        [rowSuperRowInfo addObject:@(getSuperRowBlock(rowIndex))];
    }

}


- (void)updateLayoutInfo {
    NSUInteger rowCount = [_dataSource numberOfRowInGridView:self];
    NSUInteger columnCount = [_dataSource numberOfColumnInGridView:self];

    NSMutableArray *heights = [NSMutableArray array];
    NSMutableArray *widths = [NSMutableArray array];
    NSMutableArray *columnPosition = [NSMutableArray array];
    NSMutableArray *rowPosition = [NSMutableArray array];
    _heights = heights;
    _widths = widths;
    _columnPosition = columnPosition;
    _rowPosition = rowPosition;

    CGFloat totalHeight = 0;
    CGFloat totalWidth = 0;

    for (NSUInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        CGFloat height = [_delegate gridView:self heightAtRow:rowIndex];
        [heights addObject:@(height)];
        [rowPosition addObject:@(totalHeight)];
        totalHeight += height;
    }

    for (NSUInteger columnIndex = 0; columnIndex < columnCount; columnIndex++) {
        CGFloat width = [_delegate gridView:self widthAtColumn:columnIndex];
        [widths addObject:@(width)];
        [columnPosition addObject:@(totalWidth)];
        totalWidth += width;
    }

    _fixedRowsHeight = 0;
    for (NSUInteger rowIndex = 0; rowIndex < _frozenRowCount; rowIndex++) {
        _fixedRowsHeight += [_delegate gridView:self heightAtRow:rowIndex];
    }

    _fixedColumnsWidth = 0;
    for (NSUInteger columnIndex = 0; columnIndex < _frozenColumnCount; columnIndex++) {
        _fixedColumnsWidth += [_delegate gridView:self widthAtColumn:columnIndex];
    }

    for (TreeLayerGridCell *gridCell in _indexedCells) {
        CGFloat x = [columnPosition[gridCell.column] floatValue];
        CGFloat y = [rowPosition[gridCell.row] floatValue];
        CGFloat width = 0;
        CGFloat height = 0;
        for (NSUInteger span = 0; span < gridCell.rowSpan; span++) {
            height += [heights[gridCell.row + span] floatValue];
        }

        for (NSUInteger span = 0; span < gridCell.columnSpan; span++) {
            width += [widths[gridCell.column + span] floatValue];
        }

        gridCell.frame = CGRectMake(x, y, width, height);
    }

    self.collectionView.contentSize = CGSizeMake(totalWidth, totalHeight);
}


- (TreeLayerGridCell *)getCellAtIndexPath:(NSIndexPath *)indexPath {
    return _indexedCells[indexPath.item];
}

- (void)didClick:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint clickPoint = [gestureRecognizer locationInView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:clickPoint];
    if (indexPath) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        [_delegate gridView:self didSelectCell:[self getCellAtIndexPath:indexPath] withPoint:[gestureRecognizer locationInView:cell]];
    }
}

#pragma mark - TreeLayerCollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _indexedCells.count;
}

- (TreeLayerGridCell *)gridCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self getCellAtIndexPath:indexPath];
}

- (NSInteger)numberOfRow {
    return [_dataSource numberOfRowInGridView:self];
}

- (NSInteger)numberOfColumn {
    return [_dataSource numberOfColumnInGridView:self];
}

- (TreeLayerGridCell *)cellAtRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex {
    NSIndexPath *indexPath = _rows$columnsIndex[rowIndex][columnIndex];
    return _indexedCells[indexPath.item];
}

- (NSUInteger)superRowIndexOfRowAt:(NSUInteger)rowIndex {
    return [_rowSuperRowInfo[rowIndex] unsignedIntegerValue];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TreeLayerGridCell *gridCell = [self getCellAtIndexPath:indexPath];
    if (gridCell) {
        return [_dataSource gridView:self cellViewForGridCell:gridCell];
    } else {
        return [UICollectionViewCell new];
    }
}

#pragma mark - TreeLayerCollectionViewDelegate Methods

- (NSArray *)cellHeights {
    return _heights;
}

- (NSArray *)cellWidths {
    return _widths;
}

- (NSArray *)columnPositions {
    return _columnPosition;
}

- (NSArray *)rowPositions {
    return _rowPosition;
}

- (NSUInteger)levelOfRow:(NSUInteger)rowIndex {
    return [_rowLevelInfo[rowIndex] unsignedIntegerValue];
}

- (NSUInteger)fixRowCount {
    return _frozenRowCount;
}

- (NSUInteger)fixColumnCount {
    return _frozenColumnCount;
}

- (CGFloat)fixRowsHeight {
    return _fixedRowsHeight;
}

- (CGFloat)fixColumnsWidth {
    return _fixedColumnsWidth;
}


#pragma mark - Getters & Setters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        TreeLayerLayout *layout = [TreeLayerLayout new];
        layout.fixLeveledRowHeader = _fixLeveledRowHeader;
        _collectionView = [[TreeLayerCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClick:)];
        tap.numberOfTapsRequired = 1;
        [_collectionView addGestureRecognizer:tap];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)setFixLeveledRowHeader:(BOOL)fixLeveledRowHeader {
    _fixLeveledRowHeader = fixLeveledRowHeader;
    ((TreeLayerLayout *) (_collectionView.collectionViewLayout)).fixLeveledRowHeader = fixLeveledRowHeader;
}

@end