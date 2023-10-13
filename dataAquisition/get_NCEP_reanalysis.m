% get the ncep u and v for these years
year_to_get = "2007";


ftpobj = ftp('ftp2.psl.noaa.gov');
pasv(ftpobj); %used to allow access through noaas firewall


parentdir = "/Datasets/ncep.reanalysis2/pressure/";

save_folder = '/rita/s0/scratch/nrb171/NCEP_wind_reanalysis/';



cd(ftpobj, char(parentdir));
% save file locally into newfolder
success = mget(ftpobj, char("*wnd."+year_to_get+".nc"), save_folder);
success

