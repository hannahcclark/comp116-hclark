//
//  ViewController.m
//  TransmissionSecurityTester
//
//  Created by Hannah Clark on 12/6/15.
//  Copyright © 2015 Hannah Clark. All rights reserved.
//

#define SERVER @"://transmission-security.herokuapp.com"

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, readwrite, strong) SRWebSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openSocket {
    NSMutableString *address = [NSMutableString stringWithFormat:@"wss"];
    [address appendString:SERVER];
    [address appendString:@""];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    self.socket = [[SRWebSocket alloc] initWithURLRequest:urlRequest];
    self.socket.delegate = self;
    [self.socket open];
}

- (IBAction)http:(id)sender {
    self.errorLabel.text = @"";
    NSMutableString *address = [NSMutableString stringWithFormat:@"https"];
    [address appendString:SERVER];
    [address appendString:@"/httpreq"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    req.HTTPMethod = @"GET";
    [req setValue:@"header-data" forHTTPHeaderField:@"Test-Header"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (!connectionError) {
            self.view.backgroundColor = [UIColor redColor];
        }
        else {
            self.errorLabel.text = @"HTTPS connection error";
        }
    }];
}

- (IBAction)websocket:(id)sender {
    self.errorLabel.text = @"";
    if (!self.socket || self.socket.readyState != SR_OPEN) {
        [self openSocket];
    }
    else {
        [self.socket send:[@"socketreq" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
}

- (IBAction)pushnotification:(id)sender {
    self.errorLabel.text = @"";
    NSMutableString *address = [NSMutableString stringWithFormat:@"https"];
    [address appendString:SERVER];
    [address appendString:@"/pushreq"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    req.HTTPMethod = @"GET";
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            self.errorLabel.text = @"Push Notification Request connection error";
        }
    }];
}

#pragma mark - SRWebSocket Delegate Methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    self.view.backgroundColor = [UIColor yellowColor];
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [self.socket send:[@"socketreq" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    self.socket = nil;
    self.errorLabel.text = @"Websocket connection error";
}


@end
