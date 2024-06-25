function dataave = calculate_quadrantAverage(lon, lat, clon, clat, data, direction)
    

    % lon: 2D array of longitudes
    % lat: 2D array of latitudes
    % clon: value of the storm center longitude
    % clat: value of the storm center latitude
    % data: 3D array of data
    % direction: origin direction to calculate quadrants from (METEO angle; degrees to the right of north)

    % returns: 3D array of quadrant averages. [r, z, quadrant]
    % quadrant = 1: quadrant to the left of the direction (0-90 math degrees)
    % quadrant = 2: quadrant to the left of the opposite direction (90-180 math degrees)
    % quadrant = 3: quadrant to the right of the opposite direction (180-270 math degrees)
    % quadrant = 4: quadrant to the right of the direction (270-360 math degrees)

    %e.g. if direction is the shear direction, then 1=DL, 2=UL, 3=UR, 4=DR


    
   direction = met2mat(direction);

    %put the storm centers into an array that matches the size of the wind data.
    clonmesh = ones(size(lon))*clon;
    clatmesh = ones(size(lat))*clat;

    %calculate the distance from each point from the center of the storm.
    [xd, yd, ~,~] = latlon_to_disaz(clatmesh, clonmesh, lat, lon);


    %create the grid for the azimuthal average.
    agrid0 = [0,90,180,270]+45;
    zgrid2 = 1:size(data,3);


    agrid2 = 0:1:360;
    rgrid2 = 0:1000:300*1000;
    [rmesh3, amesh3, zmesh3] = ndgrid(rgrid2, agrid2, zgrid2);
    xmesh3cyl = rmesh3.*cosd(amesh3);
    ymesh3cyl = rmesh3.*sind(amesh3);
    zmesh3cyl = zmesh3*1000;

    


    xdd = nanmean(xd,2);
    ydd = nanmean(yd,1);
    zdd = zgrid2*1000;
    
    [xmesh3, ymesh3, zmesh3] = ndgrid(xdd, ydd, zdd);
    
   

    % Create interpolant and interpolate to cylindrical coordinates.
    dataInterpolant=griddedInterpolant(xmesh3, ymesh3, zmesh3, data, 'linear', 'none');
    
    datacyl = dataInterpolant(xmesh3cyl, ymesh3cyl, zmesh3cyl);


  
    % Average the data in each quadrant.
    dataave = zeros(numel(rgrid2), numel(zgrid2), 4);
    for jj = 1:4
        % dot product: [direction of interest] (dot) [agrid] > cos(45) is all data in the quadrant
        dp = ...
            cosd(agrid2)*cosd(direction+agrid0(jj)) + ...
            sind(agrid2)*sind(direction+agrid0(jj)) ...
        ;
        inds = find(dp > cosd(45));
        
        dataave(:,:,jj) = squeeze(nanmean(datacyl(:,inds,:),2));
    end