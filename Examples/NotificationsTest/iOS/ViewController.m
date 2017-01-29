//
//  ViewController.m
//  NotificationsTest
//
//  Created by Nick Lockwood on 20/11/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import "ViewController.h"
#import "FXNotifications.h"


static NSString *const IncrementCountNotification = @"IncrementCountNotification";



@interface SomeObject : NSObject

@end

@implementation SomeObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        // We must not forget to remove observer sometime after this call
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action:) name:IncrementCountNotification object:nil];
        
        // No need to remove observer
        [[NSNotificationCenter defaultCenter] fx_addObserver:self selector:@selector(action:) name:IncrementCountNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    // Since we add weak observer in init, there's no need to remove it in dealloc
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)action:(NSNotification *)note
{
    NSLog(@"Increment in SomeObserver, note.obj - %@", note.object);
}

@end




@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) SomeObject *object;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver];
}

- (IBAction)increment
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IncrementCountNotification object:self.label];
}

- (IBAction)addObserver
{
    //using the built-in method (in a naive way), we would leak like hell
//    [[NSNotificationCenter defaultCenter] addObserverForName:IncrementCountNotification
//                                                      object:nil
//                                                       queue:[NSOperationQueue mainQueue]
//                                                  usingBlock:^(NSNotification *note) {
//
//        UILabel *label = note.object;
//        label.text = [NSString stringWithFormat:@"Presses: %@", @(++self.count)];
//    }];
    
    self.object = [SomeObject new];
    
    //using the FXNotifications method, this approach doesn't leak and just works as expected
    [[NSNotificationCenter defaultCenter] fx_addObserver:self
                                                 forName:IncrementCountNotification
                                                  object:self.label
                                                   queue:[NSOperationQueue mainQueue]
                                              usingBlock:^(NSNotification *note, ViewController *observer) {
                                                  
                                                  UILabel *label = note.object;
                                                  label.text = [NSString stringWithFormat:@"Presses: %@", @(++observer.count)];
                                              }];
}

- (IBAction)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IncrementCountNotification object:self.label];
}

@end
