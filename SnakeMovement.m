function Ps = SnakeMovement(Ps,B,dEx,dEy,Options)

sz=size(dEx);
allPoints = zeros(sz);
numContour = numel(Ps);
pIdx=cell(1,numContour);

w0=Options.w0;
Wrepel=Options.Wrepel;
Wstr=Options.Wstr;
gamma=Options.gamma;

%tmp=zeros(sz);

for i=1:1:numContour
    if(Ps{i}.valid)
        pts=Ps{i}.pts;
    
        % round to pixels and convert to index
        tx=round(pts(:,1));
        tx(tx<1)=1; tx(tx>sz(1))=sz(1);
        ty=round(pts(:,2));
        ty(ty<1)=1; ty(ty>sz(2))=sz(2);
        idx=sub2ind(sz,tx,ty);
        try
        allPoints(idx)=1;
        catch 
            keyboard
        end
%        tmp(idx)=i;
    
        pIdx{i}=idx;
    else
        pIdx{i}=[];
    end
end

parfor i=1:numContour
    if(~Ps{i}.valid)
        continue;
    end
    
    pts=Ps{i}.pts;
    idx=pIdx{i};
    
    nv = Ps{i}.normvec;  % normal vector
    tv=cat(2,-nv(:,2),nv(:,1)); % tangential vector
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% apply image force %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dpEx = interp2(dEx,pts(:,2),pts(:,1));
    dpEy = interp2(dEy,pts(:,2),pts(:,1));
    dpNorm = hypot(dpEx,dpEy);
    dpEx=dpEx./dpNorm;
    dpEy=dpEy./dpNorm;
    ds = cat(2, -dpEx, -dpEy);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% repelling force %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherPoints = allPoints;
    otherPoints(idx)=0;
    rpIdx = find(otherPoints>0);
    [xp,yp]=ind2sub(sz,rpIdx);
    
    for kk=1:1:numel(idx)
       dx=(pts(kk,1)-xp)./w0;
       dy=(pts(kk,2)-yp)./w0;
       dd=1 - hypot(dx,dy);
       dd(dd<0)=0;
       
       ds(kk,1) = ds(kk,1) + Wrepel* sum(dx.*dd);
       ds(kk,2) = ds(kk,2) + Wrepel* sum(dy.*dd); 
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% stretching force %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % length difference
    dL = tanh(Ps{i}.targetLength - Ps{i}.length);
    
    Fhead = abs(dot(ds(1,:),tv(1,:)));
    Ftail = abs(dot(ds(end,:), tv(end,:)));
    % head
    dL_head = dL * Ftail/(Fhead+Ftail);
    p0 = pts(1,:) + tv(1,:).*dL_head; % anticipated position
    ds(1,:) = ds(1,:) + Wstr*(p0-pts(1,:)); % -(pts(1,:)-p0)
    % tail
    dL_tail = dL * Fhead/(Fhead+Ftail);
    q0 = pts(end,:) - tv(end,:).*dL_tail;% in the reverse direction
    ds(end,:) = ds(end,:) + Wstr*(q0-pts(end,:)); % -(pts(end,:)-q0)
    
    ss = (gamma).*pts + ds;
    
%     % directly apply in normal direction
%     dEimgMagNormal= ds(:,1).*nv(:,1) + ds(:,2).*nv(:,2);
%     dEimgNormal(:,1) = dEimgMagNormal.*nv(:,1);
%     dEimgNormal(:,2) = dEimgMagNormal.*nv(:,2);
%     
%     ss = (Options.gamma).*pts + dEimgNormal ;
%     
%     % average of force in tangential direction
%     dEimgMagTan=ds(:,1).*tv(:,1) + ds(:,2).*tv(:,2);
%     dEimgTan(:,1) = dEimgMagTan.*tv(:,1);
%     dEimgTan(:,2) = dEimgMagTan.*tv(:,2);
%     AveEimgTan = mean(dEimgTan,1);
%     
%     ss(:,1) = ss(:,1) + AveEimgTan(1);
%     ss(:,2) = ss(:,2) + AveEimgTan(2);
    
    np = B*ss;
    
    Ps{i}.pts = np;
    
end