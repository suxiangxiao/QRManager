//
//  QRManager.m
//  QRSweepDemo
//
//  Created by suxx on 16/6/20.
//  Copyright © 2016年 suxx. All rights reserved.
//

#import "QRManager.h"

@interface QRManager ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong)UIImageView *lineImageView;
@property (nonatomic, strong)NSTimer *sweepTimer;

@end

@implementation QRManager

#pragma mark - LiftCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Delegate
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count>0) {
        //[session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
        self.sweepResult(metadataObject.stringValue);
        [self stopSweep];
    }
}


#pragma mark - Event Handle

#pragma mark - Private Method
-(CALayer *)setSweepFrame:(CGRect)frame{
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = frame;
    
    [self addImageWithName:@"qrcode_box" withFrame:_previewLayer.bounds];
    
    _lineImageView = [self addImageWithName:@"qrcode_line" withFrame:CGRectMake(2, 2, _previewLayer.frame.size.width - 4, 2)];
    
    [self startSweep];
    
    return _previewLayer;
}

-(UIImageView *)addImageWithName:(NSString *)imageName withFrame:(CGRect)frame{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    
    NSString *lineImagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    
    imageView.image = [UIImage imageWithContentsOfFile:lineImagePath];
    [_previewLayer addSublayer:imageView.layer];
    
    return imageView;
}


-(void)startSweep{
    [_session startRunning];
    _sweepTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];;
}

-(void)stopSweep{
    _sweepTimer =nil;
    [_sweepTimer invalidate];
    [_session stopRunning];
    [_previewLayer removeFromSuperlayer];
}


-(void)animation{
    static BOOL isDown = YES;
    CGFloat y = _lineImageView.frame.origin.y;
    
    if (isDown) {
        //往下走
        _lineImageView.frame = CGRectMake(_lineImageView.frame.origin.x, y + 2, _lineImageView.frame.size.width, _lineImageView.frame.size.height);
        if (y >=  _previewLayer.frame.size.height) {
            isDown = NO;
        }
    }else{
        //往上走
        
        _lineImageView.frame = CGRectMake(_lineImageView.frame.origin.x, y - 2, _lineImageView.frame.size.width, _lineImageView.frame.size.height);
        if (y <= 0) {
            isDown = YES;
        }
    }
    
}



//改变二维码大小
-(UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size{
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}

#pragma mark - Public Method
+(UIImage *)generateQRWithInfo:(NSString *)info{
    
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    
    NSData *data=[info dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *image=[filter outputImage];
    CGFloat size = 1000;
    
    //    return [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:100.0];
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}


#pragma mark - Getter 和 Setter

#pragma mark - 信号接收处理
-(void)handleSignal:(NSDictionary *)signalInfo{
    
}

@end
