//
//  CommonFunctions.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/21/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "CommonFunctions.h"
#import "SCLAlertView.h"
#import "JTProgressHUD.h"
#import <DMPasscode/DMPasscode.h>
#import "JNKeychain.h"
#import <DMPasscode/DMPasscode.h>

@implementation CommonFunctions

- (NSString *) baseURL{
    if ([self getConfigDict][@"IS_DEV"]) {
        return [self getConfigDict][@"SANDBOX_BASE_URL"];
    }
    return [self getConfigDict][@"PROD_BASE_URL"];
}

- (NSString *) formURL:(NSString *)uri{
    return [NSString stringWithFormat:@"%@%@",[self baseURL],uri];
}

- (NSDictionary *) getConfigDict{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    return dict;
}

- (NSString *)makeErrorMessage:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation{
    
    //good resource http://nshipster.com/nserror/
    
    switch (error.code) {
            // NSURLErrorDomain & CFNetworkErrors
            // SOCKS4 Errors
            // SOCKS5 Errors
            // FTP Errors
            
#pragma mark HTTP Errors
            
        case kCFErrorHTTPAuthenticationTypeUnsupported:
            break;
        case kCFErrorHTTPBadCredentials:
            break;
        case kCFErrorHTTPConnectionLost:
            break;
        case kCFErrorHTTPParseFailure:
            break;
        case kCFErrorHTTPRedirectionLoopDetected:
            break;
        case kCFErrorHTTPBadURL:
            break;
        case kCFErrorHTTPProxyConnectionFailure:
            break;
        case kCFErrorHTTPBadProxyCredentials:
            break;
        case kCFErrorPACFileError:
            break;
        case kCFErrorPACFileAuth:
            break;
        case kCFErrorHTTPSProxyConnectionFailure:
            break;
        case kCFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod:
            break;
        default:
            break;
            // CFURLConnection & CFURLProtocol Errors
            // File Errors
            // SSL Errors
            // Download and File I/O Errors
            // Cookie errors
            // CFNetServices Errors
            //
    }
    return operation.responseObject[@"error"][@"en"];
}

-(void)handleError:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation{
    [JTProgressHUD hide];
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showNotice:@"Error!" subTitle:[self makeErrorMessage:error withOperation:operation] closeButtonTitle:@"Done" duration:0.0f]; // Notice
}


- (NSMutableString *) filteredStringFromString:(NSString *)string WithFilter:(NSString *)filter
{
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[([filter length])];
    BOOL done = NO;
    
    while(onFilter < [filter length] && !done)
    {
        char filterChar = [filter characterAtIndex:onFilter];
        char originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar) {
            case '#':
                if(originalChar=='\0')
                {
                    // We have no more input numbers for the filter.  We're done.
                    done = YES;
                    break;
                }
                if(isdigit(originalChar))
                {
                    outputString[onOutput] = originalChar;
                    onOriginal++;
                    onFilter++;
                    onOutput++;
                }
                else
                {
                    onOriginal++;
                }
                break;
            default:
                // Any other character will automatically be inserted for the user as they type (spaces, - etc..) or deleted as they delete if there are more numbers to come.
                outputString[onOutput] = filterChar;
                onOutput++;
                onFilter++;
                if(originalChar == filterChar)
                    onOriginal++;
                break;
        }
    }
    outputString[onOutput] = '\0'; // Cap the output string
    return [[NSString stringWithUTF8String:outputString] mutableCopy];
}

- (NSString *)getDateTime:(NSString *)unixTimeStamp{
    NSTimeInterval interval=[unixTimeStamp doubleValue];
    // convert mSec to sec, thats why dividing by 1000
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:interval/1000];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    NSString * dateString=[formatter stringFromDate:date];
    return dateString;
}

-(NSString *) getLastObject:(NSArray *)array{
    return [NSString stringWithFormat:@"%@",array[[array count]-1]];
}

- (NSString *)fingerprint{
    //just temp until signin flow is complete.
//    if ([self getConfigDict][@"IS_DEV"]) {
//        return @"suasusau21324redakufejfjsf";
//    }
    return [NSString stringWithFormat:@"%@-AAPL",[UIDevice currentDevice].identifierForVendor.UUIDString];
}

- (NSString *)oid{
    //just temp until signin flow is complete.
//    if ([self getConfigDict][@"IS_DEV"]) {
//        return @"557387ed86c27318532fc09a";
//    }
    if ([JNKeychain loadValueForKey:@"oid"]) {
        return [JNKeychain loadValueForKey:@"oid"];
    }
    return @"na";
}

- (NSString *)refreshToken{
    //just temp until signin flow is complete.
//    if ([self getConfigDict][@"IS_DEV"]) {
//        return @"YGpR6tQmkPfkHJeLu8ixKtktDMqS96xs7A2qcuRi";
//    }
    if ([JNKeychain loadValueForKey:@"refresh_token"]) {
        return [JNKeychain loadValueForKey:@"refresh_token"];
    }
    return @"na";
}

- (NSString *)oauthKey{
    //just temp until signin flow is complete.
//    if ([self getConfigDict][@"IS_DEV"]) {
//        return @"iuda3QJXoILdGQKaAcfi67EkGjMgQKOkEnl6irWC";
//    }
    if ([JNKeychain loadValueForKey:@"oauth_key"]) {
        return [JNKeychain loadValueForKey:@"oauth_key"];
    }
    return @"na";
}

- (NSString *)clientID{
    //just temp until signin flow is complete.
    if ([self getConfigDict][@"IS_DEV"]) {
        return [self getConfigDict][@"DEV_CLIENT_ID"];
    }
    return [self getConfigDict][@"CLIENT_ID"];
}

- (NSString *)clientSecret{
    //just temp until signin flow is complete.
    if ([self getConfigDict][@"IS_DEV"]) {
        return [self getConfigDict][@"DEV_CLIENT_SECRET"];
    }
    return [self getConfigDict][@"CLIENT_SECRET"];
}

- (void)setOID:(NSString *)oid{
    if ([JNKeychain saveValue:oid forKey:@"oid"]) {
        
    } else {
        [self setOID:oid];
    }
}

- (void)setRefreshToken:(NSString *)refresh_token{
    if ([JNKeychain saveValue:refresh_token forKey:@"refresh_token"]) {
        
    } else {
        [self setRefreshToken:refresh_token];
    }
}

- (void)setOauthKey:(NSString *)oauth_key{
    if ([JNKeychain saveValue:oauth_key forKey:@"oauth_key"]) {
        
    } else {
        [self setOauthKey:oauth_key];
    }
}

- (void)signout{
    if ([JNKeychain deleteValueForKey:@"oauth_key"] && [JNKeychain deleteValueForKey:@"refresh_token"] && [JNKeychain deleteValueForKey:@"oid"]) {
        
    } else {
        [self signout];
    }
    
    if ([DMPasscode isPasscodeSet]) {
        [DMPasscode removePasscode];
    }
}

@end
