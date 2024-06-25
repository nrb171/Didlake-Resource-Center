% Changes from meteo degrees azimuth to math degrees azimuth

function m = met2mat(x)
   
   m=-1.*(x-90);
   yyy=m<0;
   m(yyy)=m(yyy)+360;
	   
   