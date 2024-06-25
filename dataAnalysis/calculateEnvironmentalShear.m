function [Shear_mag, Shear_dir, LLflow_mag, LLflow_dir] = calculateEnvironmentalShear(dt, lat, lon, varargin)
    %calculateEnvironmentalShear Get the environmental wind shear and low-level flow
    %AUTHOR: Nicholas R. Barron (nrb171@psu.edu)
    %DATE: June 2023
    %
    %   [Shear_mag, Shear_dir, LLflow_mag, LLflow_dir] = calculateEnvironmentalShear(dt,
    %   lat, lon, varargin)
    %   Inputs:
    %       dt - 1d datetime array of the times to get the environmental data
    %       lat - 1d latitude of the center of the storm
    %       lon - 1d longitude of the center of the storm
    %       varargin - optional arguments
    %           NCEPDirectory - directory where the NCEP reanalysis data is
    %           stored
    %
    %   Outputs:
    %       Shear_mag - magnitude of the environmental wind shear (m/s)
    %       Shear_dir - direction of the environmental wind shear (degrees to
    %       the right of north)
    %       LLflow_mag - magnitude of the low-level flow (m/s)
    %       LLflow_dir - direction of the low-level flow (degrees to the right
    %       of north)
    %
    %           If you need to download the ncep reanalysis data, you can do so
    %           using this bash script:

    % This script uses the irrotational and nondivergent wind component extraction method to remove the vortex winds from the environmental winds as described in:
    % Davis, C., C. Snyder, and A. C. Didlake, 2008: A vortex-based perspective of eastern Pacific tropical cyclone formation. Monthly Weather Review, 136, 2461–2477, https://doi.org/10.1175/2007MWR2317.1.

    %Please note: this radial extent is set to 800 km. Do not extend the radius much past this. The LU decomposition assumes that the data is on a flat, cartesian grid---not on a curved surface, like the Earth. You will notice inconsistencies in the corners of the grid (and subsequent issues with the shear magnitude and direction) if you extend the radius too far.

    %{
        # this bash script will get data from
        # https://downloads.psl.noaa.gov//Datasets/ncep.reanalysis2/pressure/uwnd.yyyy.nc
        #Select which years you want to download

        # 0. Define variables
        years=(1998 1999 2000 2001 2002 2020 2021)

        # 1. Download data
        for year in ${years[@]}; do
            echo "downloading $year"
            wget https://downloads.psl.noaa.gov//Datasets/ncep.reanalysis2/pressure/uwnd.$year.nc
            wget https://downloads.psl.noaa.gov//Datasets/ncep.reanalysis2/pressure/vwnd.$year.nc
        done
    %}


    %parse inputs
    p = inputParser;
    addRequired(p, 'dt', @isdatetime);
    addRequired(p, 'lat', @isnumeric);
    addRequired(p, 'lon', @isnumeric);
    addParameter(p, 'NCEPDirectory', '/rita/s0/scratch/nrb171/NCEP_wind_reanalysis/');
    parse(p, dt, lat, lon, varargin{:});
    dt = p.Results.dt;
    lat = wrapTo360(p.Results.lat);
    lon = wrapTo360(p.Results.lon);
    datadir = p.Results.NCEPDirectory;

    for i = 1:numel(dt)
        yyyy(i) = year(dt(i));
    end

    %% Get necessary location information for pass

    Shear_mag = zeros([1, numel(dt)]);
    Shear_dir = zeros([1, numel(dt)]);

    LLflow_mag = zeros([1, numel(dt)]);
    LLflow_dir = zeros([1, numel(dt)]);

    uyyyy = unique(yyyy);

    for year_ind = 1:numel(uyyyy) %This is done so that we dont need to constantly reload the reanalysis file
        year_mask = yyyy == uyyyy(year_ind);
        try
            disp("Year: " + string(uyyyy(year_ind)))
            tic
            dt_year = dt(year_mask);
            lat_year = lat(year_mask);
            lon_year = lon(year_mask);
        catch
            disp("Year: " + string(uyyyy(year_ind)) + " not found")
            continue
        end


        %%   Get wind data from NCEP Reanalysis files
        file1=['uwnd.',num2str(uyyyy(year_ind)),'.nc'];
        file2=['vwnd.',num2str(uyyyy(year_ind)),'.nc'];
        %Directory where the input data is:

        filename1=[datadir file1];
        filename2=[datadir file2];
        %Names of the variables to read
        varname1='uwnd'; %4xDaily U-wind
        varname2='vwnd';
        U = ncread(filename1, varname1);
        V = ncread(filename2, varname2);

        %Read the lat and lon
        latGrid = wrapTo360(ncread(filename1, 'lat'));
        lonGrid = wrapTo360(ncread(filename1, 'lon'));
        %Read the time - convert to datetime
        timeGrid = ncread(filename1, 'time');
        dtGrid = datetime(1800,1,1,0,0,0) + hours(timeGrid);


        %% loop over each lat/lon pair
        for p = 1:numel(dt_year);
            %get the centerfixlat/lon and fixdate of the point in question
            fixdate = dt_year(p);
            centerfixlat = lat_year(p);
            centerfixlon = lon_year(p);


            % Find the closest lat/lon grid point to the centerfixlat/lon
            [~,lonSubscript] = min(abs(lonGrid-centerfixlon));
            [~,latSubscript] = min(abs(latGrid-centerfixlat));

            %find the closest time to the fixdate
            [~,timeSubscript] = min(abs(dtGrid-fixdate));

            %get the value of the lat/lon grid point
            latSubGrid = latGrid(latSubscript);
            lonSubGrid = lonGrid(lonSubscript);

            %calculate the subgrid that is within 10 degrees of the centerfixlat/lon
            refactor = 5;
            lonRefactor = find(ismember(lonGrid, wrapTo360(lonSubGrid-refactor:2.5:lonSubGrid+refactor)));
            latRefactor = find(ismember(latGrid, wrapTo360(latSubGrid-refactor:2.5:latSubGrid+refactor)));

            % extract the subgrid
            uSubgrid850 = U(lonRefactor, latRefactor, 3, timeSubscript);
            vSubgrid850 = V(lonRefactor, latRefactor, 3, timeSubscript);
            uSubgrid200 = U(lonRefactor, latRefactor, 10, timeSubscript);
            vSubgrid200 = V(lonRefactor, latRefactor, 10, timeSubscript);
            [meshlat, meshlon] = meshgrid(latGrid(latRefactor), lonGrid(lonRefactor));

            %convert to distance in m
            centerfixlatmesh = ones(size(meshlat)).*centerfixlat;
            centerfixlonmesh = ones(size(meshlat)).*centerfixlon;
            [~,~, d, ~] = latlon_to_disaz(centerfixlatmesh, centerfixlonmesh, meshlat, meshlon);

            %calculate vortex winds
            mask = d/1000<800;

            dx = 2.7807e+05;
            dy = dx;
            [u_psi_850, v_psi_850, u_chi_850, v_chi_850, ~,~] =  helmholtz_decompose(uSubgrid850, vSubgrid850, dx, dy);
            [u_psi_200, v_psi_200, u_chi_200, v_chi_200, ~,~] =  helmholtz_decompose(uSubgrid200, vSubgrid200, dx, dy);

            %remove vortex winds
            uSubgrid850(2:end-1,2:end-1) = uSubgrid850(2:end-1, 2:end-1)-u_psi_850(2:end-1,2:end-1)-u_chi_850(2:end-1,2:end-1);
            vSubgrid850(2:end-1,2:end-1) = vSubgrid850(2:end-1, 2:end-1)-v_psi_850(2:end-1,2:end-1)-v_chi_850(2:end-1,2:end-1);
            uSubgrid200(2:end-1,2:end-1) = uSubgrid200(2:end-1, 2:end-1)-u_psi_200(2:end-1,2:end-1)-u_chi_200(2:end-1,2:end-1);
            vSubgrid200(2:end-1,2:end-1) = vSubgrid200(2:end-1, 2:end-1)-v_psi_200(2:end-1,2:end-1)-v_chi_200(2:end-1,2:end-1);



            %calculate the slab averages
            vEnv850 = nanmean(vSubgrid850(mask));
            uEnv850 = nanmean(uSubgrid850(mask));
            vEnv200 = nanmean(vSubgrid200(mask));
            uEnv200 = nanmean(uSubgrid200(mask));



            duEnv = uEnv200-uEnv850;
            dvEnv = vEnv200-vEnv850;

            smagEnv = sqrt(duEnv^2 + dvEnv^2); %in m/s
            sdirEnv = wrapTo360(mat2met(180/pi * atan2(dvEnv, duEnv))); %

            lmagEnv = sqrt(uEnv850.^2 + vEnv850.^2); %in m/s
            ldirEnv = wrapTo360(mat2met(180/pi * atan2(vEnv850, uEnv850))); %

            if numel(dt) >1
                Shear_mag(dt == fixdate) = smagEnv; %in m/s
                Shear_dir(dt == fixdate) = sdirEnv; %

                LLflow_mag(dt == fixdate) = lmagEnv; %in m/s
                LLflow_dir(dt == fixdate) = ldirEnv; %
            else
                Shear_mag = smagEnv; %in m/s
                Shear_dir = sdirEnv; %
                LLflow_mag = lmagEnv; %in m/s
                LLflow_dir = ldirEnv; %
            end
        end
        toc
    end %end year loop
