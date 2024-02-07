%Compares nearly-coincident heat stress (extreme Tw) and ARs through analyzing several
%variables, for the seven CONUS NCA regions

%File locations
icloud='~/Library/Mobile Documents/com~apple~CloudDocs/';
figloc=strcat(icloud,'General_Academics/Research/Heat_ARs/');
dataresloc_local=strcat(icloud,'General_Academics/Research/Heat_ARs/Data_&_Results/');
dataresloc_external='/Volumes/ExtDriveC/Heat_ARs/';


%Loops to run
reload=0; %3 min; required on start-up
readardata=0; %2.5 hours
finddailyars=0; %1 min
    createarcomparisonfig=0; %creates climomjjasarfreq_timestepcomparison figure
find6hourlyars=0; %20 sec
getdailyheatstress_merra2=0; %old: 2.5 hours; new: 7 hours
get3hourlyheatstress_merra2=0; %3.5 hours
dofirstcomparisonofheatandars=0; %4 min per year; only calculates for May 1-Sep 30
    startyear_comparison=1980;stopyear_comparison=2018; %default is 1980-2018
artwcomparison=0; %20 min
readothervariables=0; 
    dodailyivt=0; %25 min
    do6hourlyivt=0; %45 min
    dodailyprecipevapradsm=0; %3 hours
    do3hourlyprecipevapradsm=0; %50 min
    do1hourlyprecip=0; %45 min
    do3hourlyprecip_era5land=1; %50 min
    do1hourlyprecip_era5land=0; %55 min
    doomega500=0; %50 min
    doz500=0;
    doarscale=0; %20 min
calctivtpctiles=0; %20 sec
precipivttwcomparison=0; %15 min
makedailycompositesfortimeseries=0; %required on start-up (reanalyzepeakheatstressdays only); creates peakheatstressdays and regpeakheatstressdays arrays
    newfigureversion=0;
    reanalyzepeakheatstressdays=1; %6 min
    processvars=0; %40 min, of which 30 min are for var 4
    firstvartocomposite=1;lastvartocomposite=12; %defaults are 1 and 12
makearonlycomposites=0; %20 sec; added by reviewer request, Dec 2023
make3hourlycompositesfortimeseries=0; %unlike other loops, uses region's central points only
    reanalyzepeakheatstresstimesteps=1;
makedailycompositesformaps=1;
    makecomposites_part1=0; %30 sec; not really necessary
    makecomposites_part2=1; %old: 2.5 hrs, new: 20 min (but usually can be reloaded)
        saveoutput_makecompositespart2=1;
        compositearrtype='hs'; %'peakhs' or 'hs'
        firstreg=1;lastreg=7; %1-7 is all regions
        firstvar=1;lastvar=6; %1-6 are core variables
regionalquadrants=0; 
    rqpart1=1; %10 sec
    rqpart2=0; %1 hr 15 min
prepforcontrastingobscases=0; %5 min
comparetwprecip=0; %1 min
comparison_3hourly=0; %output can usually be reloaded; if not, runs makecompositesofasetofhours_3hourly.m and takes 10 min for var 1, 30 sec for var 2, 10 min for var 6
    saveoutput_make3hourlycomposites=1;
    timestepstodo='all'; %either 'all' or 'select' (the latter a pre-defined set)
    firstvar_3hourly=1;lastvar_3hourly=6;
comparison_1hourly=0; %output can usually be reloaded; if not, runs makecompositesofasetofhours_1hourly.m and takes 10 min for var 1, 30 sec for var 2, 10 min for var 6
    saveoutput_make1hourlycomposites=1;
    firstvar_1hourly=1;lastvar_1hourly=6; %defaults are 1, 6
    wethourthresh=0.0001; %m
getstationprecipdata=0; %3 min; connected with ts_twprecip loop
regularizestationprecipdata=0; %30 sec; follows on getncargaugeprecipdataforastn.m, and should eliminate any need for the prior two loops here; PREPARES THE WAY FOR TIMESERIES IN MAKEFIGURES.m
    hourstogoout=24; %go out this number of hours both before and after





%Settings
defaultstartyear=1980;defaultstopyear=2018; %based on intersection of merra2 and current tw data records
ardataset='merra2'; %MERRA2 runs 1980-2020
timestepreqt=2; %minimum number of consecutive 6-hourly AR timesteps to be considered an AR day

heatstressthresh_main='95';
heatstressthresh_lower='90';

%Notes
%Variables, in order, are Tw, AR, T, q, tIVT, precip, evap, net sw, net lw, toplevelsm, z500, omega500


numyears=defaultstopyear-defaultstartyear+1;
if strcmp(ardataset,'merra2');numdays=365;end
nummjjasdays=153;may1doy=121;sep30doy=273;




%Other general settings
format shortG;
southedge=24.5;northedge=50;westedge=235;eastedge=293.5;westedge2=westedge-360;eastedge2=eastedge-360; %contiguous-US lat/lon bounds
    
ncaregionnames={'';'Northwest';'Southwest';'N Great Plains';'S Great Plains';'Midwest';'Southeast';'Northeast'};
ncaregnamesshort={'nw';'sw';'ngp';'sgp';'mw';'se';'ne'};
ncaregnamesshort_caps={'NW';'SW';'NGP';'SGP';'MW';'SE';'NE'};
ncaregionsmanuallydefined;
regcolors={colors('meteoswiss_light green');colors('light red');colors('orange');colors('gold');colors('histogram blue');colors('forest green');colors('purple')};
regcolors_pale=makecolorpaler(regcolors,1);
regcolors_verypale=makecolorpaler(regcolors_pale,1);
numregs=7;

subreglabels={'a)';'b)';'c)';'d)';'e)';'f)';'g)';'h)';'i)';'j)';'k)';'l)';'m)';'n)';'o)';'p)';'q)';'r)';'s)';'t)'};

monlens=[31;28;31;30;31;30;31;31;30;31;30;31];

%For line plots
twcolor=colors('pink');
arcolor=colors('green');
tcolor=colors('red');
qcolor=colors('blue');
tivtcolor=colors('purple');
precipcolor=colors('sky blue');
evapcolor=colors('light brown');
netswcolor=colors('light orange');
netlwcolor=colors('dark orange');
toplevelsmcolor=colors('turquoise');
omega500color=colors('fuchsia');

%For 1-hourly and 3-hourly plots
firstoffsettimestep_3hr=-8;lastoffsettimestep_3hr=0; %interval is 3 hours
    timestepoffsets_3hr=firstoffsettimestep_3hr:lastoffsettimestep_3hr;
firstoffsettimestep_1hr=-24;lastoffsettimestep_1hr=24; %interval is 1 hour

%Certain figures only: instead of looping through all points, for purposes of visualization, just pick a
    %central point in each region (based on Fig 3)
%NW: 10,12 (ne Oregon)
%SW: 29,17 (s Nevada)
%NGP: 9,35 (sw North Dakota)
%SGP: 40,41 (sc Texas)
%MW: 15,61 (s Wisconsin)
%SE: 32,65 (nw Georgia)
%NE: 18,82 (se New York)
regcentralpt_rows=[10;29;9;40;15;32;18];
regcentralpt_cols=[12;17;35;41;58;65;82];





