function ap=AlignmentParameter(Ix,Iy,EigS,EigL,nbrSize)

mask=ones(nbrSize,nbrSize);  % nbrSize-by-nbrSize neighborhood
mask=mask/(nbrSize*nbrSize);

eigNorm=sqrt(Ix.^2+Iy.^2);
Ix=Ix./eigNorm;
Iy=Iy./eigNorm;

dipoleMagnitude=abs(EigL)-abs(EigS);
Ix=Ix.*dipoleMagnitude;
Iy=Iy.*dipoleMagnitude;

aveImgX=conv2(Ix,mask,'same');
aveImgY=conv2(Iy,mask,'same');

ap=sqrt(aveImgX.^2+aveImgY.^2);



