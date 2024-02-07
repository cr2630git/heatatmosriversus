makefigs1=0; %uses synthetic data to explain 'peak' definitions
makefigs8=0; %10 sec; supplemental figure showing extreme-Tw gridpoint fraction for each precip/IVT combo
makefigs9=0; %6 min
    redoreanalysiscalcs=1; %4 min
makefigs10ands11=0; %2 min for both
    makefigs10=1; %AR/Z500 composite
    makefigs11=0; %precip/IVT composite





%Definition figure
if makefigs1==1
    synthdata_aspctile=[83;78;87;97;88;86;90;95.5;98.5;98;95.5;91;93;94;98;99;93;86;76];
    p90=90.*ones(length(synthdata_aspctile),1);p95=95.*ones(length(synthdata_aspctile),1);
    figure(89);clf;
    plot(synthdata_aspctile,'linewidth',1.5,'color',colors('black'));hold on;
    plot(p90,'linewidth',2,'linestyle','--','color',colors('medium green'));
    plot(p95,'linewidth',2,'linestyle','--','color',colors('medium red'));
    ylabel('Tw Percentile');xlabel('Day Ordinate');
    set(gca,'fontweight','bold','fontname','arial','fontsize',12,'xlim',[1 19]);
    set(gcf,'color','w');
    curpart=1;highqualityfiguresetup_heatars;
    figname='figures1';curpart=2;highqualityfiguresetup_heatars;
end



if makefigs8==1
    figure(223);clf;
    lefts=[0.05;0.35;0.65;0.05;0.35;0.65;0.35];bottoms=[0.7;0.7;0.7;0.38;0.38;0.38;0.06];
    for reg=1:7
        if reg==1;subplot(1,7,reg);else;axes('Position',[lefts(reg) bottoms(reg) 0.25 0.25]);end
        imagescnan_heatars(savedextremetwgridptfracs_means{reg}./max(max(savedextremetwgridptfracs_means{reg})));caxis([0 1]);
        if reg==3 || reg==6 || reg==7;c=colorbar;c.Ticks=[0 0.25 0.5 0.75 1];end
        colormap(colormaps_heatars('whitelightreddarkred','more','not'));
        set(gca,'Position',[lefts(reg) bottoms(reg) 0.25 0.25]);
        set(gca,'xtick',[1:3],'ytick',[1:3],'xticklabel',{'IVT 1','IVT 2','IVT 3'},'yticklabel',{'P 3','P 2','P 1'});
        set(gca,'fontname','arial','fontsize',11);
        title(ncaregnamesshort_caps{reg},'fontweight','bold','fontname','arial','fontsize',12);
    end
    curpart=1;highqualityfiguresetup_heatars;
    figname='figures8';curpart=2;highqualityfiguresetup_heatars;
end


