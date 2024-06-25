function [rad,tan] = makeUVtoRadTan(U,V,xmesh,ymesh)
%U: zonal wind; V: meridonal wind; 
% xmesh (ymesh): meshgrid of the zonal (meridional) coordinates centered at the storm center
%calculate the mesh of azimuths
thmesh = atan2d(ymesh,xmesh);
%calculate the radial and tangential winds
tan = -U.*sind(thmesh) + V.*cosd(thmesh);
rad = U.*cosd(thmesh) + V.*sind(thmesh);
