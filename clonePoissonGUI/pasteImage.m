% scalar paste

function [img] = pasteImage(src, target, offX, offY)
img = target;
for i=1:size(src, 1)
    for j=1:size(src, 2)
        i = uint16(i);
        j = uint16(j);
        if(sum(src(i,j,:))~=0)
            img(i+offY,j+offX,1) = src(i,j,1);
            img(i+offY,j+offX,2) = src(i,j,2);
            img(i+offY,j+offX,3) = src(i,j,3);
        end
    end
end
end