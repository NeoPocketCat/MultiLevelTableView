//
// Created by neo on 2017/3/22.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TestView.h"
#import "TreeTableView.h"
#import "TreeNode.h"

@interface TestView () <TreeTableViewDataSource, TreeTableViewDelegate>

@property(nonatomic, strong) TreeTableView *treeTableView;

@property(nonatomic, strong) NSArray *rootNodes;

@end

@implementation TestView {

}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayout];
    }

    return self;
}


- (void)initLayout {
    [self addSubview:self.treeTableView];
}

#pragma #mark - TreeTableViewDelegate

- (CGFloat)tableView:(TreeTableView *)tableView heightForCell:(TreeNode *)treeNode {
    return 40;
}

- (void)tableView:(TreeTableView *)tableView didSelectCell:(TreeNode *)treeNode {
    NSLog(@"select cells: %@: ", treeNode);
}

- (void)tableViewDidScroll:(TreeTableView *)tableView {

}


#pragma #mark - TreeTableViewDataSource


- (NSArray<TreeNode *> *)tableViewRootCells:(TreeTableView *)tableView {
    return self.rootNodes;
}

- (UITableViewCell *)tableView:(TreeTableView *)tableView cellForRowAtTreeNode:(TreeNode *)treeNode {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor yellowColor];
    }

    cell.textLabel.text = treeNode.customData;
    cell.indentationLevel = treeNode.level;

    return cell;
}


#pragma #mark - Getters & Setters

- (TreeTableView *)treeTableView {
    if (!_treeTableView) {
        _treeTableView = [[TreeTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _treeTableView.delegate = self;
        _treeTableView.dataSource = self;
        _treeTableView.fixHeader = YES;
    }

    return _treeTableView;
}


- (NSArray *)rootNodes {
    if (!_rootNodes) {
        NSMutableArray *rootNodes = [NSMutableArray array];

        for (NSUInteger index1 = 0; index1 < 10; index1++) {
            TreeNode *nodeLevel1 = [[TreeNode alloc] init];
            nodeLevel1.customData = [NSString stringWithFormat:@"Level: 1, index:%d", index1];
            NSMutableArray *nodeLevel1Children = [NSMutableArray array];
            for (NSUInteger index2 = 0; index2 < 3; index2++) {
                TreeNode *nodeLevel2 = [[TreeNode alloc] init];
                nodeLevel2.customData = [NSString stringWithFormat:@"Level: 2, index:%d", index2];
                NSMutableArray *nodeLevel2Children = [NSMutableArray array];
                for (NSUInteger index3 = 0; index3 < 5; index3++) {
                    TreeNode *nodeLevel3 = [[TreeNode alloc] init];
                    nodeLevel3.customData = [NSString stringWithFormat:@"Level: 3, index:%d", index3];
                    nodeLevel3.parentNode = nodeLevel2;
                    [nodeLevel2Children addObject:nodeLevel3];
                }
                nodeLevel2.parentNode = nodeLevel1;
                nodeLevel2.expand = YES;
                nodeLevel2.childNodes = nodeLevel2Children;
                [nodeLevel1Children addObject:nodeLevel2];
            }
            nodeLevel1.expand = YES;
            nodeLevel1.childNodes = nodeLevel1Children;
            [rootNodes addObject:nodeLevel1];
        }

        _rootNodes = rootNodes;


    }
    return _rootNodes;
}


@end