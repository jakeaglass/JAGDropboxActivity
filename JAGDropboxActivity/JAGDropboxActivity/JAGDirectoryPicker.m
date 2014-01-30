//
//  JAGDirectoryPicker.m
//
//  Created by Jake Glass on 11/22/13.
//  Copyright (c) 2013 Jake Glass. All rights reserved.
//

#import "JAGDirectoryPicker.h"

@implementation JAGDirectoryPicker

//dataArray is the array of folder directory names in the current folder
//currentDirectory is a string object with the currently navigated path

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if(currentDirectory==nil){
        currentDirectory=@"/";
    }
    [[self restClient] loadMetadata:currentDirectory];
    
    if (self = [super initWithStyle:style])
    {
        self.title = [NSString stringWithFormat:@"Choose Dropbox Directory: %@",currentDirectory];
    }

    return self;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId=@"Cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text=[dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([currentDirectory isEqual:@"/"]){
        currentDirectory=[currentDirectory stringByAppendingString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    }
    else{
        currentDirectory=[currentDirectory stringByAppendingString:[@"/" stringByAppendingString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text]];
    }
    
    //load the directory
    [[self restClient] loadMetadata:currentDirectory];
    
}

-(NSString *)getDirectory
{
    return currentDirectory;
}

-(void)upDirectory
{
    if(![currentDirectory isEqualToString:@"/"]){
        NSArray *newDirectory=[currentDirectory componentsSeparatedByString:@"/"];
        NSMutableArray *newNewDirectory=[NSMutableArray arrayWithArray:newDirectory];
        [newNewDirectory removeObjectAtIndex:([newNewDirectory count]-1)];
        
        currentDirectory=[newNewDirectory componentsJoinedByString:@"/"];
        
        [self.restClient loadMetadata:currentDirectory];
    }
}
-(void)modalDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        
        //load only the contents of the new directory
        dataArray=[[NSMutableArray alloc]init];
        
        for (DBMetadata *file in metadata.contents) {
            if(file.isDirectory){
                [dataArray addObject:file.filename];
            }
        }
        //reload self
        
        //if we're at the top level of the directory, then allow them to cancel
        if([currentDirectory isEqualToString:@""] || [currentDirectory isEqualToString:@"/"]){
            self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(modalDismiss)];
        }
        else{
            self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back-small.png"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(upDirectory)];
        }
        
        self.title = [NSString stringWithFormat:@"Choose Dropbox Directory: %@",currentDirectory];
        [self.tableView reloadData];
    }
}


@end
