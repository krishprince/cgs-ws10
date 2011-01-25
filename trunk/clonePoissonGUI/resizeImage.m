function [res] = resizeImage(img, h1, w1, h2, w2, offX, offY)

res = zeros(h2, w2);
for i=1:h1
    for j=1:w1
        res(i+offY,j+offX) = img(i,j);
    end
end
end