//
//  MainViewController.m
//  FaceUnityDemo
//
//  Created by Elf Sundae on 2020/03/23.
//  Copyright © 2020 https://0x123.com . All rights reserved.
//

#import "MainViewController.h"
#import <FaceUnity/FaceUnity.h>
#import <ESFramework/ESFramework.h>

static NSString *const CellReuseIdentifier = @"CellReuseIdentifier";

@interface MainViewController ()

@end

@implementation MainViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = UIApplication.sharedApplication.appDisplayName;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellReuseIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"美颜设置";
            break;

        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[FUPreviewViewController new] animated:YES];
            break;

        default:
            break;
    }
}

@end
