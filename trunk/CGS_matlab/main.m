clear all
close all

% open source images, masked and truncated
[src mask] = imgSource('images/house2.jpg');
src = rgb2gray(src);
figure('Name', 'Source1');
imshow(src);

target = imread('images/nature.jpg');
target = rgb2gray(target);
figure('Name', 'target');
imshow(target);

% specify points in target
%[inj,ini] = ginput(1);

[Ix, Iy] = gradient(double(src));
diver = divergence(Ix, Iy);
[output A b] = cloneImage(target, mask, diver);

figure('Name', 'Final');
imshow(output);