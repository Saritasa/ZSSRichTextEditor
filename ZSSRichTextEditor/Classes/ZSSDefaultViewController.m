//
//  ZSSDefaultViewController.m
//  ZSSRichTextEditor
//
//  Created by Aleksey Kuznetsov on 5/26/17.
//  Copyright © 2017 Zed Said Studio. All rights reserved.
//

#import "ZSSDefaultViewController.h"
#import "ZSSRichTextEditor.h"
#import "ZSSBarButtonItem.h"

@interface ZSSDefaultViewController ()

@property (nonatomic) ZSSRichTextEditor *editorView;

@end

@implementation ZSSDefaultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editorView = [[ZSSRichTextEditor alloc] init];
    [self.view addSubview:self.editorView];

    NSMutableArray *items = [[NSMutableArray alloc] init];
    ZSSBarButtonItem *item = nil;

    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeRemoveFormat];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeUndo];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeRedo];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeBold];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeItalic];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeStrikeThrough];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeUnderline];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeH1];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeH2];
    [items addObject:item];
    item = [ZSSBarButtonItem barButtonItemForItemType:ZSSBarButtonItemTypeH3];
    [items addObject:item];


    [self.editorView setToolbarItems:items animated:NO];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.editorView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 300.0);
}

@end
