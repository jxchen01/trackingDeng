Options=struct();
Options.Wstr=0.2; 
Options.Wrepel=0.1; 
Options.nPoints=25;
Options.Iteration=30;
Options.shrinkRate=0.3;
Options.nPoints=25;
Options.alpha=0.2;
Options.beta=0;
Options.gamma=1;
Options.w0=5;
Options.Verbose=true;


%%%% load initial position %%%
ctl = im2bw(imread('img0101_ctl.png'));
Ps=ExtractCells(ctl, Options);

%%%% load raw image %%%%%
I=mat2gray(imread('img0101.png'));

% Compute inv(A+gamma*I)
B=SnakeInternalForceMatrix2D(Options.nPoints,Options.alpha,Options.beta,Options.gamma);

% Compute Image Force
EImg = imageEnhancement(I);
[dEx, dEy]=EnergyGradient(EImg,1.5,0);
%[dEx, dEy] = imgradientxy(EImg);
%[dEx,dEy]=gradient(EImg);
%keyboard

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
