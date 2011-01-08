function [res] = scaleVec(vec, wantedMin, wantedMax)

ss = max(size(vec))
min1 = min(vec);
for i=1:ss
    res(i) = vec(i) + abs(min1) + wantedMin;
end

max2 = max(res);
for i=1:ss
    res(i) = res(i) * wantedMax / max2;
end
end