if reload==1
    if strcmp(ardataset,'merra2')
        tmp=load(strcat(dataresloc_external,'allus_ars_merra2.mat'));
        lonarray=tmp.lonarray;latarray=tmp.latarray;
        lonarray_52x94=tmp.lonarray;latarray_52x94=tmp.latarray; %same as lon/latarray because this is already sized appropriately
        westernhem=lonarray_52x94>180;lonarray_52x94(westernhem)=lonarray_52x94(westernhem)-360;
        lsmask=tmp.lsmask;lsmask_52x94=flipud(lsmask');
        allusarshapes=tmp.allusarshapes;allusars_dates=tmp.allusars_dates;
        allusaraxes=tmp.allusaraxes;allusartransects=tmp.allusartransects;
    end
    largerdim=max(size(lonarray,1),size(lonarray,2));smallerdim=min(size(lonarray,1),size(lonarray,2));
        
    if strcmp(ardataset,'merra2')
        northrow=1;southrow=52;westcol=1;eastcol=94;
    end
    tmp=load(strcat(dataresloc_local,'daystocomposite_merra2.mat'));regpeakheatstressdays=tmp.daystocomposite;
    
    
    tmp=load(strcat(dataresloc_external,'heat_merra2.mat'));
    t_52x94=tmp.t_52x94+273.15;td_52x94=tmp.td_52x94+273.15;tw_52x94=tmp.tw_52x94;
    twp50=tmp.twp50;twp90=tmp.twp90;twp95=tmp.twp95;twp98=tmp.twp98;twp99=tmp.twp99;twp995=tmp.twp995;
    twmean=tmp.twmean;twmean_sm=tmp.twmean_sm;
    regtwp50=tmp.regtwp50;regtwp90=tmp.regtwp90;regtwp95=tmp.regtwp95;regtwp98=tmp.regtwp98;regtwp99=tmp.regtwp99;regtwp995=tmp.regtwp995;

    loadthese=0;
    if loadthese==1
    tmp=load(strcat(dataresloc_external,'tw_merra2_3hr.mat'));tw3hr_52x94=tmp.tw3hr_52x94;
    tmp=load(strcat(dataresloc_external,'t_merra2_3hr.mat'));t3hr_52x94=tmp.t3hr_52x94;
    tmp=load(strcat(dataresloc_external,'td_merra2_3hr.mat'));td3hr_52x94=tmp.td3hr_52x94;
    

    tmp=load(strcat(dataresloc_external,'precip_merra2.mat'));precip_52x94=tmp.precip_52x94;
    tmp=load(strcat(dataresloc_external,'ivt_merra2.mat'));tivt_52x94=tmp.tivt_52x94;
    end

    exist z500_52x94;
    if ans==0;temp=load(strcat(dataresloc_external,'z500_merra2.mat'));z500_52x94=temp.z500_52x94;end
    exist z500anoms_52x94;
    if ans==0
        for y=1:size(z500_52x94,1)
            z500anoms_52x94(y,:,:,:)=squeeze(z500_52x94(y,:,:,:))-squeeze(mean(z500_52x94));
        end
    end

    
    tmp=load(strcat(dataresloc_external,'bigpctilemap_data'));
    twpctiles=tmp.twpctiles;tpctiles=tmp.tpctiles;qpctiles=tmp.qpctiles;
    aroccurrences=tmp.aroccurrences;meanarfreq=tmp.meanarfreq;
    precippctiles=tmp.precippctiles;
    precipoccurrences=tmp.precipoccurrences;
    meanpreciplikelihood=tmp.meanpreciplikelihood;

    loadthese=0;
    if loadthese==1

    tmp=load(strcat(dataresloc_external,'bigpctilemap_3hrdata'));
    datesinsetofdays=tmp.datesinsetofdays;
    tw3hrpctiles=tmp.tw3hrpctiles;
    ar3hroccurrences=tmp.ar3hroccurrences;meanar3hrfreq=tmp.meanar3hrfreq;
    precip3hrpctiles=tmp.precip3hrpctiles;precip3hroccurrences=tmp.precip3hroccurrences;
    precip3hrmeanlikelihood=tmp.precip3hrmeanlikelihood;

    precip3hrpctiles_merra2=tmp.precip3hrpctiles;
    precip3hroccurrences_merra2=tmp.precip3hroccurrences;
    precip3hrmeanlikelihood_merra2=tmp.precip3hrmeanlikelihood;

    precip3hrpctiles_era5land=tmp.precip3hrpctiles_era5land;
    precip3hroccurrences_era5land=tmp.precip3hroccurrences_era5land;
    precip3hrmeanlikelihood_era5land=tmp.precip3hrmeanlikelihood_era5land;

    f=load(strcat(figloc,'Data_&_Results/relriskbyregdata'));
    relrisk_twp95_1day_100km_noar=f.relrisk_twp95_1day_100km_noar;
    relrisk_twp95_1day_100km_ar13=f.relrisk_twp95_1day_100km_ar13;
    relrisk_twp95_1day_100km_ar45=f.relrisk_twp95_1day_100km_ar45;
    end

    dothis=0;
    if dothis==1
    f=load(strcat(dataresloc_local,'relriskbyregdata'));
    relrisk_twp98_1day_coloc_noar=f.relrisk_twp98_1day_coloc_noar;
    relrisk_twp98_1day_coloc_ar13=f.relrisk_twp98_1day_coloc_ar13;
    relrisk_twp98_1day_coloc_ar45=f.relrisk_twp98_1day_coloc_ar45;
    relrisk_twp95_1day_coloc_noar=f.relrisk_twp95_1day_coloc_noar;
    relrisk_twp95_1day_coloc_ar13=f.relrisk_twp95_1day_coloc_ar13;
    relrisk_twp95_1day_coloc_ar45=f.relrisk_twp95_1day_coloc_ar45;
    relrisk_twp98_2days_coloc_noar=f.relrisk_twp98_2days_coloc_noar;
    relrisk_twp98_2days_coloc_ar13=f.relrisk_twp98_2days_coloc_ar13;
    relrisk_twp98_2days_coloc_ar45=f.relrisk_twp98_2days_coloc_ar45;
    relrisk_twp98_1day_200km_noar=f.relrisk_twp98_1day_200km_noar;
    relrisk_twp98_1day_200km_ar13=f.relrisk_twp98_1day_200km_ar13;
    relrisk_twp98_1day_200km_ar45=f.relrisk_twp98_1day_200km_ar45;
    f=load(strcat(dataresloc_local,'relriskbyptdata'));
    relrisk_twp95_2days_coloc_noar_bypt=f.relrisk_twp95_2days_coloc_noar_bypt;
    relrisk_twp95_2days_coloc_anyar_bypt=f.relrisk_twp95_2days_coloc_anyar_bypt;
    relrisk_twp98_2days_coloc_noar_bypt=f.relrisk_twp98_2days_coloc_noar_bypt;
    relrisk_twp98_2days_coloc_anyar_bypt=f.relrisk_twp98_2days_coloc_anyar_bypt;
    relrisk_twp95_2days_coloc_noar_bypt_may=f.relrisk_twp95_2days_coloc_noar_bypt_may;
    relrisk_twp95_2days_coloc_anyar_bypt_may=f.relrisk_twp95_2days_coloc_anyar_bypt_may;
    relrisk_twp95_2days_coloc_noar_bypt_jun=f.relrisk_twp95_2days_coloc_noar_bypt_jun;
    relrisk_twp95_2days_coloc_anyar_bypt_jun=f.relrisk_twp95_2days_coloc_anyar_bypt_jun;
    relrisk_twp95_2days_coloc_noar_bypt_jul=f.relrisk_twp95_2days_coloc_noar_bypt_jul;
    relrisk_twp95_2days_coloc_anyar_bypt_jul=f.relrisk_twp95_2days_coloc_anyar_bypt_jul;
    relrisk_twp95_2days_coloc_noar_bypt_aug=f.relrisk_twp95_2days_coloc_noar_bypt_aug;
    relrisk_twp95_2days_coloc_anyar_bypt_aug=f.relrisk_twp95_2days_coloc_anyar_bypt_aug;
    relrisk_twp95_2days_coloc_noar_bypt_sep=f.relrisk_twp95_2days_coloc_noar_bypt_sep;
    relrisk_twp95_2days_coloc_anyar_bypt_sep=f.relrisk_twp95_2days_coloc_anyar_bypt_sep;
    end

    tmp=load(strcat(dataresloc_external,'full4darrays',ardataset,'.mat'));
    arshapes_2_us_byyear=tmp.arshapes_2_us_byyear;
    twabovep995=tmp.twabovep995;twabovep99=tmp.twabovep99;
    twabovep95=tmp.twabovep95;twabovep90=tmp.twabovep90;twabovep50=tmp.twabovep50;

    f=load(strcat(dataresloc_external,'ardata_merra2.mat'));ar6hr_52x94=f.ar6hr_52x94;

    f=load(strcat(dataresloc_external,'twcomposites.mat'));twcomposite_p50=f.twcomposite_p50;twcomposite_p975=f.twcomposite_p975;
        twcomposite_p025=f.twcomposite_p025;twcomposite_p833=f.twcomposite_p833;twcomposite_p166=f.twcomposite_p166;
    f=load(strcat(dataresloc_external,'arcomposites.mat'));arcomposite_p50=f.arcomposite_p50;
    f=load(strcat(dataresloc_external,'tcomposites.mat'));tcomposite_p50=f.tcomposite_p50;tcomposite_p975=f.tcomposite_p975;
        tcomposite_p025=f.tcomposite_p025;tcomposite_p833=f.tcomposite_p833;tcomposite_p166=f.tcomposite_p166;
    f=load(strcat(dataresloc_external,'qcomposites.mat'));qcomposite_p50=f.qcomposite_p50;qcomposite_p975=f.qcomposite_p975;
        qcomposite_p025=f.qcomposite_p025;qcomposite_p833=f.qcomposite_p833;qcomposite_p166=f.qcomposite_p166;
    f=load(strcat(dataresloc_external,'tivtcomposites.mat'));tivtcomposite_p50=f.tivtcomposite_p50;tivtcomposite_p975=f.tivtcomposite_p975;
        tivtcomposite_p025=f.tivtcomposite_p025;tivtcomposite_p833=f.tivtcomposite_p833;tivtcomposite_p166=f.tivtcomposite_p166;
    f=load(strcat(dataresloc_external,'precipcomposites.mat'));precipcomposite_p50=f.precipcomposite_p50;precipcomposite_p975=f.precipcomposite_p975;
        precipcomposite_p025=f.precipcomposite_p025;precipcomposite_p833=f.precipcomposite_p833;precipcomposite_p166=f.precipcomposite_p166;
    f=load(strcat(dataresloc_external,'evapcomposites.mat'));evapcomposite_p50=f.evapcomposite_p50;evapcomposite_p975=f.evapcomposite_p975;
        evapcomposite_p025=f.evapcomposite_p025;evapcomposite_p833=f.evapcomposite_p833;evapcomposite_p166=f.evapcomposite_p166;
    f=load(strcat(dataresloc_external,'netswcomposites.mat'));netswcomposite_p50=f.netswcomposite_p50;netswcomposite_p975=f.netswcomposite_p975;
        netswcomposite_p025=f.netswcomposite_p025;netswcomposite_p833=f.netswcomposite_p833;netswcomposite_p166=f.netswcomposite_p166;
    f=load(strcat(dataresloc_external,'netlwcomposites.mat'));netlwcomposite_p50=f.netlwcomposite_p50;netlwcomposite_p975=f.netlwcomposite_p975;
        netlwcomposite_p025=f.netlwcomposite_p025;netlwcomposite_p833=f.netlwcomposite_p833;netlwcomposite_p166=f.netlwcomposite_p166;
    f=load(strcat(dataresloc_external,'toplevelsmcomposites.mat'));toplevelsmcomposite_p50=f.toplevelsmcomposite_p50;toplevelsmcomposite_p975=f.toplevelsmcomposite_p975;
        toplevelsmcomposite_p025=f.toplevelsmcomposite_p025;toplevelsmcomposite_p833=f.toplevelsmcomposite_p833;toplevelsmcomposite_p166=f.toplevelsmcomposite_p166;
    f=load(strcat(dataresloc_external,'z500composites.mat'));z500composite_p50=f.z500composite_p50;z500composite_p975=f.z500composite_p975;
        z500composite_p025=f.z500composite_p025;z500composite_p833=f.z500composite_p833;z500composite_p166=f.z500composite_p166;
    f=load(strcat(dataresloc_external,'omega500composites.mat'));omega500composite_p50=f.omega500composite_p50;omega500composite_p975=f.omega500composite_p975;
        omega500composite_p025=f.omega500composite_p025;omega500composite_p833=f.omega500composite_p833;omega500composite_p166=f.omega500composite_p166;

    

    tmp=load(strcat(dataresloc_local,'finalresults',ardataset,'.mat'));
    dothis=0;
    if dothis==1
    cooccur_arthenheat1day_1=tmp.cooccur_arthenheat1day_1;
    cooccur_arthenheat3days_1=tmp.cooccur_arthenheat3days_1;
    cooccur_arthenheat7days_1=tmp.cooccur_arthenheat7days_1;
    relriskp99_arthenheat1day_1=tmp.relriskp99_arthenheat1day_1;
    relriskp99_arthenheat3days_1=tmp.relriskp99_arthenheat3days_1;
    relriskp99_arthenheat7days_1=tmp.relriskp99_arthenheat7days_1;
    relriskp95_arthenheat1day_1=tmp.relriskp95_arthenheat1day_1;
    relriskp95_arthenheat3days_1=tmp.relriskp95_arthenheat3days_1;
    relriskp95_arthenheat7days_1=tmp.relriskp95_arthenheat7days_1;
    relriskp90_arthenheat1day_1=tmp.relriskp90_arthenheat1day_1;
    relriskp90_arthenheat3days_1=tmp.relriskp90_arthenheat3days_1;
    relriskp90_arthenheat7days_1=tmp.relriskp90_arthenheat7days_1;
    cooccur_heatthenar1day_1=tmp.cooccur_heatthenar1day_1;
    cooccur_heatthenar3days_1=tmp.cooccur_heatthenar3days_1;
    cooccur_heatthenar7days_1=tmp.cooccur_heatthenar7days_1;
    relriskp99_heatthenar1day_1=tmp.relriskp99_heatthenar1day_1;
    relriskp99_heatthenar3days_1=tmp.relriskp99_heatthenar3days_1;
    relriskp99_heatthenar7days_1=tmp.relriskp99_heatthenar7days_1;
    relriskp95_heatthenar1day_1=tmp.relriskp95_heatthenar1day_1;
    relriskp95_heatthenar3days_1=tmp.relriskp95_heatthenar3days_1;
    relriskp95_heatthenar7days_1=tmp.relriskp95_heatthenar7days_1;
    relriskp90_heatthenar1day_1=tmp.relriskp90_heatthenar1day_1;
    relriskp90_heatthenar3days_1=tmp.relriskp90_heatthenar3days_1;
    relriskp90_heatthenar7days_1=tmp.relriskp90_heatthenar7days_1;
    cooccur_arheateitherorder1day_1=tmp.cooccur_arheateitherorder1day_1;
    cooccur_arheateitherorder3days_1=tmp.cooccur_arheateitherorder3days_1;
    cooccur_arheateitherorder7days_1=tmp.cooccur_arheateitherorder7days_1;
    relriskp99_arheateitherorder1day_1=tmp.relriskp99_arheateitherorder1day_1;
    relriskp99_arheateitherorder3days_1=tmp.relriskp99_arheateitherorder3days_1;
    relriskp99_arheateitherorder7days_1=tmp.relriskp99_arheateitherorder7days_1;
    relriskp95_arheateitherorder1day_1=tmp.relriskp95_arheateitherorder1day_1;
    relriskp95_arheateitherorder3days_1=tmp.relriskp95_arheateitherorder3days_1;
    relriskp95_arheateitherorder7days_1=tmp.relriskp95_arheateitherorder7days_1;
    relriskp90_arheateitherorder1day_1=tmp.relriskp90_arheateitherorder1day_1;
    relriskp90_arheateitherorder3days_1=tmp.relriskp90_arheateitherorder3days_1;
    relriskp90_arheateitherorder7days_1=tmp.relriskp90_arheateitherorder7days_1;
    cooccur_arheateitherorder1day_2=tmp.cooccur_arheateitherorder1day_2;
    cooccur_arheateitherorder3days_2=tmp.cooccur_arheateitherorder3days_2;
    cooccur_arheateitherorder7days_2=tmp.cooccur_arheateitherorder7days_2;
    relriskp95_arheateitherorder1day_2=tmp.relriskp95_arheateitherorder1day_2;
    relriskp95_arheateitherorder3days_2=tmp.relriskp95_arheateitherorder3days_2;
    relriskp95_arheateitherorder7days_2=tmp.relriskp95_arheateitherorder7days_2;
    end

    likelihooddiffarheat=tmp.likelihooddiffarheat;
    likelihooddiffprecipheat=tmp.likelihooddiffprecipheat;
    likelihooddifftivtheat=tmp.likelihooddifftivtheat;
    arheatinteraction=tmp.arheatinteraction;
    nearbyar=tmp.nearbyar;
    clear tmp;


    f=load(strcat(dataresloc_external,'contrastingobscases.mat'));
    regheatstressdays=f.regheatstressdays;
    regheatstressdays=permute(regheatstressdays,[3 1 2]);
    z500anomsforregheatstressdays=f.z500anomsforregheatstressdays;
    highz500noheatstressdays=f.highz500noheatstressdays;

    f=load(strcat(dataresloc_local,'varioussmallarrays.mat'));
    datesaver=f.datesaver;dss_uniquedates=f.dss_uniquedates;

    
    %NCA regions and subregions within them
    thencaregions=ncaregionsfromlatlon(latarray_52x94,lonarray_52x94);
    interiornorthwest=thencaregions==2 & lonarray_52x94>=-120;
    coastalnorthwest=thencaregions==2 & lonarray_52x94<-120;
    interiorsouthwest=thencaregions==3 & lonarray_52x94>=-116;
    coastalsouthwest=thencaregions==3 & lonarray_52x94<-116;
    easternnortherngreatplains=thencaregions==4 & lonarray_52x94>=-105;
    westernnortherngreatplains=thencaregions==4 & lonarray_52x94<-105;
    uppersoutherngreatplains=thencaregions==5 & latarray_52x94>=34;
    lowersoutherngreatplains=thencaregions==5 & latarray_52x94<34;
    uppermidwest=thencaregions==6 & latarray_52x94>=43;
    lowermidwest=thencaregions==6 & latarray_52x94<43;
    uppersoutheast=thencaregions==7 & latarray_52x94>=33;
    lowersoutheast=thencaregions==7 & latarray_52x94<33;
    uppernortheast=thencaregions==8 & latarray_52x94>=43;
    lowernortheast=thencaregions==8 & latarray_52x94<43;
    
    thencasubregions=NaN.*ones(size(thencaregions,1),size(thencaregions,2));
    for row=1:size(thencaregions,1)
        for col=1:size(thencaregions,2)
            if coastalnorthwest(row,col)==1;thencasubregions(row,col)=2.1;end
            if interiornorthwest(row,col)==1;thencasubregions(row,col)=2.2;end
            if coastalsouthwest(row,col)==1;thencasubregions(row,col)=3.1;end
            if interiorsouthwest(row,col)==1;thencasubregions(row,col)=3.2;end
            if westernnortherngreatplains(row,col)==1;thencasubregions(row,col)=4.1;end
            if easternnortherngreatplains(row,col)==1;thencasubregions(row,col)=4.2;end
            if uppersoutherngreatplains(row,col)==1;thencasubregions(row,col)=5.1;end
            if lowersoutherngreatplains(row,col)==1;thencasubregions(row,col)=5.2;end
            if uppermidwest(row,col)==1;thencasubregions(row,col)=6.1;end
            if lowermidwest(row,col)==1;thencasubregions(row,col)=6.2;end
            if uppersoutheast(row,col)==1;thencasubregions(row,col)=7.1;end
            if lowersoutheast(row,col)==1;thencasubregions(row,col)=7.2;end
            if uppernortheast(row,col)==1;thencasubregions(row,col)=8.1;end
            if lowernortheast(row,col)==1;thencasubregions(row,col)=8.2;end
        end
    end
    
    %Make lat and lon arrays
    clear merra2lats;clear merra2lons;
    year=defaultstartyear;namepart='100';
    thismon=DOYtoMonth_heatars(may1doy,defaultstartyear);thisdom=DOYtoDOM_heatars(may1doy,defaultstartyear);
    if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
    if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
    thisfilename=strcat(dataresloc_external,'MERRA2_',namepart,'.tavg1_2d_slv_Nx.',num2str(year),thismon_str,thisdom_str,'.SUB.nc');

    lat=double(ncread(thisfilename,'lat'));lon=double(ncread(thisfilename,'lon'));
    for row=1:size(lat,1)
        for col=1:size(lon,1)
            merra2lats(row,col)=lat(row);merra2lons(row,col)=lon(col);
        end
    end
    westernhem=merra2lons>=180;merra2lons(westernhem)=merra2lons(westernhem)-360;
        
    
    %Set AR array according to current selection for timestepreqt
    if timestepreqt==2
        ar_52x94=arshapes_2_us_byyear;clear arshapes_2_us_byyear;
    else
        disp('Need to switch arshapes array');return;
    end

    clear tmp;
end


if readardata==1  
    filetoread='globalARcatalog_MERRA2_1980-2020_v3.0.nc';
    
    lat=ncread(strcat(dataresloc_external,filetoread),'lat');
    lon=ncread(strcat(dataresloc_external,filetoread),'lon');
    
    
    %Restrict reading to US for speed-up (using manually identified limits)
    %south: 24.5, north: 50, west: 235, east: 293.12
    lat1=230;lat2=281;lon1=377;lon2=470;
    
    lat=lat(lat1:lat2);lon=lon(lon1:lon2);
    lsmask=ncread(strcat(dataresloc_external,filetoread),'islnd',[lon1 lat1],[lon2-lon1+1 lat2-lat1+1]);
    day=ncread(strcat(dataresloc_external,filetoread),'day',[1 1 1 1],[inf inf inf inf]);
    month=ncread(strcat(dataresloc_external,filetoread),'month',[1 1 1 1],[inf inf inf inf]);
    year=ncread(strcat(dataresloc_external,filetoread),'year',[1 1 1 1],[inf inf inf inf]);
    
    clat=ncread(strcat(dataresloc_external,filetoread),'clat',[1 1 1 1],[inf inf inf inf]);
    clon=ncread(strcat(dataresloc_external,filetoread),'clon',[1 1 1 1],[inf inf inf inf]);
    shape=ncread(strcat(dataresloc_external,filetoread),'shape',[lon1 lat1 1 1 1],[lon2-lon1+1 lat2-lat1+1 inf inf inf]);
    %for testing: first timestep only: shape=ncread(strcat(icloud,'General_Academics/Research/ARs_S2S/',filetoread),'shape',[1 1 1 1 1],[inf inf 1 1 1]);
    ivtdir=ncread(strcat(dataresloc_external,filetoread),'ivtdir',[1 1 1 1],[inf inf inf inf]);
    tivt=ncread(strcat(dataresloc_external,filetoread),'tivt',[1 1 1 1],[inf inf inf inf]);
        if strcmp(ardataset,'merra2');tivt=tivt./10^6;end %to convert to 10^6 kg/s
    arwidth=ncread(strcat(dataresloc_external,filetoread),'width',[1 1 1 1],[inf inf inf inf]);
        if strcmp(ardataset,'merra2');arwidth=arwidth./10^3;end %to convert to km
    arlength=ncread(strcat(dataresloc_external,filetoread),'length',[1 1 1 1],[inf inf inf inf]);
        if strcmp(ardataset,'merra2');arlength=arlength./10^3;end %to convert to km
    axis=ncread(strcat(dataresloc_external,filetoread),'axis',[lon1 lat1 1 1 1],[lon2-lon1+1 lat2-lat1+1 inf inf inf]);
    transect=ncread(strcat(dataresloc_external,filetoread),'tnsct',[lon1 lat1 1 1 1],[lon2-lon1+1 lat2-lat1+1 inf inf inf]);
    transectwidth=ncread(strcat(dataresloc_external,filetoread),'width2',[1 1 1 1],[inf inf inf inf]);
        if strcmp(ardataset,'merra2');transectwidth=transectwidth./10^3;end %to convert to km
    
    dim1size=size(axis,1);dim2size=size(axis,2);numtimesteps=size(shape,4);
    
    
    
    clat=squeeze(clat);clon=squeeze(clon);
    shape=squeeze(shape);ivtdir=squeeze(ivtdir);tivt=squeeze(tivt);
    arwidth=squeeze(arwidth);arlength=squeeze(arlength);
    axis=squeeze(axis);transect=squeeze(transect);transectwidth=squeeze(transectwidth);
    year=squeeze(year);month=squeeze(month);day=squeeze(day);
    
    %Flip various variables to proper geographic orientation
    largerdim=max(size(shape,1),size(shape,2));smallerdim=min(size(shape,1),size(shape,2));
    axisold=axis;axis=NaN.*ones(smallerdim,largerdim,numtimesteps);
    transectold=transect;transect=NaN.*ones(smallerdim,largerdim,numtimesteps);
    shapeold=shape;shape=NaN.*ones(smallerdim,largerdim,numtimesteps);
    for timestep=1:numtimesteps
        temp=flipud(squeeze(axisold(:,:,timestep))');
        axis(:,:,timestep)=temp;
        
        temp=flipud(squeeze(transectold(:,:,timestep))');
        transect(:,:,timestep)=temp;
        
        temp=flipud(squeeze(shapeold(:,:,timestep))');
        shape(:,:,timestep)=temp;
    end
    clear shapeold;clear axisold;clear transectold;clear tivtold;clear ivtdirold;
    
    
    %Find ARs affecting any part of the US
    %No longer needed now that US requirement is imposed earlier
    clear latarray;clear lonarray;
    for i=1:size(lat,1)
        for j=1:size(lon,1)
            latarray(i,j)=lat(i);lonarray(i,j)=lon(j);
        end
    end
    latarray=flipud(latarray);
    if strcmp(ardataset,'merra2')
        save(strcat(figloc,'allus_ars_merra2.mat'),'latarray','lonarray','lsmask','-append');
    end
    
    
    allusarshapes=NaN.*ones(dim2size,dim1size,numtimesteps);allusaraxes=NaN.*ones(dim2size,dim1size,numtimesteps);allusartransects=NaN.*ones(dim2size,dim1size,numtimesteps);
    for i=1:dim2size
        for j=1:dim1size
            for timestep=1:numtimesteps
                if ~isnan(shape(i,j,timestep));allusarshapes(i,j,timestep)=1;end
                if ~isnan(axis(i,j,timestep));allusaraxes(i,j,timestep)=1;end
                if ~isnan(transect(i,j,timestep));allusartransects(i,j,timestep)=1;end
            end
        end
    end
    clear axisold;clear transectold;clear shapeold;
    
    clear finalyear;clear finalmonth;clear finalday;
    for timestep=1:numtimesteps
        keeplookingforyear=1;keeplookingformonth=1;keeplookingforday=1;
        for searchindex=1:smallerdim
            if keeplookingforyear==1
                lookhereforyear=year(searchindex,timestep);if ~isnan(lookhereforyear);finalyear(timestep)=lookhereforyear;keeplookingforyear=0;end
            end
            if keeplookingformonth==1
                lookhereformonth=month(searchindex,timestep);if ~isnan(lookhereformonth);finalmonth(timestep)=lookhereformonth;keeplookingformonth=0;end
            end
            if keeplookingforday==1
                lookhereforday=day(searchindex,timestep);if ~isnan(lookhereforday);finalday(timestep)=lookhereforday;keeplookingforday=0;end
            end
        end
    end
    
    allusars_dates=[finalyear' finalmonth' finalday'];
    save(strcat(figloc,'allus_ars_',ardataset,'.mat'),'allusarshapes','allusaraxes','allusartransects','allusars_dates','-v7.3');
    
    allusarsbytimestep=squeeze(nansum(squeeze(nansum(allusarshapes,2)),1));
    
    
    %Get details of ARs
    %This is not the count of individual ARs, but info on the ARs at each time step
    arcount=0;testararray=NaN.*ones(10^6,16);
    for timestep=1:numtimesteps
        [rows,cols]=find(~isnan(shape(:,:,timestep)));

        c=0;clear theseids;foundstg=0;
        for i=1:size(rows,1)
            c=c+1;foundstg=1;
            theseids(c)=shape(rows(i),cols(i),timestep);
        end
        
        if foundstg==1
            theseids_1d=theseids(:); %note that Matlab is column-major
            theseids_1d_nonan=theseids_1d(~isnan(theseids_1d));

            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),1)=timestep;
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),2)=theseids_1d_nonan;
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),3)=year(theseids_1d_nonan,timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),4)=month(theseids_1d_nonan,timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),5)=day(theseids_1d_nonan,timestep);
            for i=1:size(rows,1)
            testararray(arcount+i,6)=latarray(rows(i),cols(i));
            testararray(arcount+i,7)=lonarray(rows(i),cols(i))-360;
            end
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),8)=tivt(theseids_1d_nonan,timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),9)=ivtdir(theseids_1d_nonan,timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),10)=arwidth(theseids_1d_nonan,timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),11)=arlength(theseids_1d_nonan,timestep);
            for i=1:size(rows,1)
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),12)=axis(rows(i),cols(i),timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),13)=transect(rows(i),cols(i),timestep);
            end
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),14)=transectwidth(theseids_1d_nonan,timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),15)=clat(theseids_1d_nonan,timestep);
            testararray(arcount+1:arcount+size(theseids_1d_nonan,1),16)=clon(theseids_1d_nonan,timestep);

            arcount=arcount+size(theseids_1d_nonan,1);
        end
        
        if rem(timestep,1000)==0;fprintf('Timestep is %d of %d\n',timestep,numtimesteps);disp(clock);end
    end

    
    lsmask=flipud(lsmask');
        
    ararray=testararray;
    save(strcat(dataresloc_external,'allus_ars_',ardataset,'.mat'),'ararray','latarray','lonarray','lsmask','-append');
end


if finddailyars==1
    %Reload data and make various geographical adjustments to ensure that arrays are in normal map orientation (north at top, centered on 0)
    tmp=load(strcat(dataresloc_external,'allus_ars_',ardataset,'.mat'));
    allusarshapes=tmp.allusarshapes;allusaraxes=tmp.allusaraxes;allusartransects=tmp.allusartransects;allusars_dates=tmp.allusars_dates;
    
    %Finds ARs based on requirement of consecutive timesteps
    arshapes_1=zeros(numyears,366,size(latarray,1),size(latarray,2));
    arshapes_2=zeros(numyears,366,size(latarray,1),size(latarray,2));
    arshapes_3=zeros(numyears,366,size(latarray,1),size(latarray,2));
    arshapes_4=zeros(numyears,366,size(latarray,1),size(latarray,2));
    doy=1;thisyear=defaultstartyear;if rem(thisyear,4)==0;daysinyear=366;else;daysinyear=365;end
    for hour=1:56980
        if rem(hour,4)==1 %first hour of day
            arshape_6am=allusarshapes(:,:,hour);noar=isnan(arshape_6am);arshape_6am(noar)=0;
            
            arshapes_1(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_1(thisyear-defaultstartyear+1,doy,:,:))+double(arshape_6am);
        elseif rem(hour,4)==2 %second hour of day
            arshape_12pm=allusarshapes(:,:,hour);noar=isnan(arshape_12pm);arshape_12pm(noar)=0;
            A=cat(3,arshape_6am,arshape_12pm);twooverlaid=sum(A,3,'omitnan');
            
            arshapes_2(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_2(thisyear-defaultstartyear+1,doy,:,:))+double(twooverlaid==2);
            arshapes_1(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_1(thisyear-defaultstartyear+1,doy,:,:))+double(arshape_12pm);
        elseif rem(hour,4)==3 %third hour of day
            arshape_6pm=allusarshapes(:,:,hour);noar=isnan(arshape_6pm);arshape_6pm(noar)=0;
            A=cat(3,arshape_12pm,arshape_6pm);twooverlaid=sum(A,3,'omitnan');
            A=cat(3,arshape_6am,arshape_12pm,arshape_6pm);threeoverlaid=sum(A,3,'omitnan');
            
            arshapes_3(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_3(thisyear-defaultstartyear+1,doy,:,:))+double(threeoverlaid==3);
            arshapes_2(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_2(thisyear-defaultstartyear+1,doy,:,:))+double(twooverlaid==2);
            arshapes_1(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_1(thisyear-defaultstartyear+1,doy,:,:))+double(arshape_6pm);
        elseif rem(hour,4)==0 %fourth hour of day
            arshape_12am=allusarshapes(:,:,hour);noar=isnan(arshape_12am);arshape_12am(noar)=0;
            A=cat(3,arshape_6pm,arshape_12am);twooverlaid=sum(A,3,'omitnan');
            A=cat(3,arshape_12pm,arshape_6pm,arshape_12am);threeoverlaid=sum(A,3,'omitnan');
            A=cat(3,arshape_6am,arshape_12pm,arshape_6pm,arshape_12am);fouroverlaid=sum(A,3,'omitnan');
            
            arshapes_4(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_4(thisyear-defaultstartyear+1,doy,:,:))+double(fouroverlaid==4);
            arshapes_3(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_3(thisyear-defaultstartyear+1,doy,:,:))+double(threeoverlaid==3);
            arshapes_2(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_2(thisyear-defaultstartyear+1,doy,:,:))+double(twooverlaid==2);
            arshapes_1(thisyear-defaultstartyear+1,doy,:,:)=squeeze(arshapes_1(thisyear-defaultstartyear+1,doy,:,:))+double(arshape_12am);
        end
        
        if rem(hour,4)==0 && doy~=daysinyear %last hour of day
            doy=doy+1;%if rem(hour,400)==0;fprintf('year is %d, doy is %d, hour is %d\n',thisyear,doy-1,hour);end
        elseif rem(hour,4)==0 && doy==daysinyear
            doy=1;thisyear=thisyear+1;%fprintf('year is %d, doy is %d, hour is %d\n',thisyear-1,doy,hour);
            if rem(thisyear,4)==0;daysinyear=366;else;daysinyear=365;end
        end
    end
    unnecessarydetail=arshapes_1>1;arshapes_1(unnecessarydetail)=1;
    unnecessarydetail=arshapes_2>1;arshapes_2(unnecessarydetail)=1;
    unnecessarydetail=arshapes_3>1;arshapes_3(unnecessarydetail)=1;
    unnecessarydetail=arshapes_4>1;arshapes_4(unnecessarydetail)=1;
    %troubleshooting -- mean MJJAS AR frequency as a %
    meanmjjasfreq_1=squeeze(mean(squeeze(mean(arshapes_1(:,121:sep30doy,:,:),1,'omitnan')),1,'omitnan'));
    meanmjjasfreq_2=squeeze(mean(squeeze(mean(arshapes_2(:,121:sep30doy,:,:),1,'omitnan')),1,'omitnan'));
    meanmjjasfreq_3=squeeze(mean(squeeze(mean(arshapes_3(:,121:sep30doy,:,:),1,'omitnan')),1,'omitnan'));
    meanmjjasfreq_4=squeeze(mean(squeeze(mean(arshapes_4(:,121:sep30doy,:,:),1,'omitnan')),1,'omitnan'));
    
    
    if createarcomparisonfig==1
        thesearrs={100.*meanmjjasfreq_1;100.*meanmjjasfreq_2;100.*meanmjjasfreq_3;100.*meanmjjasfreq_4};
        lefts=[0.01;0.5;0.01;0.5];bottoms=[0.52;0.52;0.05;0.05];lowerlims=[0;0;0;0];upperlims=[25;15;10;5];titlephrs={'1 Timestep';'2 Timesteps';'3 Timesteps';'4 Timesteps'};
        figure(21);clf;curpart=1;highqualityfiguresetup_heatars;
        for subplotnum=1:4
            subplot(2,2,subplotnum);
            data={latarray(northrow:southrow,westcol:eastcol);lonarray(northrow:southrow,westcol:eastcol);thesearrs{subplotnum}};
            vararginnew={'datatounderlay';data;'underlaycaxismin';lowerlims(subplotnum);'underlaycaxismax';upperlims(subplotnum);'mystepunderlay';5;...
                'underlaycolormap';colormaps('q','more','not');'variable';'temperature';'overlaynow';0;...
                'conttoplot';'North America';'nonewfig';1};
            cbb=colorbar;
            datatype='custom';region='usa-slightlysmaller';
            plotModelData_heatars(data,region,vararginnew,datatype);
            set(gca,'Position',[lefts(subplotnum) bottoms(subplotnum) 0.43 0.48]);
            title(titlephrs{subplotnum},'fontsize',16,'fontweight','bold','fontname','arial');
        end
        figname='climomjjasarfreq_timestepcomparison';curpart=2;highqualityfiguresetup_heatars;
    end
end


if find6hourlyars==1
    %Reload data and make various geographical adjustments to ensure that arrays are in normal map orientation (north at top, centered on 0)
    tmp=load(strcat(dataresloc_external,'allus_ars_',ardataset,'.mat'));
    allusarshapes=tmp.allusarshapes;allusaraxes=tmp.allusaraxes;allusartransects=tmp.allusartransects;allusars_dates=tmp.allusars_dates;
    lonarray=tmp.lonarray;latarray=tmp.latarray;
    
    %Finds ARs at each timestep
    arshapes_6hr=zeros(numyears,366,4,size(latarray,1),size(latarray,2));
    doy=1;thisyear=defaultstartyear;if rem(thisyear,4)==0;daysinyear=366;else;daysinyear=365;end
    for hour=1:56980
        if rem(hour,4)==1 %first timestep of day
            arshape_6am=double(allusarshapes(:,:,hour));noar=isnan(arshape_6am);arshape_6am(noar)=0;
            arshapes_6hr(thisyear-defaultstartyear+1,doy,1,:,:)=arshape_6am;
        elseif rem(hour,4)==2 %second timestep of day
            arshape_12pm=double(allusarshapes(:,:,hour));noar=isnan(arshape_12pm);arshape_12pm(noar)=0;            
            arshapes_6hr(thisyear-defaultstartyear+1,doy,2,:,:)=arshape_12pm;
        elseif rem(hour,4)==3 %third timestep of day
            arshape_6pm=double(allusarshapes(:,:,hour));noar=isnan(arshape_6pm);arshape_6pm(noar)=0;
            arshapes_6hr(thisyear-defaultstartyear+1,doy,3,:,:)=arshape_6pm;
        elseif rem(hour,4)==0 %fourth timestep of day
            arshape_12am=double(allusarshapes(:,:,hour));noar=isnan(arshape_12am);arshape_12am(noar)=0;
            arshapes_6hr(thisyear-defaultstartyear+1,doy,4,:,:)=arshape_12am;
        end
        
        if rem(hour,4)==0 && doy~=daysinyear %last hour of day
            doy=doy+1;%if rem(hour,400)==0;fprintf('year is %d, doy is %d, hour is %d\n',thisyear,doy-1,hour);end
        elseif rem(hour,4)==0 && doy==daysinyear
            doy=1;thisyear=thisyear+1;%fprintf('year is %d, doy is %d, hour is %d\n',thisyear-1,doy,hour);
            if rem(thisyear,4)==0;daysinyear=366;else;daysinyear=365;end
        end
    end
    ar6hr_52x94=arshapes_6hr;
    clear arshapes_6hr;
    save(strcat(dataresloc_external,'ardata_merra2.mat'),'ar6hr_52x94','-append');
end


%Gets daily max of Tw, T, Td (each calculated hourly, but daily maxes are
%independent, so each variable can have a max at a different time)
%Requires access to daily MERRA2 data (too large to share directly)
%**Download instructions**

%Files are obtained from MERRA-2 tavg1_2d_slv_Nx: 2d,1-Hourly,Time-Averaged,Single-Level,Assimilation,Single-Level Diagnostics V5.12.4 (M2T1NXSLV) dataset
%e.g. https://disc.gsfc.nasa.gov

%Get/subset (using OpenDAP) and refine date, region, and variables
%	region: globe
%	variables (orig): PS, Q850, T2M, T2MDEW, T2MWET, T500, T850, U10M, V10M
%	variables (extended): T250, U850, V850, Q250, Q500

%Once links file is prepared, download and move to directory of interest (don%t keep multiple sets of files in same dir, in case their names overlap, and also just for ease of monitoring)

%Rename downloaded links file to something like my_links.txt

%Then, run wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition -i my_links.txt


%Consider May 1-Sep 30 as warm season
if getdailyheatstress_merra2==1
    tw_52x94=NaN.*ones(numyears,365,52,94);t_52x94=NaN.*ones(numyears,365,52,94);td_52x94=NaN.*ones(numyears,365,52,94);
    for year=defaultstartyear:defaultstopyear
        if year<=1991;namepart='100';elseif year<=2000;namepart='200';elseif year<=2010;namepart='300';elseif year<=2020;namepart='400';end
        for doy=may1doy:sep30doy
            thismon=DOYtoMonth_heatars(doy,1991);thisdom=DOYtoDOM_heatars(doy,1991);
            if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
            if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
            thisfilename=strcat('/Volumes/ExternalDriveF/MERRA2/MERRA2_',namepart,'.tavg1_2d_slv_Nx.',num2str(year),thismon_str,thisdom_str,'.SUB.nc');
            %tw2mtemp=ncread(thisfilename,'T2MWET'); %this is bad!!
            t2mtemp=ncread(thisfilename,'T2M');td2mtemp=ncread(thisfilename,'T2MDEW');
            psfc=ncread(thisfilename,'PS');

            if year==defaultstartyear && doy==may1doy
                lattemp=ncread(thisfilename,'lat');
                lontemp=ncread(thisfilename,'lon');
                lat=double(lattemp);lon=double(lontemp);
                for row=1:size(lat,1)
                    for col=1:size(lon,1)
                        merra2lats(row,col)=lat(row);merra2lons(row,col)=lon(col);
                    end
                end
                westernhem=merra2lons>=180;merra2lons(westernhem)=merra2lons(westernhem)-360;
            end
            
            X=merra2lons;Y=flipud(merra2lats);Xq=lonarray_52x94;Yq=latarray_52x94;
            t2mhourlyflipped=zeros(52,94,24);td2mhourlyflipped=zeros(52,94,24);psfchourlyflipped=zeros(52,94,24);
            for hr=1:24
                V=flipud(squeeze(t2mtemp(:,:,hr))');
                t2mhourlyflipped(:,:,hr)=interp2(X,Y,V,Xq,Yq);
                
                V=flipud(squeeze(td2mtemp(:,:,hr))');
                td2mhourlyflipped(:,:,hr)=interp2(X,Y,V,Xq,Yq);
                
                V=flipud(squeeze(psfc(:,:,hr))');
                psfchourlyflipped(:,:,hr)=interp2(X,Y,V,Xq,Yq);
            end
            
            tw2mhourlyflipped=calcwbt_daviesjones_heatars(t2mhourlyflipped-273.15,psfchourlyflipped,calcqfromTd_heatars(td2mhourlyflipped-273.15)./1000);
            
            
            tw2mtemp_daily=squeeze(max(tw2mhourlyflipped,[],3));
            tw_52x94(year-(defaultstartyear-1),doy,:,:)=tw2mtemp_daily; %Celsius
            
            t2mtemp_daily=squeeze(max(t2mhourlyflipped,[],3));
            t_52x94(year-(defaultstartyear-1),doy,:,:)=t2mtemp_daily-273.15; %Celsius
            
            td2mtemp_daily=squeeze(max(td2mhourlyflipped,[],3));
            td_52x94(year-(defaultstartyear-1),doy,:,:)=td2mtemp_daily-273.15; %Celsius
        end

        clear tw2mtemp;clear t2mtemp;clear td2mtemp;disp(year);disp(clock);
        clear tw2mhourlyflipped;clear t2mhourlyflipped;clear td2mhourlyflipped;
    end
    save(strcat(dataresloc_external,'heat_merra2.mat'),'tw_52x94','t_52x94','td_52x94','-append');
    
    %Also get overall Tw percentiles for MJJAS
    mjjastw=tw_52x94(:,may1doy:sep30doy,:,:);
    twp50=NaN.*ones(size(mjjastw,3),size(mjjastw,4));
    twp90=NaN.*ones(size(mjjastw,3),size(mjjastw,4));
    twp95=NaN.*ones(size(mjjastw,3),size(mjjastw,4));
    twp98=NaN.*ones(size(mjjastw,3),size(mjjastw,4));
    twp99=NaN.*ones(size(mjjastw,3),size(mjjastw,4));
    twp995=NaN.*ones(size(mjjastw,3),size(mjjastw,4));
    for i=1:size(mjjastw,3)
        for j=1:size(mjjastw,4)
            thisptdata=squeeze(mjjastw(:,:,i,j));
            thisptdata=reshape(thisptdata,[size(thisptdata,1)*size(thisptdata,2) 1]);
            if sum(~isnan(thisptdata))>=0.8*size(thisptdata,1)
                twp50(i,j)=quantile(thisptdata,0.5);
                twp90(i,j)=quantile(thisptdata,0.9);
                twp95(i,j)=quantile(thisptdata,0.95);
                twp98(i,j)=quantile(thisptdata,0.98);
                twp99(i,j)=quantile(thisptdata,0.99);
                twp995(i,j)=quantile(thisptdata,0.995);
            end
        end
    end
    save(strcat(dataresloc_external,'heat_merra2.mat'),'twp50','twp90','twp95','twp98','twp99','twp995','-append');
    save(strcat(dataresloc_external,'mjjastw_merra2.mat'),'mjjastw','-append');

    %And get *regional* Tw percentiles
    regtwp50=zeros(7,1);regtwp90=zeros(7,1);regtwp95=zeros(7,1);regtwp98=zeros(7,1);regtwp99=zeros(7,1);regtwp995=zeros(7,1);
    for reg=1:7
        thisdata=mjjastw(:,:,thencaregions==reg+1);
        c=0;clear regmeantw_byday;
        for i=1:size(thisdata,1)
            for j=1:size(thisdata,2)
                c=c+1;
                regmeantw_byday(c)=mean(thisdata(i,j,:));
            end
        end
        regtwp50(reg)=quantile(regmeantw_byday,0.5);
        regtwp90(reg)=quantile(regmeantw_byday,0.9);
        regtwp95(reg)=quantile(regmeantw_byday,0.95);
        regtwp98(reg)=quantile(regmeantw_byday,0.98);
        regtwp99(reg)=quantile(regmeantw_byday,0.99);
        regtwp995(reg)=quantile(regmeantw_byday,0.995);
    end
    save(strcat(dataresloc_external,'heat_merra2.mat'),'regtwp50','regtwp90','regtwp95','regtwp98','regtwp99','regtwp995','-append');
    
    %And calculate day-specific climo
    clear twmean;
    for i=1:52
        for j=1:94
            for doy=may1doy+1:sep30doy-1
                reldoy=doy-(may1doy-1);
                twmean(doy,i,j)=0.25*mean(mjjastw(:,reldoy-1,i,j))+0.5*mean(mjjastw(:,reldoy,i,j))+0.25*mean(mjjastw(:,reldoy+1,i,j));
            end
            twmean(may1doy,i,j)=0.5*mean(mjjastw(:,1,i,j))+0.5*mean(mjjastw(:,2,i,j));
            twmean(sep30doy,i,j)=0.5*mean(mjjastw(:,152,i,j))+0.5*mean(mjjastw(:,153,i,j));
        end
    end
    invalid=twmean==0;twmean(invalid)=NaN;twmean=twmean-273.15;
    twmean_sm=zeros(sep30doy,52,94);
    for i=1:52
        for j=1:94
            twmean_sm(may1doy:sep30doy,i,j)=smooth(squeeze(twmean(may1doy:sep30doy,i,j)),20);
        end
    end
    invalid=twmean_sm==0;twmean_sm(invalid)=NaN;
    
    save(strcat(dataresloc_external,'heat_merra2.mat'),'twmean','twmean_sm','-append');
end

%Note that timestep 1 of each day corresponds to 2-3 AM UTC, while timestep 8 is 11PM-12AM UTC
if get3hourlyheatstress_merra2==1
    tw3hr_52x94=NaN.*ones(numyears,365,8,52,94);t3hr_52x94=NaN.*ones(numyears,365,8,52,94);td3hr_52x94=NaN.*ones(numyears,365,8,52,94);
    for year=defaultstartyear:defaultstopyear
        if year<=1991;namepart='100';elseif year<=2000;namepart='200';elseif year<=2010;namepart='300';elseif year<=2020;namepart='400';end
        for doy=may1doy:sep30doy
            thismon=DOYtoMonth_heatars(doy,1991);thisdom=DOYtoDOM_heatars(doy,1991);
            if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
            if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
            thisfilename=strcat('/Volumes/ExternalDriveF/MERRA2/MERRA2_',namepart,'.tavg1_2d_slv_Nx.',num2str(year),thismon_str,thisdom_str,'.SUB.nc');
            t2mtemp=ncread(thisfilename,'T2M');td2mtemp=ncread(thisfilename,'T2MDEW');
            psfc=ncread(thisfilename,'PS');
            
            X=merra2lons;Y=flipud(merra2lats);Xq=lonarray_52x94;Yq=latarray_52x94;
            t2m3hourlyflipped=zeros(52,94,8);td2m3hourlyflipped=zeros(52,94,8);psfc3hourlyflipped=zeros(52,94,8);
            for hr=3:3:24
                V=flipud(squeeze(t2mtemp(:,:,hr))');
                t2m3hourlyflipped(:,:,hr/3)=interp2(X,Y,V,Xq,Yq);
                
                V=flipud(squeeze(td2mtemp(:,:,hr))');
                td2m3hourlyflipped(:,:,hr/3)=interp2(X,Y,V,Xq,Yq);
                
                V=flipud(squeeze(psfc(:,:,hr))');
                psfc3hourlyflipped(:,:,hr/3)=interp2(X,Y,V,Xq,Yq);
            end
            
            tw2m3hourlyflipped=calcwbt_daviesjones_heatars(t2m3hourlyflipped-273.15,psfc3hourlyflipped,calcqfromTd_heatars(td2m3hourlyflipped-273.15)./1000);
            
            
            tw3hr_52x94(year-(defaultstartyear-1),doy,:,:,:)=permute(tw2m3hourlyflipped,[3 1 2]); %Celsius
            
            t3hr_52x94(year-(defaultstartyear-1),doy,:,:,:)=permute(t2m3hourlyflipped-273.15,[3 1 2]); %Celsius
            
            td3hr_52x94(year-(defaultstartyear-1),doy,:,:,:)=permute(td2m3hourlyflipped-273.15,[3 1 2]); %Celsius
        end

        disp(year);disp(clock);
        clear tw2m3hourlyflipped;clear t2m3hourlyflipped;clear td2m3hourlyflipped;
    end
    save(strcat(dataresloc_external,'tw_merra2_3hr.mat'),'tw3hr_52x94','-v7.3');
    save(strcat(dataresloc_external,'t_merra2_3hr.mat'),'t3hr_52x94','-v7.3');
    save(strcat(dataresloc_external,'td_merra2_3hr.mat'),'td3hr_52x94','-v7.3');

    %Also get overall Tw percentiles for MJJAS (2 min)
    mjjastw3hr=tw3hr_52x94(:,may1doy:sep30doy,:,:,:);
    tw3hrp50=NaN.*ones(size(mjjastw3hr,4),size(mjjastw3hr,5));
    tw3hrp90=NaN.*ones(size(mjjastw3hr,4),size(mjjastw3hr,5));
    tw3hrp95=NaN.*ones(size(mjjastw3hr,4),size(mjjastw3hr,5));
    tw3hrp98=NaN.*ones(size(mjjastw3hr,4),size(mjjastw3hr,5));
    tw3hrp99=NaN.*ones(size(mjjastw3hr,4),size(mjjastw3hr,5));
    tw3hrp995=NaN.*ones(size(mjjastw3hr,4),size(mjjastw3hr,5));
    for i=1:size(mjjastw3hr,4)
        for j=1:size(mjjastw3hr,5)
            thisptdata=squeeze(mjjastw3hr(:,:,:,i,j));
            thisptdata=reshape(thisptdata,[size(thisptdata,1)*size(thisptdata,2)*size(thisptdata,3) 1]);
            if sum(~isnan(thisptdata))>=0.8*size(thisptdata,1)
                tw3hrp50(i,j)=quantile(thisptdata,0.5);
                tw3hrp90(i,j)=quantile(thisptdata,0.9);
                tw3hrp95(i,j)=quantile(thisptdata,0.95);
                tw3hrp98(i,j)=quantile(thisptdata,0.98);
                tw3hrp99(i,j)=quantile(thisptdata,0.99);
                tw3hrp995(i,j)=quantile(thisptdata,0.995);
            end
        end
    end
    save(strcat(dataresloc_external,'twpctiles_merra2_3hr.mat'),'tw3hrp50','tw3hrp90','tw3hrp95','tw3hrp98','tw3hrp99','tw3hrp995','-v7.3');
    save(strcat(dataresloc_external,'mjjastw3hr_merra2.mat'),'mjjastw3hr');
end




if dofirstcomparisonofheatandars==1    
    %Note that AR shape (i.e., the definition of what constitutes an AR day) has already been promulgated and stored in arshapes_X
    %2 -- 2 6-hourly timesteps per day with an AR at a gridcell
    clear twabovep995;clear twabovep99;clear twabovep95;clear twabovep90;clear twabovep50;
    clear arshapes_2_us_byyear;
    clear araxes_us_byyear;clear artransects_us_byyear;clear artivt_us_byyear;clear arivtdir_us_byyear;
    for year=startyear_comparison:startyear_comparison+size(tw_52x94,1)-1
            
        for doy=may1doy:sep30doy
            araxes_thisday=zeros(smallerdim,largerdim);artransects_thisday=zeros(smallerdim,largerdim);
            artivt_thisday=zeros(smallerdim,largerdim);arivtdir_thisday=zeros(smallerdim,largerdim);
                        
            
            for timestepsearch=1:size(allusars_dates,1)
                doysearch=DatetoDOY_heatars(allusars_dates(timestepsearch,2),allusars_dates(timestepsearch,3),allusars_dates(timestepsearch,1));
                if allusars_dates(timestepsearch,1)==year && doysearch==doy
                    A=cat(3,araxes_thisday,allusaraxes(:,:,timestepsearch));
                    araxes_thisday=sum(A,3,'omitnan');
                    A=cat(3,artransects_thisday,allusartransects(:,:,timestepsearch));
                    artransects_thisday=sum(A,3,'omitnan');
                end
            end
            
            if doy>=may1doy && doy<=sep30doy;continuewithtw=1;else;continuewithtw=0;end
            
            
            if continuewithtw==1;thistw=squeeze(tw_52x94(year-startyear_comparison+1,doy,:,:));end %so e.g. May 1 = May 1

            %Make Tw and AR arrays for the US
            if strcmp(ardataset,'merra2')
                if continuewithtw==1;thistw_us=thistw;end
                thisarshape_2_us=arshapes_2(year-(startyear_comparison-1),doy,:,:);
                thisaraxis_us=araxes_thisday;
                thisartransect_us=artransects_thisday;
            end

            arshapes_2_us_byyear(year-(startyear_comparison-1),doy,:,:)=thisarshape_2_us;
            araxes_us_byyear(year-(startyear_comparison-1),doy,:,:)=thisaraxis_us;
            artransects_us_byyear(year-(startyear_comparison-1),doy,:,:)=thisartransect_us;


            if continuewithtw==1
                twabovep995(year-(startyear_comparison-1),doy,:,:)=thistw_us>=twp995;
                twabovep99(year-(startyear_comparison-1),doy,:,:)=thistw_us>=twp99;
                twabovep95(year-(startyear_comparison-1),doy,:,:)=thistw_us>=twp95;
                twabovep90(year-(startyear_comparison-1),doy,:,:)=thistw_us>=twp90;
                twabovep50(year-(startyear_comparison-1),doy,:,:)=thistw_us>=twp50;
            end
        end
        disp(year);disp(clock);
    end
    save(strcat(dataresloc_external,'full4darrays',ardataset,'.mat'),'arshapes_2_us_byyear','araxes_us_byyear','artransects_us_byyear',...
        'twabovep995','twabovep99','twabovep95','twabovep90','twabovep50','-append');
end



if artwcomparison==1
    twabove_main=eval(['twabovep' heatstressthresh_main ';']);
    twabove_lower=eval(['twabovep' heatstressthresh_lower ';']);

    %Restrict to MJJAS days only
    if size(twabove_main,2)>=sep30doy;twabove_mjjas=twabove_main(:,may1doy:sep30doy,:,:);end

    %For each gridpoint and day, if it is a p95 heat-stress day, is there an AR nearby?
    %'Nearby' is assessed according to the latest criteria: within 1 day or 100 km
    arheatinteraction=zeros(size(ar_52x94,1),size(ar_52x94,2),size(ar_52x94,3),size(ar_52x94,4)); %among heat-stress days
    nearbyar=zeros(size(ar_52x94,1),size(ar_52x94,2),size(ar_52x94,3),size(ar_52x94,4)); %among all days

    %Troubleshooting only
    arheatinteraction_test=zeros(size(ar_52x94,1),size(ar_52x94,2),size(ar_52x94,3),size(ar_52x94,4));

    for dim1=1:size(ar_52x94,1)
        for dim2=may1doy+4:sep30doy-4
            for dim3=1:size(ar_52x94,3)
                for dim4=1:size(ar_52x94,4)
                    for dim3variation=1:size(ar_52x94,3)
                        for dim4variation=1:size(ar_52x94,4)
                            if abs(dim3variation-dim3)<=4 && abs(dim4variation-dim4)<=4 %so we're only calculating distances for points that are reasonably close
                                lat1=latarray(dim3,dim4);lat2=latarray(dim3variation,dim4variation);
                                lon1=lonarray(dim3,dim4);lon2=lonarray(dim3variation,dim4variation);
                                disttopt=sqrt(((lat1-lat2)^2+(lon1-lon2)^2)*cos((lat1*pi/180+lat2*pi/180)/2))*111;
                                if disttopt<=100
                                    if max(ar_52x94(dim1,dim2-1:dim2+1,dim3variation,dim4variation))==1
                                        if twabove_main(dim1,dim2,dim3,dim4)==1 %a heat-stress day
                                            arheatinteraction(dim1,dim2,dim3,dim4)=1;
                                        end
                                        if peakheatstressdays(dim1,dim2,dim3,dim4)==1
                                            arheatinteraction_test(dim1,dim2,dim3,dim4)=1;
                                        end
                                        nearbyar(dim1,dim2,dim3,dim4)=1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    save(strcat(figloc,'Data_&_Results/finalresults',ardataset,'.mat'),'arheatinteraction','nearbyar','-append');


    %What % of all days are 'near' an AR?
    nearar_pct=100.*squeeze(sum(sum(nearbyar,'omitnan'),'omitnan'))./((size(nearbyar,1)*((sep30doy-4)-(may1doy+4)+1)));

    %What % of all days are heat-stress days?
    hs_pct=100.*squeeze(sum(sum(twabove_main,'omitnan'),'omitnan'))./((size(twabove_main,1)*((sep30doy-4)-(may1doy+4)+1)));
    peakhs_pct=100.*squeeze(sum(sum(peakheatstressdays,'omitnan'),'omitnan'))./((size(peakheatstressdays,1)*((sep30doy-4)-(may1doy+4)+1)));

    %What % of all days are heat-stress days that are near an AR?
    arheatinteraction_pct=100.*squeeze(sum(sum(arheatinteraction,'omitnan'),'omitnan'))./((size(arheatinteraction,1)*((sep30doy-4)-(may1doy+4)+1)));

    %Of all heat-stress days, the % that are near ARs
    a=100.*arheatinteraction_pct./hs_pct;

    %Of all days, the % that are near ARs
    b=nearar_pct;

    %Likelihood difference for extreme-Tw days (how likely are they to be associated with ARs, relative to chance?)
    %This is the ratio of {pct of all heat-stress days that are near ARs}/{pct of all days that are near ARs}
    likelihooddiffarheat=a./b;


    save(strcat(figloc,'Data_&_Results/finalresults',ardataset,'.mat'),'likelihooddiffarheat','-append');
end



%Make 52x94 arrays for other variables of interest
%6-hourly MERRA2 IVT must also be downloaded
%The output files (~500 MB) for each variable can be also be shared upon request to Colin Raymond, csraymond@ucla.edu
if readothervariables==1
    
    if dodailyivt==1
        for year=defaultstartyear:defaultstopyear
            dailymeanivtx=zeros(361,576,365);dailymeanivty=zeros(361,576,365);
            ivtx=squeeze(ncread(strcat('/Volumes/ExtDriveC/ARs/MERRA2_gridptIVT/ivt_',num2str(year),'.nc'),'ivtx'));
            ivty=squeeze(ncread(strcat('/Volumes/ExtDriveC/ARs/MERRA2_gridptIVT/ivt_',num2str(year),'.nc'),'ivty'));
            ivtx=flip(ivtx,2);ivty=flip(ivty,2);
            ivtx=permute(ivtx,[2 1 3]);ivty=permute(ivty,[2 1 3]);
            
            clear dailymeanivtx_temp;clear dailymeanivty_temp;
            for hr=4:4:1460
                dailymeanivtx_temp(:,:,hr/4)=mean(ivtx(:,:,hr-3:hr),3);
                dailymeanivty_temp(:,:,hr/4)=mean(ivty(:,:,hr-3:hr),3);
            end
            for day=1:365
                temp=squeeze(dailymeanivtx_temp(:,:,day));tempadj=[temp(:,289:576) temp(:,1:288)];
                dailymeanivtx(:,:,day)=tempadj;
                temp=squeeze(dailymeanivty_temp(:,:,day));tempadj=[temp(:,289:576) temp(:,1:288)];
                dailymeanivty(:,:,day)=tempadj;
            end
            
            for doy=1:365
                temp=squeeze(dailymeanivtx(:,:,doy));
                X=merra2lons;Y=flipud(merra2lats);V=temp;Xq=lonarray_52x94;Yq=latarray_52x94;
                ivtx_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,V,Xq,Yq);
                
                temp=squeeze(dailymeanivty(:,:,doy));
                X=merra2lons;Y=flipud(merra2lats);V=temp;Xq=lonarray_52x94;Yq=latarray_52x94;
                ivty_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,V,Xq,Yq);
            end
            
            tivt_52x94(year-(defaultstartyear-1),:,:,:)=sqrt(ivtx_52x94(year-(defaultstartyear-1),:,:,:).^2+ivty_52x94(year-(defaultstartyear-1),:,:,:).^2);
            disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'ivt_merra2.mat'),'tivt_52x94','-v7.3');
    end

    if do6hourlyivt==1
        ivtx3hr_52x94=NaN.*ones(numyears,365,8,52,94);ivty3hr_52x94=NaN.*ones(numyears,365,8,52,94);
        tivt3hr_52x94=NaN.*ones(numyears,365,8,52,94);
        for year=defaultstartyear:defaultstopyear
            sixhourlyivtx=zeros(361,576,365,4);sixhourlyivty=zeros(361,576,365,4);
            ivtx=squeeze(ncread(strcat('/Volumes/ExtDriveC/ARs/MERRA2_gridptIVT/ivt_',num2str(year),'.nc'),'ivtx'));
            ivty=squeeze(ncread(strcat('/Volumes/ExtDriveC/ARs/MERRA2_gridptIVT/ivt_',num2str(year),'.nc'),'ivty'));
            ivtx=flip(ivtx,2);ivty=flip(ivty,2);
            ivtx=permute(ivtx,[2 1 3]);ivty=permute(ivty,[2 1 3]);
            

            for ts=1:365*4
                day=round2(ts/4,1,'ceil');hr=rem(ts,4);if hr==0;hr=4;end
                temp=squeeze(ivtx(:,:,ts));tempadj=[temp(:,289:576) temp(:,1:288)];
                sixhourlyivtx(:,:,day,hr)=tempadj;
                temp=squeeze(ivty(:,:,ts));tempadj=[temp(:,289:576) temp(:,1:288)];
                sixhourlyivty(:,:,day,hr)=tempadj;
            end
            
            for doy=1:365
                for hr=1:4
                    temp=squeeze(sixhourlyivtx(:,:,doy,hr));
                    X=merra2lons;Y=flipud(merra2lats);V=temp;Xq=lonarray_52x94;Yq=latarray_52x94;
                    ivtx3hr_52x94(year-(defaultstartyear-1),doy,hr*2,:,:)=interp2(X,Y,V,Xq,Yq);
                    
                    temp=squeeze(sixhourlyivty(:,:,doy));
                    X=merra2lons;Y=flipud(merra2lats);V=temp;Xq=lonarray_52x94;Yq=latarray_52x94;
                    ivty3hr_52x94(year-(defaultstartyear-1),doy,hr*2,:,:)=interp2(X,Y,V,Xq,Yq);
                end
            end
            
            tivt3hr_52x94(year-(defaultstartyear-1),:,:,:)=sqrt(ivtx3hr_52x94(year-(defaultstartyear-1),:,:,:).^2+ivty3hr_52x94(year-(defaultstartyear-1),:,:,:).^2);
            disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'ivt3hr_merra2.mat'),'tivt3hr_52x94','-v7.3');
        clear ivtx3hr_52x94;clear ivty3hr_52x94;
        clear sixhourlyivtx;clear sixhourlyivty;
    end

    if dodailyprecipevapradsm==1
        precip_52x94=zeros(numyears,365,52,94);evap_52x94=zeros(numyears,365,52,94);
        netshortwave_52x94=zeros(numyears,365,52,94);netlongwave_52x94=zeros(numyears,365,52,94);toplevelsm_52x94=zeros(numyears,365,52,94);
        for year=defaultstartyear:defaultstopyear
            for doy=1:365
                thismon=DOYtoMonth_heatars(doy,1);thisdom=DOYtoDOM_heatars(doy,1);
                if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
                if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
                if year<=1991;prefix='100';elseif year<=2000;prefix='200';elseif year<=2010;prefix='300';else;prefix='400';end
    
                thisfilename=strcat('/Volumes/ExtDriveC/MERRA2_precip/MERRA2_',prefix,'.tavg1_2d_flx_Nx.',num2str(year),thismon_str,thisdom_str,'.nc4.nc4');
                preciptemp=ncread(thisfilename,'PRECTOT');
                exist merra2lats_forprecip;
                if ans==0
                    lat=double(ncread(thisfilename,'lat'));lon=double(ncread(thisfilename,'lon'));
                    clear merra2lats_forprecip;clear merra2lons_forprecip;
                    for row=1:size(lat,1);for col=1:size(lon,1);merra2lats_forprecip(row,col)=lat(row);merra2lons_forprecip(row,col)=lon(col);end;end
                    westernhem=merra2lons_forprecip>=180;merra2lons_forprecip(westernhem)=merra2lons_forprecip(westernhem)-360;
                end

                thisfilename=strcat('/Volumes/ExtDriveC/MERRA2_radiation/MERRA2_',prefix,'.tavg1_2d_rad_Nx.',num2str(year),thismon_str,thisdom_str,'.nc4.nc4');
                netswtemp=ncread(thisfilename,'SWGNT');netlwtemp=ncread(thisfilename,'LWGNT');
                thisfilename=strcat('/Volumes/ExtDriveC/MERRA2_sfcvariabs/MERRA2_',prefix,'.tavg1_2d_lnd_Nx.',num2str(year),thismon_str,thisdom_str,'.nc4.nc4');
                evaptemp=ncread(thisfilename,'EVLAND');smtemp=ncread(thisfilename,'SFMC');
                if year==defaultstartyear && doy==1
                    lat=double(ncread(thisfilename,'lat'));lon=double(ncread(thisfilename,'lon'));
                    clear merra2lats_forothers;clear merra2lons_forothers;
                    for row=1:size(lat,1);for col=1:size(lon,1);merra2lats_forothers(row,col)=lat(row);merra2lons_forothers(row,col)=lon(col);end;end
                    westernhem=merra2lons_forothers>=180;merra2lons_forothers(westernhem)=merra2lons_forothers(westernhem)-360;
                end
                
                X=merra2lons_forprecip;Y=flipud(merra2lats_forprecip);Xq=lonarray_52x94;Yq=latarray_52x94;
                precip_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,flipud(squeeze(sum(preciptemp,3))'),Xq,Yq);
                X=merra2lons_forothers;Y=flipud(merra2lats_forothers);Xq=lonarray_52x94;Yq=latarray_52x94;
                evap_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,flipud(squeeze(sum(evaptemp,3))'),Xq,Yq);
                netshortwave_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,flipud(squeeze(mean(netswtemp,3))'),Xq,Yq);
                netlongwave_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,flipud(squeeze(mean(netlwtemp,3))'),Xq,Yq);
                toplevelsm_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,flipud(squeeze(mean(smtemp,3))'),Xq,Yq);
    
                precip_52x94(year-(defaultstartyear-1),doy,:,:)=precip_52x94(year-(defaultstartyear-1),doy,:,:).*3600./1000; %to convert from kg/m^2/sec to m
                evap_52x94(year-(defaultstartyear-1),doy,:,:)=evap_52x94(year-(defaultstartyear-1),doy,:,:).*3600./1000; %to convert from kg/m^2/sec to m
            end

            clear preciptemp;clear evaptemp;clear netswtemp;clear netlwtemp;clear smtemp;
            disp(year);
        end
        save(strcat(dataresloc_external,'precip_merra2.mat'),'precip_52x94','-v7.3');
        save(strcat(dataresloc_external,'evap_merra2.mat'),'evap_52x94','-v7.3');
        save(strcat(dataresloc_external,'netshortwave_merra2.mat'),'netshortwave_52x94','-v7.3');
        save(strcat(dataresloc_external,'netlongwave_merra2.mat'),'netlongwave_52x94','-v7.3');
        save(strcat(dataresloc_external,'toplevelsm_merra2.mat'),'toplevelsm_52x94','-v7.3');
    end


    if do3hourlyprecipevapradsm==1
        precip3hr_52x94=zeros(numyears,365,8,52,94);evap3hr_52x94=zeros(numyears,365,8,52,94);
        netshortwave3hr_52x94=zeros(numyears,365,8,52,94);netlongwave3hr_52x94=zeros(numyears,365,8,52,94);toplevelsm3hr_52x94=zeros(numyears,365,8,52,94);
        for year=defaultstartyear:defaultstopyear
            for doy=may1doy:sep30doy
                thismon=DOYtoMonth_heatars(doy,1);thisdom=DOYtoDOM_heatars(doy,1);
                if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
                if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
                if year<=1991;prefix='100';elseif year<=2000;prefix='200';elseif year<=2010;prefix='300';else;prefix='400';end
    
                thisfilename=strcat('/Volumes/ExtDriveC/MERRA2_precip/MERRA2_',prefix,'.tavg1_2d_flx_Nx.',num2str(year),thismon_str,thisdom_str,'.nc4.nc4');
                preciptemp=ncread(thisfilename,'PRECTOT');
                if year==defaultstartyear && doy==may1doy
                    lat=double(ncread(thisfilename,'lat'));lon=double(ncread(thisfilename,'lon'));
                    clear merra2lats_forprecip;clear merra2lons_forprecip;
                    for row=1:size(lat,1);for col=1:size(lon,1);merra2lats_forprecip(row,col)=lat(row);merra2lons_forprecip(row,col)=lon(col);end;end
                    westernhem=merra2lons_forprecip>=180;merra2lons_forprecip(westernhem)=merra2lons_forprecip(westernhem)-360;
                end

                thisfilename=strcat('/Volumes/ExtDriveC/MERRA2_radiation/MERRA2_',prefix,'.tavg1_2d_rad_Nx.',num2str(year),thismon_str,thisdom_str,'.nc4.nc4');
                netswtemp=ncread(thisfilename,'SWGNT');netlwtemp=ncread(thisfilename,'LWGNT');
                thisfilename=strcat('/Volumes/ExtDriveC/MERRA2_sfcvariabs/MERRA2_',prefix,'.tavg1_2d_lnd_Nx.',num2str(year),thismon_str,thisdom_str,'.nc4.nc4');
                evaptemp=ncread(thisfilename,'EVLAND');smtemp=ncread(thisfilename,'SFMC');
                if year==defaultstartyear && doy==may1doy
                    lat=double(ncread(thisfilename,'lat'));lon=double(ncread(thisfilename,'lon'));
                    clear merra2lats_forothers;clear merra2lons_forothers;
                    for row=1:size(lat,1);for col=1:size(lon,1);merra2lats_forothers(row,col)=lat(row);merra2lons_forothers(row,col)=lon(col);end;end
                    westernhem=merra2lons_forothers>=180;merra2lons_forothers(westernhem)=merra2lons_forothers(westernhem)-360;
                end
 
                
                for hr=3:3:24
                    X=merra2lons_forprecip;Y=flipud(merra2lats_forprecip);Xq=lonarray_52x94;Yq=latarray_52x94;
                    precip3hr_52x94(year-(defaultstartyear-1),doy,hr/3,:,:)=interp2(X,Y,flipud(squeeze(preciptemp(:,:,hr))'),Xq,Yq);
                    X=merra2lons_forothers;Y=flipud(merra2lats_forothers);Xq=lonarray_52x94;Yq=latarray_52x94;
                    evap3hr_52x94(year-(defaultstartyear-1),doy,hr/3,:,:)=interp2(X,Y,flipud(squeeze(evaptemp(:,:,hr))'),Xq,Yq);
                    netshortwave3hr_52x94(year-(defaultstartyear-1),doy,hr/3,:,:)=interp2(X,Y,flipud(squeeze(netswtemp(:,:,hr))'),Xq,Yq);
                    netlongwave3hr_52x94(year-(defaultstartyear-1),doy,hr/3,:,:)=interp2(X,Y,flipud(squeeze(netlwtemp(:,:,hr))'),Xq,Yq);
                    toplevelsm3hr_52x94(year-(defaultstartyear-1),doy,hr/3,:,:)=interp2(X,Y,flipud(squeeze(smtemp(:,:,hr))'),Xq,Yq);
                end
    
                precip3hr_52x94(year-(defaultstartyear-1),doy,:,:,:)=precip3hr_52x94(year-(defaultstartyear-1),doy,:,:,:).*3600./1000; %to convert from kg/m^2/sec to m
                evap3hr_52x94(year-(defaultstartyear-1),doy,:,:,:)=evap3hr_52x94(year-(defaultstartyear-1),doy,:,:,:).*3600./1000; %to convert from kg/m^2/sec to m
            end

            clear preciptemp;clear evaptemp;clear netswtemp;clear netlwtemp;clear smtemp;
            disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'precip3hr_merra2.mat'),'precip3hr_52x94','-v7.3');
        save(strcat(dataresloc_external,'evap3hr_merra2.mat'),'evap3hr_52x94','-v7.3');
        save(strcat(dataresloc_external,'netshortwave3hr_merra2.mat'),'netshortwave3hr_52x94','-v7.3');
        save(strcat(dataresloc_external,'netlongwave3hr_merra2.mat'),'netlongwave3hr_52x94','-v7.3');
        save(strcat(dataresloc_external,'toplevelsm3hr_merra2.mat'),'toplevelsm3hr_52x94','-v7.3');
    end

    if do1hourlyprecip==1
        precip1hr_52x94=NaN.*ones(numyears,365,24,52,94);
        for year=defaultstartyear:defaultstopyear
            for doy=may1doy:sep30doy
                thismon=DOYtoMonth_heatars(doy,1);thisdom=DOYtoDOM_heatars(doy,1);
                if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
                if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
                if year<=1991;prefix='100';elseif year<=2000;prefix='200';elseif year<=2010;prefix='300';else;prefix='400';end
    
                thisfilename=strcat('/Volumes/ExtDriveC/MERRA2_precip/MERRA2_',prefix,'.tavg1_2d_flx_Nx.',num2str(year),thismon_str,thisdom_str,'.nc4.nc4');
                preciptemp=ncread(thisfilename,'PRECTOT');
                if year==defaultstartyear && doy==may1doy
                    lat=double(ncread(thisfilename,'lat'));lon=double(ncread(thisfilename,'lon'));
                    clear merra2lats_forprecip;clear merra2lons_forprecip;
                    for row=1:size(lat,1);for col=1:size(lon,1);merra2lats_forprecip(row,col)=lat(row);merra2lons_forprecip(row,col)=lon(col);end;end
                    westernhem=merra2lons_forprecip>=180;merra2lons_forprecip(westernhem)=merra2lons_forprecip(westernhem)-360;
                end
 
                
                X=merra2lons_forprecip;Y=flipud(merra2lats_forprecip);Xq=lonarray_52x94;Yq=latarray_52x94;
                for hr=1:24
                    precip1hr_52x94(year-(defaultstartyear-1),doy,hr,:,:)=interp2(X,Y,flipud(squeeze(preciptemp(:,:,hr))'),Xq,Yq);
                end
    
                precip1hr_52x94(year-(defaultstartyear-1),doy,:,:,:)=precip1hr_52x94(year-(defaultstartyear-1),doy,:,:,:).*3600./1000; %to convert from kg/m^2/sec to m
            end

            clear preciptemp;
            disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'precip1hr_merra2.mat'),'precip1hr_52x94','-v7.3');
    end

    if do3hourlyprecip_era5land==1
        precip3hr_era5land_52x94=NaN.*ones(numyears,365,8,52,94);
        for year=defaultstartyear:defaultstopyear
                fname=strcat('/Volumes/ExtDriveC/ERA5Land_US/precip_',num2str(year),'_us_1hr.nc');
                preciptemp=ncread(fname,'tp');

                exist era5landlats_forprecip;
                if ans==0
                    lat=double(ncread(fname,'latitude'));lon=double(ncread(fname,'longitude'));
                    clear era5landlats_forprecip;clear era5landlons_forprecip;
                    for row=1:size(lat,1);for col=1:size(lon,1);era5landlats_forprecip(row,col)=lat(row);era5landlons_forprecip(row,col)=lon(col);end;end
                    westernhem=era5landlons_forprecip>=180;era5landlons_forprecip(westernhem)=era5landlons_forprecip(westernhem)-360;
                end

                %Interpolate to 52x94 dimensions (25 sec)
                X=era5landlons_forprecip;Y=flipud(era5landlats_forprecip);Xq=lonarray_52x94;Yq=latarray_52x94;
                preciptemp_smaller=NaN.*ones(52,94,size(preciptemp,3));
                for hr=1:size(preciptemp,3)
                    preciptemp_smaller(:,:,hr)=interp2(X,Y,flipud(squeeze(preciptemp(:,:,hr))'),Xq,Yq);
                end

                %Convert from native precip style (each hour representing
                %the daily accumulation up to that hour) to a more natural single-hour value (1 sec)
                %Don't worry about hour 1 of Jan 1
                newpreciptemp_smaller=zeros(size(preciptemp_smaller));
                for hrofyear=2:size(preciptemp_smaller,3)
                    if rem(hrofyear,24)>=3 || rem(hrofyear,24)<=1
                        newpreciptemp_smaller(:,:,hrofyear)=preciptemp_smaller(:,:,hrofyear)-preciptemp_smaller(:,:,hrofyear-1);
                    else
                        newpreciptemp_smaller(:,:,hrofyear)=preciptemp_smaller(:,:,hrofyear);
                    end
                end

                janaprhours=31*24+28*24+31*24+30*24;
                for doy=may1doy:sep30doy        
                    for hr=3:3:24
                        curhrofyear=janaprhours+(doy-may1doy)*24+hr;
                        precip3hr_era5land_52x94(year-(defaultstartyear-1),doy,hr/3,:,:)=squeeze(newpreciptemp_smaller(:,:,curhrofyear)); %units are m
                    end
                end
            %end

            clear preciptemp;
            disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'precip3hr_era5land.mat'),'precip3hr_era5land_52x94','-v7.3');
    end


    if do1hourlyprecip_era5land==1
        precip1hr_era5land_52x94=NaN.*ones(numyears,365,24,52,94);
        for year=defaultstartyear:defaultstopyear
            fname=strcat('/Volumes/ExtDriveC/ERA5Land_US/precip_',num2str(year),'_us_1hr.nc');
            preciptemp=ncread(fname,'tp');

            exist era5landlats_forprecip;
            if ans==0
                lat=double(ncread(fname,'latitude'));lon=double(ncread(fname,'longitude'));
                clear era5landlats_forprecip;clear era5landlons_forprecip;
                for row=1:size(lat,1);for col=1:size(lon,1);era5landlats_forprecip(row,col)=lat(row);era5landlons_forprecip(row,col)=lon(col);end;end
                westernhem=era5landlons_forprecip>=180;era5landlons_forprecip(westernhem)=era5landlons_forprecip(westernhem)-360;
            end

            %Interpolate to 52x94 dimensions (25 sec)
            X=era5landlons_forprecip;Y=flipud(era5landlats_forprecip);Xq=lonarray_52x94;Yq=latarray_52x94;
            preciptemp_smaller=NaN.*ones(52,94,size(preciptemp,3));
            for hr=1:size(preciptemp,3)
                preciptemp_smaller(:,:,hr)=interp2(X,Y,flipud(squeeze(preciptemp(:,:,hr))'),Xq,Yq);
            end

            %Convert from native precip style (each hour representing
            %the daily accumulation up to that hour) to a more natural single-hour value (1 sec)
            %Don't worry about hour 1 of Jan 1
            newpreciptemp_smaller=zeros(size(preciptemp_smaller));
            for hrofyear=2:size(preciptemp_smaller,3)
                if rem(hrofyear,24)>=3 || rem(hrofyear,24)<=1
                    newpreciptemp_smaller(:,:,hrofyear)=preciptemp_smaller(:,:,hrofyear)-preciptemp_smaller(:,:,hrofyear-1);
                else
                    newpreciptemp_smaller(:,:,hrofyear)=preciptemp_smaller(:,:,hrofyear);
                end
            end

            janaprhours=31*24+28*24+31*24+30*24;
            for doy=may1doy:sep30doy        
                for hr=1:24
                    curhrofyear=janaprhours+(doy-may1doy)*24+hr;
                    precip1hr_era5land_52x94(year-(defaultstartyear-1),doy,hr,:,:)=squeeze(newpreciptemp_smaller(:,:,curhrofyear)); %units are m
                end
            end

            clear preciptemp;
            disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'precip1hr_era5land.mat'),'precip1hr_era5land_52x94','-v7.3');
    end


    
    if doomega500==1
        omega500_52x94=NaN.*ones(numyears,365,52,94);
        for year=defaultstartyear:defaultstopyear
            for doy=1:365
                thismon=DOYtoMonth_heatars(doy,1);thisdom=DOYtoDOM_heatars(doy,1);
                if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
                if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
                thisfilename=strcat('/Volumes/ExternalDriveF/MERRA2/MERRA2_omega500.',num2str(year),thismon_str,thisdom_str,'.SUB.nc');
                omega500temp=ncread(thisfilename,'OMEGA500');

                if year==defaultstartyear && doy==1
                    lattemp=ncread(thisfilename,'lat');
                    lontemp=ncread(thisfilename,'lon');
                    lat=double(lattemp);lon=double(lontemp);
                    for row=1:size(lat,1)
                        for col=1:size(lon,1)
                            merra2lats(row,col)=lat(row);merra2lons(row,col)=lon(col);
                        end
                    end
                    westernhem=merra2lons>=180;merra2lons(westernhem)=merra2lons(westernhem)-360;
                end

                omega500temp_daily=flipud(squeeze(mean(omega500temp,3))');
                X=merra2lons;Y=flipud(merra2lats);V=omega500temp_daily;Xq=lonarray_52x94;Yq=latarray_52x94;
                omega500_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,V,Xq,Yq);
            end

            clear omega500temp;disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'omega500_merra2.mat'),'omega500_52x94','-v7.3');
    end

    if doz500==1
        for year=defaultstartyear:defaultstopyear
            for doy=1:365
                thismon=DOYtoMonth_heatars(doy,1);thisdom=DOYtoDOM_heatars(doy,1);
                if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
                if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
                if year<=1991;prefix='100';elseif year<=2000;prefix='200';elseif year<=2010;prefix='300';...
                elseif year==2021 && doy>=152 && doy<=243;prefix='401';else;prefix='400';end
                thisfilename=strcat('/Volumes/ExternalDriveF/MERRA2/z500/MERRA2_',prefix,'.tavg1_2d_slv_Nx.',num2str(year),thismon_str,thisdom_str,'.SUB.nc');
                z500temp=ncread(thisfilename,'H500');

                if year==defaultstartyear && doy==1
                    lattemp=ncread(thisfilename,'lat');
                    lontemp=ncread(thisfilename,'lon');
                    lat=double(lattemp);lon=double(lontemp);
                    for row=1:size(lat,1)
                        for col=1:size(lon,1)
                            merra2lats_here(row,col)=lat(row);merra2lons_here(row,col)=lon(col);
                        end
                    end
                    westernhem=merra2lons_here>=180;merra2lons_here(westernhem)=merra2lons_here(westernhem)-360;
                end

                z500temp_daily=flipud(squeeze(mean(z500temp,3))');
                X=merra2lons_here;Y=flipud(merra2lats_here);V=z500temp_daily;Xq=lonarray_52x94;Yq=latarray_52x94;
                z500_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,V,Xq,Yq);
            end

            clear z500temp;disp(year);disp(clock);
        end
        save(strcat(dataresloc_external,'z500_merra2.mat'),'z500_52x94','-v7.3');
    end
    
    %For a given day, defined as the highest scale of which there are at least 2 timesteps
    %AR scale file: obtained from Bin Guan (UCLA)
    %Output file can again be shared upon request
    if doarscale==1
        arscale_52x94=NaN.*ones(numyears,365,52,94);
        scaletemp=ncread('/Volumes/ExtDriveC/ARs/ARscale.nc','scale',[376 227 1 1 1],[97 56 1 60264 1]); %10 min
        lattemp=ncread('/Volumes/ExtDriveC/ARs/ARscale.nc','lat',[227],[56]);
        lontemp=ncread('/Volumes/ExtDriveC/ARs/ARscale.nc','lon',[376],[97]);
        lat=double(lattemp);lon=double(lontemp);
        for row=1:size(lat,1)
            for col=1:size(lon,1)
                merra2lats(row,col)=lat(row);merra2lons(row,col)=lon(col);
            end
        end
        westernhem=merra2lons>=180;merra2lons(westernhem)=merra2lons(westernhem)-360;
        
        scaletemp=squeeze(scaletemp);
        
        year=defaultstartyear;doy=1;yearlen=366;
        for timestep=4:4:59904
            todaysscales=scaletemp(:,:,timestep-3:timestep);
            todaysscales_sorted=sort(todaysscales,3);
            scaletemp_daily=flipud(squeeze(todaysscales_sorted(:,:,2))');
            X=merra2lons;Y=flipud(merra2lats);V=scaletemp_daily;Xq=lonarray_52x94;Yq=latarray_52x94;
            arscale_52x94(year-(defaultstartyear-1),doy,:,:)=interp2(X,Y,V,Xq,Yq);
            if doy==1;disp(doy);disp(year);disp(timestep/4);end
            doy=doy+1;
            if doy==yearlen+1
                year=year+1;
                doy=1;
                if rem(year,4)==0;yearlen=366;else;yearlen=365;end
            end
        end
        save(strcat(dataresloc_external,'arscale_merra2.mat'),'arscale_52x94','-v7.3');
    end
end

if calctivtpctiles==1
    %Get *regional* tIVT percentiles
    exist regtivtp50;
    if ans==0
        regtivtp50=zeros(7,1);regtivtp90=zeros(7,1);regtivtp95=zeros(7,1);regtivtp98=zeros(7,1);regtivtp99=zeros(7,1);regtivtp995=zeros(7,1);
        mjjastivt=tivt_52x94(:,may1doy:sep30doy,:,:);
        for reg=1:7
            thisdata=mjjastivt(:,:,thencaregions==reg+1);
            c=0;clear regmeantivt_byday;
            for i=1:size(thisdata,1)
                for j=1:size(thisdata,2)
                    c=c+1;
                    regmeantivt_byday(c)=mean(thisdata(i,j,:));
                end
            end
            regtivtp50(reg)=quantile(regmeantivt_byday,0.5);
            regtivtp90(reg)=quantile(regmeantivt_byday,0.9);
            regtivtp95(reg)=quantile(regmeantivt_byday,0.95);
            regtivtp98(reg)=quantile(regmeantivt_byday,0.98);
            regtivtp99(reg)=quantile(regmeantivt_byday,0.99);
            regtivtp995(reg)=quantile(regmeantivt_byday,0.995);
        end
        save(strcat(dataresloc_external,'heat_merra2.mat'),'regtivtp50','regtivtp90','regtivtp95','regtivtp98','regtivtp99','regtivtp995','-append');
    end


    for loop=2:2
        if loop==1 %IVT
            mjjasarr=tivt_52x94(:,may1doy:sep30doy,:,:);
        elseif loop==2 %precip
            mjjasarr=precip_52x94(:,may1doy:sep30doy,:,:);
        end

        arrp50=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp60=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp70=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp75=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp80=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp85=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp90=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp95=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp98=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp99=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        arrp995=NaN.*ones(size(mjjasarr,3),size(mjjasarr,4));
        for i=1:size(mjjasarr,3)
            for j=1:size(mjjasarr,4)
                thisptdata=squeeze(mjjasarr(:,:,i,j));
                thisptdata=reshape(thisptdata,[size(thisptdata,1)*size(thisptdata,2) 1]);
                if sum(~isnan(thisptdata))>=0.8*size(thisptdata,1)
                    arrp50(i,j)=quantile(thisptdata,0.5);
                    arrp60(i,j)=quantile(thisptdata,0.6);
                    arrp70(i,j)=quantile(thisptdata,0.7);
                    arrp75(i,j)=quantile(thisptdata,0.75);
                    arrp80(i,j)=quantile(thisptdata,0.8);
                    arrp85(i,j)=quantile(thisptdata,0.85);
                    arrp90(i,j)=quantile(thisptdata,0.9);
                    arrp95(i,j)=quantile(thisptdata,0.95);
                    arrp98(i,j)=quantile(thisptdata,0.98);
                    arrp99(i,j)=quantile(thisptdata,0.99);
                    arrp995(i,j)=quantile(thisptdata,0.995);
                end
            end
        end

        if loop==1
            tivtp50=arrp50;tivtp60=arrp60;tivtp70=arrp70;tivtp75=arrp75;tivtp80=arrp80;tivtp85=arrp85;tivtp90=arrp90;
            tivtp95=arrp95;tivtp98=arrp98;tivtp99=arrp99;tivtp995=arrp995;
            save(strcat(dataresloc_external,'heat_merra2.mat'),'tivtp50','tivtp60','tivtp70','tivtp75','tivtp80','tivtp85','tivtp90','tivtp95',...
                'tivtp98','tivtp99','tivtp995','-append');
        elseif loop==2
            precipp50=arrp50;precipp60=arrp60;precipp70=arrp70;precipp75=arrp75;precipp80=arrp80;precipp85=arrp85;precipp90=arrp90;
            precipp95=arrp95;precipp98=arrp98;precipp99=arrp99;precipp995=arrp995;
            save(strcat(dataresloc_external,'heat_merra2.mat'),'precipp50','precipp60','precipp70','precipp75','precipp80','precipp85','precipp90','precipp95',...
                'precipp98','precipp99','precipp995','-append');
        end
    end
end


if precipivttwcomparison==1
    twabove_main=eval(['twabovep' heatstressthresh_main ';']);
    twabove_lower=eval(['twabovep' heatstressthresh_lower ';']);

    %Restrict to MJJAS days only
    if size(twabove_main,2)>=sep30doy;twabove_mjjas=twabove_main(:,may1doy:sep30doy,:,:);end


    %For each gridpoint and day, if it is a p95 heat-stress day, is there precip or high (p90) IVT nearby?
    %'Nearby' is assessed according to the latest criteria: within 1 day or 100 km
    precipheatinteraction=zeros(size(precip_52x94,1),size(ar_52x94,2),size(ar_52x94,3),size(ar_52x94,4)); %among heat-stress days
    nearbyprecip=zeros(size(precip_52x94,1),size(ar_52x94,2),size(ar_52x94,3),size(ar_52x94,4)); %among all days
    tivtheatinteraction=zeros(size(tivt_52x94,1),size(ar_52x94,2),size(ar_52x94,3),size(ar_52x94,4)); %among heat-stress days
    nearbytivt=zeros(size(tivt_52x94,1),size(ar_52x94,2),size(ar_52x94,3),size(ar_52x94,4)); %among all days

    for dim1=1:size(tivt_52x94,1)
        for dim2=may1doy+4:sep30doy-4
            for dim3=1:size(ar_52x94,3)
                for dim4=1:size(ar_52x94,4)
                    for dim3variation=1:size(ar_52x94,3)
                        for dim4variation=1:size(ar_52x94,4)
                            if abs(dim3variation-dim3)<=4 && abs(dim4variation-dim4)<=4 %so we're only calculating distances for points that are reasonably close
                                lat1=latarray(dim3,dim4);lat2=latarray(dim3variation,dim4variation);
                                lon1=lonarray(dim3,dim4);lon2=lonarray(dim3variation,dim4variation);
                                disttopt=sqrt(((lat1-lat2)^2+(lon1-lon2)^2)*cos((lat1*pi/180+lat2*pi/180)/2))*111;
                                if disttopt<=100
                                    %Precip assessment
                                    if max(precip_52x94(dim1,dim2-1:dim2+1,dim3variation,dim4variation))>=0.001 %i.e. 1 mm
                                        if twabove_main(dim1,dim2,dim3,dim4)==1 %a heat-stress day
                                            precipheatinteraction(dim1,dim2,dim3,dim4)=1;
                                        end
                                        nearbyprecip(dim1,dim2,dim3,dim4)=1;
                                    end

                                    %tIVT assessment
                                    if max(tivt_52x94(dim1,dim2-1:dim2+1,dim3variation,dim4variation))>=tivtp75(dim3,dim4)
                                        if twabove_main(dim1,dim2,dim3,dim4)==1 %a heat-stress day
                                            tivtheatinteraction(dim1,dim2,dim3,dim4)=1;
                                        end
                                        nearbytivt(dim1,dim2,dim3,dim4)=1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    save(strcat(figloc,'Data_&_Results/finalresults',ardataset,'.mat'),'precipheatinteraction','nearbyprecip','tivtheatinteraction','nearbytivt','-append');


    %What % of all days are 'near' precip/high IVT?
    nearprecip_pct=100.*squeeze(sum(sum(nearbyprecip,'omitnan'),'omitnan'))./((size(nearbyprecip,1)*((sep30doy-4)-(may1doy+4)+1)));
    neartivt_pct=100.*squeeze(sum(sum(nearbytivt,'omitnan'),'omitnan'))./((size(nearbytivt,1)*((sep30doy-4)-(may1doy+4)+1)));

    %What % of all days are heat-stress days?
    hs_pct=100.*squeeze(sum(sum(twabove_main,'omitnan'),'omitnan'))./((size(twabove_main,1)*((sep30doy-4)-(may1doy+4)+1)));
    peakhs_pct=100.*squeeze(sum(sum(peakheatstressdays,'omitnan'),'omitnan'))./((size(peakheatstressdays,1)*((sep30doy-4)-(may1doy+4)+1)));

    %What % of all days are heat-stress days that are near precip/high IVT?
    precipheatinteraction_pct=100.*squeeze(sum(sum(precipheatinteraction,'omitnan'),'omitnan'))./((size(precipheatinteraction,1)*((sep30doy-4)-(may1doy+4)+1)));
    tivtheatinteraction_pct=100.*squeeze(sum(sum(tivtheatinteraction,'omitnan'),'omitnan'))./((size(tivtheatinteraction,1)*((sep30doy-4)-(may1doy+4)+1)));

    %Of all heat-stress days, the % that are near precip/high IVT
    a1=100.*precipheatinteraction_pct./hs_pct;
    a2=100.*tivtheatinteraction_pct./hs_pct;

    %Of all days, the % that are near precip/high IVT
    b1=nearprecip_pct;
    b2=neartivt_pct;

    %Likelihood difference for extreme-Tw days (how likely are they to be associated with precip/high IVT, relative to chance?)
    %This is the ratio of {pct of all heat-stress days that are near precip/high IVT}/{pct of all days that are near precip/high IVT}
    likelihooddiffprecipheat=a1./b1;
    likelihooddifftivtheat=a2./b2;

    save(strcat(figloc,'Data_&_Results/finalresults',ardataset,'.mat'),'likelihooddiffprecipheat','likelihooddifftivtheat','-append');
end



%For all "peak heat-stress days", i.e. sequences where Tw:
%a) is above the MJJAS 95th percentile
%b) is the highest value within 3 days on either side
%c) increases from below p90 to above p95 in 3 days
if makedailycompositesfortimeseries==1

    if reanalyzepeakheatstressdays==1
        exist tw_52x94;
        if ans==0
            tmp=load(strcat(dataresloc_external,'heat_merra2.mat'));
            tw_52x94=tmp.tw_52x94;
            twp95=tmp.twp95;twp90=tmp.twp90;
            regtwp95=tmp.regtwp95;regtwp90=tmp.regtwp90;
        end

        peakheatstressdays=zeros(numyears,nummjjasdays,52,94);
        for lat=1:size(latarray,1)
            for lon=1:size(latarray,2)
                reg=thencaregions(lat,lon)-1;
                if reg>=1
                    for y=1:39
                        for doy=may1doy+4:sep30doy-4
                            %Define peak heat-stress days based on criteria
                            if tw_52x94(y,doy,lat,lon)>=twp95(lat,lon) %criterion (a)
                                if tw_52x94(y,doy,lat,lon)>max(tw_52x94(y,doy-3:doy-1,lat,lon)) && ...
                                        tw_52x94(y,doy,lat,lon)>max(tw_52x94(y,doy+1:doy+3,lat,lon)) %criterion (b)
                                    if min(tw_52x94(y,doy-3:doy-1,lat,lon))<twp90(lat,lon) %criterion (c)
                                        peakheatstressdays(y,doy,lat,lon)=1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    
        %For each day and region, of the gridpts experiencing peak heat-stress days,
            %take only the single gridpt with the largest Tw anom (pctile-based)
        for reg=1:numregs
            gridptrowtotake{reg}=NaN.*ones(numyears,sep30doy);
            gridptcoltotake{reg}=NaN.*ones(numyears,sep30doy);
            for y=1:numyears
                for doy=may1doy+4:sep30doy-4
                    thesepeakdays=squeeze(peakheatstressdays(y,doy,:,:)==1);
                    thistwdata=squeeze(tw_52x94(y,doy,:,:));
                    %Which has largest Tw pctile on this day?
                    thesetwpctiles=NaN.*ones(52,94);
                    for i=1:52
                        for j=1:94
                            if thesepeakdays(i,j)==1 && thencaregions(i,j)==reg+1
                                thesetwpctiles(i,j)=invprctile_heatars(reshape(tw_52x94(1:numyears,may1doy:sep30doy,i,j),[numyears*153 1]),thistwdata(i,j));
                            end
                        end
                    end
    
                    if sum(sum(~isnan(thesetwpctiles)))>0
                        [~,colofmax]=max(max(thesetwpctiles));
                        [~,rowofmax]=max(thesetwpctiles(:,colofmax));
            
                        gridptrowtotake{reg}(y,doy)=rowofmax;
                        gridptcoltotake{reg}(y,doy)=colofmax;
                    end
                end
            end
        end

        regpeakheatstressdays=zeros(numyears,sep30doy,7);daysbyreg_regmean=zeros(7,1);clear regdatesaver;
        for reg=1:numregs
            for y=1:numyears
                for doy=may1doy+4:sep30doy-4
                    %Define regional peak heat-stress days
                    todaysregmeantw=mean(tw_52x94(y,doy,thencaregions==reg+1));
                    for i=-3:-1;regmeantw_past3days(i+4)=mean(tw_52x94(y,doy+i,thencaregions==reg+1));end
                    for i=1:3;regmeantw_next3days(i)=mean(tw_52x94(y,doy+i,thencaregions==reg+1));end
                    if todaysregmeantw>=regtwp95(reg) %criterion (a)
                        if todaysregmeantw>max(regmeantw_past3days) && todaysregmeantw>max(regmeantw_next3days) %criterion (b)
                            if min(regmeantw_past3days)<regtwp90(reg) %criterion (c)
                                regpeakheatstressdays(y,doy,reg)=1;

                                daysbyreg_regmean(reg)=daysbyreg_regmean(reg)+1;
                                
                                if reg==5
                                    regdatesaver(daysbyreg_regmean(reg),:)=[y doy];
                                end
                            end
                        end
                    end
                end
            end
        end

        %Final thing before getting into variables: organize dates
        daysbyreg=zeros(7,1);datesaver=cell(7,1);
        for lat=1:52
            for lon=1:94
                reg=thencaregions(lat,lon)-1;
                if reg>=1
                    for y=1:39
                        for doy=may1doy+4:sep30doy-4
                            continueon=0;
                            %old: evaluate if this day is a peak hs day (much less stringent)
                            if newfigureversion==1
                                if gridptrowtotake{reg}(y,doy)==lat && gridptcoltotake{reg}(y,doy)==lon
                                    continueon=1;
                                end
                            else
                                if peakheatstressdays(y,doy,lat,lon)==1
                                    continueon=1;
                                end
                            end
    
                            if continueon==1
                                daysbyreg(reg)=daysbyreg(reg)+1;
                                datesaver{reg}(daysbyreg(reg),:)=[y doy lat lon];
                            end
                        end
                    end
                end
            end
        end
        for reg=1:numregs
            datesaversorted=sortrows(datesaver{reg},[1 2]);
            dss_uniquedates{reg}=unique(datesaver{reg}(:,1:2),'rows');
        end
        save(strcat(dataresloc_local,'varioussmallarrays.mat'),'datesaver','dss_uniquedates','-append');
    end

    
    if processvars==1
        for varloop=firstvartocomposite:lastvartocomposite
            if varloop==1 %Tw
                twcomposite_p50=cell(7,1);twcomposite_p975=cell(7,1);twcomposite_p025=cell(7,1);twcomposite_p833=cell(7,1);twcomposite_p166=cell(7,1);temp_52x94=tw_52x94;
            elseif varloop==2 %AR
                arcomposite_p50=cell(7,1);arcomposite_p975=cell(7,1);arcomposite_p025=cell(7,1);arcomposite_p833=cell(7,1);arcomposite_p166=cell(7,1);temp_52x94=ar_52x94;
            elseif varloop==3 %T
                tcomposite_p50=cell(7,1);tcomposite_p975=cell(7,1);tcomposite_p025=cell(7,1);tcomposite_p833=cell(7,1);tcomposite_p166=cell(7,1);temp_52x94=t_52x94;
            elseif varloop==4 %q
                qcomposite_p50=cell(7,1);qcomposite_p975=cell(7,1);qcomposite_p025=cell(7,1);qcomposite_p833=cell(7,1);qcomposite_p166=cell(7,1);temp_52x94=td_52x94;
            elseif varloop==5 %tIVT
                exist tivt_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'ivt_merra2.mat'));temp_52x94=tmp.tivt_52x94;end
                tivtcomposite_p50=cell(7,1);tivtcomposite_p975=cell(7,1);tivtcomposite_p025=cell(7,1);tivtcomposite_p833=cell(7,1);tivtcomposite_p166=cell(7,1);
            elseif varloop==6 %precip
                exist precip_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'precip_merra2.mat'));temp_52x94=tmp.precip_52x94;end
                precipcomposite_p50=cell(7,1);precipcomposite_p975=cell(7,1);precipcomposite_p025=cell(7,1);precipcomposite_p833=cell(7,1);precipcomposite_p166=cell(7,1);
            elseif varloop==7 %evap
                exist evap_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'evap_merra2.mat'));temp_52x94=tmp.evap_52x94;end
                evapcomposite_p50=cell(7,1);evapcomposite_p975=cell(7,1);evapcomposite_p025=cell(7,1);evapcomposite_p833=cell(7,1);evapcomposite_p166=cell(7,1);
            elseif varloop==8 %net shortwave
                exist netshortwave_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'netshortwave_merra2.mat'));temp_52x94=tmp.netshortwave_52x94;end
                netswcomposite_p50=cell(7,1);netswcomposite_p975=cell(7,1);netswcomposite_p025=cell(7,1);netswcomposite_p833=cell(7,1);netswcomposite_p166=cell(7,1);
            elseif varloop==9 %net longwave
                exist netlongwave_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'netlongwave_merra2.mat'));temp_52x94=tmp.netlongwave_52x94;end
                netlwcomposite_p50=cell(7,1);netlwcomposite_p975=cell(7,1);netlwcomposite_p025=cell(7,1);netlwcomposite_p833=cell(7,1);netlwcomposite_p166=cell(7,1);
            elseif varloop==10 %toplevelsm
                exist toplevelsm_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'toplevelsm_merra2.mat'));temp_52x94=tmp.toplevelsm_52x94;end
                toplevelsmcomposite_p50=cell(7,1);toplevelsmcomposite_p975=cell(7,1);toplevelsmcomposite_p025=cell(7,1);toplevelsmcomposite_p833=cell(7,1);toplevelsmcomposite_p166=cell(7,1);
            elseif varloop==11 %z500
                exist z500_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'z500_merra2.mat'));temp_52x94=tmp.z500_52x94;end
                z500composite_p50=cell(7,1);z500composite_p975=cell(7,1);z500composite_p025=cell(7,1);z500composite_p833=cell(7,1);z500composite_p166=cell(7,1);
            elseif varloop==12 %omega500
                exist omega500_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'omega500_merra2.mat'));temp_52x94=tmp.omega500_52x94;end
                omega500composite_p50=cell(7,1);omega500composite_p975=cell(7,1);omega500composite_p025=cell(7,1);omega500composite_p833=cell(7,1);omega500composite_p166=cell(7,1);
            end
        
            daysbyreg=zeros(7,1);
            tempcomposite_full=cell(7,1);
            
            for lat=1:52
                for lon=1:94
                    reg=thencaregions(lat,lon)-1;
                    if reg>=1
                        for y=1:39
                            for doy=may1doy+4:sep30doy-4
                                continueon=0;
                                %old: evaluate if this day is a peak hs day (much less stringent)
                                if newfigureversion==1
                                    if gridptrowtotake{reg}(y,doy)==lat && gridptcoltotake{reg}(y,doy)==lon
                                        continueon=1;
                                    end
                                else
                                    if peakheatstressdays(y,doy,lat,lon)==1
                                        continueon=1;
                                    end
                                end
    
                                if continueon==1
                                    daysbyreg(reg)=daysbyreg(reg)+1;
        
                                    if varloop==2
                                        tempcomposite_full{reg}(daysbyreg(reg),1:9)=temp_52x94(y,doy-4:doy+4,lat,lon);
                                    elseif varloop==4
                                        q=calcqfromTd_heatars(td_52x94(y,doy-4:doy+4,lat,lon));x=calcqfromTd_heatars(td_52x94(:,may1doy:sep30doy,lat,lon));
                                        tempcomposite_full{reg}(daysbyreg(reg),1:9)=invprctile_heatars(reshape(x,[size(temp_52x94,1)*153 1]),q);
                                    else
                                        %Actual-values version
                                        %tempcomposite_full{reg}(daysbyreg(reg),1:9)=temp_52x94(y,doy-4:doy+4,lat,lon);
                                        %Pctile version
                                        tempcomposite_full{reg}(daysbyreg(reg),1:9)=...
                                            invprctile_heatars(reshape(temp_52x94(:,may1doy:sep30doy,lat,lon),[size(temp_52x94,1)*153 1]),temp_52x94(y,doy-4:doy+4,lat,lon));
                                    end
                                end
                            end
                        end
                    end
                end
            end
    
            
        
            for reg=1:numregs
                if varloop==1
                    twcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    twcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);twcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    twcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);twcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                    twcomposite_full{reg}=tempcomposite_full{reg};
                elseif varloop==2
                    arcomposite_p50{reg}=mean(tempcomposite_full{reg});
                elseif varloop==3
                    tcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    tcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);tcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    tcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);tcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==4
                    qcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    qcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);qcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    qcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);qcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==5
                    tivtcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    tivtcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);tivtcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    tivtcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);tivtcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==6
                    precipcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    precipcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);precipcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    precipcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);precipcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==7
                    evapcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    evapcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);evapcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    evapcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);evapcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==8
                    netswcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    netswcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);netswcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    netswcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);netswcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==9
                    netlwcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    netlwcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);netlwcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    netlwcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);netlwcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==10
                    toplevelsmcomposite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    toplevelsmcomposite_p975{reg}=quantile(tempcomposite_full{reg},0.975);toplevelsmcomposite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    toplevelsmcomposite_p833{reg}=quantile(tempcomposite_full{reg},0.833);toplevelsmcomposite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==11
                    z500composite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    z500composite_p975{reg}=quantile(tempcomposite_full{reg},0.975);z500composite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    z500composite_p833{reg}=quantile(tempcomposite_full{reg},0.833);z500composite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                elseif varloop==12
                    omega500composite_p50{reg}=quantile(tempcomposite_full{reg},0.5);
                    omega500composite_p975{reg}=quantile(tempcomposite_full{reg},0.975);omega500composite_p025{reg}=quantile(tempcomposite_full{reg},0.025);
                    omega500composite_p833{reg}=quantile(tempcomposite_full{reg},0.833);omega500composite_p166{reg}=quantile(tempcomposite_full{reg},0.166);
                end
            end
    
            if varloop==1
                save(strcat(dataresloc_external,'twcomposites.mat'),'twcomposite_p50','twcomposite_p975','twcomposite_p025','twcomposite_p833','twcomposite_p166');
            elseif varloop==2
                save(strcat(dataresloc_external,'arcomposites.mat'),'arcomposite_p50');
            elseif varloop==3
                save(strcat(dataresloc_external,'tcomposites.mat'),'tcomposite_p50','tcomposite_p975','tcomposite_p025','tcomposite_p833','tcomposite_p166');
            elseif varloop==4
                save(strcat(dataresloc_external,'qcomposites.mat'),'qcomposite_p50','qcomposite_p975','qcomposite_p025','qcomposite_p833','qcomposite_p166');
            elseif varloop==5
                save(strcat(dataresloc_external,'tivtcomposites.mat'),'tivtcomposite_p50','tivtcomposite_p975','tivtcomposite_p025','tivtcomposite_p833','tivtcomposite_p166');
            elseif varloop==6
                save(strcat(dataresloc_external,'precipcomposites.mat'),'precipcomposite_p50','precipcomposite_p975','precipcomposite_p025','precipcomposite_p833','precipcomposite_p166');
            elseif varloop==7
                save(strcat(dataresloc_external,'evapcomposites.mat'),'evapcomposite_p50','evapcomposite_p975','evapcomposite_p025','evapcomposite_p833','evapcomposite_p166');
            elseif varloop==8
                save(strcat(dataresloc_external,'netswcomposites.mat'),'netswcomposite_p50','netswcomposite_p975','netswcomposite_p025','netswcomposite_p833','netswcomposite_p166');
            elseif varloop==9
                save(strcat(dataresloc_external,'netlwcomposites.mat'),'netlwcomposite_p50','netlwcomposite_p975','netlwcomposite_p025','netlwcomposite_p833','netlwcomposite_p166');
            elseif varloop==10
                save(strcat(dataresloc_external,'toplevelsmcomposites.mat'),'toplevelsmcomposite_p50','toplevelsmcomposite_p975',...
                    'toplevelsmcomposite_p025','toplevelsmcomposite_p833','toplevelsmcomposite_p166');
            elseif varloop==11
                save(strcat(dataresloc_external,'z500composites.mat'),'z500composite_p50','z500composite_p975','z500composite_p025','z500composite_p833','z500composite_p166');
            elseif varloop==12
                save(strcat(dataresloc_external,'omega500composites.mat'),'omega500composite_p50','omega500composite_p975',...
                    'omega500composite_p025','omega500composite_p833','omega500composite_p166');
            end
        
            %clear tempcomposite_full;
            disp('completed another varloop');disp(clock);
        end
        clear temp_52x94;clear tivt_52x94;
    
        %Fraction of days that are peak heat-stress days
        %currently 0.9%
        tmp=squeeze(sum(squeeze(sum(peakheatstressdays,1)),1));
        uslandgridpts=ones(52,94);uslandgridpts(tmp==0)=0;
        fracpeakhsdays=sum(sum(tmp))/(sum(sum(uslandgridpts))*((sep30doy-4)-(may1doy+4))*numyears);
    end
