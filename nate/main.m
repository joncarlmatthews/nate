//
//  main.m
//  nate
//
//  Created by Jon Carl Matthews on 01/03/2014.
//  Copyright (c) 2014 Jon Carl Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioUtility.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        if (argc <= 1) {
            
            // Output usage.
            printf("usage: nate [directory to search]\n");
            
            exit(1);
        }
        
        AudioUtility *au = [[AudioUtility alloc] init];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *directoryURL = [NSURL URLWithString:[NSString stringWithUTF8String:argv[1]]];
        NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
        
        NSDirectoryEnumerator *enumerator = [fileManager
                                             enumeratorAtURL:directoryURL
                                             includingPropertiesForKeys:keys
                                             options:0
                                             errorHandler:^(NSURL *url, NSError *error) {
                                                 // Handle the error.
                                                 // Return YES if the enumeration should continue after the error.
                                                 return YES;
                                             }];
        
        for (NSURL *url in enumerator) { 
            NSError *error;
            NSNumber *isDirectory = nil;
            if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
                // handle error
            }else if(! [isDirectory boolValue]) {
                
                // No error and it’s not a directory...
                
                // Get the file path
                NSString *filePath = [[url path] copy];
                
                // Audio file regex.
                NSError *fnRegexError = nil;
                NSRegularExpression *fnRegex = [NSRegularExpression regularExpressionWithPattern:@"(.mp3|.wav)$"
                                                                                          options:NSRegularExpressionCaseInsensitive
                                                                                            error:&fnRegexError];
                
                // Perform the expression using the match count method.
                NSUInteger fnRegexMatchCount = [fnRegex numberOfMatchesInString:filePath
                                                                          options:0
                                                                            range:NSMakeRange(0, [filePath length])];
                
                if (1 == fnRegexMatchCount){
                    
                    NSMutableString *result = [[NSMutableString alloc] initWithString:filePath];
                    
                    // Lookup Bit Rate.
                    NSError *bitRateError = nil;
                    
                    NSString *bitRate = [NSString stringWithFormat:@" Bit Rate: %@kbps", [au calculateBitRateOfURL: url error:&bitRateError]];
                    
                    printf([result UTF8String]);
                    
                    if (nil != bitRateError){
                        
                        printf(" ");
                        printf([[bitRateError localizedDescription] UTF8String]);
                        
                    }else{
                        printf(" ");
                        printf([bitRate UTF8String]);
                    }
                    
                    
                    printf("\n");
                }
                
            }
        }
        
        exit(0);
        
        /*
        
        // Test task call to see if the utility is at our disposal
        // before we enter into potential recursion.
        NSTask *testTask = [[NSTask alloc] init];
        [testTask setLaunchPath: @"/usr/bin/mdls"];
        [testTask setArguments: [NSArray arrayWithObjects: NSHomeDirectory(), nil]];
        NSPipe *testPipe = [[NSPipe alloc] init];
        [testTask setStandardOutput: testPipe];
        
        // Perform test
        @try {
            [testTask launch];
        }@catch (NSException *e) {
            NSString *error = [NSString stringWithFormat:@"[error] cannot load metadata tool (%@)", [e description]];
            printf([error UTF8String]);
            exit(1);
        }
        
        // All of this code needs to be in a method that the file recursion will use...
        
        // Total number of valid files found.
        unsigned bitRateableFilesFound = 0;
        
        // Was the loop's bit rate found?
        bool bitRateFound = false;
        
        
        
        // Output the result.
        printf([result UTF8String]);
        printf("\n");
        
        if (0 == bitRateableFilesFound){
            printf("No audio files found in /path ");
        }
         
         */

        
    }
    return 0;
}

