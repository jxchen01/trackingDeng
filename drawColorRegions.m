function drawColorRegions(cellList, sz, frameIdx, cMap)

cimg = uint16(zeros(sz));

for  i=1:1:numel(cellList)
    if(cellList{i}.valid)
        pts=cellList{i}.pts;
        ind=sub2ind(sz,round(pts(:,1)),round(pts(:,2)));
        cimg(ind) = i;
    end
end

figure(5); imshow(cimg, cMap), title(['frame: ',num2str(frameIdx)]), drawnow;