end



if make3hourlycompositesfortimeseries==1
    if reanalyzepeakheatstresstimesteps==1
        peakheatstresstimesteps=zeros(numyears,nummjjasdays,52,94);
        for reg=1:numregs
            thisrow=regcentralpt_rows(reg);thiscol=regcentralpt_cols(reg);
            for y=1:39
                for doy=may1doy+4:sep30doy-4
                    %Define peak heat-stress days based on criteria
                    if tw3hr_52x94(y,doy,lat,lon)>=twp95(lat,lon) %criterion (a)
                        if tw3hr_52x94(y,doy,lat,lon)>max(tw3hr_52x94(y,doy-3:doy-1,lat,lon)) && ...
                                tw3hr_52x94(y,doy,lat,lon)>max(tw3hr_52x94(y,doy+1:doy+3,lat,lon)) %criterion (b)
                            if min(tw3hr_52x94(y,doy-3:doy-1,lat,lon))<twp90(lat,lon) %criterion (c)
                                peakheatstresstimesteps(y,doy,lat,lon)=1;
                            end
                        end
                    end
                end
            end
        end
    end
end



if makedailycompositesformaps==1
    if makecomposites_part1==1
        cbyreg=zeros(7,1);
        for reg=1:7
            clear nationaltwgtp90_days;clear nationaltwgtp95_days;clear nationaltwgtp99_days;clear nationalar_days;
            for y=1:39 %1980-2018
                for doy=may1doy+4:sep30doy-4
                    dailypeakheatstressarray=squeeze(peakheatstressdays(y,doy,:,:));
                    
                    if regpeakheatstressdays(y,doy,reg)==1
                        %Criteria satisfied; do compositing
                        doyvec=[-4:4];
                        cbyreg(reg)=cbyreg(reg)+1;
                        for dayc=1:9
                            nationaltw_days(cbyreg(reg),:,:,dayc)=squeeze(tw_52x94(y,doy+doyvec(dayc),:,:));
                            nationaltwgtp90_days(cbyreg(reg),:,:,dayc)=squeeze(tw_52x94(y,doy+doyvec(dayc),:,:))>=twp90;
                            nationaltwgtp95_days(cbyreg(reg),:,:,dayc)=squeeze(tw_52x94(y,doy+doyvec(dayc),:,:))>=twp95;
                            nationaltwgtp99_days(cbyreg(reg),:,:,dayc)=squeeze(tw_52x94(y,doy+doyvec(dayc),:,:))>=twp99;
                            nationalar_days(cbyreg(reg),:,:,dayc)=squeeze(ar_52x94(y,doy+doyvec(dayc),:,:))==1;
                            saveddates_artwcomp(cbyreg(reg),1:2)=[y doy];
                        end
                    end
                end
            end
        end
        %Fraction of days that are reg peak heat-stress days
        %These range from 0.4% (SW) to 0.9% (NE)
        for reg=1:7
            fracregpeakhsdays(reg)=sum(sum(squeeze(regpeakheatstressdays(:,:,reg))))/(39*((sep30doy-4)-(may1doy+4)+1));
        end
    end
    
    if makecomposites_part2==1
        if strcmp(compositearrtype,'peakhs') %default
            setofdays=permute(regpeakheatstressdays,[2 3 1]);
            savesuffix='';
        elseif strcmp(compositearrtype,'hs')
            setofdays=permute(regheatstressdays,[2 3 1]);
            savesuffix='_nonpeak';
        else
            disp('Need help at line 2514!');return;
        end
        %NOTE: setofdays array needs to be of shape years x day of year x region
        
        firstoffsetday=-2;lastoffsetday=2;
        makecompositesofasetofdays;
    end
