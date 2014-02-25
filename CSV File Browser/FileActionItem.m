//
//  fileActionItem.m
//  CSV File Browser
//
//  Created by Jack James on 24/02/2014.
//  Copyright (c) 2014 Jack James. All rights reserved.
//

#import "FileActionItem.h"

@implementation FileActionItem

-(id) init {
    self = [super init];
    if(self) {
        self.filename = @"filename.ext";
        self.sourcePath = nil;
        self.destinationPath = nil;
        self.status = nil;
    }
    return self;
}

@end
