function [EImg, clusterVec] = imageEnhancement(I, clusterVec, Options)

sigma_gaussian=1.5;
%sigma_smooth=1.5;
nbrSize=3; %3-by-3 neighborhood for compute alignment measure
[dimx,dimy]=size(I);

% Make 2D hessian
[Dxx,Dxy,Dyy] = Hessian2D(I,sigma_gaussian);

% Calculate (abs sorted) eigenvalues and vectors
[LambdaL,LambdaS,~,~,LIx,LIy]=eig2image(Dxx,Dxy,Dyy);

% Compute the first two principle components of LambdaL, LambdaS, I
EigenImageSpace=cat(2,LambdaL(:),LambdaS(:),I(:));
[~, PC] = princomp(EigenImageSpace); % try: zscore(X) to rescale data

% Compute the alignment parameter
ap=AlignmentParameter(LIx,LIy,LambdaS,LambdaL,nbrSize);

% Build the 3-D feature vectore for each pixel
featureMat=cat(2, PC(:,1:2), ap(:));

% fit the gaussian mixture model
if(isempty(clusterVec))
    rng(Options.gn);
    GMM = fitgmdist(featureMat,3,'RegularizationValue',1e-8); 
    clusterVec=cluster(GMM,featureMat);
else
    GMM = fitgmdist(featureMat,3,'RegularizationValue',1e-8,'Start',clusterVec);
     clusterVec=cluster(GMM,featureMat);
end

% compute the posterior probability
pp=posterior(GMM,featureMat);

if(isempty(Options.bIdx) && isempty(Options.rIdx))
    % display to determine which is background and which is ridge
    figure(1),
    subplot(2,2,1)
    imshow(reshape(pp(:,1),[dimx,dimy]))
    title('Component 1')
    
    subplot(2,2,2)
    imshow(reshape(pp(:,2),[dimx,dimy]))
    title('Component 2')
    
    subplot(2,2,3)
    imshow(reshape(pp(:,3),[dimx,dimy]))
    title('Component 3')
    
    subplot(2,2,4)
    imshow(mat2gray(I))
    title('Raw')
    
    prompt='index for ridge: ';
    ridgeIdx = input(prompt);
    prompt='idxex for background: ';
    backgroundIdx = input(prompt);
    
else
    ridgeIdx = Options.rIdx;
    backgroundIdx = Options.bIdx;
end

% build the enhanced image used to calculate image potential
EI = 0.5*pp(:,ridgeIdx) + pp(:,backgroundIdx);
EImg = reshape(EI,[dimx,dimy]);
% EImg = imgaussian(EImg,sigma_smooth);
% figure(2),imshow(mat2gray(EImg))