end



if makearonlycomposites==1
    %Make composites for AR days at regional central gridcells
    exist precip_52x94;
    if ans==0;tmp=load(strcat(dataresloc_external,'precip_merra2.mat'));precip_52x94=tmp.precip_52x94;end
    exist tivt_52x94;
    if ans==0;tmp=load(strcat(dataresloc_external,'ivt_merra2.mat'));tivt_52x94=tmp.tivt_52x94;end
    
    c=zeros(7,1);
    precipcomp=cell(7,1);tivtcomp=cell(7,1);z500anomscomp=cell(7,1);arprobcomp=cell(7,1);
    for reg=1:7
        i=regcentralpt_rows(reg);j=regcentralpt_cols(reg);
        for y=1:size(ar_52x94,1)
            for doy=may1doy:sep30doy
                if ar_52x94(y,doy,i,j)==1 %there is an AR at this gridcell on this date
                    c(reg)=c(reg)+1;
                    precipcomp{reg}(c(reg),:,:)=squeeze(precip_52x94(y,doy,:,:));
                    tivtcomp{reg}(c(reg),:,:)=squeeze(tivt_52x94(y,doy,:,:));
                    z500anomscomp{reg}(c(reg),:,:)=squeeze(z500anoms_52x94(y,doy,:,:));
                    arprobcomp{reg}(c(reg),:,:)=squeeze(ar_52x94(y,doy,:,:));
                end
            end
        end
        precipcomp_median(reg,:,:)=squeeze(median(precipcomp{reg}));
        tivtcomp_mean(reg,:,:)=squeeze(mean(tivtcomp{reg}));
        z500anomscomp_mean(reg,:,:)=squeeze(mean(z500anomscomp{reg}));
        arprobcomp_mean(reg,:,:)=squeeze(mean(arprobcomp{reg}));
    end

    %To be used in several supplemental figures
