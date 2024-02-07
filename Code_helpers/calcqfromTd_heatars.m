function qarray = calcqfromTd(Tdarray)
%Calculates q (specific humidity) from Td, using the formula of Bolton 1980
    %(listed at https://www.eol.ucar.edu/projects/ceop/dm/documents/refdata_report/eqns.html)
%Td is in C, q is in g/kg

%Table for validation: http://www.engineeringtoolbox.com/moist-air-properties-d_1256.html

%Uses vapor-pressure formulae from Huang 2018, doi:10.1175/jamc-d-17-0334.1, which is more accurate for T<0 C

%First, compute vapor pressure
%Formulae are different for Td>0 and <=0
vp=NaN.*ones(size(Tdarray));
tdlt0_vals=NaN.*ones(size(Tdarray));tdgt0_vals=NaN.*ones(size(Tdarray));

tdlt0_locs=Tdarray<=0;tdlt0_vals(tdlt0_locs)=Tdarray(tdlt0_locs);
vp_lt0=exp(43.494-(6545.8./(tdlt0_vals+278)))./((tdlt0_vals+868).^2)./100;
vp(tdlt0_locs)=vp_lt0(tdlt0_locs);

tdgt0_locs=Tdarray>0;tdgt0_vals(tdgt0_locs)=Tdarray(tdgt0_locs);
vp_gt0=exp(34.494-(4924.99./(tdgt0_vals+237.1)))./((tdgt0_vals+105).^1.57)./100;
vp(tdgt0_locs)=vp_gt0(tdgt0_locs);

%Then, specific humidity is trivial to compute, assuming that sfc pressure is 1010 mb
sfcP=1010;
qarray=1000.*(0.622.*vp)./(sfcP-(0.378.*vp));


end

