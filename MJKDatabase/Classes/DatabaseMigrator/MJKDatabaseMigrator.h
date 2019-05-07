//
//  DatabaseMigrator.h
//  ActiveObject
//
//  Created by Ansel on 16/3/26.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJKDatabase.h"

@interface MJKDatabaseMigrator : NSObject

- (BOOL)executeMigrateForDatabase:(MJKDatabase *)database
           currentDatabaseVersion:(NSString *)currentDatabaseVersion;

#pragma mark - MustOverrride

- (NSArray<NSString *> *)migrationVersionList;

//版本之间迁移
- (NSDictionary<NSString*, Class> *)migrateVersionAndExecutorMap;

@end
