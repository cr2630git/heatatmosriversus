makefig1=0; %20 sec; creates Fig 1
    regtoplot='usa-slightlysmaller'; %'central-us' or 'usa-slightlysmaller'
makefig2=0; %creates Fig 2
    doscalevsheatcalc=0; %4 min
    actuallymakeplot=1; %10 sec
makefig3=0; %1 min; creates Fig 3
makefig4=0; %creates figure 4
makefig5=0; %3 min; creates Fig 5 and Figs S2-S7
    arrtype='hs'; %'peakhs' for Fig 5, 'hs' for associated SI figure (S12)
makefig6=0; %30 sec; creates Fig 6




%Likelihood-difference map
if makefig1==1
    figure(13);clf;hold on;
    curpart=1;highqualityfiguresetup_heatars;
    set(gca,'visible','off');
    
    thisarr=likelihooddiffarheat;

    invalid=thisarr>50;thisarr(invalid)=NaN;invalid=thisarr==0;thisarr(invalid)=NaN;
    invalid=isnan(lsmask_52x94);thisarr(invalid)=NaN;invalid=lsmask_52x94==0;thisarr(invalid)=NaN;
    
    %Remove a few gridcells that are contaminated by being partly in water
    thisarr(8,68)=NaN;thisarr(10,62)=NaN;
    
    
    %Set up colormap
    maxfactor=3;
    [cmapbelow1,cmapabove1,cbticks_below1,cbticks_above1,cbticklabels_below1]=fractionalcolormap_heatars(maxfactor,colormaps_heatars('q','more','not'));

    caxismina=1/maxfactor;caxismaxa=1;caxisstep=0.1;
    relriskp95_below1=thisarr.*(thisarr<caxismaxa);
    invalid=relriskp95_below1==0;relriskp95_below1(invalid)=NaN;
    hAxesa=axes;cmapa=colormap(hAxesa,gray);

    
    if strcmp(regtoplot,'central-us');cbar1pos=0.77;cbar2pos=0.83;elseif strcmp(regtoplot,'usa');cbar1pos=0.9;cbar2pos=0.96;end
    
    if strcmp(ardataset,'era-interim')
        latarrayhere=latarray(northrow:southrow,westcol:eastcol);lonarrayhere=lonarray(northrow:southrow,westcol:eastcol);
    elseif strcmp(ardataset,'merra2')
        latarrayhere=latarray;lonarrayhere=lonarray;
    end
    data={latarrayhere;lonarrayhere;relriskp95_below1};
    vararginnew={'datatounderlay';data;'underlaycaxismin';caxismina;'underlaycaxismax';caxismaxa;'mystepunderlay';caxisstep;...
        'underlaycolormap';cmapbelow1;'variable';'temperature';'overlaynow';0;...
        'conttoplot';'North America';'nonewfig';1;'nanstransparent';1;'colorbarposition';[0.9 0.1 0.02 0.4];'colorbarfontsize';12;...
        'colorbarticks';cbticks_below1;'colorbarticklabels';cbticklabels_below1};
    datatype='custom';region=regtoplot;
    plotModelData_heatars(data,region,vararginnew,datatype);
    
    
    caxisminb=1;caxismaxb=maxfactor;caxisstep=1/maxfactor;
    relriskp95_above1=thisarr.*(thisarr>caxismaxa);
    invalid=relriskp95_above1==0;relriskp95_above1(invalid)=NaN;
    hAxesb=axes;cmapb=colormap(hAxesb,gray);
    
    data={latarrayhere;lonarrayhere;relriskp95_above1};
    vararginnew={'datatounderlay';data;'underlaycaxismin';caxisminb;'underlaycaxismax';caxismaxb;'mystepunderlay';caxisstep;...
        'underlaycolormap';cmapabove1;'variable';'temperature';'overlaynow';0;...
        'conttoplot';'North America';'nonewfig';1;'nanstransparent';1;'colorbarposition';[0.9 0.5 0.02 0.4];'colorbarfontsize';12;'colorbarticks';cbticks_above1};
    datatype='custom';region=regtoplot;
    plotModelData_heatars(data,region,vararginnew,datatype);
    
    %Add bolded region outlines
    g=geoshow(northwestpolygonlats,northwestpolygonlons);set(g,'Color','k','LineWidth',2);
    g=geoshow(southwestpolygonlats,southwestpolygonlons);set(g,'Color','k','LineWidth',2);
    g=geoshow(gpnpolygonlats,gpnpolygonlons);set(g,'Color','k','LineWidth',2);
    g=geoshow(gpspolygonlats,gpspolygonlons);set(g,'Color','k','LineWidth',2);
    g=geoshow(midwestpolygonlats,midwestpolygonlons);set(g,'Color','k','LineWidth',2);
    g=geoshow(southeastpolygonlats,southeastpolygonlons);set(g,'Color','k','LineWidth',2);
    g=geoshow(northeastpolygonlats,northeastpolygonlons);set(g,'Color','k','LineWidth',2);


    %Add insets scattered around the perimeter of the map
    inset_lefts=[0.06;0.06;0.29;0.4;0.52;0.75;0.75];inset_bottoms=[0.9;0.25;0.9;0.09;0.9;0.25;0.9];
    for reg=1:7   
        ar_thisreg=ar_52x94(:,:,thencaregions==reg+1);
        overallarprob(reg)=sum(sum(sum(sum(ar_thisreg(12:end,may1doy:sep30doy,:)))))./(28*nummjjasdays*sum(sum(thencaregions==reg+1)));
        axes('Position',[inset_lefts(reg) inset_bottoms(reg) 0.12 0.095]);
        plot(arcomposite_p50{reg},'linewidth',2,'color',regcolors{reg});hold on;
        ylabel('Pr(AR)','fontweight','bold','fontname','arial','fontsize',10);ylim([0 0.35]);
        xlim([1 9]);xticks([1;3;5;7;9]);
        set(gca,'fontweight','bold','fontname','arial','fontsize',10);
        xlabel('Days','fontweight','bold','fontname','arial','fontsize',10);
        xticklabels({'-4';'-2';'0';'2';'4'});
    end
    
    
    set(gcf,'color','w');
    figname='figure1';curpart=2;highqualityfiguresetup_heatars;
end




