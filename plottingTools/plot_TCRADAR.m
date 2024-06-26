%% A sample script to load and plot the TC radar data

type = "swath"; %"swath" or "merge"

%% ! select the file to load
filePath = "/rita/s0/scratch/nrb171/tc_radar_"+type+"_Dorian_2019.nc";

%% ! Select the variable to load
timeVariables = type+"_"+[ ...
    "year", ...
    "month", ...
    "day", ...
    "hour", ...
    "min" ...
];

locationVariables = [...
    "original_longitudes", ... %degrees
    "original_latitudes", ...
    "x_distance", ... %km from storm center
    "y_distance" ...
];

variableNames = [...
    "swath_earth_relative_zonal_wind", ... %m/s
    "swath_earth_relative_meridional_wind", ...
    "swath_zonal_wind", ...
    "swath_reflectivity" ... %dBZ
];

%% * Load the data

% Load the time variables
for ii = 1:length(timeVariables)
    timeData.(timeVariables(ii)) = ncread(filePath, timeVariables(ii));
end

% Load the location variables
for ii = 1:length(locationVariables)
    locationData.(locationVariables(ii)) = ncread(filePath, locationVariables(ii));
end

% Load the variable data
for ii = 1:length(variableNames)
    variableData.(variableNames(ii)) = ncread(filePath, variableNames(ii));
end

%% * plot samples of data
for tt = 1:size(timeData.swath_year, 1)
    for ii = 1:length(variableNames)
        fig = figure;
        contourf(...
            locationData.original_longitudes(:,:,tt), ...
            locationData.original_latitudes(:,:,tt), ...
            squeeze(variableData.(variableNames(ii))(5,:,:,tt)), ...
            64, 'LineColor','none' ...
        );
        colorbar
        timeString = ...
            timeData.swath_year(tt) + "-" + ...
            timeData.swath_month(tt) + "-" + ...
            timeData.swath_day(tt) + " " + ...
            timeData.swath_hour(tt) + ":" + ...
            timeData.swath_min(tt);
        title(timeString+" "+variableNames(ii));
        saveas(gcf, ".temp_"+timeString+"_"+variableNames(ii)+".png");
    end
end
