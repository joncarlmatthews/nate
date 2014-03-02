//
//  main.m
//  nate
//
//  Created by Jon Carl Matthews on 01/03/2014.
//  Copyright (c) 2014 Jon Carl Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        bool bitRateFound = false;
        
        NSMutableString *result = [[NSMutableString alloc] initWithString:@"Eminem - Rap God (Explicit).mp3"];
        
        // All of the code needs to be in a method that the file recursion will use.
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/mdls"];
        
        NSArray *arguments = [NSArray arrayWithObjects: @"/Users/joncarlmatthews/Music/testmp3s/Eminem - Rap God (Explicit).mp3", nil];
        [task setArguments: arguments];
        
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *mdlsData;
        mdlsData = [file readDataToEndOfFile];
        
        NSString *mdlsDataString;
        mdlsDataString = [[NSString alloc] initWithData: mdlsData encoding: NSUTF8StringEncoding];
        //NSLog (@"grep returned:\n%@", mdlsDataString);
        
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
                
                    NSRange rangeOfFirstMatch = [brvRegex rangeOfFirstMatchInString:mdlsLine
                                                            options:0
                                                            range:NSMakeRange(0, [mdlsLine length])];
                    
                    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                        
                        bitRateFound = true;
                        
                        NSString *substringForFirstMatch = [mdlsLine substringWithRange:rangeOfFirstMatch];
                        
                        NSString *bitRate = [NSString stringWithFormat:@"Bit Rate: %@", substringForFirstMatch];
                        
                        [result appendString:bitRate];
                        
                    }
                }
                
                break;
                
            } // bit rate key match count
            
            
        } // for
        
        if (!bitRateFound){
            NSLog(@"Bit Rate not found");
        }
        
        NSLog(result);
        
    }
    return 0;
}

