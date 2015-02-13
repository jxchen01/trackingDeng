function Ps=contourPropagate(Ps, sz, Options)

for i=1:1:numel(Ps)
    
    if(Ps{i}.length<Options.lengthCanSkip)
        Ps{i}.valid=false;
        continue;
    end
    
    P=Ps{i}.pts; % pixel-level accuracy (all connected grid points)
    tarLen = Ps{i}.length;
    % shrinked contour
    dl = ceil(Options.nPoints * Options.shrinkRate/2);
    K1 = P(dl+1:1:Options.nPoints-dl,:);
    [K, len]=interpolateSingleContour(K1, sz, Options.nPoints);
    
    % get the normal vector
    NN = GetContourNormals2D(K);
    
    Ps{i}=struct('pts',K,'length',len,'targetLength',tarLen,'normvec',NN,'valid',true);
    
    clear NN K len K1 dl
end