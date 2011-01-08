%a = [0, 0, 0, 0, 0; 0, 1, 1, 1, 0; 0, 1, 1, 1, 0; 0, 1, 1, 1, 0; 0, 0, 0, 0, 0]

function [output A b] = cloneImage(target, mask, div)
width = size(mask, 1)
height = size(mask, 2)

% build a map to index target's unmasked pixels
mp = containers.Map(0,0);
pnum = 1;
for y = 2:height-1
    for x = 2:width-1
        pindex = (y-1)*width + x;
        if(mask(x,y)~=0)
            mp(pindex) = pnum;
            pnum = pnum+1;
        end
    end
end

b = []; % Ax = b
% build the sparse matrix using coordinate list COO
row = [];
col = [];
val = [];
sindex = 1; % index of sprase vectors
rindex = 0; % index of row
for y = 2:height-1
    for x = 2:width-1
        if(mask(x,y) ~= 0)
            x
            y
            rindex = rindex+1;
            pindex = (y-1)*width + x;
            b( mp(pindex) ) = div(x,y);
            % top neighbor
            if(mask(x,y-1)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex-width);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex) ) = b( mp(pindex) ) - target(x,y-1);
            end
            % left neighbor
            if(mask(x-1,y)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex-1);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex) ) = b( mp(pindex) ) - target(x-1,y);
            end
            % pixel itself
            row(sindex) = rindex;
            col(sindex) = mp(pindex);
            val(sindex) = -4;
            sindex = sindex+1;
            % right neighbor
            if(mask(x+1,y)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex+1);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex) ) = b( mp(pindex) ) - target(x+1,y);
            end
            % down neighbor
            if(mask(x,y+1)~=0)
                row(sindex) = rindex;
                col(sindex) = mp(pindex+width);
                val(sindex) = 1;
                sindex = sindex+1;
            else
                b( mp(pindex) ) = b( mp(pindex) ) - target(x,y+1);
            end
        end
    end
end

% linear equation
A = sparse(row, col, val);
%x = linsolve(A,b);
xres = A/b;

% scale xres 0..255
xres = scaleVec(xres, 0, 255);

output = target;
for y = 2:height-1
    for x = 2:width-1
        if(mask(x,y) ~= 0)
            pindex = (y-1)*width + x;
            output(x,y) = xres( mp(pindex) );
        end
    end
end

%output = [row; col; val];
end