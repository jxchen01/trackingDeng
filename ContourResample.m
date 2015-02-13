function nP = ContourResample(Ps,sz, nPoints)

nP=Ps;
parfor i=1:numel(Ps)
    if(Ps{i}.valid)
        pts = Ps{i}.pts;
        if(any(isnan(pts(:))))
            Ps{i}.valid=false;
            continue;
        elseif(any(isinf(pts(:))))
            Ps{i}.valid=false;
            continue;
        end
        [K, len]=interpolateSingleContour(pts, sz, nPoints);
        
        if(any(isnan(K(:))))
            Ps{i}.valid=false;
            continue;
        end
        NN = GetContourNormals2D(K);
        nP{i}=struct('pts',K,'length',len,'targetLength',Ps{i}.targetLength,'normvec',NN,'valid',true);
    end
end