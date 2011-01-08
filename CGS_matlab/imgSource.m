function [res, mask] = imgSource( path )

img = imread(path);
figure('Name', 'Select');
showImg = imshow(img); % returns a handle to the image object, to be used in createMask
mask = createMask(imfreehand, showImg); % create a mask using freehand tool

% calc the masked image, by multiplying each channel by the mask
imgMasked(:,:,1) = img(:,:,1) .* uint8(mask); 
imgMasked(:,:,2) = img(:,:,2) .* uint8(mask);
imgMasked(:,:,3) = img(:,:,3) .* uint8(mask);
%figure('Name', 'Masked');
%imshow(imgMasked); 

% truncate black rows and cloumns
res = truncBlack(imgMasked);
mask = truncBlack(uint8(mask));
%res = img;

end