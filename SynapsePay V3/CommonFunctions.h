//
//  CommonFunctions.h
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/21/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface CommonFunctions : NSObject

- (NSString *) baseURL;
- (NSString *) formURL:(NSString *)uri;
- (NSString *) makeErrorMessage:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation;
- (void) handleError:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation;
- (NSMutableString *) filteredStringFromString:(NSString *)string WithFilter:(NSString *)filter;
- (NSString *)getDateTime:(NSString *) unixTimeStamp;
- (NSString *) getLastObject:(NSArray *)array;
- (NSString *)fingerprint;
- (NSString *)oid;
- (NSString *)refreshToken;
- (NSString *)oauthKey;
- (NSString *)clientID;
- (NSString *)clientSecret;
- (void)setOID:(NSString *)oid;
- (void)setRefreshToken:(NSString *)refresh_token;
- (void)setOauthKey:(NSString *)oauth_key;
- (void)signout;
@end
