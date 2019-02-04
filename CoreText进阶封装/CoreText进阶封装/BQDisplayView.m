//
//  BQDisplayView.m
//  CoreText进阶封装
//
//  Created by baiqiang on 16/1/5.
//  Copyright © 2016年 baiqiang. All rights reserved.
//

#import "BQDisplayView.h"
#import <CoreText/CoreText.h>
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"

@implementation BQDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setGestureEvent];
    }
    return self;
}

- (void)setGestureEvent {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClickedEvent:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - Request 手势的点击事件
- (void)tapGestureClickedEvent:(UITapGestureRecognizer *)tap {
    //得到点击所在位置的CGpoint
    CGPoint point = [tap locationInView:self];
    
    //不看 ！ 翻转图片 坐标系 如果是要我自己写文字 就要self.data.dataArray
    for (CoreTextImageData *data in self.data.imageArray) {
        //翻转坐标系imageArray中所存坐标的坐标系为CoreText坐标系
        //需要设置文字的 dataRect dataPosition  这块意思是要遍历所有图片所在的坐标
        //用在不同文字上的思路就是：给文字的设置单独创建一个类 每创建一个文字 就要用一下这个类 从而得到这个文字的具体位置
        CGRect imageRect = data.imagePosition;
        CGPoint imagePositon = imageRect.origin;
        imagePositon.y = self.bounds.size.height - imageRect.size.height - imageRect.origin.y;
        imageRect = CGRectMake(imagePositon.x, imagePositon.y, imageRect.size.width, imageRect.size.height);
        //判断点击点是否在Rect当中
        if (CGRectContainsPoint(imageRect, point)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:data.name delegate:nil cancelButtonTitle:@"OK111" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
#pragma mark - Request 通过鼠标点击的坐标 拿到这个坐标通过下面这个函数来判断
    CoreTextLinkData *linkData = [CoreTextLinkData touchLinkInView:self atPoint:point data:self.data];
    if (linkData != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:linkData.urlString delegate:nil cancelButtonTitle:@"OK222" otherButtonTitles:nil];
        [alert show];
        return;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
//    [self baseCoreTextUsingMethod];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    if (self.data) {
        // 将文字绘制到上下文中
        CTFrameDraw(self.data.ctFrame, context);
        // 将图片绘制到上下文中
#pragma mark - attention 绘制图片 注释则无图片出现
        for (CoreTextImageData *imageData in self.data.imageArray) {
            UIImage* image = [UIImage imageNamed:imageData.name];
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
    
}
- (void)setData:(CoreTextData *)data {
    if (_data != data) {
        _data = data;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.data.height);
}

#pragma mark - CoreText基础用法
/**
 *  基础的coreText用法
 */
- (void)baseCoreTextUsingMethod {
    //1.获取当前设备上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.翻转坐标系(coreText坐标系是以左下角为坐标原点，UIKit以左上角为坐标原点)
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    //3.设置绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(10, 20, self.bounds.size.width - 20, self.bounds.size.height - 40));
    //4.设置文本内容
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"Hello world"];
    //5.设置CTFrame
    CTFramesetterRef ctFrameSetting = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetting, CFRangeMake(0, [attString length]), path, NULL);
    //6.在CTFrame中绘制文本关联到上下文
    CTFrameDraw(ctFrame, context);
    //7.释放变量
    CFRelease(path);
    CFRelease(ctFrameSetting);
    CFRelease(ctFrame);
}

@end
