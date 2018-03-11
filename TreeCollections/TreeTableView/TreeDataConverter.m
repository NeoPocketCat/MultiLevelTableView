//
// Created by neo on 2017/3/2.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeDataConverter.h"
#import "TreeTableView.h"
#import "TreeNode.h"

@interface TreeDataConverter ()

@property(nonatomic, strong) NSMutableArray<TreeNode *> *nodeList;

@property(nonatomic, weak) TreeTableView *tableView;

@end

@implementation TreeDataConverter {

}

- (instancetype)initWithTableView:(TreeTableView *)tableView {
    self = [super init];
    if (self) {
        _tableView = tableView;
    }

    return self;
}


- (void)updateNodes {
    NSArray *rootNodes = [self.dataSource tableViewRootNodes:_tableView];

    if (_nodeList) {
        [_nodeList removeAllObjects];
    } else {
        _nodeList = [NSMutableArray array];
    }

    for (TreeNode *treeNode in rootNodes) {
        [self traceNodeData:treeNode expandByParent:YES insertRowDataList:_nodeList atLevel:0];
    }
}

- (void)traceNodeData:(TreeNode *)node expandByParent:(BOOL)expandByParent insertRowDataList:(NSMutableArray *)showDataList atLevel:(NSUInteger)level {
    node.level = level;
    if (expandByParent) {
        [showDataList addObject:node];
    }
    for (TreeNode *childNode in node.childNodes) {
        [self traceNodeData:childNode expandByParent:expandByParent && node.expand insertRowDataList:showDataList atLevel:level + 1];
    }
}

- (NSUInteger)fixedHeaderCountFromRowIndex:(NSUInteger)rowIndex {
    TreeNode *node = _nodeList[rowIndex];
    TreeNode *nextCellData = _nodeList[rowIndex + 1];
    if (!node || !nextCellData) {
        return 0;
    }
    NSUInteger loopCount = 0;
    while (loopCount <= node.level) {
        loopCount++;
        node = _nodeList[rowIndex + loopCount];
    }
    return loopCount;
}


- (TreeNode *)headerOfLevel:(NSInteger)level forRowIndex:(NSUInteger)index {
    TreeNode *cellData = _nodeList[index];
    if (!cellData) {
        return nil;
    }
    if (cellData.level == level) {
        return cellData;
    } else if (cellData.level > level && cellData.parentNode) {
        return [self headerOfLevel:level forRowIndex:[_nodeList indexOfObject:cellData.parentNode]];
    }
    return nil;
}

- (TreeNode *)nodeAtIndexRowIndex:(NSUInteger)index {
    return _nodeList[index];
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate tableView:_tableView didSelectCell:_nodeList[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate tableView:_tableView heightForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(tableViewDidScroll:)]) {
        [_delegate tableViewDidScroll:_tableView];
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _nodeList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource tableView:_tableView cellForRowAtTreeNode:_nodeList[indexPath.row]];
}


#pragma mark - Getters & Setters

- (void)setDataSource:(id <TreeTableViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self updateNodes];
    }
}


@end