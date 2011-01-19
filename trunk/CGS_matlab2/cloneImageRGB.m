%a = [0, 0, 0, 0, 0; 0, 1, 1, 1, 0; 0, 1, 1, 1, 0; 0, 1, 1, 1, 0; 0, 0, 0, 0, 0]

function [output A b] = cloneImageRGB(target, mask, source, shiftx, shifty)
[height,width] = size(mask);

% clac divergence
div = zeros(size(source));
for ch=1:3 % for each channel
    % first derivative
    gx = zeros(height, width); 
    gy = zeros(height, width);
    j = 1:height-1; 
    k = 1:width-1;
    gx(j,k) = (source(j,k+1,ch) - source(j,k,ch));
    gy(j,k) = (source(j+1,k,ch) - source(j,k,ch));
    
    % second derivative
    gxx = zeros(height, width);   
    gyy = zeros(height, width);
    f = zeros(height, width);
    j = 1:height-1;
    k = 1:width-1;
    % Laplacian
    gyy(j+1,k) = gy(j+1,k) - gy(j,k);       
    gxx(j,k+1) = gx(j,k+1) - gx(j,k);
    div(:,:,ch) = gxx + gyy;
end

% build a map to index target's unmasked pixels
mp = containers.Map(0,0);
pnum = 1;
for y = 2:height-1
    for x = 2:width-1
        pindex = (y-1)*width + x;
        if(mask(y,x)~=0)
            mp(pindex) = pnum;
            pnum = pnum+1;
        end
    end
end

tic % timer begin

b = zeros(pnum-1, 3, 'uint8'); % Ax = b
% build the sparse matrix using coordinate list COO
row = zeros(1, 5*(pnum-1));
col = zeros(1, 5*(pnum-1));
val = zeros(1, 5*(pnum-1));
sindex = 1; % index of sprase vectors
rindex = 0; % index of row
for y = 2:height-1
    for x = 2:width-1
        if(mask(y,x) ~= 0)
            %y
            rindex = rindex+1;
            pindex = (y-1)*width + x;
            b( mp(pindex), 1) = div(y,x,1);
            b( mp(pindex), 2) = div(y,x,2);
            b( mp(pindex), 3) = div(y,x,3);
            % top neighbor
            if(mask(y-1,x)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex-width);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex), 1 ) = b( mp(pindex),1 ) - target(shifty+y-1, shiftx+x, 1);
                b( mp(pindex), 2 ) = b( mp(pindex),2 ) - target(shifty+y-1, shiftx+x, 2);
                b( mp(pindex), 3 ) = b( mp(pindex),3 ) - target(shifty+y-1, shiftx+x, 3);
            end
            % left neighbor
            if(mask(y,x-1)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex-1);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex), 1 ) = b( mp(pindex), 1 ) - target(shifty+y, shiftx+x-1, 1);
                b( mp(pindex), 2 ) = b( mp(pindex), 2 ) - target(shifty+y, shiftx+x-1, 2);
                b( mp(pindex), 3 ) = b( mp(pindex), 3 ) - target(shifty+y, shiftx+x-1, 3);
            end
            % pixel itself
            row(sindex) = rindex;
            col(sindex) = mp(pindex);
            val(sindex) = -4;
            sindex = sindex+1;
            % right neighbor
            if(mask(y,x+1)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex+1);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex), 1 ) = b( mp(pindex), 1 ) - target(shifty+y, shiftx+x+1, 1);
                b( mp(pindex), 2 ) = b( mp(pindex), 2 ) - target(shifty+y, shiftx+x+1, 2);
                b( mp(pindex), 3 ) = b( mp(pindex), 3 ) - target(shifty+y, shiftx+x+1, 3);
            end
            % down neighbor
            if(mask(y+1,x)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex+width);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex), 1 ) = b( mp(pindex), 1 ) - target(shifty+y+1, shiftx+x, 1);
                b( mp(pindex), 2 ) = b( mp(pindex), 2 ) - target(shifty+y+1, shiftx+x, 2);
                b( mp(pindex), 3 ) = b( mp(pindex), 3 ) - target(shifty+y+1, shiftx+x, 3);
            end
        end
    end
end

% trim zeros from vectors
z = find(row==0, 1);
row = row(1:z-1);
col = col(1:z-1);
val = val(1:z-1);

% linear equation
A = sparse(row, col, val, pnum-1, pnum-1);
xres = zeros(pnum-1, 3);
for ch=1:3
    bb = double( b(:,ch) );
    xres(:,ch) = A\bb;
end

toc % timer ends

output = target;
for y = 2:height-1
    for x = 2:width-1
        if(mask(y,x) ~= 0)
            pindex = (y-1)*width + x;
            output(shifty+y, shiftx+x, 1) = uint8( xres( mp(pindex), 1 ) );
            output(shifty+y, shiftx+x, 2) = uint8( xres( mp(pindex), 2 ) );
            output(shifty+y, shiftx+x, 3) = uint8( xres( mp(pindex), 3 ) );
        end
    end
end

%output = [row; col; val];
end