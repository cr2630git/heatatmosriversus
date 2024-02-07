%A flexible plotting script that can handle multiple types of data,
%Data argument is of form {lats;lons;matrix}, or, for wind, {lats;lons;uwndmatrix;vwndmatrix}
%where each constituent array is an identically sized 2D grid

%region can be a name (e.g. 'usa'; see options below) or a cell array
%containing 4 bounds, in the order w,n,e,s, e.g. {-125;50;-65;25}

%Examples:
%Temperature field overlaid with wind barbs:
%vararginnew={'variable';'wind';'contour';1;...
                %'caxismethod';'regional10';'vectorData';data;'overlaynow';1;...
                %'overlayvariable';'temperature';'datatooverlay';overlaydata;'anomavg';'avg'};
                
%Another overlay/underlay example:
%vararginnew={'overlayvariable';'wet-bulb temp';'datatooverlay';data;'contour';0;...
%            'underlaycaxismin';310;'underlaycaxismax';375;'underlaystepsize';5;'overlaynow';1;...
%            'variable';'wind';'vectorData';winddata;'anomavg';'avg';'conttoplot';'Asia';'nonewfig';1};

%Wind barbs only:
%data={theselats;theselons;uvals;vvals};
%datatype='custom';
%region='us-ne';
%vararginnew={'variable';'wind';'overlaystepsize';1;'contour';0;...
                %'vectorData';data;'overlaynow';0;'anomavg';'avg';'customwindscaling';3;'omitfirstsubplotcolorbar';1};

%Shaded map:
    %data={theselats;theselons;mydata};
    %vararginnew={'underlayvariable';'wet-bulb temp';'contour';0;...
    %'underlaycaxismin';0.1;'underlaycaxismax';0.5;'underlaystepsize';1;'overlaynow';0;'datatounderlay';data;'centeredon';180;'conttoplot';'all'};
    %datatype='custom';
    %region='us-ne';
    
%Up-to-date but complex example with three layers, from Raymond et al. 2021, compositemaps_unabridged.m script:
%(where terraindata is of same dimensions as data)
%vararginnew={'datatounderlay';data;'underlaycaxismin';cmin;'underlaycaxismax';cmax;'underlaystepsize';cstep;...
%                'underlaycolormap';colormaps('blueyellowred','more','not');'overlaynow';1;...
%                'variable';'wind';'vectorData';winddata;'customwindscaling';windscale;'anomavg';'avg';...
%                'conttoplot';continent;'customborderwidth';2;'nonewfig';1;...
%                'contour_overlay';1;'datatooverlay';terraindata;'overlaycaxismin';0;'overlaycaxismax';3000;'omitzerocontour';1;'overlaystepsize';500;...
%                'contourlabels';1;'manualcontourlabels';1;'cblabelfontsize';cblabelfontsize};


%Another complete example (wind overlaying temperature):
%vararginnew={'mapproj';'mercator';'datatounderlay';data;'underlaycaxismin';12;'underlaycaxismax';32;'underlaystepsize';2;'underlaycolormap';cmap;
%        'contour_underlay';0;'contourunderlayfill';1;'contourunderlaycolors';cmap;'centeredon';0;...
%        'overlaynow';0;'variable';'wind';'vectorData';vectordata;'customwindscaling';6;'conttoplot';'Asia';'nonewfig';1;'omitfirstsubplotcolorbar';0;...
%        'colorbarfontsize';10};
    
%%%%In all cases, script is then summoned by simply calling %%%%plotModelData(data,region,vararginnew,datatype)%%%%


%VERY IMPORTANT
%Input latitude, longitude, and data arrays must be oriented such that north is
    %on the top and west is on the left
%ALSO, they must be centered on the Prime Meridian -- if centering on 180 is desired, the
    %array will be manipulated appropriately within this script

function [caxisRange,cmapcolorstooutput]=plotModelData(data,region,vararginnew,datatype)


caxisRange=[];
icloud='~/Library/Mobile Documents/com~apple~CloudDocs/';


cb=0;fg=0;
if strcmp(datatype,'NARR')
    lsmask=ncread('lsmasknarr.nc','land')';sz1=277;sz2=349;
elseif strcmp(datatype,'NCEP144')
    lsmask=ncread('lsmaskncep.nc','land')';sz1=144;sz2=73;
elseif strcmp(datatype,'NCEP192')
    lsmask=ncread('lsmaskncep192by94.nc','soilw');sz1=192;sz2=94;
elseif strcmp(datatype,'CPC')
    lsmask=ncread('lsmaskhalfdegree.nc','lsm');sz1=720;sz2=360;
elseif strcmp(datatype,'OISST')
    lsmask=ncread('lsmaskquarterdegree.nc','lsm');sz1=1440;sz2=720;
elseif strcmp(datatype,'PRISM')
    sz1=621;sz2=1405;
elseif strcmp(datatype,'ERA-Interim')
    sz1=480;sz2=241;
elseif strcmp(datatype,'10x10box')
    sz1=18;sz2=36;
elseif strcmp(datatype,'NorESM1M')
    lsmask=ncread('lsmask2point5by1point875.nc','sftlf');sz1=144;sz2=96;
elseif strcmp(datatype,'CNRMCM5')
    lsmask=ncread('lsmask256by128.nc','sftlf');sz1=256;sz2=128;
elseif strcmp(datatype,'MIROC5')
    lsmask=ncread('lsmask256by128.nc','sftlf');sz1=256;sz2=128;
elseif strcmp(datatype,'IPSLCM5AMR')
    lsmask=ncread('lsmaskipslcm5amr.nc','sftlf');sz1=144;sz2=143;
elseif strcmp(datatype,'CSIROMk360') || strcmp(datatype,'MPIESMMR')
    lsmask=ncread('lsmask1point875by1point875.nc','sftlf');sz1=192;sz2=96;
elseif strcmp(datatype,'CESM1deg')
    sz1=192;sz2=288;
elseif strcmp(datatype,'custom')
    sz1=size(data{1},1);sz2=size(data{1},2);
end
shadingdescr='';intervaldescr='';contoursdescr='';windbarbsdescr='';

fgTitle='';fgXaxis='';fgYaxis='';
noNewFig = false;
vectorData = {};
varlistnames={'2-m Temp.';'Wet-Bulb Temp.';'Geopot. Height';'Wind';'q'};

if strcmp(datatype,'NARR') || strcmp(datatype,'NCEP144') || strcmp(datatype,'NCEP192') || ...
        strcmp(datatype,'CPC') || strcmp(datatype,'OISST') || strcmp(datatype,'PRISM') ||...
        strcmp(datatype,'10x10box') || strcmp(datatype,'NorESM1M') ||...
        strcmp(datatype,'CNRMCM5') || strcmp(datatype,'IPSLCM5AMR') || strcmp(datatype,'CSIROMk360') ||...
        strcmp(datatype,'MPIESMMR') || strcmp(datatype,'MIROC5') || strcmp(datatype,'custom') ||...
        strcmp(datatype,'ERA-Interim') || strcmp(datatype,'CESM1deg')
else
    disp('Please enter a valid data type.');
    return;
end

if ischar(region);fprintf('Region chosen is: %s\n',region);else;disp('Region is lat/lon bounds only, no name given');end
disp('Variable arguments chosen are listed below:');
disp(vararginnew);
if mod(length(vararginnew),2)~=0
    disp('Error: must have an even # of arguments.');
