%% *Extract a single storm from TCRADAR database and save into a new .nc file.
% For reference, TCRADAR is available at: 
%   https://www.aoml.noaa.gov/ftp/pub/hrd/data/radar/level3/
% It is frequently updated. 


%% ! set name of storm to extract
stormToExtract = "Dorian";
stormYear = 2019;

%% ! Set output file directory
outputDir = '/rita/s0/scratch/nrb171/';

%% * Set file locations
fileLocations = {...
    '/rita/s0/scratch/radardata/tc_radar/tc_radar_v3h_combined_xy_rel_swath_ships.nc', ...
    '/rita/s0/scratch/radardata/tc_radar/tc_radar_v3h_combined_xy_rel_merge_ships.nc' ...
};
fileType = ["swath", "merge"];

%% * Loop over swath and merge files
for ii = 1:2
    %% * Load the data
    info = ncinfo(fileLocations{ii});

    %% * Get storm names
    storm_name = ncread(fileLocations{ii}, 'storm_name');
    data_year = ncread(fileLocations{ii}, fileType(ii)+"_year");

    %% * Find the indices of the storm
    stormIndices = find(contains(lower(storm_name), lower(stormToExtract)) & data_year == stormYear);

    %% * Create new schema for the storm (set new length for num_cases)
    newInfo = info;
    dimensions = string({newInfo.Dimensions.Name});
    variables = string({newInfo.Variables.Name});
    newInfo.Dimensions(contains(dimensions, 'num_cases')).Length = length(stormIndices); 

    %% * Overwrite length of num_cases in the variables
    for jj = 1:length(variables)
        variableDimensions = string({newInfo.Variables(jj).Dimensions.Name});
        for kk = 1:length(variableDimensions)
            if contains(newInfo.Variables(jj).Dimensions(kk).Name, 'num_cases')
                newInfo.Variables(jj).Dimensions(kk).Length = length(stormIndices);
                newInfo.Variables(jj).Size(kk) = length(stormIndices);
                newInfo.Variables(jj).ChunkSize(kk) = length(stormIndices);
            end
        end
        
    end

    %% * Create new file
    newFile = strcat(outputDir, 'tc_radar_', char(fileType(ii)),'_', stormToExtract, '_', num2str(stormYear), '.nc');
    ncwriteschema(newFile, newInfo);

    %% * Write the data
    for jj = 1:length(variables)
        fprintf('Writing variable %s\n', variables(jj));
        var = ncread(fileLocations{ii}, variables(jj));
        varDims = string({info.Variables(jj).Dimensions.Name});
        varSlicer = repmat({':'}, [1 ndims(var)]);
        dimToSlice = find(contains(varDims, 'num_cases'));
        if ~isempty(dimToSlice)
            varSlicer{dimToSlice} = stormIndices;
            varOut = var(varSlicer{:});    
        else
            varOut = var;
        end
        
        ncwrite(newFile, variables(jj), varOut);        
    end

end
