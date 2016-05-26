#import "detector-Bridging-Header.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>
#import <opencv2/nonfree/features2d.hpp>
#import <opencv2/features2d/features2d.hpp>

#endif



@interface Detector()
{
    cv::CascadeClassifier cascade;
    
}
@end

@implementation Detector: NSObject

- (id)init {
    self = [super init];
    return self;
}

cv::Mat graycolor(cv::Mat src)
{
    cv::Mat gray_img;
    cv::cvtColor(src, gray_img, CV_BGR2GRAY);
    cv::normalize(gray_img, gray_img, 0, 255, cv::NORM_MINMAX);
    //cv::Canny(gray_img, gray_img, 10, 100);
    return gray_img;
}


- (NSMutableArray *)detectPoint:(UIImage *)image {
    // UIImage -> cv::Mat変換
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat gray = graycolor(mat);
    cv::SurfFeatureDetector detector(1000);
    std::vector<cv::KeyPoint> keypoints;
    std::vector<cv::KeyPoint>::iterator itk;
    detector.detect(gray, keypoints);
    NSMutableArray *points = [[NSMutableArray alloc] init];
    

    for (itk = keypoints.begin(); itk!=keypoints.end(); ++itk) {
        NSMutableDictionary *point = [[NSMutableDictionary alloc] init];
        CGPoint pt = CGPointMake(itk->pt.x, itk->pt.y);
        [point setObject:[NSNumber numberWithFloat:itk->class_id] forKey:@"classid"];
        [point setObject:[NSValue valueWithCGPoint:pt] forKey:@"pt"];
        [point setObject:[NSNumber numberWithFloat:itk->size] forKey:@"size"];
        [point setObject:[NSNumber numberWithFloat:itk->angle] forKey:@"angle"];
        [points addObject:point];
    }

    return points;
}







- (UIImage *)detectImage:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat gray = graycolor(mat);
    cv::SurfFeatureDetector detector(1000);
    std::vector<cv::KeyPoint> keypoints;
    std::vector<cv::KeyPoint>::iterator itk;
    detector.detect(gray, keypoints);
    cv::Scalar color(100,255,50);
    for(itk = keypoints.begin(); itk!=keypoints.end(); ++itk) {
        cv::circle(gray, itk->pt, 1, color, -1);
        cv::circle(gray, itk->pt, itk->size/10, color, 1, CV_AA);
        if(itk->angle>=0) {
            cv::Point pt2(itk->pt.x + cos(itk->angle)*itk->size, itk->pt.y + sin(itk->angle)*itk->size);
            cv::line(gray, itk->pt, pt2, color, 1, CV_AA);
        }
    }
    UIImage *resultImage = MatToUIImage(gray);
    return resultImage;
}

@end
