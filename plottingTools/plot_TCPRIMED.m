
folder = "/rita/s1/nrb171/TCPRIMED/";

year = "2004";
basin = "AL";
storm = "Ivan";
stormNumber = "09";

% get folder/list of files
global stormFolder
stormFolder = folder+year+"/"+basin+"/"+stormNumber+"/";
files = dir(stormFolder+"*.nc");
fileNames = string({files.name});

for i = 1:length(fileNames)
    fileName = fileNames(i);
    obs = getVarList(fileName);
    plotOverpass(obs)
end


function [obs] = getVarList(fileName)

    global stormFolder
    attributeNames = [...
        "long_name", ...
        "units", ...
        "valid_range", ...
        "geospatial_lat_min", ...
        "geospatial_lat_max", ...
        "geospatial_lon_min", ...
        "geospatial_lon_max", ...
    ];

    %%& GET THE UNIQUE BANDS FOR EACH SATELLITE &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    %%* AMSRE_AQUA *************************************************************
        if  nnz(contains(fileName, "AMSRE_AQUA"))>0
            varList = "/passive_microwave/S6/"+["TB_B89.0H"];
            % "/passive_microwave/S5/" TB_A89.0H
        end
    %%* SSMI_FXX ***************************************************************
        if  nnz(contains(fileName, "SSMI_F13"))>0 | ...
            nnz(contains(fileName, "SSMI_F14"))>0 | ...
            nnz(contains(fileName, "SSMI_F15"))>0
            varList = "/passive_microwave/S2/"+["TB_85.5H"]
        end


    %%* TMI_TRMM ***************************************************************
        if nnz(contains(fileName, "TMI_TRMM"))>0
            varList = "/passive_microwave/S3/"+["TB_85.5H"];
        end
    %%* AMSUB_NOAAXX ***********************************************************
        if  nnz(contains(fileName, "AMSUB_NOAA17"))>0 | ...
            nnz(contains(fileName, "AMSUB_NOAA16"))>0
            varList = "/passive_microwave/S1/"+["TB_89.0_0.9QV"];
        end

    %%& RETRIEVE THE IR NEAR 90 GHZ, LATITUDE, AND LONGITUDE, AND METADATA *****
        for i=1:length(varList)
            var = varList(i);
            varName = split(var, "/");
            varName = strrep(varName(end), ".", "_" );
            obs.(varName).IR = h5read(stormFolder+fileName, var);
            for j=1:length(attributeNames)
                try
                    obs.(varName).metaData.(attributeNames(j)) = h5readatt(stormFolder+fileName, var, attributeNames(j));
                catch
                    obs.(varName).metaData.(attributeNames(j)) = "N/A";
                end
            end
            varChar = char(var);
            splitInds = strfind(varChar, "/");

            % get scan time
            obs.(varName).metaData.scan_time = nanmean(...
                datetime(1970,01,01) + ...
                seconds(...
                    h5read(...
                        stormFolder+fileName, ...
                        string(varChar(1:splitInds(end)))+"ScanTime" ...
                    )...
                )...
            );

            %get lat
            obs.(varName).metaData.lat = wrapTo180(...
                h5read(...
                    stormFolder+fileName, string(varChar(1:splitInds(end)))+"latitude"...
                )...
            );

            %get lon
            obs.(varName).metaData.lon = wrapTo180(...
                h5read(...
                    stormFolder+fileName, ...
                    string(varChar(1:splitInds(end)))+"longitude"...
                )...
            );

            %find TC position
            x = h5read(stormFolder+fileName, string(varChar(1:splitInds(end)))+"x");
            y = h5read(stormFolder+fileName, string(varChar(1:splitInds(end)))+"y");
            r = sqrt(x.^2 + y.^2);
            [rMin, tcInd] = min(r, [], 'all', 'linear');


            dDeg = 3;
            %get geospatial bounds
            obs.(varName).metaData.geospatial_lon_max = obs.(varName).metaData.lon(tcInd)+dDeg;
            obs.(varName).metaData.geospatial_lon_min = obs.(varName).metaData.lon(tcInd)-dDeg;
            obs.(varName).metaData.geospatial_lat_max = obs.(varName).metaData.lat(tcInd)+dDeg;
            obs.(varName).metaData.geospatial_lat_min = obs.(varName).metaData.lat(tcInd)-dDeg;
        end

end

function [] = plotOverpass(obs)
    global stormFolder
    scanVariables = fieldnames(obs);
    for j = 1:length(scanVariables)
        scanVariable = scanVariables{j};
        figSize = [3.25,3.25];
        fig = figure('Units', 'inches', 'Position', [0,0,figSize(1),figSize(2)]);
        ax = axes(fig);
        hold on
        ax=plotEarth(ax);
        contourf(wrapTo180(obs.(scanVariable).metaData.lon), obs.(scanVariable).metaData.lat, obs.(scanVariable).IR, 176:4:300, 'LineStyle', 'none')
        cb=colorbar;
        cb.Label.String = "Brightness Temperature (K)";
        title({string(obs.(scanVariable).metaData.long_name), string(obs.(scanVariable).metaData.scan_time(1))})
        ylim([obs.(scanVariable).metaData.geospatial_lat_min, obs.(scanVariable).metaData.geospatial_lat_max])
        xlim([obs.(scanVariable).metaData.geospatial_lon_min, obs.(scanVariable).metaData.geospatial_lon_max])
        colormap(flipud(jet(32)))
        caxis([176,300])
        if ~exist(stormFolder+"/overpass/", 'dir')
            mkdir(stormFolder+"/overpass/")
        end
        ylabel("Latitude")
        xlabel("Longitude")
        print2(fig, stormFolder+"/overpass/"+strrep(string(obs.(scanVariable).metaData.scan_time(1))," ", "-")+"_"+string(scanVariable)+".png")
    end
end