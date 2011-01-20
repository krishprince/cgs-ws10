clear all
close all

img = double( imread('f16source.jpg') );
src = img;
figure('Name', 'Select');
showImg = imshow(mat2gray(img)); % returns a handle to the image object, to be used in createMask

mask = double( createMask(imfreehand, showImg) ); % create a mask using freehand tool

target = double(imread('f16target.jpg'));

tic % timer begins

offset = [0 0];
imnew = cloneImagePoisson(src, target, mask, offset);

toc % timer ends

figure('Name', 'Final');
imshow(mat2gray(imnew));