else
    for count=1:2:length(vararginnew)-1
        key=vararginnew{count};
        val=vararginnew{count+1};
        switch key
            case 'centeredon' %longitude to center the world map on -- default is 0, other typical option is 180
                centeredon=val; 
            case 'mapproj' %usually used only in conjunction with custom lat/lon bounds -- named regions already have default mapproj values
                mapproj=val; %e.g. 'mercator', 'lambert', 'robinson'
            case 'conttoplot' %usually used only in conjunction with custom lat/lon bounds -- named regions already have default conttoplot values
                conttoplot=val;
            case 'levelplotted' %pressure level plotted -- options are 1000, 850, 500, 300, or 200
                levelplotted=val;
            %OPTIONS FOR UNDERLAID DATA
            case 'underlayvariable' %optional
                underlayvartype=val; %will be plotted as colors
            case 'datatounderlay'
                underlaydata=val;
            case 'contour_underlay'
                contour_underlay=val;
            case 'underlaystepsize'
                underlaystepsize=val; 
            case 'underlaycolormap'
                underlaycolormap=val;
            case 'underlaycaxismin'
                underlaycaxismin=val;
            case 'underlaycaxismax'
                underlaycaxismax=val;
            case 'contourunderlayfill'
                contourunderlayfill=val;
            case 'contourunderlaycolors'
                contourunderlaycolors=val; %e.g. colors('black') or colormaps('whiteorangered','more','not')
            case 'underlaytransparency'
                underlaytransparency=val; %for underlay fill: 0 is fully transparent, 1 is normal
            %OPTIONS FOR OVERLAID DATA
            case 'overlayvariable' %optional
                overlayvartype=val; %'generic scalar', 'wind', 'temperature', 'height', 'wet-bulb temp', 'wv flux convergence', or 'specific humidity'
            case 'overlayvariable2'
                overlayvartype2=val; %wind, so will be plotted as barbs
            case 'datatooverlay'
                overlaydata=val;
            case 'datatooverlay2'
                overlaydata2=val;
            case 'contour_overlay'
                contour_overlay=val;
            case 'overlaystepsize'
                overlaystepsize=val;
            case 'overlaycolormap'
                overlaycolormap=val;
            case 'overlaycaxismin'
                overlaycaxismin=val;
            case 'overlaycaxismax'
                overlaycaxismax=val;
            case 'contouroverlayfill'
                contouroverlayfill=val;
            case 'contouroverlaycolors' %note that I haven't actually figured out how to have two separate colorbars in a contourm plot, so for all practical purposes this is meaningless
                %here's an example from Heat_ARs/makefigures.m:
                %figure(80+dayc);clf;hold on;
                %data={latarray_52x94;lonarray_52x94;double(mymap_tw)};
                %overlaydata={latarray_52x94;lonarray_52x94;double(mymap_ar)+4};
                %orangeandgreencmap=[colormaps('whitelightreddarkred','more','not');colormaps('whitelightgreendarkgreen','more','not')];
                %vararginnew={'datatounderlay';data;'underlaycaxismin';-0.5;'underlaycaxismax';7.5;'underlaystepsize';1;'underlaycolormap';orangeandgreencmap;
                %    'contour_underlay';1;'contourunderlayfill';1;'contourunderlaycolors';orangeandgreencmap;'underlaytransparency';0.5;...
                %    'overlaynow';1;'nolinesbetweenfilledcontours';1;'twodifferentaxes';1;...
                %    'datatooverlay';overlaydata;'overlaycaxismin';-0.5;'overlaycaxismax';7.5;'overlaystepsize';1;'overlaycolormap';orangeandgreencmap;
                %    'contour_overlay';1;'contouroverlayfill';0;'contouroverlaycolors';orangeandgreencmap;'overlaytransparency';0.5;...
                %    'conttoplot';'North America';'nonewfig';1;'omitfirstsubplotcolorbar';1};
                contouroverlaycolors=val;
            case 'contouroverlaylinewidth'
                contouroverlaylinewidth=val;
            case 'overlaytransparency'
                overlaytransparency=val; %for underlay fill: 0 is fully transparent, 1 is normal
            %BACK TO GENERAL SETTINGS
            case 'figc'
                figc=val;
            case 'mlabelon'
                mlabelon=1;
            case 'nonewfig'
                noNewFig=val;
            case 'twodifferentaxes'
                twodifferentaxes=val;
            case 'caxismethod'
                caxis_method=val; %'regional10', 'regional25', or 'world' (last is default)
            case 'vectorData'
                vectorData=val;
            case 'customwindscaling'
                customwindscaling=val; %ranges from 8 for large-magnitude winds to 1 for small-magnitude winds
                    %(choice generally requires trial-and-error on each plot)
            case 'skipfactor'
                skipfactor=val; %plot every xth vector (large values of this are necessary for zoomed-out maps)
            case 'elongationfactor'
                elongationfactor=val; %values >1 lengthen plotted vectors, all else being equal; values <1 shorten them
            case 'referenceval'
                referenceval=val; %for wind reference vector; in m/s
            case 'extrarefvecelongfactor'
                extrarefvecelongfactor=val; %extra factor by which to multiply the length of the reference vector, e.g. for consistency across different figures; tweak this as needed
            case 'omitrefvector'
                omitrefvector=val;
            case 'anomavg'
                anomavg=val;
            case 'overlaynow'
                overlaynow=val;
            case 'unevencolordemarcations'
                unevencolordemarcations=val; 
            case 'contourlabels' %whether to add contour labels, or omit them
                contourlabels=val;
            case 'fullresboundaries' %whether to plot time-consumingly full-resolution boundaries -- default is 0
                fullresboundaries=val;
            case 'highrescoasts'
                highrescoasts=1;
            case 'stateboundaries' %1 or 0; whether to show US state boundaries -- default is 1
                stateboundaries=val;
            case 'stateboundarycolor' %default is 'k'; can be colors('gray') or something else
                stateboundarycolor=val;
            case 'countryboundaries' %1 or 0; whether to show country boundaries -- overrides default
                countryboundaries=val;
            case 'countryboundarycolor' %default is 'k'; can be colors('gray') or something else
                countryboundarycolor=val;
            case 'countryborderlinewidth' %default (if this is not set) is 1
                countryborderlinewidth=val;
            case 'stateborderlinewidth' %default (if this is not set) is 0.5
                stateborderlinewidth=val;
            case 'coastlinewidth' %default (if this is not set) is 2
                coastlinewidth=val;
            case 'omitzerocontour' %whether to omit the zero countour, in contour plots
                omitzerocontour=val;
            case 'omitfirstsubplotcolorbar' %whether to omit the colorbar on the first subplot 
                    %(b/c it'll either be added after or not at all)
                omitfirstsubplotcolorbar=val;
            case 'colorbarposition'
                colorbarposition=val;
            case 'colorbarfontsize'
                colorbarfontsize=val;
            case 'colorbarticks'
                colorbarticks=val;
            case 'colorbarticklabels'
                colorbarticklabels=val;
            case 'nolinesbetweenfilledcontours' %whether to omit the lines between filled contours in the underlaid data
                nolinesbetweenfilledcontours=1;
            case 'manualcontourlabels' %whether to place contour labels manually or algorithmically
                manualcontourlabels=1;
            case 'cblabelfontsize' %font size of colorbar labels (same font size appears bigger when plotted region is smaller)
                cblabelfontsize=val;
            case 'plotasrasters'
                plotasrasters=val; %1 plots as rasters (mostly to address wrap-around issues for full world maps), 0 does the original default
            case 'facealphaval'
                facealphaval=val;
            case 'stippling'
                signifpts=val;
            case 'nobordersatall' %often useful if plotting highrescoasts along a single-country stretch
                nobordersatall=1;
            case 'provincialbordersonly'
                provincialbordersonly=1;
            case 'noframe'
                noframe=1;
            case 'nansblack'
                nansblack=val;
            case 'nanswhite'
                nanswhite=val;
            case 'nansgray'
                nansgray=val;
            case 'nanstransparent'
                nanstransparent=1;
            case 'aretwocolorbarscombined' %if yes, code assumes the second one is the overlay
                aretwocolorbarscombined=1;
        end
    end
end
exist mapproj;if ans==0;mapproj='mercator';end
exist overlaynow;if ans==0;overlaynow=0;end
exist underlaytransparency;if ans==0;underlaytransparency=1;end %i.e. make normal (non-transparent)
exist overlaytransparency;if ans==0;overlaytransparency=1;end %i.e. make normal (non-transparent)
exist plotasrasters;if ans==0;plotasrasters=0;end %i.e. do the original default mode
exist figc;if ans==1;figc=figc+1;else;figc=1;end
exist facealphaval;if ans==0;facealphaval=1;end
exist stateboundaries;if ans==0;stateboundaries=1;end
exist countryboundaries;if ans==0;countryboundaries=1;end
exist provincialbordersonly;if ans==1;provincialbordersonly=1;else;provincialbordersonly=0;end
exist stateboundarycolor;if ans==0;stateboundarycolor=colors('black');end
exist countryboundarycolor;if ans==0;countryboundarycolor=colors('black');end
exist countryborderlinewidth;if ans==0;countryborderlinewidth=1;end
exist stateborderlinewidth;if ans==0;stateborderlinewidth=0.5;end
exist coastlinewidth;if ans==0;coastlinewidth=2;end
exist nobordersatall;if ans==1;nobordersatall=1;stateboundaries=0;countryboundaries=0;else;nobordersatall=0;end
exist conttoplot;if ans==0;conttoplot='all';end

exist underlaycolormap;if ans==0;underlaycolormap=colormaps('rainbow','more','not');end
exist contourunderlayfill;if ans==0;contourunderlayfill=1;end
exist contouroverlayfill;if ans==0;contouroverlayfill=1;end
exist contourunderlaycolors;if ans==0;contourunderlaycolors=colors('black');end
exist contouroverlaycolors;if ans==0;contouroverlaycolors=colors('black');end
exist contourunderlaylinewidth;if ans==0;contourunderlaylinewidth=2;end
exist contouroverlaylinewidth;if ans==0;contouroverlaylinewidth=2;end
exist omitzerocontour;if ans==0;omitzerocontour=0;end
exist overlayvartype;if ans==0;overlayvartype='';end
exist underlayvartype;if ans==0;underlayvartype='';end

exist contourlabels;if ans==0;contourlabels=0;end
exist contour_underlay;if ans==0;contour_underlay=0;end
exist contour_overlay;if ans==0;contour_overlay=0;end
exist cblabelfontsize;if ans==0;cblabelfontsize=15;end
exist aretwocolorbarscombined;if ans==0;aretwocolorbarscombined=0;end

exist nansgray;if ans==0;nansgray=0;end
exist nansblack;if ans==0;nansblack=0;end
exist nanswhite;if ans==0;nanswhite=0;end

%Only make a new figure (as opposed to a new subplot) if called upon to do so
if noNewFig~=1
    fg=figure(figc);clf;
    set(fg,'Color',[1,1,1]);
    axis off;
    title(fgTitle);xlabel(fgXaxis);ylabel(fgYaxis);
end


%Select region to plot
if ischar(region)
    if strcmp(region,'world')
        mapproj='robinson';
        exist centeredon;
        if ans==1
            if centeredon==0
                southlat=-90;northlat=90;westlon=-180;eastlon=180;
            elseif centeredon==180
                southlat=-90;northlat=90;westlon=-360;eastlon=0; 
            end
        else
            southlat=-90;northlat=90;westlon=-180;eastlon=180;
        end
        conttoplot='all';
    elseif strcmp(region,'worldnorthof60s')
        southlat=-60;northlat=90;mapproj='robinson';
        exist centeredon;
        if ans==1
            if centeredon==0
                westlon=-180;eastlon=180;
            elseif centeredon==180
                westlon=-360;eastlon=0;
            end
        else
            westlon=-180;eastlon=180;
        end
        conttoplot='all';
    elseif strcmp(region,'worldminuspoles')
        southlat=-55;northlat=70;mapproj='robinson';
        exist centeredon;
        if ans==1
            if centeredon==0
                westlon=-180;eastlon=180;
            elseif centeredon==180
                westlon=-360;eastlon=0;
            end
        else
            westlon=-180;eastlon=180;
        end
        conttoplot='all';
    elseif strcmp(region,'nhplustropics')
        southlat=-10;northlat=90;mapproj='robinson';
        exist centeredon;
        if ans==1
            if centeredon==0
                westlon=-180;eastlon=180;
            elseif centeredon==180
                westlon=-360;eastlon=0;
            end
        else
            westlon=-180;eastlon=180;
        end
        conttoplot='all';
    elseif strcmp(region,'world30s40n130wto160e')
        southlat=-30;northlat=40;westlon=-130;eastlon=160;mapproj='robinson';conttoplot='all';    
    elseif strcmp(region,'world60s60n')
        southlat=-60;northlat=60;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world60s60n_mainlandareasonly')
        southlat=-60;northlat=60;westlon=-130;eastlon=160;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world50s50n')
        southlat=-50;northlat=50;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world50s50n140w180e')
        southlat=-50;northlat=50;westlon=-140;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world45s45n')
        southlat=-45;northlat=45;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world40s40n')
        southlat=-40;northlat=40;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world35s35n')
        southlat=-35;northlat=35;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world30s30n')
        southlat=-30;northlat=30;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region,'world30s40n')
        southlat=-30;northlat=40;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region, 'nnh')
        southlat=30;northlat=90;westlon=-180;eastlon=180;mapproj='stereo';conttoplot='all';
    elseif strcmp(region, 'nh0to60')
        southlat=0;northlat=60;westlon=-180;eastlon=180;mapproj='robinson';conttoplot='all';
    elseif strcmp(region, 'nh0to60n140wto140e')
        southlat=0;northlat=60;westlon=-140;eastlon=140;mapproj='robinson';conttoplot='all';
    elseif strcmp(region, 'northern-south-america')
        southlat=-30;northlat=15;westlon=-90;eastlon=-30;mapproj='mercator';conttoplot='all';
    elseif strcmp(region, 'northern-south-america-sm')
        southlat=-25;northlat=5;westlon=-70;eastlon=-43;mapproj='mercator';conttoplot='all';
    elseif strcmp(region, 'greater-north-america-tropical-pacific')
        southlat=-10;northlat=70;westlon=-178;eastlon=-55;mapproj='lambert';conttoplot='all';
    elseif strcmp(region, 'greater-north-america')
        southlat=10;northlat=70;westlon=-175;eastlon=-50;mapproj='lambert';conttoplot='all';
    elseif strcmp(region, 'north-america')
        southlat=20;northlat=80;westlon=-170;eastlon=-35;mapproj='lambert';conttoplot='all';
    elseif strcmp(region,'pacific-north-america')
        southlat=20;northlat=70;westlon=-180;eastlon=-60;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region,'pacific-north-america-sm')
        southlat=20;northlat=70;westlon=-170;eastlon=-60;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'na-west')
        southlat=21;northlat=60;westlon=-170;eastlon=-100;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'na-west-slightlysmaller')
        southlat=22.5;northlat=60;westlon=-165.5;eastlon=-102.5;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'na-east')
        southlat=25;northlat=55;westlon=-100;eastlon=-50;mapproj='lambert';conttoplot='North America';
    elseif strcmp(region, 'north-america-europe')
        southlat=20;northlat=65;westlon=-135;eastlon=50;mapproj='robinson';conttoplot='all';
    elseif strcmp(region, 'north-atlantic')
        southlat=25;northlat=75;westlon=-75;eastlon=10;mapproj='lambert';conttoplot='all';
    elseif strcmp(region,'north-atlantic-small')
        southlat=10;northlat=50;westlon=-80;eastlon=-25;mapproj='lambert';conttoplot='all';
    elseif strcmp(region,'alps')
        southlat=39.5;northlat=57.5;westlon=1;eastlon=21;mapproj='mercator';conttoplot='Europe';
    elseif strcmp(region,'caspiansea')
        southlat=33.5;northlat=48.5;westlon=44;eastlon=59;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'middle-east-india')
        southlat=5;northlat=45;westlon=30;eastlon=100;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'middle-east')
        southlat=10;northlat=45;westlon=30;eastlon=80;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'middle-east-small')
        southlat=15;northlat=36;westlon=30;eastlon=70;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'persian-gulf-greater')
        southlat=18.5;northlat=35;westlon=43.5;eastlon=62.25;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'persian-gulf')
        southlat=20;northlat=32;westlon=43;eastlon=60;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'persian-gulf-slightlysmaller')
        southlat=21;northlat=30;westlon=48.5;eastlon=57.25;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'persian-gulf-sm')
        southlat=23;northlat=30;westlon=48.5;eastlon=57.25;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'dubai-area')
        southlat=23.99;northlat=26.51;westlon=54.1;eastlon=56.4;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'abudhabi-area')
        southlat=24;northlat=24.85;westlon=54;eastlon=54.95;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'red-sea')
        southlat=13;northlat=26;westlon=34;eastlon=44;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'southeast-asia')
        southlat=0;northlat=30;westlon=75;eastlon=105;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'south-asia')
        southlat=5;northlat=35;westlon=60;eastlon=95;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'eindia')
        southlat=15;northlat=27.5;westlon=78.75;eastlon=98.75;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'eindia-sm')
        southlat=15;northlat=27.5;westlon=78.75;eastlon=93;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'eindia-evensmaller')
        southlat=17;northlat=27.5;westlon=80;eastlon=92;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'pakistan-muchgreater')
        southlat=19;northlat=39;westlon=59;eastlon=80;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'pakistan-greater')
        southlat=21.5;northlat=38;westlon=62.5;eastlon=77.25;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'pakistan-slightlygreater')
        southlat=25.5;northlat=35;westlon=65;eastlon=75;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'pakistan')
        southlat=26.5;northlat=33;westlon=67.5;eastlon=72.25;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'schina')
        southlat=17.5;northlat=36.5;westlon=96;eastlon=115;mapproj='mercator';conttoplot='Asia';
    elseif strcmp(region,'saus')
        southlat=-38;northlat=-19;westlon=124.5;eastlon=143.5;mapproj='mercator';conttoplot='Australia';
    elseif strcmp(region,'safr')
        southlat=-37;northlat=-20;westlon=21;eastlon=41;mapproj='mercator';conttoplot='Africa';
    elseif strcmp(region,'australia')
        southlat=-39;northlat=-8;westlon=105;eastlon=157;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'samer')
        southlat=-37;northlat=-20;westlon=-72.5;eastlon=-52.5;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'wamazon')
        southlat=-18.75;northlat=-2.5;westlon=-75;eastlon=-61.25;mapproj='mercator';conttoplot='South America';
    elseif strcmp(region,'wamazon-south')
        southlat=-18;northlat=-8;westlon=-73;eastlon=-62;mapproj='mercator';conttoplot='South America';
    elseif strcmp(region, 'usa-canada')
        southlat=23;northlat=70;westlon=-140;eastlon=-50;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region,'greater-mexico')
        southlat=10;northlat=36;westlon=-122;eastlon=-80;mapproj='mercator';conttoplot='all';
    elseif strcmp(region,'midlatband')
        southlat=10;northlat=60;westlon=-180;eastlon=-50;mapproj='lambert';conttoplot='all';
    elseif strcmp(region,'usa-full')
        southlat=15;northlat=75;westlon=-180;eastlon=-60;mapproj='lambert';conttoplot='North America';
    elseif strcmp(region,'usaminushawaii-tight')
        southlat=22;northlat=73;westlon=-175;eastlon=-65;mapproj='lambert';conttoplot='North America';
    elseif strcmp(region,'usaminushawaii-tight2')
        southlat=20;northlat=75;westlon=-175;eastlon=-60;mapproj='lambert';conttoplot='North America';
    elseif strcmp(region,'usaminushawaii-tight3') %a little more centered over the Lower 48
        southlat=20;northlat=75;westlon=-165;eastlon=-45;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region,'usa-slightlysouth')
        southlat=18;northlat=60;westlon=-135;eastlon=-55;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'usa-exp')
        southlat=23;northlat=60;westlon=-135;eastlon=-55;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'usa-exp15')
        southlat=18;northlat=60;westlon=-135;eastlon=-55;mapproj='lambert';conttoplot='North America';
    elseif strcmp(region, 'usa-exp175')
        southlat=18;northlat=55;westlon=-150;eastlon=-55;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'usa-exp2')
        southlat=15;northlat=75;westlon=-165;eastlon=-50;mapproj='lambert';conttoplot='North America';
    elseif strcmp(region, 'usa')
        southlat=25;northlat=50;westlon=-126;eastlon=-64;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'usa-slightlylarger') 
        southlat=24.5;northlat=50;westlon=-130;eastlon=-66;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'usa-slightlysmaller') 
        southlat=24.5;northlat=50;westlon=-125;eastlon=-66.3;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'greatest-western-usa')
        southlat=27;northlat=50;westlon=-125;eastlon=-87;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'greater-western-usa')
        southlat=30;northlat=50;westlon=-125;eastlon=-86;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'greater-eastern-usa')
        southlat=18;northlat=50;westlon=-102;eastlon=-65;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region, 'eastern-usa')
        southlat=23;northlat=50;westlon=-100;eastlon=-65;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region,'central-usa')
        %southlat=30;northlat=48.5;westlon=-104;eastlon=-82;mapproj='mercator';conttoplot='North America';
        southlat=33;northlat=48.5;westlon=-104;eastlon=-82;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region, 'greatest-midwestern-usa')
        southlat=28;northlat=50;westlon=-115;eastlon=-75;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region,'us-mw')
        southlat=33;northlat=48;westlon=-105;eastlon=-80;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'midwestus')
        southlat=30;northlat=49;westlon=-102;eastlon=-83;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'omaha-area')
        southlat=39.5;northlat=43;westlon=-98;eastlon=-94;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region, 'us-ne')
        southlat=35;northlat=50;westlon=-85;eastlon=-60;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'us-se')
        southlat=23;northlat=38;westlon=-100;eastlon=-74;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'us-gulf-coast')
        southlat=24;northlat=32;westlon=-100;eastlon=-78;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'us-gulf-coast-trimmed')
        southlat=24.5;northlat=32;westlon=-99;eastlon=-78;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'rockies')
        southlat=31;northlat=51;westlon=-111;eastlon=-93;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'western-usa')
        southlat=30;northlat=53;westlon=-125;eastlon=-90;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region,'western-usa-smaller')
        southlat=30;northlat=50;westlon=-125;eastlon=-100;mapproj='robinson';conttoplot='North America';
    elseif strcmp(region,'us-sw')
        southlat=25;northlat=45;westlon=-130;eastlon=-105;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'us-sw-small')
        southlat=31;northlat=39;westlon=-121;eastlon=-109;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'socal')
        southlat=32.52;northlat=36.5;westlon=-121.2;eastlon=-115;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'la-area-shreevastava')
        southlat=33.2;northlat=34.5;westlon=-119.1;eastlon=-116.8;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'la-area-shreevastava-sm')
        southlat=33.35;northlat=34.35;westlon=-118.75;eastlon=-117.15;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'la-area-shreevastava-sm2')
        southlat=33.38;northlat=34.32;westlon=-118.73;eastlon=-117.27;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'la-area-shreevastava-verysm')
        southlat=33.42;northlat=34.28;westlon=-118.68;eastlon=-117.32;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'la-area')
        southlat=33.2;northlat=35;westlon=-119.4;eastlon=-116.5;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'la-metro')
        southlat=33.2;northlat=34.65;westlon=-119.2;eastlon=-116.8;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region,'labasin')
        southlat=33.5;northlat=34.3;westlon=-119.1;eastlon=-117.3;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region, 'us-ne-small')
        southlat=38;northlat=46;westlon=-80;eastlon=-68;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region, 'ny-pa-nj')
        southlat=38;northlat=45.1;westlon=-80;eastlon=-71.5;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region, 'nyc-area')
        southlat=39;northlat=42;westlon=-76;eastlon=-72;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region, 'nyc-area-small')
        southlat=40.4;northlat=41.1;westlon=-74.4;eastlon=-73.6;mapproj='mercator';conttoplot='North America';
    elseif strcmp(region, 'nyc-only')
        southlat=40.5;northlat=40.9;westlon=-74.1;eastlon=-73.7;mapproj='mercator';conttoplot='North America';
    else
        disp('Region not recognized!');return;
    end
