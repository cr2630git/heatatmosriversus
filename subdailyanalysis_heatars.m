%Look at subdaily T, Td, and Tw for a particular stn


%Use completestndataanalysis.m as a guide for running this script and its companions


%Total runtime: approx 30 sec per station


makefigure=0; %default is 0
standaloneplot=0; %default is 0
trytodeterminesettingsautomatically=1; %default is 1
includestnwind=0; %default is 0

validtimevec=0; %default is 0



%Time series of subdaily T, Td, and Tw at a given station on a given day, or a set of them
clear subdailytimes;clear subdailyt;clear subdailytd;clear subdailytw;
firsthourtoplot=(d-daystogoout)*24-23;lasthourtoplot=(d+daystogoout)*24;

timestopick=time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot;
subdailytimes=time(timestopick);
subdailyt=temperature(timestopick);
subdailytd=dewpoint(timestopick);
subdailytw=wetbulb(timestopick);


%Also create versions that have no gaps by filling in missing values with NaN
clear subdailytimes_filled;clear subdailyt_filled;clear subdailytd_filled;clear subdailytw_filled;
c=0;
for hr=firsthourtoplot:lasthourtoplot
    thistime=subdailytimes(subdailytimes(:,1)==hr);
    c=c+1;
    if size(thistime,1)==1 %hr exists in subdailytimes
        subdailytimes_filled(c)=subdailytimes(subdailytimes(:,1)==hr);
        subdailyt_filled(c)=subdailyt(subdailytimes(:,1)==hr);
        subdailytd_filled(c)=subdailytd(subdailytimes(:,1)==hr);
        subdailytw_filled(c)=subdailytw(subdailytimes(:,1)==hr);
    else %hr does not exist -- fill in NaN
        subdailytimes_filled(c)=NaN;
        subdailyt_filled(c)=NaN;
        subdailytd_filled(c)=NaN;
        subdailytw_filled(c)=NaN;
    end
end


%%%%%THIS IS THE END OF THE STANDARD CALCULATION -- THE REMAINDER IS
%%%%%OPTIONAL OR SPECIFIC TO PAST PROJECTS%%%%%









if trytodeterminesettingsautomatically==0
    %%shouldn't be necessary, but if desired/for troubleshooting, compare firsthourtoplot and subdailytimes(1:10) to identify the actual
    %desired start hour [adsh] and the actual hourinterval (the most common temporal resolution of the data in this timeslice)
else 
    if size(subdailytimes,1)>=1
        adsh=max(firsthourtoplot,subdailytimes(1));
        subdailytimesoffset=subdailytimes(2:end);diffs=subdailytimesoffset-subdailytimes(1:end-1);
        hourinterval=mode(diffs);
    else
        validtimevec=0;
    end
end
%fprintf('This hour interval is %d\n',hourinterval);

%Adjust for time zone
if validtimevec==1
    deshour=adsh;numhr=(lasthourtoplot-firsthourtoplot+1)/hourinterval;
    cursubdailytimeindex=1;
    clear subdailytimesadj;clear subdailytadj;clear subdailytdadj;clear subdailytwadj;
    for i=1:numhr
        %disp('line 183');disp(deshour);
        if cursubdailytimeindex<=size(subdailytimes,1)
            %disp(subdailytimes(cursubdailytimeindex));
            if checkifthingsareelementsofvector(subdailytimes(cursubdailytimeindex),deshour)
                subdailytimesadj(i)=subdailytimes(cursubdailytimeindex);
                subdailytadj(i)=subdailyt(cursubdailytimeindex);
                subdailytdadj(i)=subdailytd(cursubdailytimeindex);
                subdailytwadj(i)=subdailytw(cursubdailytimeindex);
                localhourofday(i)=rem(subdailytimes(cursubdailytimeindex)+finalstntzs(s),24);
                utchourofday(i)=rem(subdailytimes(cursubdailytimeindex),24);
                cursubdailytimeindex=cursubdailytimeindex+1;
            else
                subdailytimesadj(i)=NaN;
                subdailytadj(i)=NaN;
                subdailytdadj(i)=NaN;
                subdailytwadj(i)=NaN;
                localhourofday(i)=NaN;
                utchourofday(i)=NaN;
            end
        else
            subdailytimesadj(i)=NaN;
            subdailytadj(i)=NaN;
            subdailytdadj(i)=NaN;
            subdailytwadj(i)=NaN;
            localhourofday(i)=NaN;
            utchourofday(i)=NaN;
        end

        if localhourofday(i)>24;localhourofday(i)=localhourofday(i)-24;end
        if utchourofday(i)>24;utchourofday(i)=utchourofday(i)-24;end
        deshour=deshour+hourinterval;
    end
    invalid=subdailytadj==0;subdailytadj(invalid)=NaN;
    invalid=subdailytdadj==0;subdailytdadj(invalid)=NaN;
    invalid=subdailytwadj==0;subdailytwadj(invalid)=NaN;
end



if includestnwind==1
    exist finalwinddirarray;
    if ans==0
        disp('Need to run computedailydataaddlvars loop of downloadprephadisddata.m');return;
    end