%Compare precip in gridcells versus stations in the Midwest
%Stns (and corresponding gridcells) are listed in regularizestationprecipdataUPDATED loop of heatars_mainanalysis
if makefigs9==1
    reg=5;
    hrstolookahead=24;hrstolookbehind=-24; %sets size and location of analysis window (relative to Tw peak)


    stntw3hrdata_pctiles_bystn=cell(size(stncodes,1),1);
    analysiswindowsize=hrstolookahead+abs(hrstolookbehind)+1;
    analysiswindowsize_as3hrtimesteps=hrstolookahead/3+abs(hrstolookbehind)/3+1;
    clear mystnprecipmean;
    clear arr1;clear arr2;
    for stnidx=1:size(stncodes,1)
        thisrow=stnrows(stnidx);thiscol=stncols(stnidx);

        s=stnordsinhadisd(stnidx);
        stntz=-5; %Midwest is 5 hours behind UTC


        tmp=load(strcat(dataresloc_external,'bigpctilemap_1hrdata_',stncodes{stnidx},'.mat'));
        precip1hrpctiles_merra2=tmp.precip1hrpctiles; %size of this should be (n occurrences) x (52 lats) x (94 lons) x (49 hours)
        precip1hroccurrences_merra2_cell=tmp.precip1hroccurrences;
        tw1hrpctiles=tmp.tw1hrpctiles;
        precip1hrmeanlikelihood_merra2=tmp.precip1hrmeanlikelihood;
    
        precip1hrpctiles_era5land=tmp.precip1hrpctiles_era5land;
        precip1hroccurrences_era5land=tmp.precip1hroccurrences_era5land;
        precip1hrmeanlikelihood_era5land=tmp.precip1hrmeanlikelihood_era5land;

        precip1hroccurrences_merra2=precip1hroccurrences_merra2_cell{reg};

        clear precip3hrmeanlikelihood_merra2;clear precip3hrmeanlikelihood_era5land;clear tw3hrpctiles;
        clear precip3hrpctiles_merra2;clear precip3hroccurrences_era5land;clear precip3hrpctiles_era5land;clear precip3hroccurrences_merra2;
        hrc=0;
        for hr=1:3:size(precip1hrpctiles_merra2,4)
            hrc=hrc+1;
            if hr==1
                firsthr=hr;lasthr=hr+1;
            elseif hr==size(precip1hrpctiles_merra2,4)
                firsthr=hr-1;lasthr=hr;
            else
                firsthr=hr-1;lasthr=hr+1;
            end
            firsthr_max24=rem(firsthr,24);if firsthr_max24==0;firsthr_max24=24;end
            lasthr_max24=rem(lasthr,24);if lasthr_max24==0;lasthr_max24=24;end

            precip3hrmeanlikelihood_merra2(hrc,:,:)=squeeze(mean(precip1hrmeanlikelihood_merra2(firsthr_max24:lasthr_max24,:,:)));
            precip3hrmeanlikelihood_era5land(hrc,:,:)=squeeze(mean(precip1hrmeanlikelihood_era5land(firsthr_max24:lasthr_max24,:,:)));

            tw3hrpctiles(:,:,:,hrc)=squeeze(mean(tw1hrpctiles(:,:,:,firsthr:lasthr),4));

            precip3hrpctiles_merra2(:,:,:,hrc)=squeeze(mean(precip1hrpctiles_merra2(:,:,:,firsthr:lasthr),4));
            precip3hroccurrences_era5land(:,:,:,hrc)=squeeze(mean(precip1hroccurrences_era5land(:,:,:,firsthr:lasthr),4));
            precip3hrpctiles_era5land(:,:,:,hrc)=squeeze(mean(precip1hrpctiles_era5land(:,:,:,firsthr:lasthr),4));
            precip3hroccurrences_merra2(:,:,:,hrc)=squeeze(mean(precip1hroccurrences_merra2(:,:,:,firsthr:lasthr),4));
        end

        datesinsetofdays=tmp.datesinsetofdays;
        testarr=NaN.*ones(size(datesinsetofdays{reg},1),4);
        for i=1:size(datesinsetofdays{reg},1)
            testarr(i,1)=datesinsetofdays{reg}(i,1)+1979;
            testarr(i,2)=DOYtoMonth_heatars(datesinsetofdays{reg}(i,2),testarr(i,1));
            testarr(i,3)=DOYtoDOM_heatars(datesinsetofdays{reg}(i,2),testarr(i,1));
            testarr(i,4)=datesinsetofdays{reg}(i,3);
        end
    

        if redoreanalysiscalcs==1
    
            %Get hour-of-day-specific climos for precip at each gridpt
            weightedprecip3hrmeanlikelihood_merra2=NaN.*ones(52,94,analysiswindowsize_as3hrtimesteps);
            weightedprecip3hrmeanlikelihood_era5land=NaN.*ones(52,94,analysiswindowsize_as3hrtimesteps);

            timestepc=1;

            for tsreltopeak=hrstolookbehind/3:1:hrstolookahead/3 %in 3-hr increments relative to the Tw peak
                arrayofhours_1hrly=datesinsetofdays{reg}(:,3)+tsreltopeak;
                %arrayofhours must reflect 3-hourly, not 1-hourly, times
                arrayofhours_3hrly=round2(arrayofhours_1hrly./3,1,'ceil');

                invalid=arrayofhours_3hrly<=0;arrayofhours_3hrly(invalid)=arrayofhours_3hrly(invalid)+8;
                c=1;tmp_pr=zeros(1,52,94);tmp_pr_era5land=zeros(1,52,94);
                for hrofdaytocheck=1:8
                    numtwpeaksthishr=sum(arrayofhours_3hrly==hrofdaytocheck); %of the {peak hours, peak-1 hours, etc}, how many are this hour of the day?
                    if numtwpeaksthishr>0
                        tmp_pr(c:c+numtwpeaksthishr-1,:,:)=permute(repmat(squeeze(precip3hrmeanlikelihood(hrofdaytocheck,:,:)),[1 1 numtwpeaksthishr]),[3 1 2]);
                        tmp_pr_era5land(c:c+numtwpeaksthishr-1,:,:)=permute(repmat(squeeze(precip3hrmeanlikelihood_era5land(hrofdaytocheck,:,:)),[1 1 numtwpeaksthishr]),[3 1 2]);
                    end
                    c=c+numtwpeaksthishr;
                end
                weightedprecip3hrmeanlikelihood_merra2(:,:,timestepc)=squeeze(mean(tmp_pr,1));
                weightedprecip3hrmeanlikelihood_era5land(:,:,timestepc)=squeeze(mean(tmp_pr_era5land,1));
                timestepc=timestepc+1;
            end
        
            meanprecip3hroccurrence_merra2=squeeze(mean(precip3hroccurrences_merra2));
            meanprecip3hrrellikelihood_merra2=meanprecip3hroccurrence_merra2./weightedprecip3hrmeanlikelihood_merra2;
            meanprecip3hrpctile_merra2=squeeze(mean(precip3hrpctiles_merra2));
                
           
            meantw3hrpctile=squeeze(mean(tw3hrpctiles));
        


        
            arr1(stnidx,:)=squeeze(meantw3hrpctile(stnrows(stnidx),stncols(stnidx),:));
            arr2(stnidx,:)=squeeze(meanprecip3hrrellikelihood_merra2(stnrows(stnidx),stncols(stnidx),:));
         

            %Use pre-computed Tw for ease
            exist twarray;
            if ans==0;finalarrays=load(strcat(dataresloc_external,'updatedfinalprocesseddataarrays_2022-10.mat'));
                twarray=finalarrays.twarray;end
    
            %Get this station's Tw data for all MJJAS days at this station, in order to get proper climo pctiles by hour of day (1 min)
            %Here, hour #1 is 00:00 UTC, hour #2 is 01:00 UTC, etc.
            stntwarr_full=NaN.*ones(41,153,24);daystogoout=0;
            for thisdayyear=1980:2020
                for thisdaydoy=may1doy:sep30doy
                    d=gethadisddaynumberfromyearanddoy_heatars(thisdayyear,thisdaydoy);
                    subdailyanalysis_heatars;
                    for hrc=1:size(subdailytimes,1)
                        thishour=subdailytimes(hrc);
                        thishour_rel=thishour-firsthourtoplot+1;
                        stntwarr_full(thisdayyear-1979,thisdaydoy-(may1doy-1),thishour_rel)=subdailytw(hrc);
                    end
                end
            end

            %Repeat for precip
            f=load(strcat(dataresloc_external,'US_Hourly_Precip/ncarprecipdata_',stncodes{stnidx},'.mat'));
            ncarprecipgaugedata=f.ncarprecipgaugedata;
            stnpreciparr_full=squeeze(ncarprecipgaugedata(:,121:273,:,5));


        
            %Define Tw extremes for each station and see how precip looks around *these* hours
            %IN OTHER WORDS, DEFINE STATION AND MERRA2 TW-EXTREMES DATES SEPARATELY

            %a. Tw daily maxes
            myarr_dailymax=squeeze(max(stntwarr_full,[],3));
    
            %b. smoothed 95th percentile
            myarrdailymax_smoothedp95=NaN.*ones(153,1);
            for i=16:138;myarrdailymax_smoothedp95(i)=quantile(reshape(myarr_dailymax(:,i-15:i+15),[size(stntwarr_full,1)*31 1]),0.95);end
            for i=6:15;myarrdailymax_smoothedp95(i)=quantile(reshape(myarr_dailymax(:,i-5:i+5),[size(stntwarr_full,1)*11 1]),0.95);end
            for i=139:148;myarrdailymax_smoothedp95(i)=quantile(reshape(myarr_dailymax(:,i-5:i+5),[size(stntwarr_full,1)*11 1]),0.95);end
            myarrdailymax_smoothedp95(1:5)=myarrdailymax_smoothedp95(6);
            myarrdailymax_smoothedp95(149:153)=myarrdailymax_smoothedp95(148);
    
            %c. Tw extremes
            mystnarr_twextremes=zeros(size(stntwarr_full,1),153);
            for y=1:size(stntwarr_full,1)
                for i=1:153
                    if myarr_dailymax(y,i)>=myarrdailymax_smoothedp95(i)
                        mystnarr_twextremes(y,i)=1;
                    end
                end
            end
    
            %d. hours of Tw extremes (10 sec)
            %also save +/- 24 hr of Tw data around each Tw extreme
            mystnarr_twextr_maxhr=NaN.*ones(size(stntwarr_full,1),153);
            daystogoout=1; 
            row=0;clear mystntw;clear mystntw_aspctiles;clear peaktwhourtracker;
            for yr=1:size(stntwarr_full,1)
                for i=1:153
                    thisdayyear=yr+1979;thisdaydoy=i+120;
            
                    if mystnarr_twextremes(yr,i)==1
                        d=gethadisddaynumberfromyearanddoy_heatars(thisdayyear,thisdaydoy);
                        subdailyanalysis_heatars; %output: subdailytw array, representing 1 day's worth of data, in UTC time, containing the Tw extreme
                
                        if daystogoout==1
                            [~,maxhronpeakday]=max(subdailytw_filled(25:48)); %max Tw on peak day, and its time of occurrence
                            mystnarr_twextr_maxhr(yr,i)=maxhronpeakday;
                            
    
                            row=row+1;hrcount=0;
                            peaktwhourtracker(row)=maxhronpeakday;
                            for hroffset=-24:24
                                curhr=numhours_day1+maxhronpeakday+hroffset;hrcount=hrcount+1;
                                mystntw(row,hrcount)=subdailytw_filled(curhr); %still in UTC time
                            end
                        else
                            disp('Need to adjust at line 1541');
                        end
                    end
                end
            end

            %e. convert to pctiles
            clear mystntw_pctiles;
            for row=1:size(mystntw,1)
                thispeakhr=peaktwhourtracker(row);
                if ~isnan(thispeakhr)
                    for j=size(mystntw,2):-1:1
                        subtractamount=size(mystntw,2)-j;
                        thishr=thispeakhr-subtractamount;
                        if thishr<=0;thishr=thishr+24;if thishr<=0;thishr=thishr+24;end;end
                        mystntw_pctiles(row,j)=pctreltodistn_heatars(reshape(stntwarr_full(:,:,thishr),[size(stntwarr_full,1)*153 1]),mystntw(row,j));
                    end
                end
            end
            invalid=mystntw_pctiles==0;mystntw_pctiles(invalid)=NaN;
            
            %f. get cross-station mean
            mystntw_pctiles_mean=mean(mystntw_pctiles,'omitnan');


    
            %Also get +/- 24 hr of precip around these Tw extremes
            row=0;clear mystnprecip;clear mystndaytracker;
            for yr=1:size(stntwarr_full,1)
                for i=1:153
                    if mystnarr_twextremes(yr,i)==1
                        row=row+1;
                        maxhronpeakday=mystnarr_twextr_maxhr(yr,i);
                        maxdoy=i+120;
                        
                        hrcount=0;
                        for hroffset=-24:24
                            curhr=maxhronpeakday+hroffset;curdoy=maxdoy;hrcount=hrcount+1;
                            if curhr<=0
                                curhr=curhr+24;
                                curdoy=curdoy-1;
                            elseif curhr>=25
                                curhr=curhr-24;
                                curdoy=curdoy+1;
                            end
                            mystnprecip(row,hrcount)=ncarprecipgaugedata(yr,curdoy,curhr,5).*25.4; %convert to mm; still in UTC time
                        end
                        mystndaytracker(row,1:3)=[yr maxdoy maxhronpeakday];
                    end
                end
            end
            mystnprecip_aslikelihood=smooth(squeeze(sum(mystnprecip>=0.01,'omitnan'))./sum(~isnan(mystnprecip)));

            %Define climo likelihoods of precip at each hour of day
            tmp=reshape(stnpreciparr_full,[size(stnpreciparr_full,1)*size(stnpreciparr_full,2) 24]);
            precipclimolikelihood=smooth(sum(tmp>=0.01,'omitnan')./sum(~isnan(tmp)));

            %Calculate precip relative likelihood by comparing against
            %climo precip likelihoods weighted according to frequency of each hour of day (c.f. mystndaytracker)
            hours_forweights=size(mystnprecip);c=1;
            for peakhr=1:24
                thissum=sum(mystndaytracker(:,3)==peakhr);

                otherhrc=peakhr; %because starting at 24 hr back from peakhr, i.e. the same hour of the day
                for hrwithin=1:size(mystnprecip,2)
                    hours_forweights(c:c+thissum-1,hrwithin)=otherhrc;
                    otherhrc=otherhrc+1;if otherhrc==25;otherhrc=otherhrc-24;end
                end
                c=c+thissum;
            end

            clear precipclimolikelihood_weighted;
            for i=1:size(mystnprecip,2)
                tmpsum=0;
                for hrtoadd=1:24
                    relfreqofthishourinthispos=sum(hours_forweights(:,i)==hrtoadd)./size(mystnprecip,1);
                    tmpsum=tmpsum+relfreqofthishourinthispos*precipclimolikelihood(hrtoadd);
                end
                precipclimolikelihood_weighted(i)=tmpsum;
            end

            %Finally, compute precip rel likelihood
            preciprellikelihood=mystnprecip_aslikelihood./precipclimolikelihood_weighted';

            %Convert both Tw and precip arrays to 3-hrly
            hrc=0;clear mystnprecipmean_3hrly;clear mystnprecip_rellik_mean_3hrly;
            for hr=1:3:size(mystnprecipmean,2)
                hrc=hrc+1;
                if hr==1
                    firsthr=hr;lasthr=hr+1;
                elseif hr==size(mystnprecipmean,2)
                    firsthr=hr-1;lasthr=hr;
                else
                    firsthr=hr-1;lasthr=hr+1;
                end
                mystnprecip_rellik_mean_3hrly(:,hrc)=squeeze(mean(preciprellikelihood(firsthr:lasthr)));
                mystntw_pctiles_mean_3hrly(hrc)=squeeze(mean(mystntw_pctiles_mean(firsthr:lasthr)));
            end
        end
    end
    
    %(Outdated) Get station-Tw mean
    if doalt==0
        clear meantwbystn;
        for stnidx=1:size(stncodes,1)
            meantwbystn(stnidx,:)=mean(stntw3hrdata_pctiles_bystn{stnidx},'omitnan');
        end
    end



    %%%%Finalize and plot%%%%

    %Remove bad data (i.e. Inf)
    invalid=arr2>100;arr2(invalid)=NaN; 

    figure(111);clf;
    arr1mean=mean(arr1,'omitnan');
    arr2mean=squeeze(mean(arr2,'omitnan'));
    arr4=mystntw_pctiles_mean_3hrly; %squeeze(mean(meantwbystn,'omitnan'))
    arr5=mystnprecip_rellik_mean_3hrly; %ncarprecipdata_humidheat_3hourly_rellikelihood(1:9)
    
    yyaxis left;plot(arr1mean,'r','linewidth',1.5,'linestyle','-');hold on; %MERRA-2 Tw
    yyaxis right;plot(arr2mean,'b','linewidth',1.5,'linestyle','-'); %MERRA-2 precip

    yyaxis left;plot(arr4,'color',colors('orange'),'linewidth',1.5,'linestyle','-');hold on; %station Tw
    yyaxis right;plot(arr5,'color',colors('light blue'),'linewidth',1.5,'linestyle','-'); %station precip

    %Add label
    t=text(0.05,0.92,'Tw','units','normalized');set(t,'fontsize',12,'fontweight','bold','fontname','arial');
    t=text(0.05,0.88,'MERRA-2','units','normalized');set(t,'fontsize',11,'fontweight','bold','fontname','arial','color',colors('red'));
    t=text(0.05,0.84,'Station','units','normalized');set(t,'fontsize',11,'fontweight','bold','fontname','arial','color',colors('orange'));

    t=text(0.18,0.92,'Precip','units','normalized');set(t,'fontsize',12,'fontweight','bold','fontname','arial');
    t=text(0.18,0.88,'MERRA-2','units','normalized');set(t,'fontsize',11,'fontweight','bold','fontname','arial','color',colors('blue'));
    t=text(0.18,0.84,'Station','units','normalized');set(t,'fontsize',11,'fontweight','bold','fontname','arial','color',colors('light blue'));
    %t=text(0.18,0.80,'ERA5-Land','units','normalized');set(t,'fontsize',11,'fontweight','bold','fontname','arial','color',colors('green'));

    %Finalize and save
    yyaxis left;ylabel('Tw Percentile','fontsize',12,'fontweight','bold','fontname','arial');
    yyaxis right;ylabel('Precip Rel. Likelihood','fontsize',12,'fontweight','bold','fontname','arial');
    xticks([1 5:2:analysiswindowsize_as3hrtimesteps-4 analysiswindowsize_as3hrtimesteps]);
    if hrstolookbehind==-24 && hrstolookahead==24
        xticklabels({'-24h';'-12h';'-6h';'peak';'6h';'12h';'24h'});
    else
        disp('please update xtick labels');
    end
    xlabel('Hours Relative to Peak Tw','fontsize',12,'fontweight','bold','fontname','arial');
    set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
    xlim([1 analysiswindowsize_as3hrtimesteps]);ylim([0 4]);
    yyaxis left;set(gca,'ycolor','k');yyaxis right;set(gca,'ycolor','k');

    set(gcf,'color','w');saveaspdf=1;
    thiswidth=9;thisheight=6;
    curpart=1;highqualityfiguresetup_heatars;
    figname='figures9';
    curpart=2;highqualityfiguresetup_heatars;