else %region is a cell array containing 4 bounds, in the order w,n,e,s
    southlat=region{4};northlat=region{2};westlon=region{1};eastlon=region{3};
end


numgridptsperdegree1=sz1/360;
numgridptsperdegree2=sz2/180;
%Convert lat/lon corners to gridpts
if strcmp(datatype,'NARR')
    temp1=wnarrgridpts(northlat,eastlon,1,0,1);
    temp2=wnarrgridpts(southlat,westlon,1,0,1);
elseif strcmp(datatype,'NCEP144')
    temp1=wncepgridpts(northlat,eastlon,1,0,144);
    exist centeredon;
    if ans==1
        if centeredon==0
            temp2=wncepgridpts(southlat,westlon,1,0,144);
        elseif centeredon==180
            temp2=wncepgridpts(southlat,eastlon,1,0,144);
        else
            disp('Please make centeredon 0 or 180');return;
        end
    else
        %Default is western hemisphere, equivalent to centeredon=0
        temp2=wncepgridpts(southlat,westlon,1,0,144);
    end
elseif strcmp(datatype,'NCEP192')
    temp1=wncepgridpts(northlat,eastlon,1,0,192);
    exist centeredon;
    if ans==1
        if centeredon==0
            temp2=wncepgridpts(southlat,westlon,1,0,192);
        elseif centeredon==180
            temp2=wncepgridpts(southlat,eastlon,1,0,192);
        else
            disp('Please make centeredon 0 or 180');return;
        end
    else
        %Default is western hemisphere, equivalent to centeredon=0
        temp2=wncepgridpts(southlat,westlon,1,0,192);
    end
