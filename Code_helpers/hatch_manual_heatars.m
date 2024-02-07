function [] = hatch_manual(latarray,lonarray,valarray,valtocontourbetween_lower,valtocontourbetween_upper,linewidth,linecolor,linealpha,linedensity,hatchdir)
%Manual hatching that avoids problems with map patches and other contour-related complexities
%Replaces hatchfill.m and its ilk
%First applied in Heat_ARs/makefigures.m

%Options for linedensity are 1, 1/2, 1/3, 1/4 -- where e.g. 1/3 means every 3rd row & column are hatched, as applicable

for row=1:size(latarray,1)
    for col=1:size(latarray,2)
        thislat=latarray(row,col);thislon=lonarray(row,col);
        if row>=2 && row<=size(latarray,1)-1
            thislatspacing=(latarray(row+1,col)-latarray(row-1,col))/2;
        elseif row==1
            thislatspacing=(latarray(row+1,col)-latarray(row,col));
        elseif row==size(latarray,1)
            thislatspacing=(latarray(row,col)-latarray(row-1,col));
        end
        if col>=2 && col<=size(lonarray,2)-1
            thislonspacing=(lonarray(row,col+1)-lonarray(row,col-1))/2;
        elseif col==1
            thislonspacing=(lonarray(row,col+1)-lonarray(row,col));
        elseif col==size(lonarray,2)
            thislonspacing=(lonarray(row,col)-lonarray(row,col-1));
        end
        thislatspacing=abs(thislatspacing);
        thislonspacing=abs(thislonspacing);
        linecolor_1=linecolor(1);
        linecolor_2=linecolor(2);
        linecolor_3=linecolor(3);

        %Reduce density of hatches, as desired
        continueon=0;
        if linedensity==1
            continueon=1;
        elseif linedensity==1/2
            if strcmp(hatchdir,'sw-ne')
                if rem(row+col,2)==0 %keep only points whose row+col sum equals an even number
                    continueon=1;
                end
            elseif strcmp(hatchdir,'nw-se')
                if rem(abs(col-row),2)==0 %keep only points whose row-col difference is a multiple of 2
                    continueon=1;
                end
            end
        elseif linedensity==1/3
            if strcmp(hatchdir,'sw-ne')
                if rem((row+col)+1,3)==0 %keep only points whose row+col sum is one less than a multiple of 3
                    continueon=1;
                end
            elseif strcmp(hatchdir,'nw-se')
                if rem(abs(col-row),3)==0 %keep only points whose row-col difference is a multiple of 3
                    continueon=1;
                end
            end
        elseif linedensity==1/4
            if strcmp(hatchdir,'sw-ne')
                if rem((row+col)+2,4)==0 %keep only points whose row+col sum is two less than a multiple of 4
                    continueon=1;
                end
            elseif strcmp(hatchdir,'nw-se')
                if rem(abs(col-row),4)==0 %keep only points whose row-col difference is a multiple of 4
                    continueon=1;
                end
            end
        end

        if valarray(row,col)>=valtocontourbetween_lower && valarray(row,col)<=valtocontourbetween_upper 
            if continueon==1
                if strcmp(hatchdir,'sw-ne')
                    ll=linem([thislat-0.5*thislatspacing thislat+0.5*thislatspacing],[thislon-0.5*thislonspacing thislon+0.5*thislonspacing],...
                    'linewidth',linewidth,'color',linecolor);
                elseif strcmp(hatchdir,'nw-se')
                    ll=linem([thislat+0.5*thislatspacing thislat-0.5*thislatspacing],[thislon-0.5*thislonspacing thislon+0.5*thislonspacing],...
                    'linewidth',linewidth,'color',linecolor);
                end
                ll.Color=[linecolor_1,linecolor_2,linecolor_3,linealpha]; %linealpha: 0 is transparent, 1 is normal
            end
        end
    end
end

end
