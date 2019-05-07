//
//  MJKDatabaseDAO+DDL.h
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKDatabaseDAO.h"

@interface MJKDatabaseDAO (DDL)

- (BOOL)createTable:(NSString *)tableName constraints:(NSDictionary<NSString* , NSString *> *)constraints indexes:(NSDictionary<NSString*, NSDictionary*> *)indexes forClass:(Class)clazz;

- (BOOL)dropTable:(NSString *)tableName;

/**
 * 若是单列 就传字符串 多列传数组
 */
- (BOOL)createIndex:(NSString *)indexName onColumn:(id)column isUnique:(BOOL )isUnique forTable:(NSString *)tableName;

- (BOOL)dropIndex:(NSString *)indexName;

- (BOOL)renameTable:(NSString *)tableName toTableNewName:(NSString *)tableNewName;

/**
 * constraint :
 * eg.  1. default 0; 2. check (age >= 0);
 *
 */
- (BOOL)addColumn:(NSString *)column type:(NSString *)type constraint:(NSString *)constraint forTable:(NSString *)tableName;

@end
