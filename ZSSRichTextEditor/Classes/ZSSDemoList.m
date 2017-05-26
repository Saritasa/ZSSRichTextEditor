//
//  ZSSDemoList.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 8/12/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import "ZSSDemoList.h"
#import "ZSSDefaultViewController.h"

@interface ZSSDemoList ()
@property (nonatomic) BOOL isIPad;
@end

@implementation ZSSDemoList

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ZSSRichTextEditor Demo";
    
    self.isIPad = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad );
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //if (self.isIPad) return 6;
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Standard";
        cell.detailTextLabel.text = @"Default implementation";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Toolbar Colors";
        cell.detailTextLabel.text = @"Custom button and selected button colors";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Selective Buttons";
        cell.detailTextLabel.text = @"Pick and choose the features you want";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Custom Buttons";
        cell.detailTextLabel.text = @"Add your own customized toolbar button";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"Large";
        cell.detailTextLabel.text = @"A large amount of content in the editor";
    } else if (indexPath.row == 5) {
        cell.textLabel.text = @"iPad Form Style Modal";
        cell.detailTextLabel.text = @"Shows a form style modal on the iPad";
    }
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ZSSDefaultViewController *controller = [[ZSSDefaultViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 1) {
    } else if (indexPath.row == 2) {
    } else if (indexPath.row == 3) {
    } else if (indexPath.row == 4) {
    } else if (indexPath.row == 5) {
    }
    
}

@end