end


%Also get stn wind dirs
%Only works if stn hour interval = 1
if includestnwind==1 && validtimevec==1
    stnwinddirs=[finalwinddirarray{s}((d-15341)-3,:)';finalwinddirarray{s}((d-15341)-2,:)';...
        finalwinddirarray{s}((d-15341)-1,:)';...
        finalwinddirarray{s}((d-15341),:)';finalwinddirarray{s}((d-15341)+1,:)';...
        finalwinddirarray{s}((d-15341)+2,:)';finalwinddirarray{s}((d-15341)+3,:)'];
     stnwindspds=[finalwindspdarray{s}((d-15341)-3,:)';finalwindspdarray{s}((d-15341)-2,:)';...
        finalwindspdarray{s}((d-15341)-1,:)';...
        finalwindspdarray{s}((d-15341),:)';finalwindspdarray{s}((d-15341)+1,:)';...
        finalwindspdarray{s}((d-15341)+2,:)';finalwindspdarray{s}((d-15341)+3,:)'];
    for i=1:numhr
        if rem(i/3,1)==0
            stnwinddirs3hourly(i)=stnwinddirs(i);
            stnwindspds3hourly(i)=stnwindspds(i);
        else
            stnwinddirs3hourly(i)=NaN;
            stnwindspds3hourly(i)=NaN;
        end
    end
end


