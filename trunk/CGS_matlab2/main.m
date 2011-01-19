clear all
close all

% open source images, masked and truncated
[src mask] = imgSource('images/house2.jpg');
figure('Name', 'Source1');
imshow(src);

target = imread('images/nature.jpg');
figure('Name', 'target');
imshow(target);

% specify points in target
%[inj,ini] = ginput(1);

[output A b] = cloneImageGray(target, mask, src, 0, 0);

figure('Name', 'Final');
imshow(output);