clear all
close all

% open source images, masked and truncated
[src1 mask] = imgSource('images/house2.jpg');
figure('Name', 'Source1');
imshow(src1);

target = imread('images/nature.jpg');
figure('Name', 'target');
imshow(target);

% specify points in target
[inj,ini] = ginput(1);

%close all;

% paste
size1 = size(src1);
for i=ini(1)+1:ini(1)+size1(1)
    for j=inj(1)+1:inj(1)+size1(2)
        i = uint16(i);
        j = uint16(j);
        if(sum(src1(i-ini(1),j-inj(1),:))~=0)
            target(i,j,1) = src1(i-ini(1),j-inj(1),1);
            target(i,j,2) = src1(i-ini(1),j-inj(1),2);
            target(i,j,3) = src1(i-ini(1),j-inj(1),3);
        end
    end
end

figure('Name', 'Final');
imshow(target);