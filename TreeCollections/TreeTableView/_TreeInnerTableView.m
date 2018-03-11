//
// Created by neo on 2017/11/27.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "_TreeInnerTableView.h"
#import "TreeDataConverter.h"
#import "TreeTableView.h"


@implementation _TreeInnerTableView {
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

    NSIndexPath *firstVisibleCellIndexPath = self.indexPathsForVisibleRows.firstObject;
    NSUInteger visibleHeaderCount = [_dataConverter fixedHeaderCountFromRowIndex:firstVisibleCellIndexPath.row];

    if (firstVisibleCellIndexPath.row != _recordedPosition) {
        _recordedPosition = firstVisibleCellIndexPath.row;
        [_headerViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_reuseableCells addObjectsFromArray:_headerViews.reverseObjectEnumerator.allObjects];
        [_headerViews removeAllObjects];
        if (_reuseableCells.count < visibleHeaderCount) {
            UITableViewCell *topVisibleCell = [self cellForRowAtIndexPath:firstVisibleCellIndexPath];
            for (NSUInteger headerIndex = _reuseableCells.count; headerIndex < visibleHeaderCount; headerIndex++) {
                [_reuseableCells addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:topVisibleCell]]];
            }
        }
    }

    CGFloat offset = 0;
    CGFloat contentOffsetY = self.contentOffset.y;
    for (NSUInteger index = 0; index < visibleHeaderCount; index++) {
        UIView *headerView;
        if (_headerViews.count <= index) {
            headerView = [_dataConverter.dataSource tableView:_treeTableView cellForRowAtTreeNode:[_dataConverter headerOfLevel:index forRowIndex:firstVisibleCellIndexPath.item + index]];
            if (headerView) {
                [_headersWrapView addSubview:headerView];
                [_headersWrapView sendSubviewToBack:headerView];
                [_headerViews addObject:headerView];
            }
        } else {
            headerView = _headerViews[index];
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

#pragma mark - GesturesRecognizer Methods

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

#pragma mark - Getters & Setters

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