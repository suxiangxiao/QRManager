# QRManager
Qr code is generated and scanning

QR code scanning:
  QRManager *manager = [[QRManager alloc] init];
    //设置扫描区域的frame
    CALayer *subLayer = [manager setSweepFrame:CGRectMake(50, 100, 200, 200)];
    [self.view.layer addSublayer:subLayer];
    [self addChildViewController:manager];
    //扫描结果回调
    manager.sweepResult = ^(NSString *result){
        
    };
    
QR generated
  //接收生成的二维码图片
    UIImage *image = [QRManager generateQRWithInfo:@"http://www.baodu.com"];
