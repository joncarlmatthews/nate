//
//  AudioUtility.m
//  nate
//
//  Created by Jon Carl Matthews on 01/03/2014.
//  Copyright (c) 2014 Jon Carl Matthews. All rights reserved.
//

#import "AudioUtility.h"

@implementation AudioUtility

-(bool)performPrerequisiteCheckWithError:(NSError **)error
{
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
    
    return true;
}

-(NSString *)calculateBitRateOfURL:(NSURL *)url error:(NSError **)error
{

    // Check the type of URL.
    if (![url isFileURL]){
        
        NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc] init];
        [errorInfo setValue:@"URL is not a file resource" forKey:NSLocalizedDescriptionKey];
        
        *error = [[NSError alloc] initWithDomain:@"nate.joncarlmatthews.com"
                                            code:1
                                            userInfo:errorInfo];
        return nil;
    }
    
    bool bitRateFound = false;
    
    // Use the native mdls utility.
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/mdls"];
    
    // Create the task's arguments (single file path argument in this case).
    NSArray *arguments = [NSArray arrayWithObjects: [url path], nil];
    [task setArguments: arguments];
    
    // Create the pipe object for data transfer from mdls.
    NSPipe *pipe = [[NSPipe alloc] init];
    
    // Pass the pipe object to the task object.
    [task setStandardOutput: pipe];
    
    // Create the file handle for capturing the pipe's data stream.
    NSFileHandle *file = [[NSFileHandle alloc] init];
    
    // Get the handle for reading the stream from the pipe object.
    file = [pipe fileHandleForReading];
    
    // Run the mdls utility.
    @try {
        
        [task launch];
        
        // Create a NSData instance for capturing the data of the file handle read.
        NSData *mdlsData = [[NSData alloc] init];
        mdlsData = [file readDataToEndOfFile];
        
        // Conver the NSData into an NSString so we can find the attribute we're looking for.
        NSString *mdlsDataString;
        mdlsDataString = [[NSString alloc] initWithData: mdlsData encoding: NSUTF8StringEncoding];
        
        // Split the mdls output string on newline.
        NSArray *mdlsLines = [mdlsDataString componentsSeparatedByString:@"\n"];
        
        // Create regex pattern to match the bit rate label (key)
        NSString *brkRegexPattern = [[NSString alloc] initWithUTF8String:"kMDItemAudioBitRate"];
        
        // Build the bit rate key expression.
        NSError *brkRegexError = nil;
        NSRegularExpression *brkRegex = [NSRegularExpression regularExpressionWithPattern:brkRegexPattern
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&brkRegexError];
        
        // Loop through each of the lines.
        for (NSString *mdlsLine in mdlsLines) {
            
            // Perform the expression.
            NSUInteger brkRegexMatchCount = [brkRegex numberOfMatchesInString:mdlsLine
                                                                      options:0
                                                                        range:NSMakeRange(0, [mdlsLine length])];
            
            if (1 == brkRegexMatchCount){
                
                // Bit rate value regex
                NSError *brvRegexError = nil;
                NSRegularExpression *brvRegex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+"
                                                                                          options:NSRegularExpressionCaseInsensitive
                                                                                            error:&brvRegexError];
                
                // Perform the expression using the match count method.
                NSUInteger brvRegexMatchCount = [brvRegex numberOfMatchesInString:mdlsLine
                                                                          options:0
                                                                            range:NSMakeRange(0, [mdlsLine length])];
                
                // Was the bitrate value found?
                if (1 == brvRegexMatchCount){
                    
                    // Get the range of the match.
                    NSRange rangeOfFirstMatch = [brvRegex rangeOfFirstMatchInString:mdlsLine
                                                                            options:0
                                                                              range:NSMakeRange(0, [mdlsLine length])];
                    
                    // Was the range found?
                    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                        
                        bitRateFound = true;
                        
                        // Substring the matched line with the range of the regex.
                        NSString *fullBitRateValue = [mdlsLine substringWithRange:rangeOfFirstMatch];
                        
                        // Strip trailing zeros.
                        NSError *error = nil;
                        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0]{0,3}$"
                                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                                 error:&error];
                        NSString *formattedBitRateValue = [regex stringByReplacingMatchesInString:fullBitRateValue
                                                                                          options:0
                                                                                            range:NSMakeRange(0, [fullBitRateValue length])
                                                                                     withTemplate:@""];
                        
                        return formattedBitRateValue;
                        
                    }
                }
                
                break;
                
            } // bit rate key match count
            
            
        } // for
        
        if (!bitRateFound){
            
            NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc] init];
            [errorInfo setValue:@"Bit Rate not found" forKey:NSLocalizedDescriptionKey];
            
            *error = [[NSError alloc] initWithDomain:@"nate.joncarlmatthews.com"
                                                code:1
                                            userInfo:errorInfo];
            return nil;
        
        }
        
    }@catch (NSException *e) {
        
        NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc] init];
        [errorInfo setValue:@"Cannot read file" forKey:NSLocalizedDescriptionKey];
        
        *error = [[NSError alloc] initWithDomain:@"nate.joncarlmatthews.com"
                                            code:1
                                        userInfo:errorInfo];
        return nil;
        
    }
}

@end
