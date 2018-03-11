//
// Created by neo on 2017/3/2.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeTableView.h"
#import "_TreeInnerTableView.h"
#import "TreeDataConverter.h"


@interface TreeTableView ()

@property(nonatomic, strong) _TreeInnerTableView *tableView;

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

#pragma mark - InnerTableViewDelegate Methods


- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    if (_tableView.reuseableCells.count > 0) {
        UITableViewCell *cell = _tableView.reuseableCells.lastObject;
        [_tableView.reuseableCells removeLastObject];
        return cell;
    } else {
        return [_tableView dequeueReusableCellWithIdentifier:identifier];
    }
}

#pragma mark - Getters & Setters

- (void)setFixHeader:(BOOL)fixHeader {
    _fixHeader = fixHeader;
    _tableView.fixHeader = _fixHeader;
}

- (void)setFixFooter:(BOOL)fixFooter {
    _fixFooter = fixFooter;
    _tableView.fixFooter = _fixFooter;
}

- (_TreeInnerTableView *)tableView {
    if (!_tableView) {
        _tableView = [[_TreeInnerTableView alloc] initWithFrame:self.bounds andTreeTableView:self];
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