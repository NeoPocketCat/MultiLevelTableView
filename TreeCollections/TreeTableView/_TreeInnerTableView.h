//
// Created by neo on 2017/11/27.
// Copyright (c) 2017 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TreeTableView;
@class TreeDataConverter;

@interface _TreeInnerTableView : UITableView

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