//
//  MJKRecord+DDL.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord+DDL.h"
#import "MJKDatabaseDAO.h"
#import "MJKDatabaseDAO+DDL.h"
#import "MJKRecord+Additions.h"
#import "MJKPropertyAnalyzer.h"

@implementation MJKRecord (DDL)

- (BOOL)createTable {
    return [[MJKDatabaseDAO sharedInstance] createTable:[self tableName] constraints:[[self class] constraints] indexes:[[self class] indexes] forClass:[self class]];
}

- (BOOL)dropTable {
    BOOL result = YES;
    NSArray<NSString *> *propertyList = [self getColumns];
    NSArray *valueList = [MJKPropertyAnalyzer getColumnsValueListWithPropertyList:propertyList forObject:self];
    
    for (id value in valueList) {
        if ([value isKindOfClass:[MJKRecord class]]) {
            result = [(MJKRecord *)value dropTable];
            if (!result) {
                return result;
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            MJKRecord *record = [value firstObject];
            result = [record dropTable];
            if (!result) {
                return result;
            }
        }
    }

    return [[MJKDatabaseDAO sharedInstance] dropTable:[self tableName]];
}

- (BOOL)createIndex:(NSString *)indexName onColumn:(id)column isUnique:(BOOL )isUnique {
    return [[MJKDatabaseDAO sharedInstance] createIndex:indexName onColumn:column isUnique:isUnique forTable:[self tableName]];
}

- (BOOL)dropIndex:(NSString *)indexName {
    return [[MJKDatabaseDAO sharedInstance] dropIndex:indexName];
}

- (BOOL)renameTable:(NSString *)tableName toTableNewName:(NSString *)tableNewName {
    return [[MJKDatabaseDAO sharedInstance] renameTable:tableName toTableNewName:tableNewName];
}

- (BOOL)addColumn:(NSString *)column type:(NSString *)type {
    return [self addColumn:column type:type constraint:nil];
}

- (BOOL)addColumn:(NSString *)column type:(NSString *)type constraint:(NSString *)constraint {
    return [[MJKDatabaseDAO sharedInstance] addColumn:column type:type constraint:constraint forTable:[self tableName]];
}

@end
