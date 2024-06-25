function [dataDecomposed] = wavenumberDecomposition( data, cxGrid, cyGrid, varargin )
%assumed cartesian grid

% Parse input
p = inputParser;
addRequired(p, 'data', @isnumeric);             % data to decompose
addRequired(p, 'cxGrid', @isnumeric);           % centered x grid
addRequired(p, 'cyGrid', @isnumeric);           % centered y grid

addParameter(p, 'Wavenumbers', 1, @isnumeric);  % wavenumher(s) to calculate
addParameter(p, 'rMax', 250, @isnumeric);       % maximum radius (km)


parse(p, data, cxGrid, cyGrid, varargin{:});


%sampling frequency
fs = 360;
n =  360;

% Get parameters
data = p.Results.data;
cxGrid = p.Results.cxGrid;
cyGrid = p.Results.cyGrid;
wn = p.Results.Wavenumbers;
rMax = p.Results.rMax;

% grid calculations
[thetaMesh, rMesh] = meshgrid(0:1:359, 1:1:rMax);
xMeshCyl = rMesh.*cosd(thetaMesh);
yMeshCyl = rMesh.*sind(thetaMesh);
[yMesh, xMesh] = meshgrid(cyGrid, cxGrid);


%frequency array
f =  fs*(0:(n-1))/n;
[fmesh, ~] = meshgrid(f, 1:size(rMesh,1));

%preallocate
fTransformFull = zeros(size(rMesh,1), n);
dataDecomposed = zeros(size(data));


for kk = 1:size(data,3)
    %interpolate data to cylindrical grid
    dataInterpolant = griddedInterpolant(xMesh, yMesh, data(:,:,kk), 'linear', 'none');
    dataCyl = dataInterpolant(xMeshCyl, yMeshCyl);



    %fourier transform at each radius
    for ii = 1:size(dataCyl,1)
        y = (dataCyl(ii,:));

        %interpolate over NaNs
        if any(isnan(y))
            try
                y(isnan(y)) = interp1(find(~isnan(y)), y(~isnan(y)), find(isnan(y)), 'linear');
            catch
                %do nothing
            end
        end


        %fourier transform
        fTransform = fft(y,n);
        fTransformFull(ii,:) = fTransform;
    end

    %reconstruct data
    fTransformRecon= fTransformFull;
    fTransformRecon(~ismember(fmesh, wn)) = 0;

    dataReconCyl = real(ifft(fTransformRecon,n,2));

    dataDecomposed(:,:,kk) = griddata(xMeshCyl, yMeshCyl, dataReconCyl, xMesh, yMesh, 'linear');
end
