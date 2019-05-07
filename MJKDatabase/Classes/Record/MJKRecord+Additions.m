//
//  MJKRecord+Additions.m
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord+Additions.h"
#import "MJKDatabaseDAO+Additions.h"
#import "MJKDatabaseDefine.h"

@implementation MJKRecord (Additions)

- (NSArray<NSString *> *)getColumns {
    NSMutableArray *columns  = (NSMutableArray *)[[MJKDatabaseDAO sharedInstance] getColumnsForTableName:[self tableName]];
    [columns removeObject:ROW_ID];
    
    return columns;
}

@end
