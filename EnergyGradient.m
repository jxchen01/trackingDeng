function [FextX, FextY]=EnergyGradient(EImg,sigma,verbose)

Fx=ImageDerivatives2D(EImg,sigma,'x');
Fy=ImageDerivatives2D(EImg,sigma,'y');

FextX=Fx*2*sigma^2;
FextY=Fy*2*sigma^2;

if(verbose)
    [x,y]=ndgrid(1:5:134,1:5:207);
    figure, imshow(mat2gray(EImg));
    hold on;
    quiver(y,x,FextY(1:5:end,1:5:end),FextX(1:5:end,1:5:end));
    hold off
end