%Make figure, if desired
if makefigure==1 && validtimevec==1
    %Set figure font size
    if standaloneplot==1;fs=16;else;fs=8;end

    %Plot T, Td, and Tw, adding linear interpolation as necessary for hour intervals >1
    if hourinterval==3
        clear subdailytadjinterp;clear subdailytdadjinterp;clear subdailywbtadjinterp;
        loweroldindex=0;upperoldindex=1;
        for newindex=1:166
            if rem((newindex-1)/3,1)==0
                loweroldindex=loweroldindex+1;
                upperoldindex=upperoldindex+1;
            end
            
            if rem((newindex-1),3)==0
                subdailytadjinterp(newindex)=subdailytadj(loweroldindex);
                subdailytdadjinterp(newindex)=subdailytdadj(loweroldindex);
                subdailywbtadjinterp(newindex)=subdailytwadj(loweroldindex);
            elseif rem((newindex-1),3)==1
                subdailytadjinterp(newindex)=0.67*subdailytadj(loweroldindex)+0.33*subdailytadj(upperoldindex);
                subdailytdadjinterp(newindex)=0.67*subdailytdadj(loweroldindex)+0.33*subdailytdadj(upperoldindex);
                subdailywbtadjinterp(newindex)=0.67*subdailytwadj(loweroldindex)+0.33*subdailytwadj(upperoldindex);
            else
                subdailytadjinterp(newindex)=0.33*subdailytadj(loweroldindex)+0.67*subdailytadj(upperoldindex);
                subdailytdadjinterp(newindex)=0.33*subdailytdadj(loweroldindex)+0.67*subdailytdadj(upperoldindex);
                subdailywbtadjinterp(newindex)=0.33*subdailytwadj(loweroldindex)+0.67*subdailytwadj(upperoldindex);
            end

            %if newindex<10;disp(newindex);disp(loweroldindex);fprintf('\n');end
        end
        subdailytadj=subdailytadjinterp;
        subdailytdadj=subdailytdadjinterp;
        subdailytwadj=subdailywbtadjinterp;
    elseif hourinterval~=1
        disp('Please select a different station, or modify this code in subdailyanalysis');
    end
    exist domainstn;
    if ans==0;domainstn=1;end %default is 1

    if standaloneplot==1
        disp('line 265');
        figure(100);clf;curpart=1;highqualityfiguresetup;
        plot(subdailytadj,'r','linewidth',2);hold on;
        plot(subdailytdadj,'b','linewidth',2);
        plot(subdailytwadj,'color',colors('emerald'),'linewidth',2);
    else
        if domainstn==1
            h=plot(subdailytadj,'r','linewidth',1.5);h.Color=[h.Color 0.3];hold on;
            h=plot(subdailytdadj,'color',colors('moderate dark blue'),'linewidth',1.5);h.Color=[h.Color 0.3];
            plot(subdailytwadj,'k','linewidth',1.5);
        elseif dostn2==1
            plot(subdailytwadj,'k--','linewidth',1.5);
        elseif dostn3==1
            plot(subdailytwadj,'k:','linewidth',1.5);
        end
    end
    
    %Plot winds
    %Vectors are currently scaled assuming a max u or v wind speed
    %component of 20 knots, and this would take up a fractional size equal to double the xspacing
    if includestnwind==1
        result=get(gca,'Position');l=result(1);b=result(2);w=result(3);h=result(4);
        xspacing=w/size(stnwinddirs3hourly,2);
        sf=20; %scaling factor
        for i=1:size(stnwinddirs3hourly,2)
            thiswinddir=stnwinddirs3hourly(i);
            thiswindspd=stnwindspds3hourly(i);
            
            
            if ~isnan(thiswinddir) && ~isnan(thiswindspd)
                [u,v]=uandvfromwinddirandspeed(thiswinddir,thiswindspd);
                uscaled=(u/sf)*xspacing;vscaled=(v/sf)*xspacing;
                
                xleft=l+xspacing*i;
                x=[xleft xleft+uscaled];
                top=b+h;
                if vscaled>=0;y=[top top+vscaled];else;y=[top-vscaled top];end
                annotation('arrow',x,y);
            end
        end
    end
    
    %Include ticks and labels
    doysplotted=thisdaydoy-3:thisdaydoy+5;
    for i=1:size(doysplotted,2);thismonthday{i}=DOYtoDate(doysplotted(i),thisdayyear);end
    oldhourmethod=0;
    if oldhourmethod==1 %local
        if localhourofday(1)<10;addzero='0';else;addzero='';end;namehourlabel1=strcat(addzero,num2str(localhourofday(1)));
        if localhourofday(1)>=12;hourlabel2=localhourofday(1)-12;else;hourlabel2=localhourofday(1)+12;end
        if hourlabel2<10;addzero='0';else;addzero='';end;namehourlabel2=strcat(addzero,num2str(hourlabel2));
        hournames={namehourlabel1;namehourlabel2};
        xticks(1:12/hourinterval:numhr);
        if localhourofday(1)<12 %starts in the morning
            xticklabels({strcat([namehourlabel1,' LST ',thismonthday{1}]),...
            strcat([namehourlabel2,' LST ',thismonthday{1}]),strcat([namehourlabel1,' LST ',thismonthday{2}]),...
            strcat([namehourlabel2,' LST ',thismonthday{2}]),...
            strcat([namehourlabel1,' LST ',thismonthday{3}]),strcat([namehourlabel2,' LST ',thismonthday{3}]),...
            strcat([namehourlabel1,' LST ',thismonthday{4}]),...
            strcat([namehourlabel2,' LST ',thismonthday{4}]),strcat([namehourlabel1,' LST ',thismonthday{5}]),...
            strcat([namehourlabel2,' LST ',thismonthday{5}]),...
            strcat([namehourlabel1,' LST ',thismonthday{6}]),strcat([namehourlabel2,' LST ',thismonthday{6}]),...
            strcat([namehourlabel1,' LST ',thismonthday{7}]),strcat([namehourlabel2,' LST ',thismonthday{7}])});
        else %starts in the afternoon or evening
            xticklabels({strcat([namehourlabel1,' LST ',thismonthday{1}]),...
            strcat([namehourlabel1,' LST ',thismonthday{2}]),strcat([namehourlabel1,' LST ',thismonthday{2}]),...
            strcat([namehourlabel1,' LST ',thismonthday{3}]),...
            strcat([namehourlabel1,' LST ',thismonthday{3}]),strcat([namehourlabel1,' LST ',thismonthday{4}]),...
            strcat([namehourlabel1,' LST ',thismonthday{4}]),...
            strcat([namehourlabel1,' LST ',thismonthday{5}]),strcat([namehourlabel1,' LST ',thismonthday{5}]),...
            strcat([namehourlabel1,' LST ',thismonthday{6}]),...
            strcat([namehourlabel1,' LST ',thismonthday{6}]),strcat([namehourlabel1,' LST ',thismonthday{7}]),...
            strcat([namehourlabel1,' LST ',thismonthday{7}]),strcat([namehourlabel1,' LST ',thismonthday{8}])});
        end
    else %display UTC
        xticks(1:24/hourinterval:size(subdailytadj,2));
        xticklabels({strcat(['00 UTC ',thismonthday{2}]),strcat(['00 UTC ',thismonthday{3}]),strcat(['00 UTC ',thismonthday{4}]),...
            strcat(['00 UTC ',thismonthday{5}]),strcat(['00 UTC ',thismonthday{6}]),strcat(['00 UTC ',thismonthday{7}]),...
            strcat(['00 UTC ',thismonthday{8}]),strcat(['00 UTC ',thismonthday{9}])});
    end
    xtickangle(45);xlim([1 size(subdailytadj,2)]);
    if standaloneplot==1
        ylabel('Value (C)','fontsize',fs,'fontweight','bold','fontname','arial');
    else
        exist addylabel;
        if ans==1
            ylabel('Value (C)','fontsize',fs,'fontweight','bold','fontname','arial');
        end
    end
    if standaloneplot==1
        if d==22869
            legend('Temperature','Dewpoint','Wet-Bulb','Location','Northeast');
        elseif d==23570
            legend('T','T_d_','WBT','Location','Southeast');
        else
            legend('Temperature','Dewpoint','Wet-Bulb','Location','Southwest');
        end
    end
    set(gca,'fontsize',fs,'fontweight','bold','fontname','arial');
    if standaloneplot==1
        %title(strcat(['Subdaily Data for ',finalstnnames{s},', for the WBT Extreme of ',ymtext]),...
        %    'fontsize',18,'fontweight','bold','fontname','arial');
        figname=strcat('subdailytimeseriesday',num2str(d));curpart=2;highqualityfiguresetup;
    end
    clear addylabel;
end

