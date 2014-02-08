//
//  CoffeeRoastLoggerTests.m
//  CoffeeRoastLoggerTests
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRRoastManager.h"
#import "CRRoastDataSource.h"
#import "CRRoast.h"
#import "CRHeatingInformation.h"
#import "CRRoastInformation.h"
#import "CREnvironmentInformation.h"
#import "CREnvironment.h"
#import "CRBean.h"
#import "CRBeanInformation.h"

@interface CoffeeRoastLoggerTests : XCTestCase

@end

@interface CoffeeRoastLoggerTests()<CRRoastDataSourceDelegate>

@end

@implementation CoffeeRoastLoggerTests
{
    BOOL _willCalled;
    BOOL _changeCalled;
    BOOL _didCalled;
    NSString *_failTestString;
    NSInteger _returnedScore;
}

- (void)setUp
{
    [super setUp];
    [CRRoastManager sharedManager].dataSource.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDidFail:) name:CRRoastDataSourceDidFailSavingNotification object:nil];
    _willCalled = NO;
    _changeCalled = NO;
    _didCalled = NO;
}

- (void)saveDidFail:(NSNotification *)notification
{
    _failTestString = @"Fail";
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSavingRoastInformation
{
    CRRoastInformation *information = [[CRRoastInformation alloc] init];
    information.result = @"Result Test";
    information.score = 20;
    
    CREnvironmentInformation *environment = [[CREnvironmentInformation alloc] init];
    environment.temperature = 30;
    environment.humidity = 40;
    environment.date = [NSDate date].timeIntervalSince1970;
    information.environment = environment;
    
    CRRoast *roast = [[CRRoastManager sharedManager] addNewRoastInformation:information];
    
    XCTAssertEqual(roast.result, @"Result Test",);
    XCTAssertNotEqual(roast.result, @"Result Tests",);
    XCTAssertTrue(roast.score == 20,);
    XCTAssertFalse(roast.score == 10,);
    
    XCTAssertTrue(roast.environment.temperature == 30,);
    
    XCTAssertNil(_failTestString,);
    
    XCTAssertTrue(_willCalled, );
    XCTAssertTrue(_changeCalled, );
    XCTAssertTrue(_didCalled, );
    
    XCTAssertTrue(_returnedScore == 20, );
    
    NSLog(@"Count = %d", [CRRoastManager sharedManager].dataSource.countOfRoastInformation);
}

- (void)testGettingBeanArea
{
    CRRoastInformation *information = [[CRRoastInformation alloc] init];
    information.result = @"Result Test";
    information.score = 20;
    
    CREnvironmentInformation *environment = [[CREnvironmentInformation alloc] init];
    environment.temperature = 30;
    environment.humidity = 40;
    environment.date = [NSDate date].timeIntervalSince1970;
    information.environment = environment;
    
    CRBeanInformation *bean = [[CRBeanInformation alloc] init];
    bean.area = @"Japan";
    information.beans = @[bean];
    
    CRRoast *roast = [[CRRoastManager sharedManager] addNewRoastInformation:information];
    
    CRRoastInformation *information1 = [[CRRoastInformation alloc] init];
    information.result = @"Result Test2";
    information.score = 23;
    
    information1.environment = environment;
    
    bean = [[CRBeanInformation alloc] init];
    bean.area = @"Japan";
    information1.beans = @[bean];
    bean.area = @"Canada";
    information1.beans = @[bean];
    
    roast = [[CRRoastManager sharedManager] addNewRoastInformation:information1];
    
    NSArray *beanAreas = [CRRoastManager sharedManager].dataSource.beanAreas;
    XCTAssertTrue([beanAreas containsObject:@"Japan"], );
    XCTAssertTrue([beanAreas containsObject:@"Canada"], );
    XCTAssertFalse([beanAreas containsObject:@"China"], );
}

- (void)dataSourceWillChangeContent:(CRRoastDataSource *)dataSource
{
    _willCalled = YES;
}

- (void)dataSource:(CRRoastDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(CRRoastDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    _returnedScore = ((CRRoast *)anObject).score;
    _changeCalled = YES;
}

- (void)dataSourceDidChangeContent:(CRRoastDataSource *)dataSource
{
    _didCalled = YES;
}

@end
