//
// Created by neo on 2017/3/2.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TreeTableViewDelegate;
@protocol TreeTableViewDataSource;
@class TreeTableView;
@class TreeNode;

@interface TreeDataConverter : NSObject <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) id <TreeTableViewDelegate> delegate;

@property(nonatomic, weak) id <TreeTableViewDataSource> dataSource;

- (instancetype)initWithTableView:(TreeTableView *)tableView;

- (void)updateNodes;

- (NSUInteger)fixedHeaderCountFromRowIndex:(NSUInteger)rowIndex;

- (TreeNode *)headerOfLevel:(NSInteger)level forRowIndex:(NSUInteger)index;

- (TreeNode *)nodeAtIndexRowIndex:(NSUInteger)index;

@end