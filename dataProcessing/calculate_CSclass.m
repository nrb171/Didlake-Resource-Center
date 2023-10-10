function csc = calccsclass(dbz,xgrid,ygrid,alt)
%******************************************************************************
%* CALCULATE_CSCLASS.F -- This routine takes in MXDBZ reflectivity values and
%* classifies each pixel as convective or stratiform precipitation (or weak echo
%* or no echo.) The algorithm used is the same as in Yuter et al. (2005) and tuned
%* for this specific data set from the N43 radar.


%* INPUTS
%* dbz -- Reflectivity (dBZ) values (3D array)
%* xgrid -- X grid values (1D array)
%* ygrid -- Y grid values (1D array)
%* alt -- Altitude (km) values (1D array)

%* OUTPUTS
%* csc -- Convective/Stratiform classification (3D array)
%*        0 = No echo
%*        1 = Weak echo
%*        2 = Stratiform
%*        3 = Convective

%* CHANGE LOG
%* 2007/07/13 - Original writing - Anthony Didlake
%* 2023/10/10 - updated documentation - Nicholas Barron

%******************************************************************************



%  1. Set parameters
calt = 2.0;  % Selected altitude (km) of focus
malt = 4.5;  % Altitude (km) of bright band
rad = 12;    % Radius (km) of background reflectivity calculation
rad2 =12;    % Radius (km) of background reflectivity for stratiform
a = 6.00;    % Convective criteria parameter
b = 42.0;    % Convective criteria parameter (make equal to Zti)
Zti = 42.0;  % Reflectivity (dBZ) threshold for Convective classification
Zwe = 13.0;  % Reflectivity (dBZ) threshold for Weak Echo classification
scal =  0.0; % Reflectivity scaling for convective radius

nx=numel(dbz(:,1,1));ny=numel(dbz(1,:,1));nz=numel(dbz(1,1,:));
dx=xgrid(2)-xgrid(1);dy=ygrid(2)-ygrid(1);
dbz=dbz+scal;
zzz=10.^(dbz./10);
[X,Y]=meshgrid(xgrid,ygrid);
[val cz]=min(abs(calt-alt));
[val mz]=min(abs(malt-alt));

%====================================================================
%  2. Caclulate the background reflectivity at each point.

for j=1:ny
   for i=1:nx

%      i=  80;j=120;
%  2a. Adjust background limits according to data domain
       imax=i+ceil(rad/dx);i1=imax;
       jmax=j+ceil(rad/dy);j1=jmax;
       imin=i-ceil(rad/dx);i0=imin;
       jmin=j-ceil(rad/dy);j0=jmin;
       if(imax>nx) i1=nx; end
       if(imin<1)  i0=1;  end
       if(jmax>ny) j1=ny; end
       if(jmin<1)  j0=1;  end
%  2b. Cacluate background reflectivity for each point within range
%      at two altitudes (calt and malt)
       CX=X(i0:i1,j0:j1)-X(i,j);CY=Y(i0:i1,j0:j1)-Y(i,j);
       dist=sqrt(CX.^2+CY.^2);
       locs=dist<=rad;
       zzz2=zzz(i0:i1,j0:j1,cz); zzz3=zzz2(locs);
       zzbg(i,j)=nanmean(zzz3);
       Zbg(i,j)=10.*log10(zzbg(i,j));
       % Choose official malt from altitude with larger dBZ
       locs=dist<=rad2;
       [val mz2]=max(dbz(i,j,mz-1:mz+1));
       zzz4=zzz(i0:i1,j0:j1,mz+mz2-2); zzz5=zzz4(locs);
       zzbg2(i,j)=nanmean(zzz5);
       Zbg2(i,j)=10.*log10(zzbg2(i,j));

   end
end

%====================================================================
%  3. Find convective centers
%  3a. Use threshold intensity value or convective criteria

dZ=dbz(:,:,cz)-Zbg;
dZcc=a.*cos((pi./2).*(Zbg./b));
%tst=0:1:40;
%dZcctst=a.*cos((pi./2).*tst./b);

locti=dbz(:,:,cz)>=Zti;
%loccc=(dZ>=dZcc)&(dbz(:,:,cz)>=Zbg2);
loccc=(dZ>=dZcc)&(Zbg>=Zbg2);
%qplot(locti);title(varname(locti));
%qplot(loccc);title(varname(loccc));

loccc(locti)=1;
%qplot(loccc);title(varname(loccc));


%  4. Classify convective (3) within convective radius

csc2=NaN(size(Zbg));

% Scaling parameters for convective radius
d1=15+scal;  d2=30+scal;
r1=1.5; r2=4.5;

Ztemp1=Zbg<d1;
Ztemp2=(Zbg>=d1)&(Zbg<d2);
Ztemp3=Zbg>=d2;

crad=NaN(size(Zbg));
crad(Ztemp1)=r1;
crad(Ztemp2)=r1+(((r2-r1)./(d2-d1)).*(Zbg(Ztemp2)-d1));
crad(Ztemp3)=r2;
%crad(~loccc)=0;

for j=1:ny
   for i=1:nx
      imax=i+ceil(r2/dx);i1=imax;
      jmax=j+ceil(r2/dy);j1=jmax;
      imin=i-ceil(r2/dx);i0=imin;
      jmin=j-ceil(r2/dy);j0=jmin;
      if(imax>nx) i1=nx; end
      if(imin<1)  i0=1;  end
      if(jmax>ny) j1=ny; end
      if(jmin<1)  j0=1;  end
      if(loccc(i,j))
	 for ii=i0:i1
	 for  jj=j0:j1
	    dist=sqrt((X(i,j)-X(ii,jj)).^2+(Y(i,j)-Y(ii,jj)).^2);
	    if(dist<=crad(i,j))
	       csc2(ii,jj)=3;
	    end
	 end
      end
   end
end
end

%  5. Classify no echo (0), weak echo (1), or stratiform (2)

locswe=(dbz(:,:,cz)<Zwe)&(csc2~=3);
csc2(locswe)=1;
locsne=isnan(dbz(:,:,cz));
csc2(locsne)=0;
locsst=isnan(csc2);
csc2(locsst)=2;



%  6. Extend classifications to all levels
csc=repmat(csc2,[1 1 nz]);
