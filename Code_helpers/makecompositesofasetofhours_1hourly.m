%This is a helper script that should be called from within the
%comparison_1hourly loop of heatars_mainanalysis
%Gets MERRA2 data (*not* station data itself)


exist tw1hr_52x94;
if ans==0
    tmp=load(strcat(dataresloc_external,'heat_merra2_1hr.mat'));
    tw1hr_52x94=tmp.tw1hr_52x94;
    t1hr_52x94=tmp.t1hr_52x94;
    td1hr_52x94=tmp.td1hr_52x94;
end
exist ar6hr_52x94;
if ans==0
    tmp=load(strcat(dataresloc_external,'ardata_merra2.mat'));
    ar6hr_52x94=tmp.ar6hr_52x94;

    %Create a 1-hourly version of the AR array by simply spacing out the 6-hourly data
    ar1hr_52x94=NaN.*ones(size(ar6hr_52x94,1),size(ar6hr_52x94,2),24,52,94);
    for hr=1:4
        ar1hr_52x94(:,:,hr*6,:,:)=ar6hr_52x94(:,:,hr,:,:);
    end
end

for varloop=firstvar_1hourly:lastvar_1hourly
    if varloop==1 || varloop==6 %1 and 6 are all that's needed for the paper

    if varloop==1 %Tw
        tw1hrpctiles=cell(7,1);temp_52x94=tw1hr_52x94-273.15;
    elseif varloop==2 %AR
        ar1hroccurrences=cell(7,1);temp_52x94=ar1hr_52x94;
    elseif varloop==3 %T
        t1hrpctiles=cell(7,1);temp_52x94=t_52x94-273.15;
    elseif varloop==4 %q
        q1hrpctiles=cell(7,1);temp_52x94=td_52x94;
    elseif varloop==5 %tIVT
        tmp=load(strcat(dataresloc_external,'ivt1hr_merra2.mat'));temp_52x94=tmp.tivt1hr_52x94;
        tivt1hrpctiles=cell(7,1);
    elseif varloop==6 %precip
        tmp=load(strcat(dataresloc_external,'precip1hr_merra2.mat'));temp_52x94=tmp.precip1hr_52x94;
        precip1hrpctiles=cell(7,1);precip1hroccurrences=cell(7,1);
        tmp=load(strcat(dataresloc_external,'precip1hr_era5land.mat'));temp_era5land_52x94=tmp.precip1hr_era5land_52x94;

        %Need to set minimal precip values to 0 to get statistics that are meaningful
        invalid=temp_52x94<wethourthresh;temp_52x94(invalid)=0;
        invalid=temp_era5land_52x94<wethourthresh;temp_era5land_52x94(invalid)=0;
    elseif varloop==7 %evap
        tmp=load(strcat(dataresloc_external,'evap_merra2.mat'));temp_52x94=tmp.evap_52x94;
        evap1hrpctiles=cell(7,1);
    elseif varloop==8 %net shortwave
        tmp=load(strcat(dataresloc_external,'netshortwave_merra2.mat'));temp_52x94=tmp.netshortwave_52x94;
        netsw1hrpctiles=cell(7,1);
    elseif varloop==9 %net longwave
        tmp=load(strcat(dataresloc_external,'netlongwave_merra2.mat'));temp_52x94=tmp.netlongwave_52x94;
        netlw1hrpctiles=cell(7,1);
    elseif varloop==10 %top-level sm
        tmp=load(strcat(dataresloc_external,'toplevelsm_merra2.mat'));temp_52x94=tmp.toplevelsm_52x94;
        toplevelsm1hrpctiles=cell(7,1);
    elseif varloop==11 %z500
        tmp=load(strcat(dataresloc_external,'z500_merra2.mat'));temp_52x94=tmp.z500_52x94;
        z5001hrpctiles=cell(7,1);
    elseif varloop==12 %omega500
        tmp=load(strcat(dataresloc_external,'omega500_merra2.mat'));temp_52x94=tmp.omega500_52x94;
        omega5001hrpctiles=cell(7,1);
    end

    dim1sz=size(temp_52x94,1);
    
    timestepoffsets_1hr=firstoffsettimestep_1hr:lastoffsettimestep_1hr;
    datesinsetofdays=cell(numregs,1);
    %This loop gets MERRA2 data for the gridcell closest to select stations
    %As a reminder, these stations are set in the regularizestationprecipdataUPDATED loop of heatars_mainanalysis
    for reg=5:5
        for stn=1:size(stncodes,1)
            temppctiles=[];
            c=0;
            precip1hrpctiles_era5land=[];precip1hroccurrences_era5land=[];
            
            thisrow=stnrows(stn);
            thiscol=stncols(stn);
            for y=1:size(setofdays,1) %number of years
                for doy=may1doy+4:sep30doy-4
                    if setofdays(y,doy,thisrow,thiscol)==1 %if this is a day of interest
                        %Composite this day -- get its percentiles at each point across the US
                        %For ARs, get occurrences at each point and divide by regional-mean frequency
                        c=c+1;
                        datesinsetofdays{reg}(c,1)=y;datesinsetofdays{reg}(c,2)=doy;
    
                        temppctiles(c,:,:,:)=NaN.*ones(52,94,size(timestepoffsets_1hr,2));
                        if varloop==6;precip1hrpctiles_era5land(c,:,:,:)=NaN.*ones(52,94,size(timestepoffsets_1hr,2));end
    
    
                        %We know this is a peak heat-stress day of interest...
                        %but when does the peak actually occur?
                        thisdayvals=squeeze(tw1hr_52x94(y,doy,:,thisrow,thiscol));
                        [~,maxhr]=max(thisdayvals);
                        datesinsetofdays{reg}(c,3)=maxhr;
    
                        curhr=maxhr;curday=doy;
                        clear hrsaver;clear doysaver;
                        %Go back 24 hours from the peak-Tw hour, recording the days and hours
                        for mini_ts=25:-1:1
                            hrsaver(mini_ts,1)=curhr;
                            doysaver(mini_ts,1)=curday;
                            curhr=curhr-1;
                            if curhr==0;curhr=curhr+24;curday=curday-1;end
                        end
                        curhr=maxhr;curday=doy;
                        for mini_ts=25:1:49 %also go forward a full 24 hours
                            hrsaver(mini_ts,1)=curhr;
                            doysaver(mini_ts,1)=curday;
                            curhr=curhr+1;
                            if curhr==25;curhr=curhr-24;curday=curday+1;end
                        end
                        %%%%
    
                        %Get variable values, accounting for the daily cycle (so e.g. the situation at 8am can be fairly assessed and not overlooked in favor of the afternoon), 
                        %but ignoring the seasonal one for simplicity
                        for ts_count=1:size(timestepoffsets_1hr,2)
                            doy_incloffset=doysaver(-1*firstoffsettimestep_1hr+1+timestepoffsets_1hr(ts_count)); %i.e. if firstoffsettimestep_1hr=-24, the 25th element of doysaver and hrsaver is the peak-Tw hour
                            hr_incloffset=hrsaver(-1*firstoffsettimestep_1hr+1+timestepoffsets_1hr(ts_count));
                            for i=1:52
                                for j=1:94
                                    if varloop~=2 %everything but ARs
                                        temppctiles(c,i,j,ts_count)=...
                                            pctreltodistn_heatars(reshape(temp_52x94(:,may1doy:sep30doy,hr_incloffset,i,j),[dim1sz*nummjjasdays 1]),temp_52x94(y,doy_incloffset,hr_incloffset,i,j));
                                    end
    
                                    %Do special stuff for ARs and precip; also prepare to get relative likelihoods
                                    if varloop==2 && rem(ts_count-1,3)==0 %because we don't have any actual 3-hourly AR data
                                        ar1hroccurrences{reg}(c,i,j,ts_count)=temp_52x94(y,doy_incloffset,hr_incloffset,i,j);
                                    elseif varloop==6 %precip
                                        if temp_52x94(y,doy_incloffset,hr_incloffset,i,j)>=wethourthresh %i.e. 0.1 mm = a precip hour ("wet")
                                            precip1hroccurrences{reg}(c,i,j,ts_count)=1;
                                        else
                                            precip1hroccurrences{reg}(c,i,j,ts_count)=0;
                                        end
    
                                        %For precip, also get ERA5-Land value,
                                        %defining both pctiles and occurrences
                                        precip1hrpctiles_era5land(c,i,j,ts_count)=...
                                            pctreltodistn_heatars(reshape(temp_era5land_52x94(:,may1doy:sep30doy,hr_incloffset,i,j),[dim1sz*nummjjasdays 1]),...
                                            temp_era5land_52x94(y,doy_incloffset,hr_incloffset,i,j));
                                        
                                        if temp_era5land_52x94(y,doy_incloffset,hr_incloffset,i,j)>=wethourthresh %i.e. 0.1 mm = a precip hour ("wet")
                                            precip1hroccurrences_era5land(c,i,j,ts_count)=1;
                                        else
                                            precip1hroccurrences_era5land(c,i,j,ts_count)=0;
                                        end
                                    end
                                    
                                end
                            end
                        end
                    end
                end
            end
    
    
            if varloop==1;tw1hrpctiles=temppctiles;elseif varloop==3;t1hrpctiles=temppctiles;...
            elseif varloop==4;q1hrpctiles=temppctiles;elseif varloop==5;tivt1hrpctiles=temppctiles;...
            elseif varloop==6;precip1hrpctiles=temppctiles;elseif varloop==7;evap1hrpctiles=temppctiles;elseif varloop==8;netsw1hrpctiles=temppctiles;...
            elseif varloop==9;netlw1hrpctiles=temppctiles;elseif varloop==10;toplevelsm1hrpctiles=temppctiles;elseif varloop==11;z5001hrpctiles=temppctiles;...
            elseif varloop==12;omega5001hrpctiles=temppctiles;
            end
        
            if varloop==2
                %Really only have AR data for hours 6, 12, 18, 24
                meanar1hrfreq=zeros(24,52,94);
                for hr=6:6:24
                    meanar1hrfreq(hr,:,:)=squeeze(sum(reshape(temp_52x94(:,may1doy:sep30doy,hr,:,:),[dim1sz*nummjjasdays 52 94]))/(dim1sz*nummjjasdays));
                end
            elseif varloop==6
                overallprecipoccurrence=temp_52x94(:,may1doy:sep30doy,:,:,:)>=wethourthresh;
                precip1hrmeanlikelihood=squeeze(mean(reshape(overallprecipoccurrence,[size(overallprecipoccurrence,1)*(sep30doy-may1doy+1) 24 52 94]))); %24 is because there are 24 hours in a day..
        
                overallprecipoccurrence_era5land=temp_era5land_52x94(:,may1doy:sep30doy,:,:,:)>=wethourthresh;
                precip1hrmeanlikelihood_era5land=squeeze(mean(reshape(overallprecipoccurrence_era5land,[numyears*(sep30doy-may1doy+1) 24 52 94])));
            end
            
            if saveoutput_make1hourlycomposites==1
                fname=strcat(dataresloc_external,'bigpctilemap_1hrdata_',stncodes{stn},'.mat');
                if varloop==1
                    if isfile(fname);save(fname,'tw1hrpctiles','-append');else;save(fname,'tw1hrpctiles');end
                elseif varloop==2
                    if isfile(fname);save(fname,'ar1hroccurrences','meanar1hrfreq','-append');else;save(fname,'ar1hroccurrences','meanar1hrfreq');end
                elseif varloop==3
                    if isfile(fname);save(fname,'t1hrpctiles','-append');else;save(fname,'t1hrpctiles');end;clear t1hrpctiles;
                elseif varloop==4
                    if isfile(fname);save(fname,'q1hrpctiles','-append');else;save(fname,'q1hrpctiles');end;clear q1hrpctiles;
                elseif varloop==5
                    if isfile(fname);save(fname,'tivt1hrpctiles','-append');else;save(fname,'tivt1hrpctiles');end;clear tivt1hrpctiles;
                elseif varloop==6
                    if isfile(fname);save(fname,'precip1hrpctiles','precip1hroccurrences','precip1hrmeanlikelihood','-append');
                    else;save(fname,'precip1hrpctiles','precip1hroccurrences','precip1hrmeanlikelihood');
                    end
                    if isfile(fname);save(fname,'precip1hrpctiles_era5land','precip1hroccurrences_era5land','precip1hrmeanlikelihood_era5land','-append');
                    else;save(fname,'precip1hrpctiles_era5land','precip1hroccurrences_era5land','precip1hrmeanlikelihood_era5land');
                    end
                    clear precip1hrpctiles;clear precip1hrpctiles_era5land;
                elseif varloop==7
                    if isfile(fname);save(fname,'evap1hrpctiles','-append');else;save(fname,'evap1hrpctiles');end;clear evap1hrpctiles;
                elseif varloop==8
                    if isfile(fname);save(fname,'netsw1hrpctiles','-append');else;save(fname,'netsw1hrpctiles');end
                elseif varloop==9
                    if isfile(fname);save(fname,'netlw1hrpctiles','-append');else;save(fname,'netlw1hrpctiles');end
                elseif varloop==10
                    if isfile(fname);save(fname,'toplevelsm1hrpctiles','-append');else;save(fname,'toplevelsm1hrpctiles');end
                elseif varloop==11
                    if isfile(fname);save(fname,'z5001hrpctiles','-append');else;save(fname,'z5001hrpctiles');end
                elseif varloop==12
                    if isfile(fname);save(fname,'omega5001hrpctiles','-append');else;save(fname,'omega5001hrpctiles');end
                end
                save(strcat(dataresloc_external,'bigpctilemap_1hrdata_',stncodes{stn},'.mat'),'datesinsetofdays','-append');
            end
            fprintf('Just completed variable %d in makecompositesofasetofhours_1hourly\n',varloop);
        end
    end
    end
end