end



if makefigs10ands11==1
    lefts=[0.02;0.35;0.68;0.02;0.35;0.68;0.35];
    bottoms=[0.67;0.67;0.67;0.34;0.34;0.34;0.01];
    widtth=0.31;heighht=0.31;

    if makefigs10==1
        figure(850);clf;hold on;
        for reg=1:7
            arprob=squeeze(arprobcomp_mean(reg,:,:));
            z500anom=squeeze(z500anomscomp_mean(reg,:,:));
    
            %Tw/AR
            mymap_z500=zeros(52,94);mymap_ar=zeros(52,94);
            for lat=1:52
                for lon=1:94
                    if arprob(lat,lon)>=0.8
                        mymap_ar(lat,lon)=2;
                    elseif arprob(lat,lon)>=0.5
                        mymap_ar(lat,lon)=1;
                    end

                    if z500anom(lat,lon)>=50
                        mymap_z500(lat,lon)=5;
                    elseif z500anom(lat,lon)>=25
                        mymap_z500(lat,lon)=4;
                    elseif z500anom(lat,lon)<=-50
                        mymap_z500(lat,lon)=1;
                    elseif z500anom(lat,lon)<=-25
                        mymap_z500(lat,lon)=2;
                    end
                end
            end
            mymap_ar=double(mymap_ar)+6;

            %tonan=mymap_ar==6;mymap_ar(tonan)=NaN;
            tonan=mymap_z500==0;mymap_z500(tonan)=NaN;

            
            %Make plot with shading and contours
            if reg==1;subplot(3,3,1);set(gca,'visible','off');else;axes('Position',[lefts(reg) bottoms(reg) widtth heighht]);end
            
            data={latarray_52x94;lonarray_52x94;double(mymap_z500)};
            overlaydata={latarray_52x94;lonarray_52x94;double(mymap_ar)};
            cmapz500=colormaps_heatars('t','100','not');cmapar_tmp=colormaps_heatars('q','100','not');cmapar=cmapar_tmp(51:100,:);
            combinedcmap=[cmapz500;cmapar]; %underlay colormap first
            caxmax=8;caxmin=-0.5;
            vararginnew={'datatounderlay';data;'underlaycaxismin';caxmin;'underlaycaxismax';caxmax;'underlaystepsize';1;'underlaycolormap';combinedcmap;
                'contour_underlay';1;'contourunderlayfill';1;'contourunderlaycolors';combinedcmap;'underlaytransparency';0.6;...
                'overlaynow';1;'nolinesbetweenfilledcontours';1;'twodifferentaxes';1;...
                'datatooverlay';overlaydata;'overlaycaxismin';caxmin;'overlaycaxismax';caxmax;'overlaystepsize';1;'overlaycolormap';combinedcmap;
                'contour_overlay';1;'contouroverlayfill';0;'contouroverlaycolors';combinedcmap;'contouroverlaylinewidth';2;'overlaytransparency';0.5;...
                'conttoplot';'North America';'nonewfig';1;'omitfirstsubplotcolorbar';1;'stateboundarycolor';'k'};
            datatype='custom';region='usa-slightlysmaller';stateboundaries=1;
            plotModelData_heatars(data,region,vararginnew,datatype);

            %Finish
            t=text(-0.02,0.51,subreglabels{reg},'units','normalized');set(t,'fontsize',14,'fontweight','bold','fontname','arial');
            set(gca,'Position',[lefts(reg) bottoms(reg) widtth heighht]);
            set(gca,'visible','off');

            %Include color key
            dokey=0;
            if dokey==1
            if reg==7
                fs=14;
                t=text(1.1,0.7,'RR[AR] > 3','color',combinedcmap(round(8*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.6,'RR[AR] > 2','color',combinedcmap(round(7*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.5,'Tw > p95','color',combinedcmap(round(3*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.4,'Tw > p90','color',combinedcmap(round(2*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.3,'Tw > p75','color',combinedcmap(round(1*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
            end
            end
            %%%
        end
        set(gcf,'color','w');
        curpart=1;highqualityfiguresetup_heatars;figname='figures10';curpart=2;highqualityfiguresetup_heatars;
    end


    if makefigs11==1
        exist tivt_p70;
        if ans==0;f=load(strcat(dataresloc_external,'heat_merra2.mat'));tivtp50=f.tivtp50;tivtp75=f.tivtp75;tivtp90=f.tivtp90;tivtp95=f.tivtp95;end

        figure(950);clf;hold on;
        for reg=1:7
            tivtval=squeeze(tivtcomp_mean(reg,:,:));
            precipval=squeeze(precipcomp_median(reg,:,:));
    
            %Tw/AR
            mymap_precip=zeros(52,94);mymap_tivt=zeros(52,94);
            for lat=1:52
                for lon=1:94
                    if tivtval(lat,lon)>=tivtp85(lat,lon)
                        mymap_tivt(lat,lon)=2;
                    elseif tivtval(lat,lon)>=tivtp70(lat,lon)
                        mymap_tivt(lat,lon)=1;
                    end

                    if precipval(lat,lon)>=precipp80(lat,lon)
                        mymap_precip(lat,lon)=2;
                    elseif precipval(lat,lon)>=precipp60(lat,lon)
                        mymap_precip(lat,lon)=1;
                    end
                end
            end
            mymap_tivt=double(mymap_tivt)+2;

            tonan=mymap_precip==0;mymap_precip(tonan)=NaN;
            drysummer=precipp95<0.002;mymap_precip(drysummer)=NaN;

            
            %Make plot with shading and contours
            if reg==1;subplot(3,3,1);set(gca,'visible','off');else;axes('Position',[lefts(reg) bottoms(reg) widtth heighht]);end
            
            data={latarray_52x94;lonarray_52x94;double(mymap_precip)};
            overlaydata={latarray_52x94;lonarray_52x94;double(mymap_tivt)};
            cmapprecip=colormaps_heatars('whitelightbluedarkblue','100','not');cmaptivt_tmp=colormaps_heatars('whiteendrainbow','300','not');cmaptivt=cmaptivt_tmp(221:300,:);
            combinedcmap=[cmapprecip;cmaptivt]; %underlay colormap first
            caxmax=4;caxmin=-0.5;
            vararginnew={'datatounderlay';data;'underlaycaxismin';caxmin;'underlaycaxismax';caxmax;'underlaystepsize';1;'underlaycolormap';combinedcmap;
                'contour_underlay';1;'contourunderlayfill';1;'contourunderlaycolors';combinedcmap;'underlaytransparency';0.6;...
                'overlaynow';1;'nolinesbetweenfilledcontours';1;'twodifferentaxes';1;...
                'datatooverlay';overlaydata;'overlaycaxismin';caxmin;'overlaycaxismax';caxmax;'overlaystepsize';1;'overlaycolormap';combinedcmap;
                'contour_overlay';1;'contouroverlayfill';0;'contouroverlaycolors';combinedcmap;'contouroverlaylinewidth';2;'overlaytransparency';0.5;...
                'conttoplot';'North America';'nonewfig';1;'omitfirstsubplotcolorbar';1;'stateboundarycolor';'k'};
            datatype='custom';region='usa-slightlysmaller';stateboundaries=1;
            plotModelData_heatars(data,region,vararginnew,datatype);

            %Finish
            set(gca,'Position',[lefts(reg) bottoms(reg) widtth heighht]);
            t=text(-0.02,0.51,subreglabels{reg},'units','normalized');set(t,'fontsize',14,'fontweight','bold','fontname','arial');
            set(gca,'visible','off');

            %Include color key
            dokey=0;
            if dokey==1
            if reg==7
                fs=14;
                t=text(1.1,0.7,'RR[AR] > 3','color',combinedcmap(round(8*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.6,'RR[AR] > 2','color',combinedcmap(round(7*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.5,'Tw > p95','color',combinedcmap(round(3*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.4,'Tw > p90','color',combinedcmap(round(2*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.3,'Tw > p75','color',combinedcmap(round(1*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
            end
            end
            %%%
        end
        set(gcf,'color','w');
        curpart=1;highqualityfiguresetup_heatars;figname='figures11';curpart=2;highqualityfiguresetup_heatars;
    end
end
