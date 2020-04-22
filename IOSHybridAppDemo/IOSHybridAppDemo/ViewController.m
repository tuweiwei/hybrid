//
//  ViewController.m
//  ImoocHybridIOSNative

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "Constants.h"

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewConfiguration *wkWebViewConfiguration;
@property (nonatomic, strong) WKUserContentController *wkUserContentController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initWebView];
}

- (void)initWebView {
    //配置wkWebViewConfiguration
    [self wkConfiguration];
    //初始化webView
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.wkWebViewConfiguration];
    self.webView.backgroundColor = [UIColor whiteColor];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    NSURL *url = [NSURL URLWithString:WEB_URL];
//    为保证演示效果设置缓存策越为不缓存
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [self.webView loadRequest: request];
    
    [self.view addSubview:self.webView];
    
    //OC注册供JS调用的方法
    [self addScriptFunction];
}

- (void)wkConfiguration {
    self.wkWebViewConfiguration = [[WKWebViewConfiguration alloc]init];
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    self.wkWebViewConfiguration.preferences = preferences;
    
}

#pragma mark -  OC注册供JS调用的方法，IOS 注入 jsbridge 对象名为 webkit
- (void)addScriptFunction {
    self.wkUserContentController = [self.webView configuration].userContentController;
    
    [self.wkUserContentController addScriptMessageHandler:self name:@"IOSTestFunction1"];
    [self.wkUserContentController addScriptMessageHandler:self name:@"IOSTestFunction2"];
}

#pragma mark -  Alert弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --- WKScriptMessageHandler ---
//OC在JS调用方法做的处理
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //前端主动JS发送消息，前端指令动作
    if ([@"IOSTestFunction1" isEqualToString:message.name]) {
        [self IOSTestFunction1:message.body];
    } else if ([@"IOSTestFunction2" isEqualToString:message.name]) {
        [self IOSTestFunction2:message.body];
    }
}

#pragma mark - 与 Android 不同，IOS可以直接接收一个对象Object数据
- (void)IOSTestFunction1:(id)body {
    NSDictionary *dict = body;
    NSString *msg = [dict objectForKey:@"msg"];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 调用该方法，回调 web 端 onFunctionIOS 方法，并传递字符串
- (void)IOSTestFunction2:(id)body {
    
    [self.webView evaluateJavaScript:@"onFunctionIOS('IOSTestFunction2方法执行完成')" completionHandler:^(id result, NSError * _Nullable error) {
        
        NSLog(@"%@", result);
        
    }];
    
}

@end
