//
//  MJKRecord+Transaction.m
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord+Transaction.h"
#import "MJKDatabaseDAO.h"
#import "MJKDatabaseDAO+Transaction.h"

@implementation MJKRecord (Transaction)

- (BOOL)beginDeferredTransaction {
    return [[MJKDatabaseDAO sharedInstance] beginDeferredTransaction];
}

- (BOOL)beginImmediateTransaction {
    return [[MJKDatabaseDAO sharedInstance] beginImmediateTransaction];
}

- (BOOL)beginExclusiveTransaction {
    return [[MJKDatabaseDAO sharedInstance] beginExclusiveTransaction];
}

- (BOOL)startSavePointWithName:(NSString*)name {
    return [[MJKDatabaseDAO sharedInstance] startSavePointWithName:name];
}

- (BOOL)releaseSavePointWithName:(NSString*)name {
    return [[MJKDatabaseDAO sharedInstance] releaseSavePointWithName:name];
}

- (BOOL)rollbackToSavePointWithName:(NSString*)name {
    return [[MJKDatabaseDAO sharedInstance] rollbackToSavePointWithName:name];
}

- (BOOL)rollback {
    return [[MJKDatabaseDAO sharedInstance] rollback];
}

- (BOOL)commit {
    return [[MJKDatabaseDAO sharedInstance] commit];
}
@end
