//
//  AppDelegate.m
//  CSV File Browser
//
//  Created by Jack James on 20/02/2014.
//  Copyright (c) 2014 Jack James. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.csvParser = [[CSVParser alloc]init];
    self.csvParser.csvFilePath = @"Test path.csv";
    self.destinationFolder = @"Test path";
}

@end