elseif strcmp(datatype,'CPC') %north on top, centered on 180
    northindex=1+180-2*northlat;southindex=180-2*southlat;
    westindex=1;eastindex=720;
elseif strcmp(datatype,'custom') %any size array that's desired can be accommodated
    northindex=1;southindex=sz1;
    westindex=1;eastindex=sz2;
else
    if southlat>=0;southindex=sz2-((90-southlat)*numgridptsperdegree2);else southindex=(90+southlat)*numgridptsperdegree2;end
    if northlat>=0;northindex=sz2-((90-northlat)*numgridptsperdegree2);else northindex=(90+northlat)*numgridptsperdegree2;end
    if westlon>=0;westindex=sz1-((180-westlon)*numgridptsperdegree1);else westindex=(180+westlon)*numgridptsperdegree1;end
    if eastlon>=0;eastindex=sz1-((180-eastlon)*numgridptsperdegree1);else eastindex=(180+eastlon)*numgridptsperdegree1;end
    if southindex==0;southindex=1;end
    if northindex==0;northindex=1;end
    if westindex==0;westindex=1;end
    if eastindex==0;eastindex=1;end
end

%If necessary, move Eastern Hemisphere to left so array is centered on 180
exist centeredon;
if ans==1
    exist underlayvartype;
    if ans==1
        arraysz=size(underlaydata{1});
    end
    if centeredon==180 %essentially need to move one half of the array to the other side before plotting can proceed
        exist underlayvartype;
        disp('Moving Eastern Hemisphere to left to center array on 180 W');
        if ans==1
            arraysz=size(underlaydata{3});
            underlaydata{3}=[underlaydata{3}(:,arraysz(2)/2+1:arraysz(2)) underlaydata{3}(:,1:arraysz(2)/2)];
        end
    end
