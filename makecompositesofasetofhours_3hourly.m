exist tw3hr_52x94;
if ans==0
    tmp=load(strcat(dataresloc_external,'heat_merra2_3hr.mat'));
    tw3hr_52x94=tmp.tw3hr_52x94;
    t3hr_52x94=tmp.t3hr_52x94;
    td3hr_52x94=tmp.td3hr_52x94;
end
exist ar6hr_52x94;
if ans==0
    tmp=load(strcat(dataresloc_external,'ardata_merra2.mat'));
    ar6hr_52x94=tmp.ar6hr_52x94;

    %Create an interpolated 3-hourly AR array (ONLY EVEN TIMESTEPS, I.E. ORIG DATA, ARE ACTUALLY USED)
    ar3hr_52x94=NaN.*ones(size(ar6hr_52x94,1),size(ar6hr_52x94,2),8,52,94);
    for hr=1:8
        if rem(hr,2)==0
            ar3hr_52x94(:,:,hr,:,:)=ar6hr_52x94(:,:,hr/2,:,:);
        elseif hr==3 || hr==5 || hr==7
            ar3hr_52x94(:,:,hr,:,:)=(ar6hr_52x94(:,:,hr/2-0.5,:,:)+ar6hr_52x94(:,:,hr/2+0.5,:,:))/2;
        elseif hr==1
            for doy=2:365
                ar3hr_52x94(:,doy,1,:,:)=(ar6hr_52x94(:,doy-1,4,:,:)+ar6hr_52x94(:,doy,1,:,:))/2;
            end
            %doy=1
            ar3hr_52x94(2:numyears,1,1,:,:)=(ar6hr_52x94(1:numyears-1,365,4,:,:)+ar6hr_52x94(2:numyears,1,1,:,:))/2;
        end
    end
end

