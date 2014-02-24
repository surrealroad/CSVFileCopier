//
//  AppDelegate.h
//  CSV File Browser
//
//  Created by Jack James on 20/02/2014.
//  Copyright (c) 2014 Jack James. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CSVParser.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong) CSVParser *csvParser;
@property (strong) NSString *destinationFolder;

@end