end
    
%Account for the fact that the inputted corners may be just outside the domain
if ~strcmp(datatype,'OISST')
    if ~strcmp(region,'world')
        exist northindex;
        if ans==0
            if temp1(1,1)<1000;northindex=temp1(1,1);else northindex=sz1;end
            if temp1(1,2)<1000;eastindex=temp1(1,2);else eastindex=sz2;end
            if temp2(1,1)<1000;southindex=temp2(1,1);else southindex=1;end
            if temp2(1,2)<1000;westindex=temp2(1,2);else westindex=1;end
        end
    else
        northindex=1;eastindex=1;southindex=sz2;westindex=sz1;
    end
end

clear ax1;
ax1=axesm(mapproj,'MapLatLimit',[southlat northlat],'MapLonLimit',[westlon eastlon]);
%fprintf('At line 619, southlat is %d, northlat is %d, westlon is %d, eastlon is %d\n',southlat,northlat,westlon,eastlon);return;

framem on;gridm off;axis on;axis off;
exist mlabelon;if ans==0;mlabel off;end
exist plabelon;if ans==0;plabel off;end
exist noframe;if ans==1;framem off;end


if length(underlaycolormap)>0;set(ax1,'colormap',underlaycolormap);else;set(ax1,'colormap',colormap('jet'));end


exist underlayvartype;
if ans==1
    if strcmp(underlayvartype,'wet-bulb temp') || strcmp(underlayvartype,'temperature')
        dispunits='deg C';
    elseif strcmp(underlayvartype,'height')
        dispunits='m';
    elseif strcmp(underlayvartype,'wind')
        dispunits='m/s';
    elseif strcmp(underlayvartype,'specific humidity')
        dispunits='g/kg';
        %underlaydata{3}=underlaydata{3}.*1000;
    elseif strcmp(underlayvartype,'wv flux convergence')
        dispunits='kg/m^-^2';
    elseif strcmp(underlayvartype,'generic scalar')
        dispunits=''; %no units necessary
    else
        dispunits='';
    end
else
    if strcmp(vartype,'wet-bulb temp') || strcmp(vartype,'temperature')
        dispunits='deg C';
    elseif strcmp(vartype,'height')
        dispunits='m';
    elseif strcmp(vartype,'wind')
        dispunits='m/s';
    elseif strcmp(vartype,'specific humidity')
        dispunits='g/kg';
        %underlaydata{3}=underlaydata{3}.*1000;
    elseif strcmp(vartype,'wv flux convergence')
        dispunits='kg/m^-^2';
    elseif strcmp(vartype,'generic scalar')
        dispunits=''; %no units necessary
    else
        dispunits='';
    end
end