end



%Experiment if more insight can be achieved by splitting each region's MJJAS precipitation days into
%9 types -- terciles of both reg-mean precip and reg AR gridpt fraction -- and comparing the patterns assoc with each
if regionalquadrants==1
    if rqpart1==1
        exist precip_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'precip_era5.mat'));precip_52x94=tmp.precip_52x94;end
        clear arprecipquadrantnum_2;clear arprecipquadrantnum;clear tivtprecipquadrantnum_2;clear tivtprecipquadrantnum;
    
        for thisreg=1:7
            thisreg_precip=precip_52x94(:,:,thencaregions==thisreg+1);
            thisreg_tivt=tivt_52x94(:,:,thencaregions==thisreg+1);
            thisreg_ar=ar_52x94(:,:,thencaregions==thisreg+1);
            thisreg_extremetw=twabovep95(:,:,thencaregions==thisreg+1);
        
            %First, establish reg-mean precip amount, reg-mean tIVT, and reg AR gridpt fraction that defines each tercile of MJJAS days
            i=0;clear thisregprecipmeanbyday;clear thisregtivtmeanbyday;clear thisregargridptfraction;clear thisregextremetwgridptfraction;clear daytracker;
            for y=1:39
                for doy=may1doy:sep30doy
                    i=i+1;
                    thisregprecipmeanbyday(i)=mean(thisreg_precip(y,doy,:));
                    thisregtivtmeanbyday(i)=mean(thisreg_tivt(y,doy,:));
                    thisregargridptfraction(i)=sum(thisreg_ar(y,doy,:));
                    thisregextremetwgridptfraction(i)=sum(thisreg_extremetw(y,doy,:));
                    daytracker(i,:)=[y doy];
                end
            end
            thisreg_p67precipthresh=quantile(thisregprecipmeanbyday,0.67);
            thisreg_p33precipthresh=quantile(thisregprecipmeanbyday,0.33);

            thisreg_p67tivtthresh=quantile(thisregtivtmeanbyday,0.67);
            thisreg_p33tivtthresh=quantile(thisregtivtmeanbyday,0.33);

            nonzeroarfrac=thisregargridptfraction;invalid=thisregargridptfraction==0;nonzeroarfrac(invalid)=NaN;
            thisreg_p50argridptfrac_ofnonzerodays=quantile(nonzeroarfrac,0.5);

            nonzeroextremetwfrac=thisregextremetwgridptfraction;invalid=thisregextremetwgridptfraction==0;nonzeroextremetwfrac(invalid)=NaN;
            thisreg_p50extremetwgridptfrac_ofnonzerodays=quantile(nonzeroextremetwfrac,0.5);
        
            mycateg=zeros(39,sep30doy);regprecipfrac=zeros(39,sep30doy);regtivtfrac=zeros(39,sep30doy);regarfrac=zeros(39,sep30doy);regextremetwfrac=zeros(39,sep30doy);
            for y=1:39
                for doy=may1doy:sep30doy
                    %Determine reg precip fraction for this day
                    if mean(thisreg_precip(y,doy,:))>=thisreg_p67precipthresh
                        regprecipfrac(y,doy)=3;
                    elseif mean(thisreg_precip(y,doy,:))>=thisreg_p33precipthresh
                        regprecipfrac(y,doy)=2;
                    else
                        regprecipfrac(y,doy)=1;
                    end

                    %Determine reg tIVT fraction for this day
                    if mean(thisreg_tivt(y,doy,:))>=thisreg_p67tivtthresh
                        regtivtfrac(y,doy)=3;
                    elseif mean(thisreg_tivt(y,doy,:))>=thisreg_p33tivtthresh
                        regtivtfrac(y,doy)=2;
                    else
                        regtivtfrac(y,doy)=1;
                    end
        
                    %Determine reg AR-gridpt fraction for this day
                    if sum(thisreg_ar(y,doy,:))>=thisreg_p50argridptfrac_ofnonzerodays
                        regarfrac(y,doy)=3;
                    elseif sum(thisreg_ar(y,doy,:))>0
                        regarfrac(y,doy)=2;
                    else
                        regarfrac(y,doy)=1;
                    end

                    %Determine reg extreme-Tw gridpt fraction for this day
                    if sum(thisreg_extremetw(y,doy,:))>=thisreg_p50extremetwgridptfrac_ofnonzerodays
                        regextremetwfrac(y,doy)=3;
                    elseif sum(thisreg_extremetw(y,doy,:))>0
                        regextremetwfrac(y,doy)=2;
                    else
                        regextremetwfrac(y,doy)=1;
                    end
        
                    %Create 'quadrants' using these categorizations/terciles
                    %Precip is on y-axis, AR on x-axis
                    if regprecipfrac(y,doy)==3 && regarfrac(y,doy)==1 %1st row, 1st col
                        arprecipquadrantnum(y,doy)=1;
                    elseif regprecipfrac(y,doy)==3 && regarfrac(y,doy)==2 %1st row, 2nd col
                        arprecipquadrantnum(y,doy)=2;
                    elseif regprecipfrac(y,doy)==3 && regarfrac(y,doy)==3 %1st row, 3rd col
                        arprecipquadrantnum(y,doy)=3;
                    elseif regprecipfrac(y,doy)==2 && regarfrac(y,doy)==1 %2nd row, 1st col
                        arprecipquadrantnum(y,doy)=4;
                    elseif regprecipfrac(y,doy)==2 && regarfrac(y,doy)==2 %2nd row, 2nd col
                        arprecipquadrantnum(y,doy)=5;
                    elseif regprecipfrac(y,doy)==2 && regarfrac(y,doy)==3 %2nd row, 3rd col
                        arprecipquadrantnum(y,doy)=6;
                    elseif regprecipfrac(y,doy)==1 && regarfrac(y,doy)==1 %3rd row, 1st col
                        arprecipquadrantnum(y,doy)=7;
                    elseif regprecipfrac(y,doy)==1 && regarfrac(y,doy)==2 %3rd row, 2nd col
                        arprecipquadrantnum(y,doy)=8;
                    elseif regprecipfrac(y,doy)==1 && regarfrac(y,doy)==3 %3rd row, 3rd col
                        arprecipquadrantnum(y,doy)=9;
                    end

                    %Precip is on y-axis, tIVT on x-axis
                    if regprecipfrac(y,doy)==3 && regtivtfrac(y,doy)==1 %1st row, 1st col
                        tivtprecipquadrantnum(y,doy)=1;
                    elseif regprecipfrac(y,doy)==3 && regtivtfrac(y,doy)==2 %1st row, 2nd col
                        tivtprecipquadrantnum(y,doy)=2;
                    elseif regprecipfrac(y,doy)==3 && regtivtfrac(y,doy)==3 %1st row, 3rd col
                        tivtprecipquadrantnum(y,doy)=3;
                    elseif regprecipfrac(y,doy)==2 && regtivtfrac(y,doy)==1 %2nd row, 1st col
                        tivtprecipquadrantnum(y,doy)=4;
                    elseif regprecipfrac(y,doy)==2 && regtivtfrac(y,doy)==2 %2nd row, 2nd col
                        tivtprecipquadrantnum(y,doy)=5;
                    elseif regprecipfrac(y,doy)==2 && regtivtfrac(y,doy)==3 %2nd row, 3rd col
                        tivtprecipquadrantnum(y,doy)=6;
                    elseif regprecipfrac(y,doy)==1 && regtivtfrac(y,doy)==1 %3rd row, 1st col
                        tivtprecipquadrantnum(y,doy)=7;
                    elseif regprecipfrac(y,doy)==1 && regtivtfrac(y,doy)==2 %3rd row, 2nd col
                        tivtprecipquadrantnum(y,doy)=8;
                    elseif regprecipfrac(y,doy)==1 && regtivtfrac(y,doy)==3 %3rd row, 3rd col
                        tivtprecipquadrantnum(y,doy)=9;
                    end
                end
            end
        
            arprecipquadrantnum_2(:,:,thisreg)=arprecipquadrantnum; %so it's of shape years x day of year x region
            tivtprecipquadrantnum_2(:,:,thisreg)=tivtprecipquadrantnum; %so it's of shape years x day of year x region


            %Additionally, consolidate each array into a 3x3 box and add up
            %ARs and extreme Tw for each 'quadrant' (i.e. tercile combination)
            sums=zeros(3,3);savedargridptfracs{thisreg}=cell(3,3);savedextremetwgridptfracs{thisreg}=cell(3,3);
            corresprows=[1;1;1;2;2;2;3;3;3];correspcols=[1;2;3;1;2;3;1;2;3];
            for y=1:size(regprecipfrac,1)
                for doy=may1doy:sep30doy
                    thisquadr=tivtprecipquadrantnum(y,doy);
                    r=corresprows(thisquadr);c=correspcols(thisquadr);
                    sums(r,c)=sums(r,c)+1;
                    savedargridptfracs{thisreg}{r,c}(sums(r,c))=sum(thisreg_ar(y,doy,:))./sum(sum(thencaregions==thisreg+1));
                    savedextremetwgridptfracs{thisreg}{r,c}(sums(r,c))=sum(thisreg_extremetw(y,doy,:))./sum(sum(thencaregions==thisreg+1));
                end
            end

            for r=1:3
                for c=1:3
                    savedargridptfracs_means{thisreg}(r,c)=mean(savedargridptfracs{thisreg}{r,c});
                    savedextremetwgridptfracs_means{thisreg}(r,c)=mean(savedextremetwgridptfracs{thisreg}{r,c});
                end
            end
        end
        save(strcat(dataresloc_external,'quadrantsdata.mat'),'arprecipquadrantnum_2','tivtprecipquadrantnum_2','savedargridptfracs','savedextremetwgridptfracs','-append');
    end


    if rqpart2==1
        firstreg=4;lastreg=4;
        firstvar=1;lastvar=6;
        
        for thisreg=firstreg:lastreg
            for thisquad=1:3
                if thisquad==1 || thisquad==3 %the only ones we will be mapping
                    setofdays=arprecipquadrantnum_2;
                    invalid=arprecipquadrantnum_2~=thisquad;setofdays(invalid)=0;
                    tolookat=arprecipquadrantnum_2==thisquad;setofdays(tolookat)=1;
                    
                    firstoffsetday=-3;lastoffsetday=3;
                    saveoutput_makecompositespart2=0;
                    makecompositesofasetofdays;
            
                    meantwpctile{thisreg,thisquad}=squeeze(mean(twpctiles{thisreg}));
                    meanaroccurrences{thisreg,thisquad}=squeeze(mean(aroccurrences{thisreg}));
                    meantpctile{thisreg,thisquad}=squeeze(mean(tpctiles{thisreg}));
                    meanqpctile{thisreg,thisquad}=squeeze(mean(qpctiles{thisreg}));
                    meantivtpctile{thisreg,thisquad}=squeeze(mean(tivtpctiles{thisreg}));
                    meanprecippctile{thisreg,thisquad}=squeeze(mean(precippctiles{thisreg}));
        
                    disp(thisquad);disp(clock);
                end
            end
        end
        save(strcat(dataresloc_external,'quadrantsdata.mat'),'meantwpctile','meanaroccurrences','meantpctile','meanqpctile','meantivtpctile','meanprecippctile','-append');
    end
