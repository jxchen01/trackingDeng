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

sq=1;
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
    m=max(EImg(:));
     for bb=4:1:5
         EImg(6-bb,:)=m+bb*0.2; EImg(:,6-bb)=m+bb*0.2;
         EImg(end-5+bb,:)=m+bb*0.2; EImg(:,end-5+bb)=m+bb*0.2;
     end
    [dEx, dEy]=EnergyGradient(EImg,1.5,0);
    
    if(Options.Verbose)
        figure(2), imshow(mat2gray(EImg)), hold on; h=drawContours(Ps,0,[],0);
    end
    
    for i=1:1:Options.Iteration
        Ps = SnakeMovement(Ps,B,dEx,dEy,Options);
        if(Options.Verbose)
            h=drawContours(Ps,i/Options.Iteration,h,i);
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


 %   drawColorRegions(Ps, [xdim,ydim], frameIdx ,cMap);
 %   saveas(gcf,[fpath,'sq',num2str(sq),'\Princeton_track\img0',num2str(frameIdx+100),'.png'],'png');
    
    % cellFrameTracked=cellFrame{1};
    % save([fpath,'sq',num2str(sq),'/track_data/seg0',num2str(100+frameIdx),'.mat'],'cellFrameTracked');
    
    Ps = contourPropagate(Ps,[xdim,ydim],Options);
    
    clear dEx dEy EImg I
end

poolobj = gcp('nocreate');
delete(poolobj);
