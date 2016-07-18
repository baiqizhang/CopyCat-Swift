//
//  UIImage+Thumbnail.m
//  CameraOverlay
//
//  Created by Baiqi Zhang on 7/10/15.
//  Copyright (c) 2015 Baiqi Zhang. All rights reserved.
//

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)

- (UIImage *)thumbnail{
    return [self thumbnailWithFactor:100];
}


- (UIImage *)thumbnailWithFactor:(float)factor{
    UIImage * sourceImage  = self;
    
    // input size comes from image
    CGSize inputSize = sourceImage.size;
    
    CGFloat sideLength = factor;
    
    // round up side length to avoid fractional output size
    sideLength = ceilf(sideLength);
    
    // output size has sideLength for both dimensions
    CGSize outputSize = CGSizeMake(sideLength, sideLength);
    
    // calculate scale so that smaller dimension fits sideLength
    CGFloat scale = MAX(sideLength / inputSize.width,
                        sideLength / inputSize.height);
    
    // scaling the image with this scale results in this output size
    CGSize scaledInputSize = CGSizeMake(inputSize.width * scale,
                                        inputSize.height * scale);
    
    // determine point in center of "canvas"
    CGPoint center = CGPointMake(outputSize.width/2.0,
                                 outputSize.height/2.0);
    
    // calculate drawing rect relative to output Size
    CGRect outputRect = CGRectMake(center.x - scaledInputSize.width/2.0,
                                   center.y - scaledInputSize.height/2.0,
                                   scaledInputSize.width,
                                   scaledInputSize.height);
    
    // begin a new bitmap context, scale 0 takes display scale
    UIGraphicsBeginImageContextWithOptions(outputSize, YES, 0);
    
    // optional: set the interpolation quality.
    // For this you need to grab the underlying CGContext
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    
    // draw the source image into the calculated rect
    [sourceImage drawInRect:outputRect];
    
    // create new image from bitmap context
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up
    UIGraphicsEndImageContext();
    
    // pass back new image
    return outImage;
}

#pragma mark - bad code below, will cause memory issue, don't know why yet

- (UIImage *)crop{
    CGRect rect;
    if (self.size.width>self.size.height)
        rect = CGRectMake((self.size.width-self.size.height)/2.0, 0, self.size.height, self.size.height);
    else
        rect = CGRectMake(0, (self.size.height-self.size.width)/2.0, self.size.width, self.size.width);
    
    rect = CGRectMake(rect.origin.x*self.scale,
                      rect.origin.y*self.scale,
                      rect.size.width*self.scale,
                      rect.size.height*self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}


- (UIImage *)resizeWithFactor:(float)factor{
    UIImage* image=self;
    
    struct CGImage *tmCGImage=[image CGImage];

    float width=image.size.width*factor,height=image.size.height*factor;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0,-1.0);
    CGContextTranslateCTM(context, 0, -height);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height),tmCGImage);
    UIImage *tmImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tmImage;
}


- (UIImage *)zoomWithFactor:(float)factor{
    UIImage* image=self;
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0,-1.0);
    CGContextTranslateCTM(context, 0, -image.size.height);
    CGContextDrawImage(context, CGRectMake(-image.size.width*(factor-1)/2, -image.size.height*(factor-1)/2, image.size.width*factor, image.size.height*factor),[self CGImage]);
    UIImage *tmImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tmImage;
}

-(UIImage *) maskWithColor:(UIColor *)color
{
    CGImageRef maskImage = self.CGImage;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef cImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *coloredImage = [UIImage imageWithCGImage:cImage];
    
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cImage);
    
    return coloredImage;
}
@end
