function [imNew] = cloneImagePoisson(imSrc, imDest, imMask, offset)
% imSrc - source image
% imDest - destination image
% imMask - a black and white mask to indicate the irregular boundary
% posOffset - offset of corresponding pixel from the source to the destination

laplacian = [0 1 0; 1 -4 1; 0 1 0];

[imDestR imDestG imDestB] = decomposeRGB(imDest);
[imSrcR imSrcG imSrcB] = decomposeRGB(imSrc);

% height and width of both the source image and the destination image
[heightSrc widthSrc] = size(imSrcR);
[heightDest widthDest] = size(imDestR);
[heightMask widthMask] = size(imMask);

% check if the mask is too big
if heightSrc < heightMask | widthSrc < widthMask | heightDest < heightMask | widthDest < widthMask
    fprintf('Error - the mask is too big\n');    
end

% the offset between the source and the destination
xoff = offset(1);
yoff = offset(2);

% --------------------------------------------
% calculate the number of pixels that are 0
% for sparse matrix allocation
% --------------------------------------------
n = size(find(imMask), 1);

%---------------------------------------------
% sparse matrix allocation
%---------------------------------------------
fprintf('Matrix dimension = %d x %d\n', n, n);
M = spalloc(n, n, 5*n);

% also the boundary condition
b = zeros(3, n);

% temperary matrix index holder
% need to point the pixel position in the image to
% the row index of the solution vector to
imIndex = zeros(heightDest, widthDest);

count = 0;
% now fill in the 
for y = 1:heightDest
    for x = 1:widthDest
        if imMask(y+yoff, x+xoff) ~= 0
            count = count + 1;            
            imIndex(y, x) = count;
        end
    end
end
        
if count ~= n
    fprintf('Error - wrong matrix size\n');
end
        
%---------------------------------------------
% construct the matrix here
%---------------------------------------------

% construct the laplacian image.
imLaplacianR = conv2(imSrcR, -laplacian, 'same');
imLaplacianG = conv2(imSrcG, -laplacian, 'same');
imLaplacianB = conv2(imSrcB, -laplacian, 'same');

% matrix row count
count = 0; % count is the row index
for y = 2:heightSrc-1
    for x = 2:widthSrc-1

        % if the mask is not zero, then add to the matrix
        if imMask(y, x) ~= 0

            % increase the counter
            count = count + 1;   
            
            % the corresponding position in the destination image
            yd = y - yoff;
            xd = x - xoff; 
             
            %------------------------------------------------------
            % if Neighbourhood(p) is in the interia of the region
            %------------------------------------------------------
            
            % gathering the coefficient for the matrix
            %------------------------------------------------------
            % if on the top
            if imMask(y-1, x) ~= 0
                % this pixel is already used
                % get the diagonal position of the pixel
                colIndex = imIndex(yd-1, xd);
                M(count, colIndex) = -1;
            else % at the top boundary
                b(1, count) = b(1, count) + imDestR(yd-1, xd);
                b(2, count) = b(2, count) + imDestG(yd-1, xd);
                b(3, count) = b(3, count) + imDestB(yd-1, xd);
            end
            
            % if on the left
            if imMask(y, x-1) ~= 0
                colIndex = imIndex(yd, xd-1);
                M(count, colIndex) = -1;
            else % at the left boundary
                b(1, count) = b(1, count) + imDestR(yd, xd-1);
                b(2, count) = b(2, count) + imDestG(yd, xd-1);
                b(3, count) = b(3, count) + imDestB(yd, xd-1);
            end
            
            % if on the bottom            
            if imMask(y+1, x) ~= 0
                colIndex = imIndex(yd+1, xd);
                M(count, colIndex) = -1;
            else    % at the bottom boundary
                b(1, count) = b(1, count) + imDestR(yd+1, xd);
                b(2, count) = b(2, count) + imDestG(yd+1, xd);
                b(3, count) = b(3, count) + imDestB(yd+1, xd);
            end
            
            % if on the right side
            if imMask(y, x+1) ~= 0
                colIndex = imIndex(yd, xd+1);
                M(count, colIndex) = -1;
            else    % at the right boundary
                b(1, count) = b(1, count) + imDestR(yd, xd+1);
                b(2, count) = b(2, count) + imDestG(yd, xd+1);
                b(3, count) = b(3, count) + imDestB(yd, xd+1);
            end       
            
            M(count, count) = 4;
            
            % construct the guidance field		
            b(1, count) = b(1, count) + imLaplacianR(y, x);
            b(2, count) = b(2, count) + imLaplacianG(y, x);
            b(3, count) = b(3, count) + imLaplacianB(y, x);
        end
    end
end

if count ~= n
    fprintf('Error - wrong matrix size\n');
end

%---------------------------------------------
% solve for the sparse matrix
%---------------------------------------------
xR = M\( b(1,:)' );
xG = M\( b(2,:)' );
xB = M\( b(3,:)' );
%---------------------------------------------
% now fill in the solved values
%---------------------------------------------
imNewR = imDestR;
imNewG = imDestG;
imNewB = imDestB;

% now fill in the 
for y1 = 1:heightDest
    for x1 = 1:widthDest
        if imMask(y1+yoff, x1+xoff) ~= 0
            index = imIndex(y1, x1);
            imNewR(y1, x1) = xR(index);
            imNewG(y1, x1) = xG(index);
            imNewB(y1, x1) = xB(index);
        end
    end
end

imNew = composeRGB(imNewR, imNewG, imNewB);