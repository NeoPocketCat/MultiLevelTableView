//
// Created by neo on 2017/12/8.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TreeLayerGridCell;
@protocol TreeLayerCollectionViewDelegate, TreeLayerCollectionViewDataSource;


@interface TreeLayerCollectionView : UICollectionView

@property(nonatomic, weak, nullable) id <TreeLayerCollectionViewDelegate> delegate;
@property(nonatomic, weak, nullable) id <TreeLayerCollectionViewDataSource> dataSource;

@end

@protocol TreeLayerCollectionViewDelegate <UICollectionViewDelegate>

- (NSArray *)cellHeights;

- (NSArray *)cellWidths;

- (NSArray *)rowPositions;

- (NSArray *)columnPositions;

- (NSUInteger)levelOfRow:(NSUInteger)rowIndex;

- (NSUInteger)fixRowCount;

- (NSUInteger)fixColumnCount;

- (CGFloat)fixRowsHeight;

- (CGFloat)fixColumnsWidth;

@end

@protocol TreeLayerCollectionViewDataSource <UICollectionViewDataSource>

- (TreeLayerGridCell *)gridCellAtIndexPath:(NSIndexPath *)indexPath;

- (TreeLayerGridCell *)cellAtRow:(NSUInteger)rowIndex column:(NSUInteger)column;

- (NSUInteger)superRowIndexOfRowAt:(NSUInteger)rowIndex;

- (NSInteger)numberOfRow;

- (NSInteger)numberOfColumn;

@end