//
//  FileListHelper.m
//  CSV File Browser
//
//  Created by Jack James on 21/02/2014.
//  Copyright (c) 2014 Jack James. All rights reserved.
//

#import "FileListHelper.h"

@implementation FileListHelper

NSArray *sourceFolders;
NSArray *fileList;

-(void) awakeFromNib {
    sourceFolders = [NSLocale preferredLanguages];
    fileList = [NSLocale preferredLanguages];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if([[aTableView identifier]  isEqualToString:@"sourceFolders"]) return [sourceFolders count];
    else if([[aTableView identifier] isEqualToString:@"fileList"]) return [fileList count];
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if([aTableView.identifier isEqualToString:@"sourceFolders"]) return [sourceFolders objectAtIndex:rowIndex];
    else if([aTableView.identifier isEqualToString:@"fileList"]) {
        if([aTableColumn.identifier isEqualToString:@"file"]) return [fileList objectAtIndex:rowIndex];
        else if([aTableColumn.identifier isEqualToString:@"source"]) return [fileList objectAtIndex:rowIndex];
        else if([aTableColumn.identifier isEqualToString:@"destination"]) return [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:[fileList objectAtIndex:rowIndex]];
    }
    return nil;
}


@end
