//
// Created by neo on 2017/3/2.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeTableView.h"
#import "NSArray+Utils.h"
#import "TreeDataConverter.h"
#import "TreeNode.h"


@interface _InnerTableView : UITableView

@property(nonatomic, strong) UIView *headersWrapView;

@property(nonatomic, strong) UIView *footersWrapView;

@property(nonatomic, strong) NSMutableArray *headerViews;

@property(nonatomic, strong) NSMutableArray *reuseableCells;

@property(nonatomic, weak) TreeTableView *treeTableView;

@property(nonatomic, weak) TreeDataConverter *dataConverter;

@property(nonatomic, assign) BOOL fixHeader;

@property(nonatomic, assign) BOOL fixFooter;

- (instancetype)initWithFrame:(CGRect)frame andTreeTableView:(TreeTableView *)treeTableView;

@end

@implementation _InnerTableView {
    NSInteger _recordedPosition;
}

- (instancetype)initWithFrame:(CGRect)frame andTreeTableView:(TreeTableView *)treeTableView {
    self = [super initWithFrame:frame];
    if (self) {
        _treeTableView = treeTableView;
        _reuseableCells = [NSMutableArray array];
        _headerViews = [NSMutableArray array];
        _recordedPosition = -1;
    }

    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutHeaderView];

}

- (void)layoutHeaderView {
    if (!_fixHeader) {
        return;
    }

    NSIndexPath *firstVisibleCellIndexPath = [self.indexPathsForVisibleRows if_objectAtIndex:0];
    NSUInteger visibleHeaderCount = [_dataConverter fixedHeaderCountFromRowIndex:firstVisibleCellIndexPath.row];

    if (firstVisibleCellIndexPath.row != _recordedPosition) {
        _recordedPosition = firstVisibleCellIndexPath.row;
        [_headerViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_reuseableCells addObjectsFromArray:_headerViews.reverseObjectEnumerator.allObjects];
        [_headerViews removeAllObjects];
        if (_reuseableCells.count < visibleHeaderCount) {
            UITableViewCell *firstCell = [self cellForRowAtIndexPath:firstVisibleCellIndexPath];
            for (NSUInteger headerIndex = _reuseableCells.count; headerIndex < visibleHeaderCount; headerIndex++) {
                [_reuseableCells addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:firstCell]]];
            }
        }
    }

    CGFloat offset = 0;
    CGFloat contentOffsetY = self.contentOffset.y;
    for (NSUInteger index = 0; index < visibleHeaderCount; index++) {
        UIView *headerView = [_headerViews if_objectAtIndex:index];
        if (!headerView) {
            headerView = [_dataConverter.dataSource tableView:_treeTableView cellForRowAtTreeNode:[_dataConverter headerOfLevel:index forRowIndex:firstVisibleCellIndexPath.item + index]];
            if (headerView) {
                [_headersWrapView addSubview:headerView];
                [_headersWrapView sendSubviewToBack:headerView];
                [_headerViews addObject:headerView];
            }
        }
        if (index != visibleHeaderCount - 1 || self.contentOffset.y < 0) {
            CGFloat cellHeight = [_dataConverter tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForItem:firstVisibleCellIndexPath.item + index inSection:firstVisibleCellIndexPath.section]];
            headerView.frame = CGRectMake(0, offset, self.frame.size.width, cellHeight);
            offset += headerView.frame.size.height;
        } else {
            CGRect cellFrame = [self rectForRowAtIndexPath:[NSIndexPath indexPathForItem:firstVisibleCellIndexPath.item + index inSection:firstVisibleCellIndexPath.section]];
            headerView.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y - contentOffsetY, cellFrame.size.width, cellFrame.size.height);
        }
    }

    self.headersWrapView.frame = CGRectMake(0, MAX(contentOffsetY, 0), self.frame.size.width, offset);

}

#pragma #mark - GesturesRecognizer Methods

- (void)clickHeaderWrapView:(UITapGestureRecognizer *)recognizer {
    for (NSUInteger index = 0; index < _headerViews.count; index++) {
        UIView *headerView = _headerViews[index];
        if ([headerView.layer containsPoint:[recognizer locationInView:headerView]]) {
            CGPoint location = [recognizer locationInView:self];
            NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
            [_dataConverter.delegate tableView:_treeTableView didSelectCell:[_dataConverter headerOfLevel:index forRowIndex:indexPath.row]];
            return;
        }
    }

}

#pragma #mark - Getters & Setters

- (void)setFixHeader:(BOOL)fixHeader {
    _fixHeader = fixHeader;
    _headersWrapView.hidden = !_fixHeader;
}

- (void)setFixFooter:(BOOL)fixFooter {
    _fixFooter = fixFooter;
    _footersWrapView.hidden = !_fixFooter;
}


- (UIView *)headersWrapView {
    if (!_headersWrapView) {
        _headersWrapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        _headersWrapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHeaderWrapView:)];
        tap.numberOfTapsRequired = 1;
    }
    return _headersWrapView;
}

- (UIView *)footersWrapView {
    if (!_footersWrapView) {
        _footersWrapView = [[UIView alloc] init];
    }
    return _footersWrapView;
}

- (void)setDataConverter:(TreeDataConverter *)dataConverter {
    _dataConverter = dataConverter;
    self.delegate = self.dataConverter;
    self.dataSource = self.dataConverter;
    [self addSubview:self.headersWrapView];
}

@end

@interface TreeTableView ()

@property(nonatomic, strong) _InnerTableView *tableView;

@property(nonatomic, strong) TreeDataConverter *dataConverter;

@end

@implementation TreeTableView {
}

- (CGPoint)contentOffset {
    return _tableView.contentOffset;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [_tableView setContentOffset:contentOffset];
}

- (void)reloadData {
    [_dataConverter updateNodes];
    [_tableView reloadData];
}

- (UITableView *)innerTableView {
    return _tableView;
}

#pragma #mark - InnerTableViewDelegate Methods


- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    if (_tableView.reuseableCells.count > 0) {
        UITableViewCell *cell = _tableView.reuseableCells.lastObject;
        [_tableView.reuseableCells removeLastObject];
        return cell;
    } else {
        return [_tableView dequeueReusableCellWithIdentifier:identifier];
    }
}

#pragma #mark - Getters & Setters

- (void)setFixHeader:(BOOL)fixHeader {
    _fixHeader = fixHeader;
    _tableView.fixHeader = _fixHeader;
}

- (void)setFixFooter:(BOOL)fixFooter {
    _fixFooter = fixFooter;
    _tableView.fixFooter = _fixFooter;
}

- (_InnerTableView *)tableView {
    if (!_tableView) {
        _tableView = [[_InnerTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) andTreeTableView:self];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (void)setDataSource:(id <TreeTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.dataConverter.dataSource = _dataSource;
}

- (void)setDelegate:(id <TreeTableViewDelegate>)delegate {
    _delegate = delegate;
    self.dataConverter.delegate = _delegate;
}


- (TreeDataConverter *)dataConverter {
    if (!_dataConverter) {
        _dataConverter = [[TreeDataConverter alloc] initWithTableView:self];
        self.tableView.dataConverter = _dataConverter;
    }
    return _dataConverter;
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator {
    _showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    _tableView.showsVerticalScrollIndicator = _showsVerticalScrollIndicator;
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    _showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    _tableView.showsHorizontalScrollIndicator = _showsHorizontalScrollIndicator;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
    _separatorStyle = separatorStyle;
    _tableView.separatorStyle = _separatorStyle;
}


@end