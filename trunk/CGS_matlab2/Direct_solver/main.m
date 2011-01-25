clear all
close all

% Read Input Gray Image
imgstr = 'f16source.jpg'; 
disp(sprintf('Reading Image %s',imgstr));
img = imread(imgstr);     
[H,W,C] = size(img);      
img = double(rgb2gray(img));

mask = imread('f16mask.jpg');
mask = double(rgb2gray(mask));
mask = mask/255;

source = img.*mask;
figure('Name', 'source');
imagesc(source);colormap gray;

% Find gradinets
gx = zeros(H,W); 
gy = zeros(H,W);       
j = 1:H-1; 
k = 1:W-1;
gx(j,k) = (source(j,k+1) - source(j,k));
gy(j,k) = (source(j+1,k) - source(j,k));

target = imread('f16target.jpg');
target = double(rgb2gray(target));
btarget = target.*not(mask);
figure('Name', 'BTarget');
imagesc(btarget);colormap gray;

% Reconstruct image from gradients for verification
img_rec = poisson_solver_function(gx, gy, btarget);
img_rec = double(img_rec);
output = btarget;
%for i=1:H
%    for j=1:W
%        if(mask(i,j)==1)
%            output(i,j) = img_rec(i,j);
 %       end
%    end
%end


%figure('Name', 'Image');
%imagesc(img);colormap gray;

figure('Name', 'Target');
imagesc(target);colormap gray;

figure('Name', 'Reconstructed');
imagesc(img_rec);colormap gray;

figure('Name', 'Output');
imagesc(output);colormap gray;

%figure('Name', 'Abs error');
%imagesc(abs(img_rec-img));colormap gray;