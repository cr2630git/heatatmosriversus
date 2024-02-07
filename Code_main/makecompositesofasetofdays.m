for varloop=firstvar:lastvar
    if varloop==1 %Tw
        twpctiles=cell(7,1);temp_52x94=tw_52x94-273.15;
    elseif varloop==2 %AR
        aroccurrences=cell(7,1);temp_52x94=ar_52x94;
    elseif varloop==3 %T
        tpctiles=cell(7,1);temp_52x94=t_52x94-273.15;
    elseif varloop==4 %q
        qpctiles=cell(7,1);temp_52x94=td_52x94;
    elseif varloop==5 %tIVT
        tmp=load(strcat(dataresloc_external,'ivt_merra2.mat'));temp_52x94=tmp.tivt_52x94;
        tivtpctiles=cell(7,1);
    elseif varloop==6 %precip
        tmp=load(strcat(dataresloc_external,'precip_merra2.mat'));temp_52x94=tmp.precip_52x94;
        precippctiles=cell(7,1);precipoccurrences=cell(7,1);
        wetdays=temp_52x94>=0.001;
    elseif varloop==7 %evap
        tmp=load(strcat(dataresloc_external,'evap_merra2.mat'));temp_52x94=tmp.evap_52x94;
        evappctiles=cell(7,1);
    elseif varloop==8 %net shortwave
        tmp=load(strcat(dataresloc_external,'netshortwave_merra2.mat'));temp_52x94=tmp.netshortwave_52x94;
        netswpctiles=cell(7,1);
    elseif varloop==9 %net longwave
        tmp=load(strcat(dataresloc_external,'netlongwave_merra2.mat'));temp_52x94=tmp.netlongwave_52x94;
        netlwpctiles=cell(7,1);
    elseif varloop==10 %top-level sm
        tmp=load(strcat(dataresloc_external,'toplevelsm_merra2.mat'));temp_52x94=tmp.toplevelsm_52x94;
        toplevelsmpctiles=cell(7,1);
    elseif varloop==11 %z500
        tmp=load(strcat(dataresloc_external,'z500_merra2.mat'));temp_52x94=tmp.z500_52x94;
        z500pctiles=cell(7,1);
    elseif varloop==12 %omega500
        tmp=load(strcat(dataresloc_external,'omega500_merra2.mat'));temp_52x94=tmp.omega500_52x94;
        omega500pctiles=cell(7,1);
    end

    dim1sz=size(temp_52x94,1);
    cbyreg=zeros(7,1);
    temppctiles=cell(7,1);
    dayoffsets=firstoffsetday:lastoffsetday;
    for reg=firstreg:lastreg
        if strcmp(compositearrtype,'peakhs')
            endyr=size(setofdays,1);
        elseif strcmp(compositearrtype,'hs')
            endyr=15; %reduced array size to save time
        end

        for y=1:endyr %number of years
            for doy=may1doy+2:sep30doy-2
                if setofdays(y,doy,reg)==1 %if this is a day of interest
                    %Composite this day -- get its percentiles at each point across the US
                    %For ARs, get occurrences at each point and divide by regional-mean frequency
                    cbyreg(reg)=cbyreg(reg)+1;
                    temppctiles{reg}(cbyreg(reg),:,:,:)=NaN.*ones(52,94,size(dayoffsets,2));
                    for i=1:52
                        for j=1:94
                            for dayints=1:size(dayoffsets,2)
                                %if dayints~=2 && dayints~=6 %skip days we won't be plotting
                                    offset=dayoffsets(dayints);
                                    if varloop~=2 %everything but ARs
                                        temppctiles{reg}(cbyreg(reg),i,j,dayints)=pctreltodistn(reshape(temp_52x94(:,may1doy:sep30doy,i,j),[dim1sz*nummjjasdays 1]),temp_52x94(y,doy+offset,i,j));
                                    end
                                    if varloop==2 %for ARs and precip, also prepare to get relative likelihoods
                                        aroccurrences{reg}(cbyreg(reg),i,j,dayints)=temp_52x94(y,doy+offset,i,j);
                                    elseif varloop==6
                                        if temp_52x94(y,doy+offset,i,j)>=0.001 %i.e. 1 mm = a precip day ("wet")
                                            precipoccurrences{reg}(cbyreg(reg),i,j,dayints)=1;
                                        else
                                            precipoccurrences{reg}(cbyreg(reg),i,j,dayints)=0;
                                        end
                                    end
                                %end
                            end
                        end
                    end
                end
            end
        end
    end

    if varloop==2
        meanarfreq=zeros(52,94);
        for i=1:52;for j=1:94;meanarfreq(i,j)=sum(reshape(temp_52x94(:,may1doy:sep30doy,i,j),[dim1sz*nummjjasdays 1]))/(dim1sz*nummjjasdays);end;end
    elseif varloop==6
        meanpreciplikelihood=zeros(52,94);
        for i=1:52;for j=1:94;meanpreciplikelihood(i,j)=sum(reshape(wetdays(:,may1doy:sep30doy,i,j),[dim1sz*nummjjasdays 1]))/(dim1sz*nummjjasdays);end;end
    end

    if varloop==1;twpctiles=temppctiles;elseif varloop==3;tpctiles=temppctiles;...
    elseif varloop==4;qpctiles=temppctiles;elseif varloop==5;tivtpctiles=temppctiles;...
    elseif varloop==6;precippctiles=temppctiles;elseif varloop==7;evappctiles=temppctiles;elseif varloop==8;netswpctiles=temppctiles;...
    elseif varloop==9;netlwpctiles=temppctiles;elseif varloop==10;toplevelsmpctiles=temppctiles;elseif varloop==11;z500pctiles=temppctiles;...
    elseif varloop==12;omega500pctiles=temppctiles;
    end
    
    if saveoutput_makecompositespart2==1
        if varloop==1
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'twpctiles','-append');
        elseif varloop==2
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'aroccurrences','meanarfreq','-append');
        elseif varloop==3
           save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'tpctiles','-append');clear tpctiles;
        elseif varloop==4
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'qpctiles','-append');clear qpctiles;
        elseif varloop==5
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'tivtpctiles','-append');clear tivtpctiles;
        elseif varloop==6
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),...
                'precippctiles','precipoccurrences','meanpreciplikelihood','-append');clear precippctiles;
        elseif varloop==7
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'evappctiles','-append');clear evappctiles;
        elseif varloop==8
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'netswpctiles','-append');
        elseif varloop==9
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'netlwpctiles','-append');
        elseif varloop==10
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'toplevelsmpctiles','-append');
        elseif varloop==11
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'z500pctiles','-append');
        elseif varloop==12
            save(strcat(dataresloc_external,'bigpctilemap_data',savesuffix),'omega500pctiles','-append');
        end
    end
    fprintf('Just completed variable %d in makecompositesofasetofdays\n',varloop);
end
