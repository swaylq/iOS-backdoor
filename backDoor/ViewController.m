//
//  ViewController.m
//  backdoor
//
//  Created by sway on 16/1/22.
//  Copyright © 2016年 sway. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
@end

@implementation ViewController
{
    sqlite3 *db;
}
    

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) getCallList:(id)sender {
    NSMutableArray *list = [[NSMutableArray alloc] init];

    int result = sqlite3_open("/private/var/wireless/Library/CallHistory/call_history.db", &db);
    if (result == SQLITE_OK) {

        NSString *sql = @"SELECT ROWID,address,date,duration,flags FROM call ORDER BY ROWID DESC";
        sqlite3_stmt *statement;
        const char *errorMsg;
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* date_date = [[NSDate alloc]init];

        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, &errorMsg) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {

                char *addr = (char *)sqlite3_column_text(statement, 1);
                NSString *address = [[NSString alloc] initWithUTF8String:addr];
                int date = sqlite3_column_int(statement, 2);
                date_date = [date_date initWithTimeIntervalSince1970:(NSTimeInterval)date];
                NSString* dateString = [formatter stringFromDate:date_date];

                int duration = sqlite3_column_int(statement, 3);
                int flag = sqlite3_column_int(statement, 4);

                NSMutableDictionary *record = [NSMutableDictionary dictionary];
                [record setValue:address forKey:@"phoneNum"];
                [record setValue:dateString forKey:@"date"];
                [record setValue:[NSNumber numberWithInt:duration] forKey:@"duration"];
                switch (flag) {
                    case 0:
                        [record setValue:@"call in" forKey:@"direction"];
                        break;
                    case 9:
                        [record setValue:@"call out" forKey:@"direction"];
                    default:
                        [record setValue:@"unknown" forKey:@"direction"];
                        break;
                }
                [list addObject:record];
            }
        } else {
            NSLog(@"%s", errorMsg);
        }
    }
    NSLog(@"%d", result);
}

- (IBAction) getAddressBook:(id)sender {
    int result = sqlite3_open("/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb", &db);
    NSLog(@"%d", result);
}

- (IBAction) getSMS:(id)sender {
    int result = sqlite3_open("/private/var/mobile/Library/SMS/sms.db", &db);
    NSLog(@"%d", result);
}

@end
