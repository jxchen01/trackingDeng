function [Lambda1,Lambda2,sIx,sIy,lIx,lIy]=eig2image(Dxx,Dxy,Dyy)
% This function eig2image calculates the eigen values from the
% hessian matrix, sorted by abs value, and two eigenvectors


% Compute the eigenvectors of J, v1 and v2
tmp = sqrt((Dxx - Dyy).^2 + 4*Dxy.^2);
v2x = 2*Dxy; v2y = Dyy - Dxx + tmp;

% Normalize
mag = sqrt(v2x.^2 + v2y.^2); i = (mag ~= 0);
v2x(i) = v2x(i)./mag(i);
v2y(i) = v2y(i)./mag(i);

% The eigenvectors are orthogonal
v1x = -v2y; 
v1y = v2x;

% Compute the eigenvalues
mu1 = 0.5*(Dxx + Dyy + tmp);
mu2 = 0.5*(Dxx + Dyy - tmp);

% Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
check=abs(mu1)>abs(mu2);

Lambda1=mu1; Lambda1(check)=mu2(check);
Lambda2=mu2; Lambda2(check)=mu1(check);

sIx=v1x; sIx(check)=v2x(check);
sIy=v1y; sIy(check)=v2y(check);

lIx=v2x; lIx(check)=v1x(check);
lIy=v2y; lIy(check)=v1y(check);



