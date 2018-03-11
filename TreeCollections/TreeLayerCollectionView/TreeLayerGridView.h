//
// Created by neo on 2017/12/11.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TreeLayerGridViewDelegate, TreeLayerGridViewDataSource;
@class TreeLayerGridCell, TreeLayerCollectionViewCell;
@class TreeLayerCollectionView;


@interface TreeLayerGridView : UIView
@property(nonatomic, weak, nullable) id <TreeLayerGridViewDelegate> delegate;
@property(nonatomic, weak, nullable) id <TreeLayerGridViewDataSource> dataSource;

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, assign) NSUInteger frozenRowCount;
@property(nonatomic, assign) NSUInteger frozenColumnCount;

@property(nonatomic, assign) BOOL fixLeveledRowHeader;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forGridCell:(TreeLayerGridCell *)gridCell;

- (void)reloadData;

@end


@protocol TreeLayerGridViewDelegate <NSObject>

- (CGFloat)gridView:(TreeLayerGridView *)gridView heightAtRow:(NSUInteger)rowIndex;

- (CGFloat)gridView:(TreeLayerGridView *)gridView widthAtColumn:(NSUInteger)columnIndex;

- (NSUInteger)gridView:(TreeLayerGridView *)gridView levelOfRow:(NSUInteger)rowIndex;

- (void)gridView:(TreeLayerGridView *)gridView didSelectCell:(TreeLayerGridCell *)gridCell withPoint:(CGPoint)point;

@end

@protocol TreeLayerGridViewDataSource <NSObject>

- (NSUInteger)numberOfRowInGridView:(TreeLayerGridView *)gridView;

- (NSUInteger)numberOfColumnInGridView:(TreeLayerGridView *)gridView;

- (TreeLayerGridCell *)gridView:(TreeLayerGridView *)gridView cellAtRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex;

- (TreeLayerCollectionViewCell *)gridView:(TreeLayerGridView *)gridView cellViewForGridCell:(TreeLayerGridCell *)gridCell;

@end