if makefig6==1
    x=-4:4;shadealpha=0.2;
    %Midwest is all by itself, others are (manually) combined into a single SI figure
    %for reg=1:numregs
    for reg=5:5
        figure(210+reg);clf;

        axes('position',[0.1 0.8 0.8 0.15]);
        plot(x,arcomposite_p50{reg},'linewidth',2,'color',arcolor);hold on;
        t1=ylabel('Prob(AR)','fontweight','bold','fontname','arial','fontsize',14);ylim([0 0.4]);
        set(gca,{'ycolor'},{arcolor});
        set(gca,'fontweight','bold','fontname','arial','fontsize',11);

        yyaxis right;plot(x,twcomposite_p50{reg},'linewidth',2,'color',twcolor);
        t2=ylabel(strcat('Tw'),'fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        t1.Color=arcolor;t2.Color=twcolor;
        set(gca,{'ycolor'},{twcolor});set(gca,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,twcomposite_p166{reg},twcomposite_p833{reg},twcolor);alpha(p,shadealpha);
        
        yyaxis left;set(gca,{'ycolor'},{arcolor});xticklabels({});
        title(strcat([ncaregionnames{reg+1}]),'fontweight','bold','fontname','arial','fontsize',16);
        num1=size(dss_uniquedates{reg},1);
        t=text(0.7,0.6,strcat(['unique days: ',CommaFormat(num1)]),'units','normalized');
            set(t,'fontweight','bold','fontname','arial','fontsize',11);
        num2=round(daysbyreg(reg)/num1);
        t=text(0.7,0.3,strcat(['mean gridcells/day: ',num2str(num2)]),'units','normalized');
            set(t,'fontweight','bold','fontname','arial','fontsize',11);
        
        
        axes('position',[0.1 0.62 0.8 0.15]);
        plot(x,tcomposite_p50{reg},'linewidth',2,'color',tcolor);hold on;
        t1=ylabel(strcat('T'),'fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        ax1=gca;set(ax1,{'ycolor'},{tcolor});set(ax1,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,tcomposite_p166{reg},tcomposite_p833{reg},tcolor);alpha(p,shadealpha);

        yyaxis right;plot(x,qcomposite_p50{reg},'linewidth',2,'color',qcolor);
        t2=ylabel('q','fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        t1.Color=tcolor;t2.Color=qcolor;ax2=gca;set(ax2,{'ycolor'},{qcolor});set(ax2,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,qcomposite_p166{reg},qcomposite_p833{reg},qcolor);alpha(p,shadealpha);
        
        yyaxis left;set(gca,{'ycolor'},{tcolor});xticklabels({});
        
        
        axes('position',[0.1 0.44 0.8 0.15]);
        plot(x,tivtcomposite_p50{reg},'linewidth',2,'color',tivtcolor);hold on;
        t1=ylabel('tIVT','fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        ax1=gca;set(ax1,{'ycolor'},{tivtcolor});set(ax1,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,tivtcomposite_p166{reg},tivtcomposite_p833{reg},tivtcolor);alpha(p,shadealpha);

        yyaxis right;plot(x,precipcomposite_p50{reg},'linewidth',2,'color',precipcolor);
        t2=ylabel('precip','fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        t1.Color=tivtcolor;t2.Color=precipcolor;
        ax2=gca;set(ax2,{'ycolor'},{precipcolor});set(ax2,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,precipcomposite_p166{reg},precipcomposite_p833{reg},precipcolor);alpha(p,shadealpha);
        
        yyaxis left;set(gca,{'ycolor'},{tivtcolor});xticklabels({});
        
        
        axes('position',[0.1 0.26 0.8 0.15]);
        plot(x,toplevelsmcomposite_p50{reg},'linewidth',2,'color',toplevelsmcolor);hold on;
        t1=ylabel('SM0-5','fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        ax1=gca;set(ax1,{'ycolor'},{toplevelsmcolor});set(ax1,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,toplevelsmcomposite_p166{reg},toplevelsmcomposite_p833{reg},toplevelsmcolor);alpha(p,shadealpha);

        yyaxis right;plot(x,evapcomposite_p50{reg},'linewidth',2,'color',evapcolor);
        t2=ylabel('evap','fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        t1.Color=toplevelsmcolor;t2.Color=evapcolor;
        ax2=gca;set(ax2,{'ycolor'},{evapcolor});set(ax2,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,evapcomposite_p166{reg},evapcomposite_p833{reg},evapcolor);alpha(p,shadealpha);
        
        yyaxis left;set(gca,{'ycolor'},{toplevelsmcolor});xticklabels({});
        
        
        axes('position',[0.1 0.08 0.8 0.15]);
        plot(x,netswcomposite_p50{reg},'linewidth',2,'color',netswcolor);hold on;
        t1=ylabel('Net SW','fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        ax1=gca;set(ax1,{'ycolor'},{netswcolor});set(ax1,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,netswcomposite_p166{reg},netswcomposite_p833{reg},netswcolor);alpha(p,shadealpha);

        yyaxis right;plot(x,netlwcomposite_p50{reg},'linewidth',2,'color',netlwcolor); %positive already is downwards in MERRA2
        t2=ylabel('Net LW','fontweight','bold','fontname','arial','fontsize',14);ylim([0 100]);
        t1.Color=netswcolor;t2.Color=netlwcolor;
        ax2=gca;set(ax2,{'ycolor'},{netlwcolor});set(ax2,'fontweight','bold','fontname','arial','fontsize',11);
        p=fillbetween(x,netlwcomposite_p166{reg},netlwcomposite_p833{reg},netlwcolor);alpha(p,shadealpha);
        
        yyaxis left;set(gca,{'ycolor'},{netswcolor});
        xticks(-4:2:4);xticklabels({'-4';'-2';'0';'2';'4'});
        xlabel('Days Relative to Peak Tw','fontweight','bold','fontname','arial','fontsize',12);
        
        thiswidth=7;
        curpart=1;highqualityfiguresetup_heatars;set(gcf,'color','w');
        figname=strcat('multivartimeseries_',ncaregnamesshort{reg});curpart=2;highqualityfiguresetup_heatars;close;
    end
    
    exist tivt_52x94;
    if ans==0;tmp=load(strcat(dataresloc_external,'ivt_merra2.mat'));tivt_52x94=tmp.tivt_52x94;end
    c=0;
    for lat=1:52
        for lon=1:94
            reg=thencaregions(lat,lon)-1;
            if reg==5
                for y=1:28 %currently, 1991-2018
                    for doy=may1doy:sep30doy
                        c=c+1;allmwtivtvals(c)=tivt_52x94(y,doy,lat,lon);
                    end
                end
            end
        end
    end
    mw_tivt_p10=quantile(allmwtivtvals,0.1);
    mw_tivt_p50=quantile(allmwtivtvals,0.5);
    mw_tivt_p90=quantile(allmwtivtvals,0.9);
end



if makefig5==1
    if strcmp(arrtype,'peakhs')
        suf='';reg1=1;reg2=numregs;
    elseif strcmp(arrtype,'hs') %generally, only do MW (reg 5)
        suf='_nonpeak';reg1=5;reg2=5;
    end
    tmp=load(strcat(dataresloc_external,'bigpctilemap_data',suf));
    tivtpctiles=tmp.tivtpctiles;precippctiles=tmp.precippctiles;
    aroccurrences=tmp.aroccurrences;precipoccurrences=tmp.precipoccurrences;
    tpctiles=tmp.tpctiles;twpctiles=tmp.twpctiles;qpctiles=tmp.qpctiles;
    if strcmp(arrtype,'peakhs')
    evappctiles=tmp.evappctiles;
    netswpctiles=tmp.netswpctiles;netlwpctiles=tmp.netlwpctiles;toplevelsmpctiles=tmp.toplevelsmpctiles;
    z500pctiles=tmp.z500pctiles;omega500pctiles=tmp.omega500pctiles;
    end

    for reg=reg1:reg2
        meantwpctile=squeeze(mean(twpctiles{reg},'omitnan'));
        meanarrellikelihood=squeeze(mean(aroccurrences{reg},'omitnan'))./repmat(meanarfreq,[1 1 5]);
        meanpreciprellikelihood=squeeze(mean(precipoccurrences{reg},'omitnan'))./repmat(meanpreciplikelihood,[1 1 5]);
        meantpctile=squeeze(mean(tpctiles{reg},'omitnan'));
        meanqpctile=squeeze(mean(qpctiles{reg},'omitnan'));
        meanprecippctile=squeeze(mean(precippctiles{reg},'omitnan'));
        meantivtpctile=squeeze(mean(tivtpctiles{reg},'omitnan'));
        %daystopick=[1;3;5]; %old default
        daystopick=[2;3;4];

        figure(700+reg);clf;
        %Left column: Tw/AR
        for dayc=1:3
            mymap_tw=zeros(52,94);mymap_ar=2.*ones(52,94);
            daytopick=daystopick(dayc);
            for lat=1:52
                for lon=1:94
                    if meantwpctile(lat,lon,daytopick)>=95
                        mymap_tw(lat,lon)=3;
                    elseif meantwpctile(lat,lon,daytopick)>=90
                        mymap_tw(lat,lon)=2;
                    elseif meantwpctile(lat,lon,daytopick)>=75
                        mymap_tw(lat,lon)=1;
                    end

                    if meanarrellikelihood(lat,lon,daytopick)>=3
                        mymap_ar(lat,lon)=4;
                    elseif meanarrellikelihood(lat,lon,daytopick)>=2
                        mymap_ar(lat,lon)=3;
                    end
                end
            end
            mymap_ar=double(mymap_ar)+4;mymap_tw=double(mymap_tw);

            tonan=mymap_tw==0;mymap_tw(tonan)=NaN;
            
            %Make plot with shading and contours
            if dayc==1;subplot(3,1,1);else;axes('Position',[0.05 0.67-0.33*dayc 0.31 0.31]);end
            data={latarray_52x94;lonarray_52x94;mymap_tw};
            overlaydata={latarray_52x94;lonarray_52x94;mymap_ar};
            combinedcmap=[colormaps_heatars('whitelightreddarkred','more','not');colormaps_heatars('q','more','not')];
            caxmax=8;caxmin=-0.5;
            vararginnew={'datatounderlay';data;'underlaycaxismin';caxmin;'underlaycaxismax';caxmax;'underlaystepsize';1;'underlaycolormap';combinedcmap;
                'contour_underlay';1;'contourunderlayfill';1;'contourunderlaycolors';combinedcmap;'underlaytransparency';0.6;...
                'overlaynow';1;'nolinesbetweenfilledcontours';1;'twodifferentaxes';1;...
                'datatooverlay';overlaydata;'overlaycaxismin';caxmin;'overlaycaxismax';caxmax;'overlaystepsize';1;'overlaycolormap';combinedcmap;
                'contour_overlay';1;'contouroverlayfill';0;'contouroverlaycolors';combinedcmap;'contouroverlaylinewidth';1.5;'overlaytransparency';0.5;...
                'conttoplot';'North America';'nonewfig';1;'omitfirstsubplotcolorbar';1};
            datatype='custom';region='usa-slightlysmaller';
            clear cmapcolorstooutput1;
            [~,cmapcolorstooutput1]=plotModelData_heatars(data,region,vararginnew,datatype);
            %Add hatching between contours
            linewidth=0.8;linealpha=1;linedensity=1/4;lowercontourval=6.5;uppercontourval=7.5;
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_ar,lowercontourval,uppercontourval,...
                linewidth,cmapcolorstooutput1(8,:),linealpha,linedensity,'sw-ne');
            
            lowercontourval=7.5;uppercontourval=8.5;
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_ar,lowercontourval,uppercontourval,...
                linewidth,cmapcolorstooutput1(9,:),linealpha,linedensity,'nw-se');
            
            %Include color key
            t=text(0.41,0.08,'Tw > p95','color',combinedcmap(round(3*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.41,0.05,'Tw > p90','color',combinedcmap(round(2*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.41,0.02,'Tw > p75','color',combinedcmap(round(1*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.4,0.17,'RR[AR] > 3','color',combinedcmap(round(8*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.4,0.14,'RR[AR] > 2','color',combinedcmap(round(7*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            
            %Finish
            t=text(-0.02,0.51,subreglabels{dayc*3-2},'units','normalized');set(t,'fontsize',14,'fontweight','bold','fontname','arial');
            set(gca,'Position',[0.05 1-0.33*dayc 0.31 0.31]);

            set(gcf,'color','w');


            %Middle column: T/q
            mymap_t=zeros(52,94);mymap_q=5.*ones(52,94);
            daytopick=daystopick(dayc);
            for lat=1:52
                for lon=1:94
                    if meantpctile(lat,lon,daytopick)>=85
                        mymap_t(lat,lon)=3;
                    elseif meantpctile(lat,lon,daytopick)>=80
                        mymap_t(lat,lon)=2;
                    elseif meantpctile(lat,lon,daytopick)>=75
                        mymap_t(lat,lon)=1;
                    end

                    if meanqpctile(lat,lon,daytopick)>=95
                        mymap_q(lat,lon)=8;
                    elseif meanqpctile(lat,lon,daytopick)>=90
                        mymap_q(lat,lon)=7;
                    elseif meanqpctile(lat,lon,daytopick)>=75
                        mymap_q(lat,lon)=6;
                    end
                end
            end
            mymap_q=double(mymap_q);

            tonan=mymap_t==0;mymap_t(tonan)=NaN;
            
            %Make plot with shading and contours
            axes('Position',[0.37 0.67-0.33*dayc 0.31 0.31]);
            data={latarray_52x94;lonarray_52x94;double(mymap_t)};
            overlaydata={latarray_52x94;lonarray_52x94;double(mymap_q)};
            combinedcmap=[colormaps_heatars('whitelightreddarkred','more','not');colormaps_heatars('whitelightgreendarkgreen','more','not')];
            caxmax=8;caxmin=-0.5;
            vararginnew={'datatounderlay';data;'underlaycaxismin';caxmin;'underlaycaxismax';caxmax;'underlaystepsize';1;'underlaycolormap';combinedcmap;
                'contour_underlay';1;'contourunderlayfill';1;'contourunderlaycolors';combinedcmap;'underlaytransparency';0.6;...
                'overlaynow';1;'nolinesbetweenfilledcontours';1;'twodifferentaxes';1;...
                'datatooverlay';overlaydata;'overlaycaxismin';caxmin;'overlaycaxismax';caxmax;'overlaystepsize';1;'overlaycolormap';combinedcmap;
                'contour_overlay';1;'contouroverlayfill';0;'contouroverlaycolors';combinedcmap;'contouroverlaylinewidth';1.5;'overlaytransparency';0.5;...
                'conttoplot';'North America';'nonewfig';1;'omitfirstsubplotcolorbar';1};
            datatype='custom';region='usa-slightlysmaller';
            clear cmapcolorstooutput2;
            [~,cmapcolorstooutput2]=plotModelData_heatars(data,region,vararginnew,datatype);
            %Add hatching between contours
            linewidth=0.8;linealpha=1;linedensity=1/4;
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_q,5.5,6.5,...
                linewidth,cmapcolorstooutput2(7,:),linealpha,linedensity,'sw-ne');
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_q,6.5,7.5,...
                linewidth,cmapcolorstooutput2(8,:),linealpha,linedensity,'nw-se');
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_q,7.5,8.5,...
                linewidth,cmapcolorstooutput2(9,:),linealpha,linedensity,'sw-ne');

            %Finish
            t=text(-0.02,0.51,subreglabels{dayc*3-1},'units','normalized');set(t,'fontsize',14,'fontweight','bold','fontname','arial');
            set(gca,'Position',[0.37 1-0.33*dayc 0.31 0.31]);

            %Include color key
            t=text(0.42,0.08,'T > p85','color',combinedcmap(round(3*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.42,0.05,'T > p80','color',combinedcmap(round(2*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.42,0.02,'T > p75','color',combinedcmap(round(1*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.42,0.17,'q > p95','color',combinedcmap(round(8*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.42,0.14,'q > p90','color',combinedcmap(round(7*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.42,0.11,'q > p75','color',combinedcmap(round(6*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');

            set(gcf,'color','w');



            %Right column: Precip/IVT
            mymap_precip=zeros(52,94);mymap_tivt=1.*ones(52,94);
            daytopick=daystopick(dayc);
            for lat=1:52
                for lon=1:94
                    %if meanprecippctile(lat,lon,daytopick)>=75
                    %    mymap_precip(lat,lon)=3;
                    %elseif meanprecippctile(lat,lon,daytopick)>=66.7
                    %    mymap_precip(lat,lon)=2;
                    %end

                    if meanpreciprellikelihood(lat,lon,daytopick)>=2
                        mymap_precip(lat,lon)=3;
                    elseif meanpreciprellikelihood(lat,lon,daytopick)>=1.75
                        mymap_precip(lat,lon)=2;
                    elseif meanpreciprellikelihood(lat,lon,daytopick)>=1.5
                        mymap_precip(lat,lon)=1;
                    end

                    if meantivtpctile(lat,lon,daytopick)>=80
                        mymap_tivt(lat,lon)=4;
                    elseif meantivtpctile(lat,lon,daytopick)>=75
                        mymap_tivt(lat,lon)=3;
                    elseif meantivtpctile(lat,lon,daytopick)>=67
                        mymap_tivt(lat,lon)=2;
                    end
                end
            end
            mymap_precip=double(mymap_precip);mymap_tivt=double(mymap_tivt)+4;
            invalid=meanpreciplikelihood<0.1;mymap_precip(invalid)=0; %mask typically dry areas

            tonan=mymap_precip==0;mymap_precip(tonan)=NaN;
            
            %Make plot with shading and contours
            axes('Position',[0.69 0.67-0.33*dayc 0.31 0.31]);
            data={latarray_52x94;lonarray_52x94;double(mymap_precip)};
            overlaydata={latarray_52x94;lonarray_52x94;mymap_tivt};
            cmap1=colormaps_heatars('whitelightbluedarkblue','more','not');cmap2=colormaps_heatars('whiteendrainbow','129','not');
            combinedcmap=[cmap1;cmap2];
            caxmax=8;caxmin=-0.5;
            vararginnew={'datatounderlay';data;'underlaycaxismin';caxmin;'underlaycaxismax';caxmax;'underlaystepsize';1;'underlaycolormap';combinedcmap;
                'contour_underlay';1;'contourunderlayfill';1;'contourunderlaycolors';combinedcmap;'underlaytransparency';0.6;...
                'overlaynow';1;'nolinesbetweenfilledcontours';1;'twodifferentaxes';1;...
                'datatooverlay';overlaydata;'overlaycaxismin';caxmin;'overlaycaxismax';caxmax;'overlaystepsize';1;'overlaycolormap';combinedcmap;
                'contour_overlay';1;'contouroverlayfill';0;'contouroverlaycolors';combinedcmap;'contouroverlaylinewidth';1.5;'overlaytransparency';0.5;...
                'conttoplot';'North America';'nonewfig';1;'omitfirstsubplotcolorbar';1;'aretwocolorbarscombined';1};
            datatype='custom';region='usa-slightlysmaller';
            clear cmapcolorstooutput3;
            [~,cmapcolorstooutput3]=plotModelData_heatars(data,region,vararginnew,datatype);
            %Add hatching between contours
            linewidth=0.8;linealpha=1;linedensity=1/4;
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_tivt,5.5,6.5,...
                linewidth,cmapcolorstooutput3(7,:),linealpha,linedensity,'sw-ne');
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_tivt,6.5,7.5,...
                linewidth,cmapcolorstooutput3(8,:),linealpha,linedensity,'nw-se');
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_tivt,7.5,8.5,...
                linewidth,cmapcolorstooutput3(9,:),linealpha,linedensity,'sw-ne');
            %Finish
            t=text(-0.02,0.51,subreglabels{dayc*3},'units','normalized');set(t,'fontsize',14,'fontweight','bold','fontname','arial');
            set(gca,'Position',[0.69 1-0.33*dayc 0.31 0.31]);

            %Include color key
            t=text(0.39,0.08,'RR[P] > 2','color',combinedcmap(round(3*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.39,0.05,'RR[P] > 1.75','color',combinedcmap(round(2*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.39,0.02,'RR[P] > 1.5','color',combinedcmap(round(1*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.39,0.17,'IVT > p80','color',cmapcolorstooutput3(9,:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.39,0.14,'IVT > p75','color',cmapcolorstooutput3(8,:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');
            t=text(0.39,0.11,'IVT > p67','color',cmapcolorstooutput3(7,:),'units','normalized');set(t,'fontsize',9,'fontweight','bold','fontname','arial');

            set(gcf,'color','w');
        end

        curpart=1;highqualityfiguresetup_heatars;
        figname=strcat('bigpctilemap_',ncaregnamesshort{reg},'_',suf);
        curpart=2;highqualityfiguresetup_heatars;
    end
end


if makefig3==1
    lefts=[0.02;0.35;0.68;0.02;0.35;0.68;0.35];
    bottoms=[0.67;0.67;0.67;0.34;0.34;0.34;0.01];
    widtth=0.31;heighht=0.31;

    exist aroccurrences;
    if ans==0
        tmp=load(strcat(dataresloc_external,'bigpctilemap_data'));aroccurrences=tmp.aroccurrences;clear tmp;
    end

    supraregnames={'western-usa-smaller';'western-usa-smaller';'greater-western-usa'};

    figure(720);clf;hold on;
    for reg=1:7
        meantwpctile=squeeze(mean(twpctiles{reg}));
        meanarrellikelihood=squeeze(mean(aroccurrences{reg}))./repmat(meanarfreq,[1 1 5]);
        daystopick=[1;3;5];

        %Tw/AR
        for dayc=2:2 %i.e. central day/day 0
            mymap_tw=zeros(52,94);mymap_ar=2.*ones(52,94);
            daytopick=daystopick(dayc);
            for lat=1:52
                for lon=1:94
                    if meantwpctile(lat,lon,daytopick)>=95
                        mymap_tw(lat,lon)=3;
                    elseif meantwpctile(lat,lon,daytopick)>=90
                        mymap_tw(lat,lon)=2;
                    elseif meantwpctile(lat,lon,daytopick)>=75
                        mymap_tw(lat,lon)=1;
                    end

                    if meanarrellikelihood(lat,lon,daytopick)>=3
                        mymap_ar(lat,lon)=4;
                    elseif meanarrellikelihood(lat,lon,daytopick)>=2
                        mymap_ar(lat,lon)=3;
                    end
                end
            end
            mymap_ar=double(mymap_ar)+4;
            invalid=meanarfreq<0.05;mymap_ar(invalid)=6; %mask low-frequency areas

            
            %Make plot with shading and contours
            if reg==1;subplot(3,3,1);set(gca,'visible','off');else;axes('Position',[lefts(reg) bottoms(reg) widtth heighht]);end
            
            data={latarray_52x94;lonarray_52x94;double(mymap_tw)};
            overlaydata={latarray_52x94;lonarray_52x94;mymap_ar};
            combinedcmap=[colormaps_heatars('whitelightreddarkred','more','not');colormaps_heatars('q','more','not')]; %underlay colormap first
            caxmax=8;caxmin=-0.5;
            vararginnew={'datatounderlay';data;'underlaycaxismin';caxmin;'underlaycaxismax';caxmax;'underlaystepsize';1;'underlaycolormap';combinedcmap;
                'contour_underlay';1;'contourunderlayfill';1;'contourunderlaycolors';combinedcmap;'underlaytransparency';0.6;...
                'overlaynow';1;'nolinesbetweenfilledcontours';1;'twodifferentaxes';1;...
                'datatooverlay';overlaydata;'overlaycaxismin';caxmin;'overlaycaxismax';caxmax;'overlaystepsize';1;'overlaycolormap';combinedcmap;
                'contour_overlay';1;'contouroverlayfill';0;'contouroverlaycolors';combinedcmap;'contouroverlaylinewidth';1.5;'overlaytransparency';0.5;...
                'conttoplot';'North America';'nonewfig';1;'omitfirstsubplotcolorbar';1;'stateboundarycolor';'k'};
            datatype='custom';region='usa-slightlysmaller';stateboundaries=1;
            clear cmapcolorstooutput1;
            [~,cmapcolorstooutput1]=plotModelData_heatars(data,region,vararginnew,datatype);

            linewidth=0.8;linealpha=1;linedensity=1/4;
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_ar,6.5,7.5,...
                linewidth,cmapcolorstooutput1(8,:),linealpha,linedensity,'sw-ne');
            hatch_manual_heatars(latarray_52x94,lonarray_52x94,mymap_ar,7.5,8.5,...
                linewidth,cmapcolorstooutput1(9,:),linealpha,linedensity,'nw-se');
            %Finish
            t=text(-0.05,1,subreglabels{reg},'units','normalized');set(t,'fontsize',14,'fontweight','bold','fontname','arial');
            set(gca,'Position',[lefts(reg) bottoms(reg) widtth heighht]);
            set(gca,'visible','off');


            %Include color key
            if reg==7
                fs=14;
                t=text(1.1,0.7,'Pr[AR] > 3','color',combinedcmap(round(8*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.6,'Pr[AR] > 2','color',combinedcmap(round(7*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.5,'Tw > p95','color',combinedcmap(round(3*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.4,'Tw > p90','color',combinedcmap(round(2*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
                t=text(1.1,0.3,'Tw > p75','color',combinedcmap(round(1*length(combinedcmap)/8),:),'units','normalized');set(t,'fontsize',fs,'fontweight','bold','fontname','arial');
            end
            %%%
        end
    end
    set(gcf,'color','w');
    curpart=1;highqualityfiguresetup_heatars;figname='figure3';curpart=2;highqualityfiguresetup_heatars;

    clear aroccurrences;
end


%AR scale/humid heat scatterplot
if makefig2==1
    %Tw anom vs max AR scale in a 3-day window at that location
    %When there's high heat stress, is it more likely to be extreme if there's a more intense AR nearby?
    %For MJJAS days
    if doscalevsheatcalc==1
        tmp=load(strcat(figloc,'Data_&_Results/arscale_merra2.mat'));arscale_52x94=tmp.arscale_52x94;

        noarc=zeros(7,1);ar13c=zeros(7,1);ar45c=zeros(7,1);
        noar_twp95_1day_100km=cell(7,1);ar13_twp95_1day_100km=cell(7,1);ar45_twp95_1day_100km=cell(7,1);
    
        noarc_bypt_may=zeros(52,94);anyarc_bypt_may=zeros(52,94);
        noarc_bypt_jun=zeros(52,94);anyarc_bypt_jun=zeros(52,94);
        noarc_bypt_jul=zeros(52,94);anyarc_bypt_jul=zeros(52,94);
        noarc_bypt_aug=zeros(52,94);anyarc_bypt_aug=zeros(52,94);
        noarc_bypt_sep=zeros(52,94);anyarc_bypt_sep=zeros(52,94);
        noar_twp95_1day_100km_bypt=cell(52,94);anyar_twp95_1day_100km_bypt=cell(52,94);
        noar_twp95_1day_100km_bypt_may=cell(52,94);anyar_twp95_1day_100km_bypt_may=cell(52,94);
        noar_twp95_1day_100km_bypt_jun=cell(52,94);anyar_twp95_1day_100km_bypt_jun=cell(52,94);
        noar_twp95_1day_100km_bypt_jul=cell(52,94);anyar_twp95_1day_100km_bypt_jul=cell(52,94);
        noar_twp95_1day_100km_bypt_aug=cell(52,94);anyar_twp95_1day_100km_bypt_aug=cell(52,94);
        noar_twp95_1day_100km_bypt_sep=cell(52,94);anyar_twp95_1day_100km_bypt_sep=cell(52,94);
    
        for y=1:41
            for doy=may1doy+1:sep30doy-1
                mon=DOYtoMonth_heatars(doy,y);
                for i=1:52
                    for j=1:94
                        reg=thencaregions(i,j)-1;
                        if reg~=-1
                            %AR within 1 day and within 100 km
                            mylat=latarray_52x94(i,j);mylon=lonarray_52x94(i,j);maxarscalesofar=0;
                            for ii=max(1,i-5):min(52,i+5)
                                for jj=max(1,j-5):min(94,j+5)
                                    lat2=latarray_52x94(ii,jj);lon2=lonarray_52x94(ii,jj);
                                    if 111*sqrt((mylat-lat2)^2+(mylon-lon2)^2)<=100 %use approx. distance, to speed things up
                                        tocompare=max(arscale_52x94(y,doy-1:doy+1,ii,jj));
                                        if tocompare>maxarscalesofar;maxarscalesofar=tocompare;end
                                    end
                                end
                            end
                            if maxarscalesofar==0 %no AR
                                noarc(reg)=noarc(reg)+1;
                                if tw_52x94(y,doy,i,j)>=twp95(i,j);noar_twp95_1day_100km{reg}(noarc(reg))=1;else;noar_twp95_1day_100km{reg}(noarc(reg))=0;end

                                if mon==5
                                    noarc_bypt_may(i,j)=noarc_bypt_may(i,j)+1;noar_twp95_1day_100km_bypt_may{i,j}(noarc_bypt_may(i,j))=1;
                                elseif mon==6
                                    noarc_bypt_jun(i,j)=noarc_bypt_jun(i,j)+1;noar_twp95_1day_100km_bypt_jun{i,j}(noarc_bypt_jun(i,j))=1;
                                elseif mon==7
                                    noarc_bypt_jul(i,j)=noarc_bypt_jul(i,j)+1;noar_twp95_1day_100km_bypt_jul{i,j}(noarc_bypt_jul(i,j))=1;
                                elseif mon==8
                                    noarc_bypt_aug(i,j)=noarc_bypt_aug(i,j)+1;noar_twp95_1day_100km_bypt_aug{i,j}(noarc_bypt_aug(i,j))=1;
                                elseif mon==9
                                    noarc_bypt_sep(i,j)=noarc_bypt_sep(i,j)+1;noar_twp95_1day_100km_bypt_sep{i,j}(noarc_bypt_sep(i,j))=1;
                                end
                            elseif maxarscalesofar<=3 %AR 1-3
                                ar13c(reg)=ar13c(reg)+1;
                                if tw_52x94(y,doy,i,j)>=twp95(i,j);ar13_twp95_1day_100km{reg}(ar13c(reg))=1;else;ar13_twp95_1day_100km{reg}(ar13c(reg))=0;end
                            elseif maxarscalesofar>=4 %AR 4-5
                                ar45c(reg)=ar45c(reg)+1;
                                if tw_52x94(y,doy,i,j)>=twp95(i,j);ar45_twp95_1day_100km{reg}(ar45c(reg))=1;else;ar45_twp95_1day_100km{reg}(ar45c(reg))=0;end
                            end
                            if maxarscalesofar>=1
                                if mon==5
                                    anyarc_bypt_may(i,j)=anyarc_bypt_may(i,j)+1;anyar_twp95_1day_100km_bypt_may{i,j}(anyarc_bypt_may(i,j))=1;
                                elseif mon==6
                                    anyarc_bypt_jun(i,j)=anyarc_bypt_jun(i,j)+1;anyar_twp95_1day_100km_bypt_jun{i,j}(anyarc_bypt_jun(i,j))=1;
                                elseif mon==7
                                    anyarc_bypt_jul(i,j)=anyarc_bypt_jul(i,j)+1;anyar_twp95_1day_100km_bypt_jul{i,j}(anyarc_bypt_jul(i,j))=1;
                                elseif mon==8
                                    anyarc_bypt_aug(i,j)=anyarc_bypt_aug(i,j)+1;anyar_twp95_1day_100km_bypt_aug{i,j}(anyarc_bypt_aug(i,j))=1;
                                elseif mon==9
                                    anyarc_bypt_sep(i,j)=anyarc_bypt_sep(i,j)+1;anyar_twp95_1day_100km_bypt_sep{i,j}(anyarc_bypt_sep(i,j))=1;
                                end
                            end
                        end
                    end
                end
            end
        end
        save(strcat(figloc,'Data_&_Results/arscalearrays'),'noarc','ar13c','ar45c',...
            'noar_twp95_1day_100km','ar13_twp95_1day_100km','ar45_twp95_1day_100km');      
        
        
        %Relative risk of exceeding Tw extremes for no AR vs AR 1-3 vs AR 4-5
        for reg=1:7
            relrisk_twp95_1day_100km_noar(reg)=(sum(noar_twp95_1day_100km{reg})/noarc(reg))./0.05;
            relrisk_twp95_1day_100km_ar13(reg)=(sum(ar13_twp95_1day_100km{reg})/ar13c(reg))./0.05;
            relrisk_twp95_1day_100km_ar45(reg)=(sum(ar45_twp95_1day_100km{reg})/ar45c(reg))./0.05;
        end
        for i=1:52
            for j=1:94
                relrisk_twp95_1day_100km_noar_bypt_may(i,j)=(sum(noar_twp95_1day_100km_bypt_may{i,j})/noarc_bypt_may(i,j))./0.05;
                relrisk_twp95_1day_100km_anyar_bypt_may(i,j)=(sum(anyar_twp95_1day_100km_bypt_may{i,j})/anyarc_bypt_may(i,j))./0.05;
                relrisk_twp95_1day_100km_noar_bypt_jun(i,j)=(sum(noar_twp95_1day_100km_bypt_jun{i,j})/noarc_bypt_jun(i,j))./0.05;
                relrisk_twp95_1day_100km_anyar_bypt_jun(i,j)=(sum(anyar_twp95_1day_100km_bypt_jun{i,j})/anyarc_bypt_jun(i,j))./0.05;
                relrisk_twp95_1day_100km_noar_bypt_jul(i,j)=(sum(noar_twp95_1day_100km_bypt_jul{i,j})/noarc_bypt_jul(i,j))./0.05;
                relrisk_twp95_1day_100km_anyar_bypt_jul(i,j)=(sum(anyar_twp95_1day_100km_bypt_jul{i,j})/anyarc_bypt_jul(i,j))./0.05;
                relrisk_twp95_1day_100km_noar_bypt_aug(i,j)=(sum(noar_twp95_1day_100km_bypt_aug{i,j})/noarc_bypt_aug(i,j))./0.05;
                relrisk_twp95_1day_100km_anyar_bypt_aug(i,j)=(sum(anyar_twp95_1day_100km_bypt_aug{i,j})/anyarc_bypt_aug(i,j))./0.05;
                relrisk_twp95_1day_100km_noar_bypt_sep(i,j)=(sum(noar_twp95_1day_100km_bypt_sep{i,j})/noarc_bypt_sep(i,j))./0.05;
                relrisk_twp95_1day_100km_anyar_bypt_sep(i,j)=(sum(anyar_twp95_1day_100km_bypt_sep{i,j})/anyarc_bypt_sep(i,j))./0.05;
            end
        end
        save(strcat(figloc,'Data_&_Results/relriskbyregdata'),'relrisk_twp95_1day_100km_noar','relrisk_twp95_1day_100km_ar13','relrisk_twp95_1day_100km_ar45');
        save(strcat(figloc,'Data_&_Results/relriskbyptdata'),'relrisk_twp95_1day_100km_noar_bypt_may','relrisk_twp95_1day_100km_anyar_bypt_may',...
            'relrisk_twp95_1day_100km_noar_bypt_jun','relrisk_twp95_1day_100km_anyar_bypt_jun','relrisk_twp95_1day_100km_noar_bypt_jul','relrisk_twp95_1day_100km_anyar_bypt_jul',...
            'relrisk_twp95_1day_100km_noar_bypt_aug','relrisk_twp95_1day_100km_anyar_bypt_aug','relrisk_twp95_1day_100km_noar_bypt_sep','relrisk_twp95_1day_100km_anyar_bypt_sep');
    end
    
    %Plot
    if actuallymakeplot==1
        tmp=load(strcat(figloc,'Data_&_Results/arscale_merra2.mat'));arscale_52x94=tmp.arscale_52x94;

        figure(676);clf;
        subplot(2,1,1);hold on;
        stdnumpts=50;
        numpts_2to3=round(stdnumpts*((1/2-1/3)/(1-1/2)));
        newyaxes=unique([linspace(1/3,1/2,numpts_2to3) linspace(1/2,1,stdnumpts) linspace(1,2,stdnumpts) linspace(2,3,numpts_2to3)]);
        for reg=1:7
            noar_valtoplot=relrisk_twp95_1day_100km_noar(reg);
            ar13_valtoplot=relrisk_twp95_1day_100km_ar13(reg);
            ar45_valtoplot=relrisk_twp95_1day_100km_ar45(reg);

            valstoplot=[noar_valtoplot;ar13_valtoplot;ar45_valtoplot];
            %colorstoplot={colors('gold');colors('histogram blue');colors('purple')};
            colorstoplot={regcolors_verypale{reg};regcolors_pale{reg};regcolors{reg}};

            %Add light gray shaded boxes in background to better distinguish regions from each other
            if rem(reg,2)==0
                p=patch([reg*5-5.5 reg*5-5.5 reg*5-0.5 reg*5-0.5],[0.001 10 10 0.001],colors('very light gray'),'EdgeColor',colors('very light gray'));
            end

            for val=1:3
                origy=valstoplot(val);
                [~,temp]=min(abs(origy-newyaxes));relpos=temp/size(newyaxes,2);
                if val==1
                    p=plot(reg*5-4,relpos,'o','MarkerSize',12,'MarkerEdgeColor',colorstoplot{val},'MarkerFaceColor',colorstoplot{val});
                elseif val==2
                    p=plot(reg*5-3,relpos,'o','MarkerSize',12,'MarkerEdgeColor',colorstoplot{val},'MarkerFaceColor',colorstoplot{val});
                elseif val==3
                    p=plot(reg*5-2,relpos,'o','MarkerSize',12,'MarkerEdgeColor',colorstoplot{val},'MarkerFaceColor',colorstoplot{val});
                end
                
                if reg==1 && val==1
                    [~,temp]=min(abs(1/3-newyaxes));relpos_onethird=temp/size(newyaxes,2)-0.5/size(newyaxes,2);
                    [~,temp]=min(abs(1/2-newyaxes));relpos_onehalf=temp/size(newyaxes,2)-0.5/size(newyaxes,2);
                    [~,temp]=min(abs(1-newyaxes));relpos_one=temp/size(newyaxes,2)-0.5/size(newyaxes,2);
                    [~,temp]=min(abs(2-newyaxes));relpos_two=temp/size(newyaxes,2)-0.5/size(newyaxes,2);
                    [~,temp]=min(abs(3-newyaxes));relpos_three=temp/size(newyaxes,2)-0.5/size(newyaxes,2);
                end
            end
        end
        ylim([0 1]);xlim([0.5 33.5]);
        yticklocs=[relpos_onethird relpos_onehalf relpos_one relpos_two relpos_three];
        set(gca,'ytick',yticklocs,'yticklabels',{'1/3';'1/2';'1';'2';'3'});
        xticklocs=[2:5:numregs*5];
        set(gca,'xtick',xticklocs,'xticklabels',ncaregnamesshort_caps);
        ylabel('Rel. Risk of Extreme Tw','fontsize',12,'fontweight','bold','fontname','arial');
        set(gca,'fontsize',12,'fontweight','bold','fontname','arial');



        %Below, put the former "hsvsnohs" plot
        %Contrast humid-heat versus no-humid-heat sets of days, esp in terms of AR gridpt fraction
        argridptfrac_obscontrast_hs=cell(7,1);argridptfrac_obscontrast_nohs=cell(7,1);
        %argridptfrac_obscontrast_hs_mean=zeros(7,1);
        for reg=1:7
            c1=0;c2=0;
            for y=1:41
                for doy=may1doy:sep30doy
                    if regheatstressdays(y,doy,reg)==1
                        c1=c1+1;argridptfrac_obscontrast_hs{reg}(c1)=mean(ar_52x94(y,doy,thencaregions==reg+1));
                    elseif highz500noheatstressdays(y,doy,reg)==1
                        c2=c2+1;argridptfrac_obscontrast_nohs{reg}(c2)=mean(ar_52x94(y,doy,thencaregions==reg+1));
                    end
                end
            end
    
            f300=figure(300+reg);clf;edges=[0:0.2:1];
            subplot(2,1,1);h1=histogram(argridptfrac_obscontrast_hs{reg},edges,'Normalization','probability');xlim([0 1]);ylim([0 0.75]);
            subplot(2,1,2);h2=histogram(argridptfrac_obscontrast_nohs{reg},edges,'Normalization','probability');xlim([0 1]);ylim([0 0.75]);
    
            figure(676);subplot(2,1,2);hold on;
            hratio=h1.Values./h2.Values;invalid=h1.Values==0;hratio(invalid)=NaN;invalid=h2.Values<0.01;hratio(invalid)=NaN;
            transformed=transformdata_heatars(hratio,4);
            plot(transformed,'color',regcolors{reg},'linewidth',2);
            set(gca,'fontsize',11,'fontweight','bold','fontname','arial');
            xlim([1 5]);set(gca,'xtick',1:5,'xticklabel',{'0-0.2';'0.2-0.4';'0.4-0.6';'0.6-0.8';'0.8-1'});
            ylim([1 5]);set(gca,'ytick',1:5,'yticklabel',{'1/4';'1/2';'1';'2';'4'});
            xlabel('AR gridpoint fraction','fontsize',12,'fontweight','bold','fontname','arial');
    
            y2=3.*ones(5,1);x2=[1:5]';plot(x2,y2,'--','color',colors('gray'),'linewidth',1.5);
            
            close(f300);
        end
        set(gca,'Position',[0.25 0.08 0.5 0.4],'fontsize',12,'fontweight','bold','fontname','arial');
        ylabel('Rel. Risk of Extreme Tw','fontsize',12,'fontweight','bold','fontname','arial');

        set(gcf,'color','w');
        curpart=1;highqualityfiguresetup_heatars;
        figname='figure2';curpart=2;highqualityfiguresetup_heatars;
    end
    clear arscale_52x94; %to save workspace memory
end


if makefig4==1
    figure(21);clf;hold on;curpart=1;highqualityfiguresetup_heatars;
    set(gca,'visible','off');
    
    for loop=1:4
        if loop==1
            thisarr=likelihooddiffprecipheat;
            leftpos=0.02;bottompos=0.5;
        elseif loop==2
            thisarr=likelihooddiffarheat./likelihooddiffprecipheat;subplot(10,10,100);set(gca,'visible','off');
            leftpos=0.02;bottompos=0.02;
        elseif loop==3
            thisarr=likelihooddifftivtheat;subplot(10,10,100);set(gca,'visible','off');
            leftpos=0.48;bottompos=0.5;
        elseif loop==4
            thisarr=likelihooddiffarheat./likelihooddifftivtheat;subplot(10,10,100);set(gca,'visible','off');
            leftpos=0.48;bottompos=0.02;
        end
        width=0.42;height=0.45;
    
        invalid=thisarr>50;thisarr(invalid)=NaN;invalid=thisarr==0;thisarr(invalid)=NaN;
        invalid=isnan(lsmask_52x94);thisarr(invalid)=NaN;invalid=lsmask_52x94==0;thisarr(invalid)=NaN;
        
        %Remove a few gridcells that are contaminated by being partly in water
        thisarr(8,68)=NaN;thisarr(10,62)=NaN;
        
        
        %Set up colormap
        maxfactor=3;
        [cmapbelow1,cmapabove1]=fractionalcolormap_heatars(maxfactor,colormaps_heatars('q','more','not'));
    
        caxismina=1/maxfactor;caxismaxa=1;caxisstep=0.1;
        relriskp95_below1=thisarr.*(thisarr<caxismaxa);
        invalid=relriskp95_below1==0;relriskp95_below1(invalid)=NaN;
        hAxesa=axes;cmapa=colormap(hAxesa,gray);
        
        if maxfactor==4
            cbticks_below1=[1/4 2/4 3/4];
            cbticklabels_below1={'0.25','0.33','0.5'};
            cbticks_above1=[1 2 3 4];
        elseif maxfactor==3
            cbticks_below1=[1/3 2/3];
            cbticklabels_below1={'0.33','0.5'};
            cbticks_above1=[1 2 3];
        elseif maxfactor==2
            cbticks_below1=[1/2];
            cbticklabels_below1={'0.5'};
            cbticks_above1=[1 2];
        end
        
        if strcmp(regtoplot,'central-us');cbar1pos=0.77;cbar2pos=0.83;elseif strcmp(regtoplot,'usa');cbar1pos=0.9;cbar2pos=0.96;end
        
        if strcmp(ardataset,'era-interim')
            latarrayhere=latarray(northrow:southrow,westcol:eastcol);lonarrayhere=lonarray(northrow:southrow,westcol:eastcol);
        elseif strcmp(ardataset,'merra2')
            latarrayhere=latarray;lonarrayhere=lonarray;
        end
        data={latarrayhere;lonarrayhere;relriskp95_below1};
        vararginnew={'datatounderlay';data;'underlaycaxismin';caxismina;'underlaycaxismax';caxismaxa;'mystepunderlay';caxisstep;...
            'underlaycolormap';cmapbelow1;'variable';'temperature';'overlaynow';0;...
            'conttoplot';'North America';'nonewfig';1;'nanstransparent';1;'colorbarposition';[0.92 0.1 0.02 0.4];'colorbarfontsize';12;...
            'colorbarticks';cbticks_below1;'colorbarticklabels';cbticklabels_below1};
        datatype='custom';region=regtoplot;
        plotModelData_heatars(data,region,vararginnew,datatype);

        set(gca,'Position',[leftpos bottompos width height]);

        %Add bolded region outlines
        g=geoshow(northwestpolygonlats,northwestpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(southwestpolygonlats,southwestpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(gpnpolygonlats,gpnpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(gpspolygonlats,gpspolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(midwestpolygonlats,midwestpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(southeastpolygonlats,southeastpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(northeastpolygonlats,northeastpolygonlons);set(g,'Color','k','LineWidth',2);


        
        caxisminb=1;caxismaxb=maxfactor;caxisstep=1/maxfactor;
        relriskp95_above1=thisarr.*(thisarr>caxismaxa);
        invalid=relriskp95_above1==0;relriskp95_above1(invalid)=NaN;
        hAxesb=axes;cmapb=colormap(hAxesb,gray);
        
        data={latarrayhere;lonarrayhere;relriskp95_above1};
        vararginnew={'datatounderlay';data;'underlaycaxismin';caxisminb;'underlaycaxismax';caxismaxb;'mystepunderlay';caxisstep;...
            'underlaycolormap';cmapabove1;'variable';'temperature';'overlaynow';0;...
            'conttoplot';'North America';'nonewfig';1;'nanstransparent';1;'colorbarposition';[0.92 0.5 0.02 0.4];'colorbarfontsize';12;'colorbarticks';cbticks_above1};
        datatype='custom';region=regtoplot;
        plotModelData_heatars(data,region,vararginnew,datatype);

        set(gca,'Position',[leftpos bottompos width height]);

        
        %Add bolded region outlines
        g=geoshow(northwestpolygonlats,northwestpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(southwestpolygonlats,southwestpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(gpnpolygonlats,gpnpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(gpspolygonlats,gpspolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(midwestpolygonlats,midwestpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(southeastpolygonlats,southeastpolygonlons);set(g,'Color','k','LineWidth',2);
        g=geoshow(northeastpolygonlats,northeastpolygonlons);set(g,'Color','k','LineWidth',2);

        t=text(-0.01,0.51,splabels{loop},'units','normalized');set(t,'fontsize',12,'fontweight','bold','fontname','arial');
    end
    set(gcf,'color','w');
    
    curpart=1;highqualityfiguresetup_heatars;
    figname='figure4';curpart=2;highqualityfiguresetup_heatars;
end
