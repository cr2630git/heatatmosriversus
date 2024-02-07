function daynumber = gethadisddaynumberfromyearanddoy(year,doy)
%Gets HadISD day number from any year/day combination
%  This is based on HadISD data starting 1/1/1931

input_mon=DOYtoMonth(doy,year);
input_dom=DOYtoDOM(doy,year);
daynumber=DaysApart(12,31,1930,input_mon,input_dom,year);

end
