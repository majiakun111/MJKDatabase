//
//  DatabaseAutoMigrator.m
//  ActiveObject
//
//  Created by Ansel on 16/4/8.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKDatabaseAutoMigrator.h"
#import "MJKDatabaseDefine.h"
#import "MJKDatabaseDAO+DDL.h"
#import "MJKDatabaseDAO+Additions.h"
#import "MJKRecord+DDL.h"
#import "MJKPropertyAnalyzer.h"

@implementation MJKDatabaseAutoMigrator

- (BOOL)autoExecuteMigrate {
    NSArray<NSString *> *tableNames = [[MJKDatabaseDAO sharedInstance] getAllTableName];
    
    BOOL result = YES;
    for (NSString *tableName in tableNames) {
        result = [self executeColumnMigrateForTable:tableName];
        if (!result) {
            break;
        }
        
        result = [self executeIndexesMigrateForTable:tableName];
        if (!result) {
            break;
        }
    }
    
    return result;
}

#pragma mark - PrivateMethod

- (BOOL)executeColumnMigrateForTable:(NSString *)tableName {
    Class clazz = NSClassFromString(tableName);
    NSArray<MJKPropertyInfo *> *propertyInfoList = [MJKPropertyAnalyzer getPropertyInfoListForClass:clazz];
    
    NSArray *columns = [[MJKDatabaseDAO sharedInstance] getColumnsForTableName:tableName];
    
    NSMutableArray<MJKPropertyInfo *> *addColumns = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *deleteAfterColumns = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *needDeleteColumns = [[NSMutableArray alloc] init];

    for (MJKPropertyInfo *propertyInfo in propertyInfoList) {
        if (![columns containsObject:propertyInfo.propertyName]) {
            [addColumns addObject:propertyInfo];
        }
    }
    
    for (NSString *column in columns) {
        __block BOOL isContian = NO;
        [propertyInfoList enumerateObjectsUsingBlock:^(MJKPropertyInfo*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([propertyInfo.propertyName isEqualToString:column]) {
                *stop = YES;
                isContian = YES;
            }
        }];
        
        if (isContian) {
            [deleteAfterColumns addObject:column];
        } else {
            [needDeleteColumns addObject:column];
        }
    }
    
    BOOL result = YES;
    do {
        if ([deleteAfterColumns count] != [columns count]) {
            result = [self executeDeleteColumnsWithDeleteAfterColumns:deleteAfterColumns needDeleteColumns:needDeleteColumns forTable:tableName];
            
            if (!result) {
                break;
            }
        }
        
        if ([addColumns count] > 0) {
            result = [self executeAddColumns:addColumns forTable:tableName];
            
            if (!result) {
                break;
            }
        }
    } while (0);
    
    return result;
}

- (BOOL)executeAddColumns:(NSArray<MJKPropertyInfo *> *)columns forTable:(NSString *)tableName {
    BOOL result = YES;
    
    Class class = NSClassFromString(tableName);
    NSDictionary<NSString*, NSString*> *contraints = [class constraints];
    for (MJKPropertyInfo *propertyInfo in columns) {
        NSString *columnName = propertyInfo.propertyName;
        
        result = [[MJKDatabaseDAO sharedInstance] addColumn:propertyInfo.propertyName type:propertyInfo.databaseType constraint:contraints[columnName] forTable:tableName];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

//若删除的column对应table 自需要自己实现删除
- (BOOL)executeDeleteColumnsWithDeleteAfterColumns:(NSArray<NSString *> *)deleteAfterColumns needDeleteColumns:(NSArray<NSString *> *)needDeleteColumns forTable:(NSString *)tableName {
    BOOL result = YES;
        
    NSString *tmpTableName = [NSString stringWithFormat:@"tmp%@", tableName];
    result = [[MJKDatabaseDAO sharedInstance] renameTable:tableName toTableNewName:tmpTableName];
    if (!result) {
        return result;
    }
    
    Class class = NSClassFromString(tableName);
    result = [[MJKDatabaseDAO sharedInstance] createTable:tableName constraints:[class constraints] indexes:[class indexes] forClass:class];
    if (!result) {
        return result;
    }
    
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"insert into Person(%@) select %@ from %@", [deleteAfterColumns componentsJoinedByString:@", "], [deleteAfterColumns componentsJoinedByString:@", "], tmpTableName];
    
    result = [[MJKDatabaseDAO sharedInstance] executeUpdate:sql];
    if (!result) {
        return result;
    }
    
    result = [[MJKDatabaseDAO sharedInstance] dropTable:tmpTableName];
    
    return result;
}

- (BOOL)executeIndexesMigrateForTable:(NSString *)tableName {
    NSDictionary<NSString*, NSDictionary*> *sqliteMasteIndexes = [[MJKDatabaseDAO sharedInstance] getIndexesFromSqliteMasterForTable:tableName];
    
    Class class = NSClassFromString(tableName);
    NSDictionary<NSString*, NSDictionary*> *indexes = [class indexes];
    
    NSMutableDictionary<NSString*, NSDictionary*> *addIndexes = [NSMutableDictionary dictionary];
    NSMutableArray<NSString *> *deleteIndexNames = [[NSMutableArray alloc] init];
    
    NSArray *currentColumns = [sqliteMasteIndexes allKeys];
    NSArray *columns = [indexes allKeys];
    
    for (NSString *columnName in columns) {
        if (![currentColumns containsObject:columnName]) {
            [addIndexes setObject:indexes[columnName] forKey:columnName];
        }
    }
    
    for (NSString *columnName in currentColumns) {
        if (![columns containsObject:columnName]) {
            [deleteIndexNames addObject:sqliteMasteIndexes[columnName][INDEX_NAME]];
        }
    }
    
    BOOL result = YES;
    do {
        if ([deleteIndexNames count] > 0) {
            result = [self executeDropIndexesWithIndexNames:deleteIndexNames];
            
            if (!result) {
                break;
            }
        }
        
        if ([addIndexes count] > 0) {
            result = [self executeAddIndexesWithColumnIndexes:addIndexes forTable:tableName];
            
            if (!result) {
                break;
            }
        }
    } while (0);
    
    return result;
}

- (BOOL)executeAddIndexesWithColumnIndexes:(NSDictionary<NSString*, NSDictionary*> *)columnIndexes forTable:(NSString *)tableName {
    BOOL result = YES;
    for (NSString *columnName in columnIndexes) {
        NSDictionary *columnIndex = columnIndexes[columnName];
        
        result = [[MJKDatabaseDAO sharedInstance] createIndex:columnIndex[INDEX_NAME] onColumn:columnName isUnique:[columnIndex[IS_UNIQUE] boolValue] forTable:tableName];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

- (BOOL)executeDropIndexesWithIndexNames:(NSArray<NSString *> *)indexNames {
    BOOL result = YES;
    for (NSString *indexName in indexNames) {
        result = [[MJKDatabaseDAO sharedInstance] dropIndex:indexName];
        if (!result) {
            break;
        }
    }
    
    return result;
}

@end
