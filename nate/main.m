//
//  main.m
//  nate
//
//  Created by Jon Carl Matthews on 01/03/2014.
//  Copyright (c) 2014 Jon Carl Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioUtility.h"

// Prototype for printBitRate method
void printBitRate(AudioUtility *au, NSURL *url, unsigned *bitRateableFilesFound, bool printFilePath);

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // Binary location:
        //NSLog(@"%s", argv[0]);
        
        if (argc <= 1) {
            
            // Output usage.
            printf("usage: nate [directory to search]\n");
            
            exit(1);
        }
        
        AudioUtility *au = [[AudioUtility alloc] init];
        
        NSError *error = nil;
        [au performPrerequisiteCheckWithError: &error];
        
        if (error != nil){
            printf([[error localizedDescription] UTF8String]);
            printf("\n");
            exit(2);
        }
        
        // Total number of valid files found.
        unsigned bitRateableFilesFound = 0;
        
        // Get the file path.
        NSString *filePath = [NSString stringWithUTF8String:argv[1]];
        
        // Create instance of NSFileManager for working with the file path.
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        // Does something exist at the location passed in?
        if (![fileManager fileExistsAtPath:filePath]) {
            printf("[error] no file or folder at that location found");
            printf("\n");
            exit(3);
        }
        
        NSString *fileType = nil;
        
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        fileType = attributes[NSFileType];
        
        if ([fileType isEqualToString:@"NSFileTypeDirectory"]){
            
            // Create a NSURL instance from the file path string.
            NSURL *directoryURL = [NSURL URLWithString:filePath];
            
            // Keys for then enumerator.
            NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
            
            // Enumerator for looping recursively over the given directory.
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
                    
                    // handle error?
                    
                }else if(! [isDirectory boolValue]) {
                    
                    // No error and it’s not a directory...
                    // Output the file's bit rate.
                    printBitRate(au, url, &bitRateableFilesFound, true);

                }
                
            }
            
        }else if ([fileType isEqualToString:@"NSFileTypeRegular"]){
            
            // Create an NSURL instance from the file path
            NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:filePath isDirectory: NO];
            
            // Output the file's bit rate.
            printBitRate(au, fileUrl, &bitRateableFilesFound, false);
            
        }else{
            
            // Unsupported
        }
        
        if (0 == bitRateableFilesFound){
            printf("No audio files found in %s", argv[1]);
            printf("\n");
            exit(4);
        }
        
    }
    
    return 0;
}

void printBitRate(AudioUtility *au, NSURL *url, unsigned *bitRateableFilesFound, bool printFilePath)
{
    // Get the file path
    NSString *filePath = [[url path] copy];
    
    // Audio file regex.
    NSError *fnRegexError = nil;
    NSRegularExpression *fnRegex = [NSRegularExpression regularExpressionWithPattern:@"(.mp3|.wav|.wma|.mid)$"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&fnRegexError];
    
    // Perform the expression using the match count method.
    NSUInteger fnRegexMatchCount = [fnRegex numberOfMatchesInString:filePath
                                                            options:0
                                                              range:NSMakeRange(0, [filePath length])];
    
    if (1 == fnRegexMatchCount){
        
        // Lookup Bit Rate.
        NSError *bitRateError = nil;
        
        NSString *bitRate = [NSString stringWithFormat:@"Bit Rate: %@kbps", [au calculateBitRateOfURL:url error:&bitRateError]];
        
        if (printFilePath){
            printf([filePath UTF8String]);
            printf(" ");
        }
        
        if (nil != bitRateError){
            
            if (printFilePath){
                printf(" ");
            }
            
            printf([[bitRateError localizedDescription] UTF8String]);
            
        }else{
        
            printf([bitRate UTF8String]);
            
            // Dereference counter variable.
            *bitRateableFilesFound = (*bitRateableFilesFound + 1);
        }
        
        
        printf("\n");
    }
}