for varloop=firstvar_3hourly:lastvar_3hourly
    if varloop==1 || varloop==6 %the only ones allowed right now

    if varloop==1 %Tw
        tw3hrpctiles=cell(7,1);temp_52x94=tw3hr_52x94-273.15;
    elseif varloop==2 %AR
        ar3hroccurrences=cell(7,1);temp_52x94=ar3hr_52x94;
    elseif varloop==3 %T
        t3hrpctiles=cell(7,1);temp_52x94=t_52x94-273.15;
    elseif varloop==4 %q
        q3hrpctiles=cell(7,1);temp_52x94=td_52x94;
    elseif varloop==5 %tIVT
        tmp=load(strcat(dataresloc_external,'ivt3hr_merra2.mat'));temp_52x94=tmp.tivt3hr_52x94;
        tivt3hrpctiles=cell(7,1);
    elseif varloop==6 %precip
        tmp=load(strcat(dataresloc_external,'precip3hr_merra2.mat'));temp_52x94=tmp.precip3hr_52x94;
        precip3hrpctiles=cell(7,1);precip3hroccurrences=cell(7,1);
        tmp=load(strcat(dataresloc_external,'precip3hr_era5land.mat'));temp_era5land_52x94=tmp.precip3hr_era5land_52x94;
        precip3hrpctiles_era5land=cell(7,1);precip3hroccurrences_era5land=cell(7,1);

        %Need to set minimal precip values to 0 to get statistics that are meaningful
        invalid=temp_52x94<wethourthresh;temp_52x94(invalid)=0;
        invalid=temp_era5land_52x94<wethourthresh;temp_era5land_52x94(invalid)=0;
    elseif varloop==7 %evap
        tmp=load(strcat(dataresloc_external,'evap_merra2.mat'));temp_52x94=tmp.evap_52x94;
        evap3hrpctiles=cell(7,1);
    elseif varloop==8 %net shortwave
        tmp=load(strcat(dataresloc_external,'netshortwave_merra2.mat'));temp_52x94=tmp.netshortwave_52x94;
        netsw3hrpctiles=cell(7,1);
    elseif varloop==9 %net longwave
        tmp=load(strcat(dataresloc_external,'netlongwave_merra2.mat'));temp_52x94=tmp.netlongwave_52x94;
        netlw3hrpctiles=cell(7,1);
    elseif varloop==10 %top-level sm
        tmp=load(strcat(dataresloc_external,'toplevelsm_merra2.mat'));temp_52x94=tmp.toplevelsm_52x94;
        toplevelsm3hrpctiles=cell(7,1);
    elseif varloop==11 %z500
        tmp=load(strcat(dataresloc_external,'z500_merra2.mat'));temp_52x94=tmp.z500_52x94;
        z5003hrpctiles=cell(7,1);
    elseif varloop==12 %omega500
        tmp=load(strcat(dataresloc_external,'omega500_merra2.mat'));temp_52x94=tmp.omega500_52x94;
        omega5003hrpctiles=cell(7,1);
    end

    dim1sz=size(temp_52x94,1);
    cbyreg=zeros(numregs,1);
    temppctiles=cell(numregs,1);
    
    datesinsetofdays=cell(numregs,1);
    for reg=5:5
        thisrow=regcentralpt_rows(reg);
        thiscol=regcentralpt_cols(reg);
        for y=1:size(setofdays,1) %number of years
            for doy=may1doy+4:sep30doy-4
                if setofdays(y,doy,thisrow,thiscol)==1 %if this is a day of interest
                    %Composite this day -- get its percentiles at each point across the US
                    %For ARs, get occurrences at each point and divide by regional-mean frequency
                    cbyreg(reg)=cbyreg(reg)+1;
                    datesinsetofdays{reg}(cbyreg(reg),1)=y;datesinsetofdays{reg}(cbyreg(reg),2)=doy;

                    temppctiles{reg}(cbyreg(reg),:,:,:)=NaN.*ones(52,94,size(timestepoffsets_3hr,2));
                    if varloop==6;precip3hrpctiles_era5land{reg}(cbyreg(reg),:,:,:)=NaN.*ones(52,94,size(timestepoffsets_3hr,2));end

                    %We know this is a peak heat-stress day of interest...
                    %but when does the peak actually occur?
                    thisdayvals=squeeze(tw3hr_52x94(y,doy,:,thisrow,thiscol));
                    [~,maxts]=max(thisdayvals);
                    curhr=maxts;curday=doy;
                    clear hrsaver;clear doysaver;
                    for mini_ts=9:-1:1 %go out a full 24 hours (8 timesteps) on either side, in case these data are needed
                        hrsaver(mini_ts,1)=curhr;
                        doysaver(mini_ts,1)=curday;
                        curhr=curhr-1;
                        if curhr==0;curhr=curhr+8;curday=curday-1;end
                    end
                    curhr=maxts;curday=doy;
                    for mini_ts=9:1:17 %second part
                        hrsaver(mini_ts,1)=curhr;
                        doysaver(mini_ts,1)=curday;
                        curhr=curhr+1;
                        if curhr==9;curhr=curhr-8;curday=curday+1;end
                    end
                    %%%%


                    %Account for daily cycle (so e.g. 8am can be fairly assessed against 4pm), but ignore seasonal one for simplicity
                    for ts_count=1:size(timestepoffsets_3hr,2)
                        continueon=0;
                        if ts_count==2 || ts_count==3 || ts_count==4 || ts_count==6 %only do these in the 'all timesteps' case
                            if strcmp(timestepstodo,'all');continueon=1;end
                        else
                            continueon=1;
                        end

                        if continueon==1
                            doy_incloffset=doysaver(9+timestepoffsets_3hr(ts_count));
                            hr_incloffset=hrsaver(9+timestepoffsets_3hr(ts_count));
                            for i=1:52
                                for j=1:94
                                    if varloop~=2 %everything but ARs
                                        temppctiles{reg}(cbyreg(reg),i,j,ts_count)=...
                                            pctreltodistn_heatars(reshape(temp_52x94(:,may1doy:sep30doy,hr_incloffset,i,j),[dim1sz*nummjjasdays 1]),temp_52x94(y,doy_incloffset,hr_incloffset,i,j));
                                    end

                                    %Do special stuff for ARs and precip; also prepare to get relative likelihoods
                                    if varloop==2 && ts_count~=8 %no actual 3-hourly AR data
                                        ar3hroccurrences{reg}(cbyreg(reg),i,j,ts_count)=temp_52x94(y,doy_incloffset,hr_incloffset,i,j);
                                    elseif varloop==6
                                        if temp_52x94(y,doy_incloffset,hr_incloffset,i,j)>=0.0001 %i.e. 0.1 mm = a precip hour ("wet")
                                            precip3hroccurrences{reg}(cbyreg(reg),i,j,ts_count)=1;
                                        else
                                            precip3hroccurrences{reg}(cbyreg(reg),i,j,ts_count)=0;
                                        end

                                        %For precip, also get ERA5-Land value,
                                        %defining both pctiles and occurrences
                                        precip3hrpctiles_era5land{reg}(cbyreg(reg),i,j,ts_count)=...
                                            pctreltodistn_heatars(reshape(temp_era5land_52x94(:,may1doy:sep30doy,hr_incloffset,i,j),[dim1sz*nummjjasdays 1]),...
                                            temp_era5land_52x94(y,doy_incloffset,hr_incloffset,i,j));
                                        
                                        if temp_era5land_52x94(y,doy_incloffset,hr_incloffset,i,j)>=wethourthresh %i.e. 0.1 mm = a precip hour ("wet")
                                            precip3hroccurrences_era5land{reg}(cbyreg(reg),i,j,ts_count)=1;
                                        else
                                            precip3hroccurrences_era5land{reg}(cbyreg(reg),i,j,ts_count)=0;
                                        end
                                    end
                                    
                                end
                            end
                            datesinsetofdays{reg}(cbyreg(reg),3)=hr_incloffset;
                        end
                    end
                end
            end
        end
    end


    if varloop==1;tw3hrpctiles=temppctiles;elseif varloop==3;t3hrpctiles=temppctiles;...
    elseif varloop==4;q3hrpctiles=temppctiles;elseif varloop==5;tivt3hrpctiles=temppctiles;...
    elseif varloop==6;precip3hrpctiles=temppctiles;elseif varloop==7;evap3hrpctiles=temppctiles;elseif varloop==8;netsw3hrpctiles=temppctiles;...
    elseif varloop==9;netlw3hrpctiles=temppctiles;elseif varloop==10;toplevelsm3hrpctiles=temppctiles;elseif varloop==11;z5003hrpctiles=temppctiles;...
    elseif varloop==12;omega5003hrpctiles=temppctiles;
    end

    if varloop==2
        %Really only have AR data for hours 6, 12, 18, 24 (timesteps 2, 4, 6, 8)
        meanar3hrfreq=zeros(8,52,94);
        for hr=2:2:8
            meanar3hrfreq(hr,:,:)=squeeze(sum(reshape(temp_52x94(:,may1doy:sep30doy,hr,:,:),[dim1sz*nummjjasdays 52 94]))/(dim1sz*nummjjasdays));
        end
    elseif varloop==6
        overallprecipoccurrence=temp_52x94(:,may1doy:sep30doy,:,:,:)>=wethourthresh;
        precip3hrmeanlikelihood=squeeze(mean(reshape(overallprecipoccurrence,[numyears*(sep30doy-may1doy+1) 8 52 94])));

        overallprecipoccurrence_era5land=temp_era5land_52x94(:,may1doy:sep30doy,:,:,:)>=wethourthresh;
        precip3hrmeanlikelihood_era5land=squeeze(mean(reshape(overallprecipoccurrence_era5land,[numyears*(sep30doy-may1doy+1) 8 52 94])));
    end
    
    if saveoutput_make3hourlycomposites==1
        if varloop==1
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'tw3hrpctiles','-append');
        elseif varloop==2
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'ar3hroccurrences','meanar3hrfreq','-append');
        elseif varloop==3
           save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'t3hrpctiles','-append');clear t3hrpctiles;
        elseif varloop==4
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'q3hrpctiles','-append');clear q3hrpctiles;
        elseif varloop==5
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'tivt3hrpctiles','-append');clear tivt3hrpctiles;
        elseif varloop==6
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'precip3hrpctiles','precip3hroccurrences','precip3hrmeanlikelihood','-append');
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),...
                'precip3hrpctiles_era5land','precip3hroccurrences_era5land','precip3hrmeanlikelihood_era5land','-append');
            clear precip3hrpctiles;clear precip3hrpctiles_era5land;
        elseif varloop==7
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'evap3hrpctiles','-append');clear evap3hrpctiles;
        elseif varloop==8
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'netsw3hrpctiles','-append');
        elseif varloop==9
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'netlw3hrpctiles','-append');
        elseif varloop==10
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'toplevelsm3hrpctiles','-append');
        elseif varloop==11
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'z5003hrpctiles','-append');
        elseif varloop==12
            save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'omega5003hrpctiles','-append');
        end
        save(strcat(dataresloc_external,'bigpctilemap_3hrdata'),'datesinsetofdays','-append');
    end
    fprintf('Just completed variable %d in makecompositesofasetofhours_3hourly\n',varloop);
    end
end