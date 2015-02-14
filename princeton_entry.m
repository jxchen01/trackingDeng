%%%%%%%%%%%%%%%%%%% main entry for active membrane  %%%%%%%%%%%%%%%%%%%%%%%
% citation:
% Deng, Yi, et al. "Efficient multiple object tracking using mutually 
% repulsive active membranes." PloS one 8.6 (2013): e65769.
% Created by Jianxu Chen (University of Notre Dame) 
% Date: Jan. 2015 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function princeton_entry(sq)

%clc
%disp('Program Starts...');

%parpool('local',2);

sq=21;
%fpath = '/Users/JianxuChen/Dropbox/Private/miccai2015/';
fpath='C:\Users\jchen16\Dropbox\Private\miccai2015\';
%fpath='/afs/crc.nd.edu/user/d/dlv1/Private/miccai2015/data/';
dh='\';

Options= set_parameters(sq);
numFrame=Options.numFrame;

% Compute inv(A+gamma*I)
B=SnakeInternalForceMatrix2D(Options.nPoints,Options.alpha,Options.beta,Options.gamma);

cMap=rand(1000,3);
cMap(1,:)=[0,0,0];

%%%% load initial position %%
ctl = im2bw(imread([fpath,'sq',num2str(sq),dh,'ctl.png']));
Ps=ExtractCells(ctl, Options);

[xdim,ydim]=size(ctl);

clear ctl

clusterVec=[];
for frameIdx=2:1:numFrame
    disp(['frame: ',num2str(frameIdx)]);

    %%%% load raw image %%%%%
    I=mat2gray(imread([fpath,'sq',num2str(sq),dh,'raw',dh,'img0',num2str(100+frameIdx),'.png']));
    
    % Compute Image Force
    [EImg, clusterVec] = imageEnhancement(I,clusterVec,Options);
%     m=max(EImg(:));
%     for bb=5:1:5
%         EImg(6-bb,:)=m+bb*0.2; EImg(:,6-bb)=m+bb*0.2;
%         EImg(end-5+bb,:)=m+bb*0.2; EImg(:,end-5+bb)=m+bb*0.2;
%     end
    [dEx, dEy]=EnergyGradient(EImg,1.5,0);
    
    if(Options.Verbose)
        figure(2), imshow(mat2gray(EImg)), hold on; h=drawContours(Ps,0,[],0);
    end
    
    checkValue = 0.8*graythresh(smooth(I));
    for i=1:1:Options.Iteration
        Ps = SnakeMovement(Ps,B,dEx,dEy,Options);
        if(Options.Verbose)
            h=drawContours(Ps,i/Options.Iteration,h,i);
        end
        for pp=1:1:numel(Ps)
            if(Ps{pp}.valid)
                pts=Ps{pp}.pts;
                
                if(isCloseToBoundary(pts,xdim,ydim))
                    Ps{pp}.valid = false;
                    continue;
                end
                
                pts = round(pts);
                pts(pts(:,1)<1, 1)=1; pts(pts(:,1)>xdim,1)=xdim;
                pts(pts(:,2)<1, 2)=1; pts(pts(:,2)>ydim,2)=ydim;
                pts_idx = sub2ind([xdim,ydim],pts(:,1), pts(:,2));
                
                if(mean(I(pts_idx))<checkValue)
                    Ps{pp}.valid = false;
                    continue;
                end
                
                if(~any(pts(:,1)>6)  || ~any(pts(:,1)<xdim-5) || ~any(pts(:,2)>6) || ~any(pts(:,2)<ydim-5))
                    Ps{pp}.valid = false;
                    continue;
                end
                
            end
        end
        Ps = ContourResample(Ps,size(I),Options.nPoints);
    end
    
    save([fpath,'sq',num2str(sq),dh,'track_data_princeton',dh,'track0',num2str(frameIdx+100),'.mat'],'Ps');

    flag=false;
    for i=1:1:numel(Ps)
        if(Ps{i}.valid)
            flag=true;
            break;
        end
    end

    if(~flag)
        break;
    end

  %  drawColorRegions(Ps, [xdim,ydim], frameIdx ,cMap);
 %   saveas(gcf,[fpath,'sq',num2str(sq),'\Princeton_track\img0',num2str(frameIdx+100),'.png'],'png');
    
    Ps = contourPropagate(Ps,[xdim,ydim],Options);
    
    clear dEx dEy EImg I
end

poolobj = gcp('nocreate');
delete(poolobj);
