//
// Created by neo on 2017/3/2.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TreeTableView;
@class TreeNode;

@protocol TreeTableViewDelegate <NSObject>

- (CGFloat)tableView:(TreeTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(TreeTableView *)tableView didSelectCell:(TreeNode *)treeNode;

- (void)tableViewDidScroll:(TreeTableView *)tableView;

@end

@protocol TreeTableViewDataSource <NSObject>

- (NSArray<TreeNode *> *)tableViewRootNodes:(TreeTableView *)tableView;

- (UITableViewCell *)tableView:(TreeTableView *)tableView cellForRowAtTreeNode:(TreeNode *)treeNode;

@end

@interface TreeTableView : UIView

@property(nonatomic, assign) BOOL fixHeader;
@property(nonatomic, assign) BOOL fixFooter;
@property(nonatomic, assign) CGPoint contentOffset;
@property(nonatomic, weak) id <TreeTableViewDataSource> dataSource;
@property(nonatomic, weak) id <TreeTableViewDelegate> delegate;
@property(nonatomic) BOOL showsVerticalScrollIndicator;
@property(nonatomic) BOOL showsHorizontalScrollIndicator;
@property(nonatomic) UITableViewCellSeparatorStyle separatorStyle;

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;

- (UITableView *)innerTableView;

@end