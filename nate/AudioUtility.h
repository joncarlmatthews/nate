//
//  AudioUtility.h
//  nate
//
//  Created by Jon Carl Matthews on 01/03/2014.
//  Copyright (c) 2014 Jon Carl Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioUtility : NSObject

-(bool)performPrerequisiteCheckWithError:(NSError **)error;

-(NSString *)calculateBitRateOfURL:(NSURL *)url error:(NSError **)error;

@end
