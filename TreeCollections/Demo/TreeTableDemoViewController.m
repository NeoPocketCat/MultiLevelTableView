//
// Created by neo on 2017/11/27.
// Copyright (c) 2017 neo. All rights reserved.
//

#import "TreeTableDemoViewController.h"
#import "TreeTableView.h"
#import "TreeNode.h"


@interface TreeTableDemoViewController () <TreeTableViewDataSource, TreeTableViewDelegate>

@property(nonatomic, strong) TreeTableView *treeTableView;

@property(nonatomic, strong) NSArray *rootNodes;

@end

@implementation TreeTableDemoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.treeTableView];
}


#pragma #mark - TreeTableViewDelegate

- (CGFloat)tableView:(TreeTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(TreeTableView *)tableView didSelectCell:(TreeNode *)treeNode {
    NSLog(@"select cells: %@: ", treeNode);
}

- (void)tableViewDidScroll:(TreeTableView *)tableView {

}


#pragma #mark - TreeTableViewDataSource


- (NSArray<TreeNode *> *)tableViewRootNodes:(TreeTableView *)tableView {
    return self.rootNodes;
}

- (UITableViewCell *)tableView:(TreeTableView *)tableView cellForRowAtTreeNode:(TreeNode *)treeNode {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }

    cell.textLabel.text = treeNode.customData;
    cell.indentationLevel = treeNode.level;

    return cell;
}


#pragma #mark - Getters & Setters

- (TreeTableView *)treeTableView {
    if (!_treeTableView) {
        _treeTableView = [[TreeTableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        _treeTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _treeTableView.delegate = self;
        _treeTableView.dataSource = self;
        _treeTableView.fixHeader = YES;
        _treeTableView.innerTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
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
                for (NSUInteger index3 = 0; index3 < 3; index3++) {
                    TreeNode *nodeLevel3 = [[TreeNode alloc] init];
                    nodeLevel3.customData = [NSString stringWithFormat:@"Level: 3, index:%d", index3];
                    NSMutableArray *nodeLevel3Children = [NSMutableArray array];
                    for (NSUInteger index4 = 0; index4 < 5; index4++) {
                        TreeNode *nodeLevel4 = [[TreeNode alloc] init];
                        nodeLevel4.customData = [NSString stringWithFormat:@"Level: 4, index:%d", index4];
                        nodeLevel4.parentNode = nodeLevel3;
                        [nodeLevel3Children addObject:nodeLevel4];
                    }
                    nodeLevel3.parentNode = nodeLevel2;
                    nodeLevel3.expand = YES;
                    nodeLevel3.childNodes = nodeLevel3Children;
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