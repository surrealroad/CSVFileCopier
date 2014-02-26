//
//  fileActionItem.h
//  CSV File Browser
//
//  Created by Jack James on 24/02/2014.
//  Copyright (c) 2014 Jack James. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileActionItem : NSObject

@property (strong) NSString *filename;
@property (strong) NSURL *sourcePath;
@property (strong) NSURL *destinationPath;
@property (strong) NSString *status;


@end