%Determine the color range, either by specification in the function call or by default here
%Account for the fact that we don't know a priori which of (eastindex,westindex) and (southindex,northindex) will be larger
exist caxis_min;
if ans==0
    exist underlaycaxismin;
    if ans==0
        exist caxis_method;
        if ans==0 %default is to determine range globally
            exist underlaydata;
            if ans==1;overlaycaxismin=round2(min(min(underlaydata{3})),overlaystepsize,'floor');end
        elseif strcmp(caxis_method,'regional10')
            overlaycaxismin=round2(min(min(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),overlaystepsize,'floor');
            %caxis_min=round2(min(min(underlaydata{3})),mystep,'floor');
            disp('Note: Step size and color range have been overwritten to match the regional nature of the color axis.');
        elseif strcmp(caxis_method,'regional25')
            overlaystepsize=(max(max(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex))))-...
                min(min(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))))/25;
            overlaycaxismin=round2(min(min(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),overlaystepsize,'floor');
            disp('Note: Step size and color range have been overwritten to match the regional nature of the color axis.');
        else
            overlaycaxismin=round2(min(min(underlaydata{3})),overlaystepsize,'floor');
        end
    end
end
exist caxis_max;
if ans==0
    exist underlaycaxismax;
    if ans==0
        exist caxis_method;
        if ans==0 %default is to determine range globally
            exist underlaydata;
            if ans==1;overlaycaxismax=round2(max(max(underlaydata{3})),overlaystepsize,'ceil');end
        elseif strcmp(caxis_method,'regional10')
            overlaycaxismax=round2(max(max(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),overlaystepsize,'ceil');
        elseif strcmp(caxis_method,'regional25')
            overlaycaxismax=round2(max(max(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),overlaystepsize,'ceil');
        else
            overlaycaxismax=round2(max(max(underlaydata{3})),overlaystepsize,'ceil');
        end
    end
end

%Set underlay-data color axis
exist underlaycaxismin;
if ans==1;caxisRangeunderlay=[underlaycaxismin,underlaycaxismax];caxis(caxisRangeunderlay);end


%Display the underlaid (or only) data, contoured or not
exist underlaydata;
if ans==1
    if contour_underlay
        if size(underlaydata{3},1)~=size(underlaydata{2},1);underlaydata{3}=underlaydata{3}';end
        exist unevencolordemarcations;
        if ans==0 %step is set or chosen to be a fixed value
            v=underlaycaxismin:underlaystepsize:underlaycaxismax;
        else %variable intervals are set to demarcate colors
            v=unevencolordemarcations;
        end
        exist nolinesbetweenfilledcontours;
        %Option a: no lines between filled contours
        if ans==1
            if plotasrasters==1
                latlim=[southlat northlat];
                if westlon<0;eastlon=eastlon-westlon;westlon=0;end
                %if eastlon<0;eastlon=eastlon+360;end
                if strcmp(region,'world');westlon=0;eastlon=360;end %if plotting entire globe
                lonlim=[westlon eastlon];
                Z1=underlaydata{3};
                R=georefcells(latlim,lonlim,size(Z1),'ColumnsStartFrom','north');
                contourm(Z1,R,v,'Fill','on');hold on;
            else %the original default mode, with contours filled
                if contourunderlayfill==1
                    h=contourm(underlaydata{1},underlaydata{2},underlaydata{3},v,'Fill','on','edgecolor','none');hold on;
                else
                    h=contourm(underlaydata{1},underlaydata{2},underlaydata{3},v,'Fill','off','linewidth',2);hold on;
                    colormap(ax1,contourunderlaycolors);%disp('line 729');
                end
                if underlaytransparency~=1;alpha(underlaytransparency);end
            end
        else %Option b: black lines between filled contours
            if plotasrasters==1
                latlim=[southlat northlat];
                if westlon<0;eastlon=eastlon-westlon;westlon=0;end
                if strcmp(region,'world');westlon=0;eastlon=360;end %if plotting entire globe
                lonlim=[westlon eastlon];
                Z1=underlaydata{3};
                R=georefcells(latlim,lonlim,size(Z1),'ColumnsStartFrom','north');
                contourm(Z1,R,v,'Fill','on');hold on;
            else %the original default mode
                %disp(transparency);disp(v);
                h=contourm(underlaydata{1},underlaydata{2},underlaydata{3},v,'Fill','on');
                hold on;
                if underlaytransparency~=1;alpha(underlaytransparency);end
            end
        end
        exist nansblack;
        if ans==1
            thesenans=isnan(underlaydata{3});
            underlaydata{3}(thesenans)=999;
            underlaycolormap(1,:)=[0 0 0];
        end
        colormap(ax1,underlaycolormap);
        
    else
        t=pcolorm(underlaydata{1},underlaydata{2},underlaydata{3},'FaceAlpha',facealphaval);hold on;
        
        exist nanstransparent;
        if ans==1;set(t,'alphadata',~isnan(underlaydata{3}));end

        cmaplen=length(underlaycolormap);

        %If we'll be adding NaNs -- how many??
        exist colorbarticks;
        if ans==1 %we already know what categories we're looking for, so make NaNs one of these
            numcategsdisplayed=length(colorbarticks);
            numnanstoadd=round(cmaplen/numcategsdisplayed)+2;
            nanindex1=cmaplen+1;nanindex2=cmaplen+numnanstoadd;
        else %just add NaN as the very last color
            nanindex1=cmaplen+1;nanindex2=cmaplen+1;numnanstoadd=1;
        end
        
        if nanswhite==1
            thesenans=isnan(underlaydata{3});
            underlaydata{3}(thesenans)=10^6;
            rightside=repmat([1 1 1],[numnanstoadd 1]);
            underlaycolormap(nanindex1:nanindex2,:)=rightside;
        end
        if nansgray==1
            thesenans=isnan(underlaydata{3});
            underlaydata{3}(thesenans)=10^6;
            rightside=repmat([0.6 0.6 0.6],[numnanstoadd 1]);
            underlaycolormap(nanindex1:nanindex2,:)=rightside;
        end
        if nansblack==1
            thesenans=isnan(underlaydata{3});
            underlaydata{3}(thesenans)=10^6;
            rightside=repmat([0 0 0],[numnanstoadd 1]);
            underlaycolormap(nanindex1:nanindex2,:)=rightside;
        end
        %disp('line 849');disp(length(underlaycolormap));
        %Apply updated colormap
        exist underlaycolormap;if ans==1;colormap(ax1,underlaycolormap);end
        t=pcolorm(underlaydata{1},underlaydata{2},underlaydata{3},'FaceAlpha',facealphaval);hold on;
            
        %Applying stippling, if desired (adds about 5 min)
        %This code needs to be adjusted manually for each dataset
        exist signifpts;
        if ans==1
            numsigniffound=0;
            for i=1:size(underlaydata{1},1)
                for j=1:size(underlaydata{1},2)
                    if i<=35 || i>=55 %extratropics
                        if signifpts(i,j)==1
                            plotm(underlaydata{1}(i,j),underlaydata{2}(i,j),signifpts(i,j),'k.');
                            numsigniffound=numsigniffound+1;
                        end
                    end
                end
                if rem(i,20)==0;fprintf('At %d for stippling section of plotModelData\n',i);end
            end
        end
    end
end



%Plot overlaid data (scalar only)
if overlaynow==1
    %Add second axes, so this data can have its own colormap
    clear ax2;
    exist twodifferentaxes;
    if ans==1
        twoaxes=1;
        ax2=axesm(mapproj,'MapLatLimit',[southlat northlat],'MapLonLimit',[westlon eastlon]);
    else
        twoaxes=0;
        ax2=gca;
    end

    if contour_overlay==1
        if size(overlaydata,1)==3 %i.e. not wind
            v=overlaycaxismin:overlaystepsize:overlaycaxismax;
            if omitzerocontour==1
                %Plots positive solid and negative dashed, and omits the zero contour
                if overlaycaxismin<0
                    contourm(overlaydata{1},overlaydata{2},overlaydata{3},[overlaycaxismin:overlaystepsize:0-overlaystepsize],...
                        '--','linewidth',contouroverlaylinewidth,'linecolor','k');hold on;
                    [C,h]=contourm(overlaydata{1},overlaydata{2},overlaydata{3},[overlaystepsize:overlaystepsize:overlaycaxismax],...
                        'linewidth',contouroverlaylinewidth,'linecolor','k');
                else
                    [C,h]=contourm(overlaydata{1},overlaydata{2},overlaydata{3},[overlaystepsize:overlaystepsize:overlaycaxismax],...
                        'linewidth',contouroverlaylinewidth,'linecolor','k');
                end
                if overlaytransparency~=1;alpha(overlaytransparency);end
            else
                %Plots all contours solid
                if size(contouroverlaycolors,1)==1 %single color
                    [C,h]=contourm(overlaydata{1},overlaydata{2},overlaydata{3},v,'LineWidth',contouroverlaylinewidth,'LineColor',contouroverlaycolors);
                else %multiple colors
                    %disp('line 1029');
                    hold on;
                    clear C;clear h;
                    [C,h]=contourm(overlaydata{1},overlaydata{2},overlaydata{3},v,'LineWidth',contouroverlaylinewidth);
                    cmap=colormap(ax2,contouroverlaycolors);

                    clear cmapcolorstooutput;
                    vmin=min(v);vmax=max(v);vrange=vmax-vmin;vsize=size(v,2);
                    
                    cmapspacing=size(cmap,1)/(vsize-1);%disp(vsize);disp(cmapspacing);disp('line 1041');
                    if aretwocolorbarscombined==0 %default assumption
                        for i=1:vsize-1
                            cmapcounter=round2(1+(cmapspacing*(i-1)),1,'floor');
                            cmapcolorstooutput(i,:)=cmap(cmapcounter,:);
                            %disp('line 1040');disp(i);disp(cmapcounter);disp(cmap(cmapcounter,:));
                        end
                    else %two distinct colorbars (i.e. for different variables) have been combined, so this must be taken into account
                        %in particular, we really only need one of them -- we'll assume the second half (for hatching purposes, etc)
                        for i=round(vsize/2):vsize-1
                            cmapcounter=round2(-cmapspacing/2+(cmapspacing*(i-1)),1,'floor');
                            cmapcolorstooutput(i,:)=cmap(cmapcounter,:);
                            %disp('line 1053');disp(i);disp(cmapcounter);disp(cmap(cmapcounter,:));
                        end
                    end
                    cmapcolorstooutput(vsize,:)=cmap(end,:);
                    %disp(cmapspacing);disp(size(cmap,1));disp('line 1006');
                end
                if overlaytransparency~=1;alpha(overlaytransparency);end
            end


            %Space out the labels so there's not too many but every line is still labeled
            %Bigger numbers = more space between labels
            if isstr(region)
                if strcmp(region, 'us-ne') || strcmp(region, 'us-ne-small') || strcmp(region, 'nyc-area') || ...
                        strcmp(region, 'nyc-area-small') || strcmp(region,'nyc-only') || ...
                        strcmp(region,'us-sw-small') || strcmp(region,'omaha-area') || strcmp(region,'us-mw') ||...
                        strcmp(region,'us-se') || strcmp(region,'us-gulf-coast') || strcmp(region,'labasin')
                    labelspacing=1000; 
                elseif strcmp(region, 'north-america') || strcmp(region,'midlatband') || strcmp(region,'usa') || strcmp(region,'usa-canada')
                    labelspacing=500;
                else
                    labelspacing=10000;
                end
            else
                labelspacing=10000;
            end


            %Labels are made toward the end of the script, so that they are not
                %overwritten by state borders (search for "actually make labels")
        end
        hold on;
    
        exist overlayvartype2;
        if ans~=0
            contourm(overlaydata2{1},overlaydata2{2},overlaydata2{3},'LineWidth',contouroverlaylinewidth,'LineColor','k');
        end

        overlaymax=roundsd(max(max(overlaydata{3})),1);overlaymin=roundsd(min(min(overlaydata{3})),1);
        overlayrange=overlaymax-overlaymin;overlayrangetenths=overlayrange/10;
        exist mystep;
        if ans==0
            overlaysteps=overlaymin:overlayrangetenths:overlaymax;
        else
            overlaysteps=overlaymin:overlaystepsize:overlaymax;
        end
        %Round steps to nearest 'number that ends in a zero' so they aren't odd values
        for i=1:size(overlaysteps,2)
            if abs(overlaysteps(i))<10
                overlaysteps(i)=round2(overlaysteps(i),20);
            elseif abs(overlaysteps(i))<100
                overlaysteps(i)=round2(overlaysteps(i),40);
            elseif abs(overlaysteps(i))>=100
                overlaysteps(i)=round2(overlaysteps(i),200);
            end
        end
        overlaysteps=unique(overlaysteps); %remove duplicate values
    else
        ax=ax2;
        t=pcolorm(overlaydata{1},overlaydata{2},overlaydata{3},'FaceAlpha',facealphaval);hold on;

        if nanswhite==1
            thesenans=isnan(overlaydata{3});
            overlaydata{3}(thesenans)=999;
            overlaycolormap(1,:)=[1 1 1];
        end
        if nansgray==1
            thesenans=isnan(overlaydata{3});
            overlaydata{3}(thesenans)=999;
            overlaycolormap(1,:)=[0.6 0.6 0.6];
        end
        if nansblack==1
            thesenans=isnan(overlaydata{3});
            overlaydata{3}(thesenans)=999;
            overlaycolormap(1,:)=[0 0 0];
        end
        
        linkaxes([ax1,ax2]);alpha(ax1,0.5)
        ax2.Visible='off';ax2.XTick=[];ax2.YTick=[];
        colormap(ax2,overlaycolormap);
    end
end

%Second overlaid variable could show up under either of these names
exist overlayvartype2;phrfound=0;
if ans==1
    if strcmp(overlayvartype2,'wind');phr='Arrows: Wind in m/s';else phr='';end
    phrfound=1;
end
exist overlaydata;
if ans==1 && phrfound==0
    if size(overlaydata,1)==4;phr='Arrows: Wind in m/s';else phr='';end
else
    phr='';
end
windbarbsdescr=phr;

%Plot geography in background
exist highrescoasts;if ans==0;load coastlines;end
%Border/frame
framem on;


%Set color to shade the land areas (each US state and all countries in the domain)
co=colors('ghost white'); %defaults are ghost white or light gray, but this can be any color in 'colors' script
if ~nobordersatall
    cbc=countryboundarycolor;
else
    cbc=colors('ghost white');
end



exist stateboundaries;
if ans==1
    exist fullresboundaries;
    if ans==1
        filename=unzip(strcat(icloud,'General_Academics/Research/KeyFiles/gshhg-bin-2.3.7.zip'));
        delete COPYING.LESSERv3;delete LICENSE.TXT;delete README.TXT;
        %delete gshhs_c.b;
        %delete gshhs_h.b;delete gshhs_i.b;delete gshhs_l.b;
        %delete wdb_borders_c.b;
        %delete wdb_borders_h.b;delete wdb_borders_i.b;delete wdb_borders_l.b;
        %delete wdb_rivers_c.b;
        %delete wdb_rivers_h.b;delete wdb_rivers_i.b;delete wdb_rivers_l.b;
        borderstoplot=gshhs(filename{4},[southlat northlat],[westlon eastlon]);
        coaststoplot=gshhs(filename{17},[southlat northlat],[westlon eastlon]);
        geoshow([borderstoplot.Lat],[borderstoplot.Lon],'Color','k','LineWidth',2);hold on;
        geoshow([coaststoplot.Lat],[coaststoplot.Lon],'Color','k');
        
        %Show counties
        %colin=shaperead('cb_2016_us_county_500k.shp','UseGeoCoords',true);
        %geoshow(colin,'DisplayType','polygon','DefaultFaceColor',co,'FaceAlpha',0);
    else
        if stateboundaries==1
            states=shaperead('usastatelo','UseGeoCoords',true);
            geoshow(states,'DisplayType','polygon','DefaultFaceColor',co,'FaceAlpha',0);
        end
    end
else %default is to show states only
    if ~nobordersatall
        states=shaperead('usastatelo','UseGeoCoords',true);
        geoshow(states,'DisplayType','polygon','DefaultFaceColor',co,'FaceAlpha',0);
    end
end

exist highrescoasts;
if ans==1
    filename=unzip(strcat(icloud,'General_Academics/Research/KeyFiles/gshhg-bin-2.3.7.zip'));
    delete COPYING.LESSERv3;delete LICENSE.TXT;delete README.TXT;
    coaststoplot=gshhs(filename{5},[southlat northlat],[westlon eastlon]);
    geoshow([coaststoplot.Lat],[coaststoplot.Lon],'Color','k','linewidth',coastlinewidth);
end


exist countryboundaries;
if ans==1
    if countryboundaries==0;cbc=colors('ghost white');co=cbc;end
end


%HERE IS WHERE BORDERS ARE ACTUALLY ADDED -- state/country options may need to
%be fed to addborders.m separately because it's a regular script, not a function
if ~nobordersatall;clw=countryborderlinewidth;slw=stateborderlinewidth;addborders;end
%%%


exist colorbarfontsize;
if ans==0;colorbarfontsize=15;end

exist colorbarticks;
if ans==1;specifycbticks=1;else;specifycbticks=0;end

exist colorbarticklabels;
if ans==1;specifycbticklabels=1;else;specifycbticklabels=0;end


if ~noNewFig
    exist underlaydata;
    if ans==1
        exist omitfirstsubplotcolorbar;
        if ans==1
            if omitfirstsubplotcolorbar~=1
                exist colorbarposition;
                if ans==0
                    cb=colorbar('Location','eastoutside');set(cb,'fontweight','bold','fontsize',colorbarfontsize);
                else
                    cb=colorbar;set(cb,'fontweight','bold','fontsize',colorbarfontsize,'Position',colorbarposition);
                end
                if specifycbticks==1;set(cb,'xtick',colorbarticks);end
                if specifycbticklabels==1;set(cb,'xticklabel',colorbarticklabels);end
            end
        else
            exist colorbarposition;
            if ans==0
                cb=colorbar('Location','eastoutside');set(cb,'fontweight','bold','fontsize',colorbarfontsize);
            else
                cb=colorbar;set(cb,'fontweight','bold','fontsize',colorbarfontsize,'Position',colorbarposition);
            end
            if specifycbticks==1;set(cb,'xtick',colorbarticks);end
            if specifycbticklabels==1;set(cb,'xticklabel',colorbarticklabels);end
        end
    end
else
    exist omitfirstsubplotcolorbar;
    if ans==1
        if omitfirstsubplotcolorbar~=1
            exist colorbarposition;
            if ans==0
                cb=colorbar('Location','eastoutside');set(cb,'fontweight','bold','fontsize',colorbarfontsize);
            else
                cb=colorbar;set(cb,'fontweight','bold','fontsize',colorbarfontsize,'Position',colorbarposition);
            end
            if specifycbticks==1;set(cb,'xtick',colorbarticks);end
            if specifycbticklabels==1;set(cb,'xticklabel',colorbarticklabels);end
        end
    else
        exist colorbarposition;
        if ans==0
            cb=colorbar('Location','eastoutside');set(cb,'fontweight','bold','fontsize',colorbarfontsize);
        else
            cb=colorbar;set(cb,'fontweight','bold','fontsize',colorbarfontsize,'Position',colorbarposition);
        end
        if specifycbticks==1;set(cb,'xtick',colorbarticks);end
        if specifycbticklabels==1;set(cb,'xticklabel',colorbarticklabels);end
    end
end

if ischar(region)
    if strcmp(region,'us-ne') || strcmp(region,'us-ne-small') || strcmp(region,'us-sw-small') || strcmp(region,'us-mw') ||...
        strcmp(region,'us-se') || strcmp(region,'us-gulf-coast') || strcmp(region,'labasin')
        zoom(2.5);ylim([0.6 1.0]);
    end
end

   

%Add text labels in various places
if overlaynow==1
    exist underlayvartype;
    if ans==1
        if strcmp(underlayvartype,'height')
            underlaydatanum=3;phr=sprintf('Shading: %s',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'temperature')
            underlaydatanum=1;phr=sprintf('Shading: %s in deg C',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'wet-bulb temp')
            underlaydatanum=2;phr=sprintf('Shading: %s in deg C',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'specific humidity')
            underlaydatanum=5;phr=sprintf('Shading: %s in g/kg',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'wv flux convergence')
            underlaydatanum=6;phr=sprintf('Shading: %s in kg/m^-2',varlistnames{underlaydatanum});
        else
            phr='';
        end
    else
        if strcmp(vartype,'height')
            datanum=3;phr=sprintf('Shading: %s',varlistnames{datanum});
        elseif strcmp(vartype,'temperature')
            datanum=1;phr=sprintf('Shading: %s in deg C',varlistnames{datanum});
        elseif strcmp(vartype,'wet-bulb temp')
            datanum=2;phr=sprintf('Shading: %s in deg C',varlistnames{datanum});
        elseif strcmp(vartype,'specific humidity')
            datanum=5;phr=sprintf('Shading: %s in g/kg',varlistnames{datanum});
        elseif strcmp(vartype,'wv flux convergence')
            datanum=6;phr=sprintf('Shading: %s in kg/m^-2',varlistnames{datanum});
        else
            phr='';
        end
        shadingdescr=phr;
    end
    
    
    exist overlayvartype;
    if ans==1
        if strcmp(overlayvartype,'height')
            overlaydatanum=3;phrcont=sprintf('Contours: %s in m',varlistnames{overlaydatanum});
        elseif strcmp(overlayvartype,'temperature')
            overlaydatanum=1;phrcont=sprintf('Contours: %s in deg C',varlistnames{overlaydatanum});
        elseif strcmp(overlayvartype,'wind')
            overlaydatanum=4;phrcont=sprintf('Contours: %s in m/s',varlistnames{overlaydatanum});
        elseif strcmp(overlayvartype,'wet-bulb temp')
            overlaydatanum=2;phrcont=sprintf('Contours: %s in deg C',varlistnames{overlaydatanum});
        elseif strcmp(overlayvartype,'wv flux convergence')
            overlaydatanum=5;phrcont=sprintf('Contours: %s in kg/m^-2',varlistnames{overlaydatanum});
        else
            phrcont='';
        end
        contoursdescr=phrcont;
    end
end

%Phrases to display in the caption
displaycaption=0;
if displaycaption==1
    if contour_overlay || contour_underlay
        if ~strcmp(underlayvartype,'')
            if strcmp(underlayvartype,'height')
                phr=sprintf('(interval: %0.0f %s)',underlaystepsize,dispunits);
            else
                exist unevencolordemarcations;
                if ans==0;phr=sprintf(' (interval: %0.1f %s)',underlaystepsize,dispunits);end
            end
        else
            if strcmp(vartype,'height')
                phr=sprintf('(interval: %0.0f %s)',overlaystepsize,dispunits);
            else
                phr=sprintf(' (interval: %0.1f %s)',overlaystepsize,dispunits);
            end
        end
        intervaldescr=phr;
        
        fullshadingdescr=strcat([shadingdescr,' ',intervaldescr]);
        shadingphr=fullshadingdescr;
        
        if ~strcmp(overlayvartype,'')
            if size(overlaydata,1)==3 %i.e. if it's a scalar, contoured thing
                fullcontoursdescr=strcat([contoursdescr,' ',intervaldescr]);
                contoursphr=fullcontoursdescr;
            end
        end
        
        %Manual contour labeling
        %if overlaynow==1
        %    disp('line 731');uicontrol('Style','text','String',phrcont,'Units','normalized',...
        %            'Position',[0.4 0.07 0.2 0.05],'BackgroundColor','w','FontName','Arial','FontSize',18);
        %end
    end
end



%%%Prepare settings for displaying wind vectors%%%

%skipfactor plots every xth vector
    
%Defaults for all regions: refvectorshrinkfactor=1, maparea=maparea/4
if length(vectorData)~=0
    maparea=((northlat-southlat)*(eastlon-westlon));

    %Default skipfactor=1
    %Varargins required are maparea and referenceval
    %elongationfactor is usually helpful, though

    exist customwindscaling;
    if ans==1
        if customwindscaling==1 %for winds that are smallest in magnitude
            exist referenceval;if ans==0;referenceval=0.5;end %in m/s
            exist elongationfactor;if ans==0;elongationfactor=5;end
            exist skipfactor;if ans==0;skipfactor=1;end
        elseif customwindscaling==2
            exist referenceval;if ans==0;referenceval=1;end
            exist elongationfactor;if ans==0;elongationfactor=3;end
            exist skipfactor;if ans==0;skipfactor=1;end
        elseif customwindscaling==3
            exist referenceval;if ans==0;referenceval=2;end
            exist elongationfactor;if ans==0;elongationfactor=1;end
            exist skipfactor;if ans==0;skipfactor=1;end
        elseif customwindscaling==4
            exist referenceval;if ans==0;referenceval=3;end
            exist elongationfactor;if ans==0;elongationfactor=1;end
            exist skipfactor;if ans==0;skipfactor=2;end
        elseif customwindscaling==5
            exist referenceval;if ans==0;referenceval=5;end
            exist elongationfactor;if ans==0;elongationfactor=1;end
            exist skipfactor;if ans==0;skipfactor=2;end
        elseif customwindscaling==6
            exist referenceval;if ans==0;referenceval=10;end
            exist elongationfactor;if ans==0;elongationfactor=1;end
            exist skipfactor;if ans==0;skipfactor=2;end
        elseif customwindscaling==7
            exist referenceval;if ans==0;referenceval=15;end
            exist elongationfactor;if ans==0;elongationfactor=0.8;end
            exist skipfactor;if ans==0;skipfactor=2;end
        elseif customwindscaling==8 %for winds that are largest in magnitude
            exist referenceval;if ans==0;referenceval=25;end
            exist elongationfactor;if ans==0;elongationfactor=0.5;end
            exist skipfactor;if ans==0;skipfactor=4;end
        end
    end

    exist referenceval;if ans==0;referenceval=2;end %set default; can be set as low as 0.5 or as high as 50 depending on
        %the maps scale, anomalies vs averages, etc

    exist elongationfactor;
    if ans==0;elongationfactor=1;end
    exist extrarefvecelongfactor;
    if ans==0;extrarefvecelongfactor=1;end
    exist skipfactor;if ans==0;skipfactor=1;end
    exist omitrefvector;
    if ans==0;omitrefvector=0;end
    
    
    disp('skipfactor');disp(skipfactor);
    disp('elongationfactor');disp(elongationfactor);
    disp('extrarefvecelongfactor');disp(extrarefvecelongfactor);
    disp('referenceval');disp(referenceval);
end


%WHERE WIND IS PLOTTED
exist vectorData;
if ans==1
    if length(vectorData)~=0
        quivermc(vectorData{1},vectorData{2},vectorData{3},vectorData{4},...
            'dontaddtext','reference',referenceval, ...
            'maparea',maparea,'skipfactor',skipfactor,'elongationfactor',elongationfactor,'linewidth',2);

        %Plot reference vector
        xlength=(referenceval*elongationfactor*extrarefvecelongfactor)/1000;
        if extrarefvecelongfactor<2;xstart=0.77;else;xstart=0.73;end
        if omitrefvector==0;annotation('arrow',[xstart xstart+xlength],[0.09 0.09],'HeadWidth',10,'HeadLength',8,'LineWidth',3);end
    end
end
%%%%

exist refval;if ans==0;referenceval=0;end
exist windbarbsdescr;if ans==0;windbarbsdescr='';end
exist normrefveclength;if ans==0;normrefveclength=0;end
exist fullshadingdescr;if ans==0;fullshadingdescr='';end
exist fullcontoursdescr;if ans==0;fullcontoursdescr='';end
clear centeredon;

set(gca,'Position',[0.1 0.1 0.8 0.8]);
tightmap;

if contourlabels==1
    axHidden = axesm(mapproj,'MapLatLimit',[southlat northlat],'MapLonLimit',[westlon eastlon]);
    exist manualcontourlabels;
    if ans==1
        t=clabelm(C,h,'manual');
    else
        exist omitzerocontour;
        if ans==1
            t=clabelm(C,h,2:size(v,2));
        else
            t=clabelm(C,h,[2,2.5,3]);
        end
    end
    set(t,'FontSize',cblabelfontsize,'FontWeight','bold');
    set(t,'Parent',axHidden);
end

exist manualcontourlabels;
if ans==0;tightmap;end


clear overlayvartype;


