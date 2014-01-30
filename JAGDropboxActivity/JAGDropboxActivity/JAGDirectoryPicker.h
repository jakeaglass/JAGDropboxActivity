//
//  SQUDirectoryPicker.h
//  ÜberHighlighter
//
//  Created by Jake Glass on 11/22/13.
//  Copyright (c) 2013 Squee! Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "MBProgressHUD.h"

@interface JAGDirectoryPicker : UITableViewController
{
    NSMutableArray *dataArray;
    NSString *currentDirectory;
}

@property (nonatomic, strong) DBRestClient *restClient;

-(NSString *)getDirectory;
-(void)upDirectory;
-(void)modalDismiss;

@end