end


if prepforcontrastingobscases==1
    %Get distn of z500 anoms corresponding to observed humid heat,
    %then find a set of days with an identical z500 distn that did not see
    %humid heat, and finally composite the AR gridpt fractions of these two
    %contrasting cases

    %Uses reg heat-stress days (*no need for peak*)
    

    regheatstressdays=zeros(numyears,sep30doy,7);
    z500anomarray_byreg=NaN.*ones(numyears,sep30doy,7);
    z500anomsforregheatstressdays=cell(7,1);
    for reg=1:7
        c=0;
        for y=1:numyears
            for doy=may1doy:sep30doy
                todaysregmeantw=mean(tw_52x94(y,doy,thencaregions==reg+1));
                if todaysregmeantw>=regtwp95(reg)
                    regheatstressdays(y,doy,reg)=1;
                    c=c+1;
                    z500anomsforregheatstressdays{reg}(c)=mean(z500anoms_52x94(y,doy,thencaregions==reg+1));
                end
                z500anomarray_byreg(y,doy,reg)=mean(z500anoms_52x94(y,doy,thencaregions==reg+1));
            end
        end
    end

    %Days with similar z500 but without heat stress
    highz500noheatstressdays=zeros(41,273,7);
    for reg=1:7
        startat=round2(min(z500anomsforregheatstressdays{reg}),10,'floor');
        endat=round2(max(z500anomsforregheatstressdays{reg}),10,'ceil');
        for bin=1:(endat-startat)/10
            numinbin=sum(z500anomsforregheatstressdays{reg}<=startat+10*bin & z500anomsforregheatstressdays{reg}>startat+10*(bin-1));
            numfoundsofar=0;
            continueon=1;
            for y=1:size(tw_52x94,1)
                for doy=may1doy:sep30doy
                    todaysregmeanz500anom=z500anomarray_byreg(y,doy,reg);
                    todaysregmeantw=mean(tw_52x94(y,doy,thencaregions==reg+1));
                    if todaysregmeanz500anom<=startat+10*bin && todaysregmeanz500anom>startat+10*(bin-1) && todaysregmeantw<regtwp95(reg)
                        numfoundsofar=numfoundsofar+1;
                        highz500noheatstressdays(y,doy,reg)=1;

                        if numfoundsofar==numinbin;continueon=0;break;end
                    end
                end
                if continueon==0;break;end
            end
        end
    end

    save(strcat(dataresloc_external,'contrastingobscases.mat'),'regheatstressdays','z500anomsforregheatstressdays','highz500noheatstressdays');

    %Figure 2 contrasts these two sets of days, esp in terms of AR gridpt fraction
