function [Vout,RMSE] = barnesInterp(Xi,Yi,Zi,dat,Xo,Yo,Zo, num_passes,xr,zr)
%{
Take the input meshes (Xi, Yi, Zi) along with the corresponding data (dat)
and interpolate to the output meshes (Xo,Yo,Zo)


INPUTS:
Xi, Yi, Zi  - x,y,z meshes of input data
dat         - data to be interpolated corresponding with Xi, Yi, Zi
Xo, Yo, Zo  - x,y,z meshes of output data
num_passes  - number of interpolation passes to make through the data
xr          - horizontal influence range (same units as Xi, Yi, Zi)
zr          - vertical influence range (same units as Xi, Yi, Zi)

OUTPUTS:
Vout        - interpolated data corresponding with Xo, Yo, Zo
RMSE        - root mean squared error of the interpolation

Example:



[Tinterp] = barnesInterp(...)

CHANGE LOG:
2022-07 - Initial creation - Nicholas Barron
%}


Xi2 = Xi(:,:,1); Xi2 = Xi2(:);
Yi2 = Yi(:,:,1); Yi2 = Yi2(:);

Xo2 = Xo(:,:,1); Xo2 = Xo2(:);
Yo2 = Yo(:,:,1); Yo2 = Yo2(:);


[~,I] = pdist2([Xi2,Yi2],[Xo2,Yo2],'Euclidean','smallest',20);
[XI,YI] = ind2sub(size(Xi(:,:,1)),I);
clear I



%dn = (max(Xi(:))-min(Xi(:)))

ir=3;

nx=size(Xo,1);
ny=size(Xo,2);

%influence range
yr = xr;



xr = 5.052*(2*xr/pi)^2;
yr = 5.052*(2*yr/pi)^2;
zr = 5.052*(2*zr/pi)^2;



Vout = NaN(size(Xo));
%VoutTemp2 = NaN(size(Xo));



Corr = 0;
datDiff = zeros(size(dat));



for n = 1:num_passes
    disp(char("starting round "+string(n)+" of "+string(num_passes)));
    tic
    for i = 1:size(Xo,1)
        if mod(i,10)==0
            fprintf('.')
        end



        %locx=Xo(i,1,1);
        %dx = locx-Xi;

        %tic
        for j=1:size(Xo,2)


            inds = sub2ind([nx,ny],i,j);

            ib=max(1,min(XI(:,inds)));
            ie=min(size(Xi,1),max(XI(:,inds)));
            jb=max(1,min(YI(:,inds)));
            je=min(size(Xi,2),max(YI(:,inds)));
            Xi2=Xi(ib:ie,jb:je,:);
            Yi2=Yi(ib:ie,jb:je,:);
            Zi2=Zi(ib:ie,jb:je,:);
            dat2=dat(ib:ie,jb:je,:);
            datDiff2 = datDiff(ib:ie,jb:je,:);


            locx=Xo(i,j,1);
            locy=Yo(i,j,1);
            dx = locx-Xi2;
            dy= locy-Yi2;

            for k=1:size(Xo,3)


                locz=Zo(i,j,k);

                dz=locz-Zi2;


                w = exp(-dx.^2/xr -dy.^2/yr - dz.^2/zr );

                if n ==1

                    Vout(i,j,k) = nansum(w.*dat2, 'all')/sum(w,'all');
                else

                    Vout(i,j,k) = Vout(i,j,k) + nansum(w.*datDiff2, 'all')/sum(w,'all');
                end





            end

        end
        %toc

    end

    if n == num_

    Vout(Vout == 0) = NaN;
    fprintf('done\n')

    fprintf('calculating error matrix\n')
    try
        Fv = griddedInterpolant(Xo,Yo,Zo,Vout);
    catch
        Fv = scatteredInterpolant(double(Xo(:)),double(Yo(:)),double(Zo(:)),double(Vout(:)));
    end
    datDiff = dat-Fv(double(Xi),double(Yi),double(Zi));
    RMSE = sqrt(nanmean(datDiff.^2,'all'));
    disp(char("RMSE = "+string(RMSE)));

toc
end

%% Corrected Pass
%g0=griddedInterpolant(Xo(:),Yo(:),Zo(:),VoutTemp(:));
%{
for i = 1:size(Xo,1)
    ib=max(1,i-ir);
    ie=min(nx,i+ir);
    tic
    for j=1:size(Xo,2)
        jb=max(1,j-ir);
        je=min(ny,j+ir);
        Xi2=Xi(ib:ie,jb:je,:);
        Yi2=Yi(ib:ie,jb:je,:);
        Zi2=Zi(ib:ie,jb:je,:);
        dat2=dat(ib:ie,jb:je,:);


        for k=1:size(Xo,3)

            locx=Xo(i,j,k);
            locy=Yo(i,j,k);
            locz=Zo(i,j,k);
            %find closest "real" value to the locs
            r = sqrt((locx-Xi2).^2 + (locy-Yi2).^2 + (locz-Zi2).^2);
            imin=find(r == min(r(:)));

            %mask = r < rRange;
            w = exp(-r.^2/kappa);
            lambda = min(r(:));
            D1=exp(-kappa*(pi/lambda)^2)^gamma;
            VoutTemp2(i,j,k) = VoutTemp(i,j,k) + nanmean((dat2(imin)-g0(double(Xi2(imin)),double(Yi2(imin)),double(Zi2(imin))))*D1);


            r2 = sqrt((Xi(i,j,k)-Xi2).^2 + (Yi(i,j,k)-Yi2).^2 + (Zi(i,j,k)-Zi2).^2);
            w2 = exp(-r2.^2/kappa);
            Corr = (dat(i,j,k) -(nansum(w2.*dat2,'all')/sum(w2,'all')));



        end


    end
    toc

end
%}
