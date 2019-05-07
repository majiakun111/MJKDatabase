//
//  MJKRecord+DML.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord+DML.h"
#import "MJKDatabaseDefine.h"
#import "MJKDatabaseDAO.h"
#import "MJKDatabaseDAO+DML.h"
#import "MJKDatabaseDAO+Additions.h"
#import "MJKRecord+Additions.h"
#import "MJKRecord+Condition.h"
#import "MJKRecord+Additions.h"
#import "MJKRecord+DDL.h"
#import "MJKPropertyAnalyzer.h"

@implementation MJKRecord (DML)

- (BOOL)save {
    BOOL result = YES;
    
    [self saveBefore];
    
    result = [self insert];
    
    [self saveAfter];
    
    return result;
}

- (BOOL)delete {
    [self deleteBefore];
    
    BOOL result = YES;
    
    //删除关联的表对应的数据
    NSArray<NSString *> *propertyList = [self getColumns];
    NSArray *valueList = [MJKPropertyAnalyzer getColumnsValueListWithPropertyList:propertyList forObject:self];
    
    for (NSInteger index = 0; index < [valueList count]; index++) {
        id value = valueList[index];
        if ([value isKindOfClass:[MJKRecord class]]) {
            
            [(MJKRecord *)value setWhere:@{ROW_ID : @([(MJKRecord *)value rowId])}];
            result = [(MJKRecord *)value delete];
            if (!result) {
                return result;
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (MJKRecord *record in value) {
                [record setWhere:@{ROW_ID : @([record rowId])}];
                result = [record delete];
                if (!result) {
                    return result;
                }
            }
        }
    }
    
    result = [[MJKDatabaseDAO sharedInstance] deleteWithWhere:self.where forTable:[self tableName]];
    
    [self deleteAfter];
    
    return result;
}

- (BOOL)update {
    [self updateBefore];
    
    BOOL result = [[MJKDatabaseDAO sharedInstance] updateWithUpdateField:self.updateField where:self.where forTable:[self tableName]];

    [self updateAfter];
    
    return result;
}

#pragma mark - Hook Method

- (void)saveBefore{}

- (void)saveAfter{}

- (void)deleteBefore{}

- (void)deleteAfter{}

- (void)updateBefore{}

- (void)updateAfter{}

#pragma mark - PrivateMethod

- (BOOL)insert {
    NSArray<NSString *> *propertyList = [self getColumns];
    NSArray *valueList = [MJKPropertyAnalyzer getColumnsValueListWithPropertyList:propertyList forObject:self];
    
    NSMutableString *valuesSql = [NSMutableString string];
    NSInteger count = [valueList count];
    for (NSInteger index = 0; index < count; index++) {
        id value = valueList[index];
        
        if ([value isKindOfClass:[MJKRecord class]]) {
            [value save];
            
            long long lastRowId = [[MJKDatabaseDAO sharedInstance] lastInsertRowId];
            [valuesSql appendFormat:@"'%lld'", lastRowId];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *rowIds = [NSMutableArray array];
            for (MJKRecord *record in value) {
                BOOL result =  [record save];
                if (result) {
                    long long rowId = [[MJKDatabaseDAO sharedInstance] lastInsertRowId];
                    [rowIds addObject: @(rowId)];
                }
            }
            
            [valuesSql appendFormat:@"'%@'", [rowIds componentsJoinedByString:@","]];
        } else {
            [valuesSql appendFormat:@"'%@'", value];
        }
        
        if (index != count - 1) {
            [valuesSql appendString:@", "];
        }
    }
    
    return [[MJKDatabaseDAO sharedInstance] insertWithFields:[propertyList componentsJoinedByString:@", "] values:valuesSql forTable:[self tableName]];
}

@end
