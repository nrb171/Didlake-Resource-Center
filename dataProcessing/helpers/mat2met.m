% Changes from math degrees azimuth to meteo degrees azimuth

function m = mat2met(x)
   
   m=90-x;
   m2=m;
   if (m<0)
      m=m2+360;
   end
      