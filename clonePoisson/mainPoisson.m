clear all
close all

img = double( imread('../images/f16source.jpg') );
src = img;
figure('Name', 'Select');
showImg = imshow(mat2gray(img)); % returns a handle to the image object, to be used in createMask

mask = double( createMask(imfreehand, showImg) ); % create a mask using freehand tool
% mask = double(rgb2gray(imread('../images/f16mask.jpg')));
% for i=1:size(mask,1)
%     for j=1:size(mask,2)
%         if(mask(i,j)>200) mask(i,j)=255;
%         else mask(i,j)=0;
%         end
%     end
% end

target = double(imread('../images/f16target.jpg'));

[imr img imb] = decomposeRGB(target);
[imir imig imib] = decomposeRGB(src);

tic

offset = [0 0];
% imr = cloneImagePoisson(imir, imr, mask, offset);
% img = cloneImagePoisson(imig, img, mask, offset);
% imb = cloneImagePoisson(imib, imb, mask, offset);

% imnew = composeRGB(imr, img, imb);
imnew = cloneImagePoisson2(src, target, mask, offset);
toc

figure('Name', 'Final');
imshow(mat2gray(imnew));