end %end of function

function [u_psi, v_psi, u_chi, v_chi, psi,chi] = helmholtz_decompose(U,V, dx, dy)

    % This subroutine compute the helmholtz decomposition of a 2D wind field (U,V)
    % which are assumed to be on the same 2D grid, with grid spacing dx and dy on
    % the two direction.
    % This subroutine returns the non-divergent and irrotational wind and the
    % corresponding streamfunction psi and velocity potential chi.
    % The "environmental" component can be compute easily by subtracting
    % (u,v)_psi and (u,v)_chi from the full (u,v).


    dimsize = size(U);
    if dimsize == size(V)

        % Compute Divergence and Vorticity at the interior of the domain
        Div = d_dx_c(U, dx, 1) + d_dx_c(V, dy, 2);
        Vor = d_dx_c(V, dx, 1) - d_dx_c(U, dy, 2);

        % Define solving variables for LU decomposition
        Nx = dimsize(1);
        Ny = dimsize(2);

        f1= zeros(Nx*Ny,1);           % vorticity
        y1= zeros(Nx*Ny,1);
        s1= zeros(Nx*Ny,1);

        f2= zeros(Nx*Ny,1);           % divergence
        y2= zeros(Nx*Ny,1);
        s2= zeros(Nx*Ny,1);

        dum_1d = zeros(Nx,1);
        psi= zeros(Nx,Ny);           % Streamfunction
        chi= zeros(Nx,Ny);           % Velocity Potential

        u_psi= zeros(Nx,Ny);           % nondivergent wind
        v_psi= zeros(Nx,Ny);

        u_chi= zeros(Nx,Ny);           % irrotational wind
        v_chi= zeros(Nx,Ny);

        A= zeros(Nx,Nx,Ny-1);
        B= zeros(Nx,Nx,Ny);
        C= zeros(Nx,Nx,Ny-1);

        V= zeros(Nx,Nx,Ny);
        InvV = zeros(Nx,Nx,Ny);
        U= zeros(Nx,Nx,Ny-1);

        for j = 1:Ny
            for i = 1:Nx
                ip = i+1;
                in = i-1;
                jp = j+1;
                jn = j-1;

                if (i+1 > Nx)
                    ip = i;
                end
                if (i-1 < 1)
                    in = i;
                end

                B(i,ip,j) = 1/dx^2;
                B(i,in,j) = 1/dx^2;
                B(i,i,j) = -2/dx^2 - 2/dy^2;

                if (jn >= 1)
                    A(i,i,jn) = 1/dy^2;
                end
                if (jp <= Ny)
                    C(i,i,jp-1) = 1/dy^2;
                end
                ii = (j-1)*Nx+i;
                f1(ii) = Vor(i,j);
                f2(ii) = Div(i,j);
            end
        end
        %% LU decomposition
        % First step is the same for both f1 and f2
        V(:,:,1) = B(:,:,1);
        InvV(:,:,1) = inv(V(:,:,1));
        for j = 1:Ny-1
            j;
            U(:,:,j) = InvV(:,:,j)*C(:,:,j);
            V(:,:,j+1) = B(:,:,j+1) - A(:,:,j)*U(:,:,j);
            InvV(:,:,j+1) = inv(V(:,:,j+1));
        end

        % Do this two times for f1 and f2
        % for f1
        y1(1:Nx,1) = InvV(:,:,1)*f1(1:Nx,1);
        y2(1:Nx,1) = InvV(:,:,1)*f2(1:Nx,1);
        for j = 2:Ny
            dum_1d(1:Nx,1) = y1((j-2)*Nx+1:(j-1)*Nx,1);
            y1((j-1)*Nx+1:j*Nx,1) = InvV(:,:,j)*(  f1((j-1)*Nx+1:j*Nx,1) - A(:,:,j-1)*dum_1d );

            dum_1d(1:Nx,1) = y2((j-2)*Nx+1:(j-1)*Nx,1);
            y2((j-1)*Nx+1:j*Nx,1) = InvV(:,:,j)*(  f2((j-1)*Nx+1:j*Nx,1) - A(:,:,j-1)*dum_1d );
        end

        s1((Ny-1)*Nx+1:Nx*Ny,1) = y1((Ny-1)*Nx+1:Nx*Ny,1);
        s2((Ny-1)*Nx+1:Nx*Ny,1) = y2((Ny-1)*Nx+1:Nx*Ny,1);
        for j = Ny-1:-1:1
            dum_1d(1:Nx,1) = s1(j*Nx+1:(j+1)*Nx,1);
            s1((j-1)*Nx+1:j*Nx,1) = y1((j-1)*Nx+1:j*Nx,1) - U(:,:,j)*dum_1d;

            dum_1d(1:Nx,1) = s2(j*Nx+1:(j+1)*Nx,1);
            s2((j-1)*Nx+1:j*Nx,1) = y2((j-1)*Nx+1:j*Nx,1) - U(:,:,j)*dum_1d;
        end


        for j = 1:Ny
            for i = 1:Nx
                psi(i,j) = s1((j-1)*Nx+i,1);
                chi(i,j) = s2((j-1)*Nx+i,1);
            end
        end

        u_chi = d_dx_c(chi, dx, 1);
        v_chi = d_dx_c(chi, dy, 2);

        u_psi = -d_dx_c(psi, dy, 2);
        v_psi = d_dx_c(psi, dx, 1);


    else
        'Error: U and V are not the same size!!!'

    end