end


%Scatterplot of days, axes are Tw vs precip within 100-km radius and 1-day
%radius, dots colored by AR nearby or not
if comparetwprecip==1
    exist precip_52x94;if ans==0;tmp=load(strcat(dataresloc_external,'precip_era5.mat'));precip_52x94=tmp.precip_52x94;end
    
    for thisreg=1:numregs
        regc=0;clear twvec;clear precipvec;clear arvec;
        for i=1:52
            for j=1:94
                if i==regcentralpt_rows(thisreg) && j==regcentralpt_cols(thisreg)
                    for y=1:numyears
                        for doy=may1doy:sep30doy
                            regc=regc+1;
    
                            twvec(regc)=tw_52x94(y,doy,i,j);
                        
        
                            thisprecip=0;ptsfound=0;
                            for minii=max(1,i-5):min(52,i+5)
                                for minij=max(1,j-5):min(94,j+5)
                                    lat1=latarray(i,j);lat2=latarray(minii,minij);
                                    lon1=lonarray(i,j);lon2=lonarray(minii,minij);
                                    disttopt=sqrt(((lat1-lat2)^2+(lon1-lon2)^2)*cos((lat1*pi/180+lat2*pi/180)/2))*111;
                                    if disttopt<=100
                                        ptsfound=ptsfound+1;
                                        thisprecip=thisprecip+sum(precip_52x94(y,doy-1:doy+1,i,j));
                                    end
                                end
                            end
                            precipvec(regc)=thisprecip/ptsfound;
    
    
                            arvec(regc)=ar_52x94(y,doy,i,j);
                        end
                    end
                end
            end
        end
        invalid=precipvec<0;precipvec(invalid)=0;

        %Scatter with colors varying by AR status?
    
        %Based on this...
        numciles=3;clear ciles_x_upper;clear ciles_y_upper;
        for cile=1:numciles-1
            ciles_x_upper(cile)=quantile(twvec',cile/numciles);
            ciles_y_upper(cile)=quantile(precipvec',cile/numciles);
        end
        countsums=zeros(numciles,numciles);arsums=zeros(numciles,numciles);
        for i=1:size(twvec,2)
            foundyet=0;
            for tocheck=1:numciles-1
                if twvec(i)>=ciles_x_upper(tocheck)
                    mycol=tocheck+1;foundyet=1;
                end
            end
            if foundyet==0;mycol=1;end
    
            foundyet=0;
            for tocheck=1:numciles-1
                if precipvec(i)>=ciles_y_upper(tocheck)
                    myrow=tocheck+1;foundyet=1;
                end
            end
            if foundyet==0;myrow=1;end
    
            countsums(myrow,mycol)=countsums(myrow,mycol)+1;
            arsums(myrow,mycol)=arsums(myrow,mycol)+arvec(i);
        end
        chanceofbox=flipud(arsums./countsums);
        overallarprob=sum(sum(arsums))./sum(sum(countsums));
        relrisk_twprecip_ars{thisreg}=chanceofbox./overallarprob;

        %Actual figure is made in makesupplementalfigures.m
    end
end


if comparison_3hourly==1
    setofdays=peakheatstressdays;   
    
    makecompositesofasetofhours_3hourly;
end


if comparison_1hourly==1
    setofdays=peakheatstressdays;
    
    makecompositesofasetofhours_1hourly;
end

%Data are freely available from https://www.ncei.noaa.gov/products/land-based-station/integrated-surface-database
%Colin Raymond can also help here, if desired
if getstationprecipdata==1
    stnnames={'MSN';'YNG';'COU'}; %Madison WI; Youngstown OH; Columbia MO
    stnrows=[15;19;23];stncols=[58;72;53];
    stncodes={'726410-14837';'725250-14852';'724450-03945'};

    %Get station precip data (measured in inches)
    stationprecipvals={};
    for stn=1:size(stnnames,1)
        stationprecipvals{stn}=NaN.*ones(numyears,8760);
        for year=2012:2020
            fname=strcat('/Volumes/ExtDriveC/ISH_station_data/',num2str(year),'/',stncodes{stn},'-',num2str(year));
            fid=fopen(fname);
            tmp=fscanf(fid,'%c');
            %Search within string for hourly precip values
            hourinyear=1;
            for loc=1:size(tmp,2)-10
                if strcmp(tmp(loc:loc+10),'INCREMENTAL')
                    [stringshere,matches]=strsplit(tmp(loc:loc+170),{' ',':','\n','0T','1T','2T','3T','4T','5T','6T','7T','8T','9T'}); %want to split on all of these delimiters
                    origsize=size(stringshere,2);origindices=1:origsize;curindices=origindices;

                    if origsize>=29 %otherwise, skip
                        %Deal with situation where numeric and trace precip values are recorded without an intervening space
                        %(0.00T is a special case)
                        %Note that e.g. match #7 will go in spot #8 of stringshere
                        numreplaced=0;
                        for match=1:size(matches,2)
                            if strcmp(char(matches{match}),':')
                                startthisday=match;
                            elseif strcmp(strip(matches{match}),'0T')
                                for minii=origsize+numreplaced+1:-1:match+numreplaced+2
                                    stringshere{minii}=stringshere{minii-1}; %shift over to accommodate newly-found info
                                end
                                stringshere{match+numreplaced}='0.00';
                                stringshere{match+1+numreplaced}='0.005';
                                numreplaced=numreplaced+1;
                                curindices=curindices(find(curindices~=match+1));
                            end
                        end
                        for tackon=1:size(origindices,2)-size(curindices,2)
                            curindices(size(curindices,2)+1)=curindices(end)+1;
                        end
                        %Comparing origindices and curindices shows how the first version of stringshere was mapped to the present one
                        %Each insertion is found at the index of curindices where the difference between curindices and origindices increments by 1
        
                        lookfor={'1T';'2T';'3T';'4T';'5T';'6T';'7T';'8T';'9T'};
                        replacewith=[0.01;0.02;0.03;0.04;0.05;0.06;0.07;0.08;0.09];
                        for loop=1:9
                            for match=1:size(matches,2)
                                if strcmp(char(matches{match}),':')
                                    startthisday=match;
                                elseif strcmp(strip(matches{match}),lookfor{loop})
                                    newmatchpos=curindices(match);
                                    sz=size(stringshere,2);
                                    for minii=sz+1:-1:newmatchpos+2
                                        stringshere{minii}=stringshere{minii-1};
                                    end
                                    stringshere{newmatchpos}=num2str(replacewith(loop));stringshere{newmatchpos+1}='0.005';
                                end
                            end
                        end
        
                        for hrlater=0:23
                            if strcmp(stringshere{hrlater+5},'M') %missing
                                stationprecipvals{stn}(year-(defaultstartyear-1),hourinyear+hrlater)=NaN;
                            elseif strcmp(stringshere{hrlater+5},'T') %trace
                                stationprecipvals{stn}(year-(defaultstartyear-1),hourinyear+hrlater)=0.005;
                            elseif size(stringshere{hrlater+5},2)>=10
                                stationprecipvals{stn}(year-(defaultstartyear-1),hourinyear+hrlater)=-99;
                            else %actual good data
                                stationprecipvals{stn}(year-(defaultstartyear-1),hourinyear+hrlater)=str2double(stringshere{hrlater+5});
                            end
                        end
                    end
                    hourinyear=hourinyear+24;
                end
            end

            invalid=stationprecipvals{stn}<0;stationprecipvals{stn}(invalid)=NaN;
            for hr=24:24:8784
                stationprecipvals_daily{stn}(year-(defaultstartyear-1),hr/24)=sum(stationprecipvals{stn}(year-(defaultstartyear-1),hr-23:hr));
            end
            fprintf('Completed year %d for station-precip-gathering\n',year);
        end
    end
    %NOTE THAT DATA ARE STILL IN INCHES AT THIS POINT, TO FACILITATE COMPARISON AGAINST REPORTED NUMBERS FROM OTHER US SOURCES
    save(strcat(dataresloc_external,'stationprecipdata.mat'),'stationprecipvals','stationprecipvals_daily','-append');
end




%Data saved is 1-hourly and in UTC
if regularizestationprecipdata==1
    %columbia mo; indianapolis in; saginaw mi; madison wi; peoria il; sioux
    %city ia; youngstown oh; minneapolis mn; green bay wi; chicago il;
    %grand rapids mi
    reg=5;
    stncodes={'COU';'IND';'MBS';'MSN';'PIA';'SUX';'YNG';'MSP';'GRB';'ORD';'GRR'};
    stnlats=[38.95;39.77;43.42;43.07;40.69;42.5;41.1;44.98;44.51;41.88;42.96];stnlons=[-92.33;-86.16;-83.95;-89.4;-89.59;-96.4;-80.65;-93.27;-88.01;-87.63;-85.67];
    stnordsinhadisd=[3506;3499;3740;3746;3631;3671;3620;3770;3752;3635;3734]; %using stationdatafinder_ohaupdate.m
    for stn=1:size(stncodes,1)
        mindist=10^6;
        for i=1:52
            for j=1:94
                thisdist=sqrt((latarray(i,j)-stnlats(stn))^2+((lonarray(i,j)-360)-stnlons(stn))^2);
                if thisdist<mindist;mindist=thisdist;mini=i;minj=j;end
            end
        end
        stnrows(stn)=mini;stncols(stn)=minj;

    

        tmp=load(strcat(dataresloc_external,'bigpctilemap_1hrdata_',stncodes{stn}));datesinsetofdays=tmp.datesinsetofdays;testarr=NaN.*ones(size(datesinsetofdays{reg},1),4);
        for i=1:size(datesinsetofdays{reg},1)
            testarr(i,1)=datesinsetofdays{reg}(i,1)+1979;
            testarr(i,2)=DOYtoMonth_heatars(datesinsetofdays{reg}(i,2),testarr(i,1));
            testarr(i,3)=DOYtoDOM_heatars(datesinsetofdays{reg}(i,2),testarr(i,1));
            testarr(i,4)=datesinsetofdays{reg}(i,3);
        end
    end

    row=0;
    ncarprecipdata_humidheat=NaN.*ones(1,hourstogoout*2+1);ncarprecipdata_humidheat_locanddates=NaN.*ones(1,hourstogoout*2+1,4);
    mjjaspreciphoursdiurnal=[];numhourswithgooddata=[];meanpreciplikelihood=[];
    for stn=1:size(stncodes,1)
        f=load(strcat(icloud,'General_Academics/Research/Polished_Datasets/US_Hourly_Precip/ncarprecipdata_',stncodes{stn},'.mat'));
        ncarprecipgaugedata=f.ncarprecipgaugedata;
        ncarprecipgaugedata=ncarprecipgaugedata.*25.4; %convert from inches to mm

        %Convert from 1-hourly to 3-hourly
        ncarprecipgaugedata_3hourly=NaN.*ones(41,366,8,5); %1980-2020
        for hr=3:3:24
            ncarprecipgaugedata_3hourly(:,:,hr/3,:)=sum(ncarprecipgaugedata(:,:,hr-2:hr,:),3,'omitnan');
        end

        %Get mean likelihood of MJJAS precip at each 3-hour interval,
        %weighted to match hour distribution of humid-heat events
        %Pull 100x more in each case
        newarr=[];prarr=[];c=0;
        for hr=1:24
            numhumidheatthishr=sum(testarr(:,4)==hr);
            for idx=1:numhumidheatthishr*100
                c=c+1;
                randyear=randi([2000,2020]);
                randdoy=randi([may1doy,sep30doy]);
                if ncarprecipgaugedata(randyear-1979,randdoy,hr,5)>=0.1 %precip this hr
                    prarr(c)=1;
                elseif isnan(ncarprecipgaugedata(randyear-1979,randdoy,hr,5))
                    prarr(c)=NaN;
                end
            end
        end
        numhourswithgooddata=squeeze(sum(sum(~isnan(ncarprecipgaugedata_3hourly(:,may1doy:sep30doy,:,5)))));
        meanpreciplikelihood(stn)=sum(prarr,'omitnan')./sum(~isnan(prarr));


        %Get station precip data specifically around humid-heat events
        for i=1:size(testarr,1)
            year=testarr(i,1);
            if year>=2000
                coredoy=DatetoDOY_heatars(testarr(i,2),testarr(i,3),testarr(i,1));
                corehr=testarr(i,4);

                row=row+1;
        
                daychanged=1;
        
                negoffset=-1*hourstogoout;posoffset=hourstogoout;
                for relhr=negoffset:posoffset
                    %Get hour & day
                    doy=coredoy;
                    hr=corehr+relhr;
                    if hr<1 %move back a day
                        doy=doy-1;hr=hr+24;daychanged=1;
                    elseif hr>24 %move forward a day
                        doy=doy+1;hr=hr-24;daychanged=1;
                    end
                    
                    ncarprecipdata_humidheat(row,relhr+posoffset+1)=ncarprecipgaugedata(year-1979,doy,hr,5);
                    ncarprecipdata_humidheat_locanddates(row,relhr+posoffset+1,:)=[stn year doy hr];
                end
            end
        end
    end

    %Convert precip likelihoods from 1-hourly to 3-hourly
    clear ncarprecipdata_humidheat_3hourly;
    hrc=0;
    for hr=1:3:hourstogoout*2+1
        hrc=hrc+1;
        if hr==1 || hr==hourstogoout*2+1
            ncarprecipdata_humidheat_3hourly(:,hrc)=squeeze(sum(ncarprecipdata_humidheat(:,hr),2,'omitnan'));
        else
            ncarprecipdata_humidheat_3hourly(:,hrc)=squeeze(sum(ncarprecipdata_humidheat(:,hr-1:hr+1),2,'omitnan'));
        end
    end

    %Get mean precip likelihood surrounding humid heat
    ncarprecipdata_humidheat_3hourly_mean=mean(ncarprecipdata_humidheat_3hourly>=0.3,'omitnan');

    %Get mean precip likelihood in general (i.e. not diurnally varying)
    mpl=mean(meanpreciplikelihood);

    %Finally, get relative likelihood of humid heat
    ncarprecipdata_humidheat_3hourly_rellikelihood=ncarprecipdata_humidheat_3hourly_mean./mpl;

    figure(80);plot(ncarprecipdata_humidheat_3hourly_rellikelihood);
    figure(81);imagescnan_heatars(ncarprecipdata_humidheat_3hourly>=0.3);
end





clear lattemp;clear lontemp;
clear thisprecip;