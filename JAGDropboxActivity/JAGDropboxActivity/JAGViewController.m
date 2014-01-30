//
//  JAGViewController.m
//  JAGDropboxActivity
//
//  Created by Jake Glass on 1/29/14.
//  Copyright (c) 2014 Jake Glass. All rights reserved.
//

#import "JAGViewController.h"

@implementation JAGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButton:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* example code you can follow to make the dropbox upload work
 ***
 ***
 ***
 ***
 ***
*/
-(void)saveButton:(id)sender

{
    //make a UIAlertView to prompt the user for the filename
    UIAlertView *sphere=[[UIAlertView alloc]initWithTitle:@"Enter Filename" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    sphere.alertViewStyle=UIAlertViewStylePlainTextInput;
    [sphere show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //continue with save process
    if(buttonIndex!=0){
        fileName=[alertView textFieldAtIndex:0].text;
        
        [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] keyWindow] rootViewController].view animated:YES];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self saveProcess]; //start saving the doc
        });
    }
}

-(void)saveProcess
{
    //let the user know we're working with a handy loading indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //check for the filetype--did the user add one? if not, you'll probably want to add an extension
    if ([fileName rangeOfString:@".pdf"].location == NSNotFound) {
        fileName=[fileName stringByAppendingString:@".pdf"];
    }
    
    //<INSERT DOCUMENT SAVING CODE HERE>
    
    //get the path of the file we just saved
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    
    //Set up some NSUserDefaults objects so we can save the filePaths and access them later
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *currentFileList=[prefs objectForKey:@"fileList"];
    
    //if there's nothing in NSUserDefaults yet, create the array
    if(currentFileList==nil){
        currentFileList=[[NSMutableArray alloc]init];
    }
    
    //make a new array to overwrite the old one with
    NSMutableArray *uberList=[NSMutableArray arrayWithArray:currentFileList];
    [uberList setObject:filePath atIndexedSubscript:[uberList count]];
    
    //add it to
    [prefs setObject:uberList forKey:@"fileList"];
    [prefs synchronize];
    
    //create the sharing pane as a UIActivityView
    _dbUploader=[[JAGDropboxActivity alloc]init];
    _shareMenu=[[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObject:[NSURL fileURLWithPath:filePath]] applicationActivities:@[_dbUploader]];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //present the share menu as a popover from the left bar button item
    _sharePopup=[[UIPopoverController alloc]initWithContentViewController:_shareMenu];
    [_sharePopup presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
@end
