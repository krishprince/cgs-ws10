function [ img ] = truncBlack( img )
% truncate black rows and cloumns : 
% if the sum of a whole row in all channels =0 then it's black
% 1 - rows
% 1.1 - remove first row until there's content : result = nextRow->End
while(sum(img(2,:,:))==0)
    imgSize = size(img);
    img = img(2:imgSize(1),:,:);
end
% 1.2 - remove last row until there's content : result = first->prevRow
imgSize = size(img);
while(sum(img(imgSize(1)-1,:,:))==0)
    img = img(1:imgSize(1)-1,:,:);
    imgSize = size(img);
end

% 2 - cols
% 2.1 - remove first col until there's content : result = nextCol->End
while(sum(img(:,2,:))==0)
    imgSize = size(img);
    img = img(:,2:imgSize(2),:);
end
% 2.2 - remove last col until there's content : result = first->prevCol
imgSize = size(img);
while(sum(img(:,imgSize(2)-1,:))==0)
    img = img(:,1:imgSize(2)-1,:);
    imgSize = size(img);
end
end