end % end helmholtz_decomp

function dVdx = d_dx_c(V,dx,dim)
    %% Description
    % d_dx_c is for derivative along one dimension with constant spacing (c stands for constant dx)
    % Centered difference is used at the interior, while varying off-centered
    % difference is used at the two boundary of the targeted dimension.
    % The output variable dVdx is of the same dimension as V.
    % The dx is assumed to be single value, and should constant at the targeted
    % dimension.
    Ndim = length(size(V));

    if dim <= Ndim
        dimsize = size(V);
        Nx = dimsize(dim);
        dimOrder = 1:Ndim;

        dimOrder2 = dimOrder;
        dimOrder2(dim) = 1;
        dimOrder2(1) = dim;

        V2 = permute(V,dimOrder2);
        dimsize2 = size(V2);

        dVdx2 = zeros(dimsize2);

        dVdx2(2:Nx-1,:,:,:,:,:) = (V2(3:Nx,:,:,:,:,:) - V2(1:Nx-2,:,:,:,:,:))/(2*dx);
        dx1 = dx;
        dx2 = 2*dx;
        dVdx2(1,:,:,:,:,:) = (V2(2,:,:,:,:,:)*(dx2^2) - V2(3,:,:,:,:,:)*(dx1^2) - V2(1,:,:,:,:,:)*(dx2^2 - dx1^2))/(dx1*dx2*(dx2-dx1));
        dx1 = -2*dx;
        dx2 = -dx;
        dVdx2(Nx,:,:,:,:,:) = (V2(Nx-2,:,:,:,:,:)*(dx2^2) - V2(Nx-1,:,:,:,:,:)*(dx1^2) - V2(Nx,:,:,:,:,:)*(dx2^2 - dx1^2))/(dx1*dx2*(dx2-dx1));

        % Permute dVdx2 back to dVdx using the same permute order (which is also the inverse order)
        dVdx = permute(dVdx2,dimOrder2);


    else
        'Error dim is wrong!!!'
    end
end
