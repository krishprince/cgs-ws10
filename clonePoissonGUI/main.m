%clear all
%close all

%[fname, fpath, findex] = uigetfile('*.jpg');

%img = double( imread('../images/horse2.jpg') );
sfpn = evalin('base', 'sfpn');
img = double( imread(sfpn));
src = img;
figure('Name', 'Select');
showImg = imshow(mat2gray(img)); % returns a handle to the image object, to be used in createMask
% create a mask using freehand tool
mask = double( createMask(imfreehand, showImg) ); 

%target = double(imread('../images/nature.jpg'));
tfpn = evalin('base', 'tfpn');
target = double(imread(tfpn));
figure('Name', 'Target');
imshow(mat2gray(target, [0 255]));

% get only the selected part from source
[truncSrc margin]= truncImage(src, mask);

offX = 0;
offY = 0;
while(true)
    % specify points in target
    [inj,ini, button] = ginput(1);
    % left button, select position
    if(button==1)
        offX = uint16(inj(1));
        offY = uint16(ini(1));
        % paste it in scalar to target
        t = pasteImage(truncSrc, target, offX, offY);
        imshow(mat2gray(t, [0 255]));
    % right button, return position to start clonning
    else
        break
    end
end

tic % timer begins

offset = [offX-margin(2) offY-margin(1)];
imnew = cloneImagePoisson(src, target, mask, offset);

toc % timer ends

figure('Name', 'Final');
imshow(mat2gray(imnew, [0 255]));