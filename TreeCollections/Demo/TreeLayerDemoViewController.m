//
// Created by neo on 2017/12/13.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeLayerDemoViewController.h"
#import "TreeLayerGridView.h"
#import "TreeLayerGridCell.h"
#import "TreeLayerCollectionViewCell.h"

@interface TreeLayerDemoViewController () <TreeLayerGridViewDataSource, TreeLayerGridViewDelegate>

@property(nonatomic, strong) NSArray *levels;
@property(nonatomic, strong) NSArray *heights;
@property(nonatomic, assign) NSUInteger frozenRow;
@property(nonatomic, assign) NSUInteger frozenColumn;

@end

@implementation TreeLayerDemoViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    TreeLayerGridView *gridView = [[TreeLayerGridView alloc] initWithFrame:self.view.bounds];
    [gridView registerClass:[TreeLayerCollectionViewCell class] forCellWithReuseIdentifier:@"__cells__"];
    gridView.fixLeveledRowHeader = YES;
    gridView.dataSource = self;
    gridView.delegate = self;
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.frozenRowCount = _frozenRow = 2;
    gridView.frozenColumnCount = _frozenColumn = 1;
    [self.view addSubview:gridView];
    [self prepareData];
}

- (void)prepareData {
    NSMutableArray *level = [NSMutableArray array];
    _levels = level;
    for (NSUInteger x = 0; x < _frozenRow; x++) {
        [level addObject:@(0)];
    }
    for (NSUInteger x = 0; x < 3; x++) {
        [level addObject:@(0)];
        for (NSUInteger y = 0; y < 4; y++) {
            [level addObject:@(1)];
            for (NSUInteger z = 0; z < 5; z++) {
                [level addObject:@(2)];
                for (NSUInteger za = 0; za < 6; za++) {
                    [level addObject:@(3)];
                }
            }
        }
    }
}

#pragma mark - TreeLayerGridViewDataSource Methods

- (NSUInteger)numberOfRowInGridView:(TreeLayerGridView *)gridView {
    return _levels.count;
}

- (NSUInteger)numberOfColumnInGridView:(TreeLayerGridView *)gridView {
    return 3;
}

- (TreeLayerGridCell *)gridView:(TreeLayerGridView *)gridView cellAtRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex {
    TreeLayerGridCell *cell = [TreeLayerGridCell new];
    cell.rowSpan = 1;
    cell.columnSpan = 1;
    cell.row = rowIndex;
    cell.column = columnIndex;
    return cell;
}

- (TreeLayerCollectionViewCell *)gridView:(TreeLayerGridView *)gridView cellViewForGridCell:(TreeLayerGridCell *)gridCell {
    TreeLayerCollectionViewCell *cell = [gridView dequeueReusableCellWithReuseIdentifier:@"__cells__" forGridCell:gridCell];
    UILabel *label;
    if (cell.contentView.subviews.count > 0) {
        label = cell.contentView.subviews[0];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.layer.borderWidth = 1;
        [cell.contentView addSubview:label];
    }
    NSUInteger level = [_levels[gridCell.row] unsignedIntegerValue];
    NSString *offsetString = @"";
    for (NSUInteger index = 0; index < level; index++) {
        offsetString = [offsetString stringByAppendingString:@"  "];
    }
    label.text = [NSString stringWithFormat:@"%@(%d, %d)", offsetString, gridCell.row, gridCell.column];
    if (gridCell.row < _frozenRow) {
        if (gridCell.column < _frozenColumn) {
            cell.backgroundColor = [UIColor colorWithRed:0.77f green:0.71f blue:0.8f alpha:1];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:0.77f green:0.71f blue:0.1f alpha:1];
        }
    } else {
        if (gridCell.column < _frozenColumn) {
            CGFloat red = 0.5f + level / 10.0f;
            cell.backgroundColor = [UIColor colorWithRed:red green:0.71f blue:0.5f alpha:1];
        } else {
            CGFloat green = 0.21f + level / 10.0f;
            cell.backgroundColor = [UIColor colorWithRed:0.5f green:green blue:0.1f alpha:1];
        }
    }
    return cell;
}


#pragma mark - TreeLayerGridViewDelegate Methods

- (CGFloat)gridView:(TreeLayerGridView *)gridView heightAtRow:(NSUInteger)rowIndex {
    return 40;
}

- (CGFloat)gridView:(TreeLayerGridView *)gridView widthAtColumn:(NSUInteger)columnIndex {
    return 150;
}

- (NSUInteger)gridView:(TreeLayerGridView *)gridView levelOfRow:(NSUInteger)rowIndex {
    return [_levels[rowIndex] unsignedIntegerValue];
}


@end