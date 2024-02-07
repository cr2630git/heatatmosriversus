function perc = pctreltodistn(backgrounddistribution,curval)
%Given an input value, calculates its percentile relative to a background (usually empirical) distribution
%   Originally written for script discomfscoresrecentreanalyses

%FOR MULTIDIMENSIONAL FUNCTIONALITY, USE INVPRCTILE INSTEAD

oldv=0;
if oldv==1
    distnwithcurval=[backgrounddistribution;curval];
    refvals=[1:size(distnwithcurval,1)]';
    fullarr=[distnwithcurval refvals];
    distnfullsorted=sortrows(fullarr);
    rowfoundaftersorting=0;row=1;
    while row<=size(distnfullsorted,1) && rowfoundaftersorting==0
        if distnfullsorted(row,2)==size(distnfullsorted,1)
            rowtosave=row;
            rowfoundaftersorting=1;
        end
        row=row+1;
    end
    perc=100*((rowtosave/size(distnfullsorted,1))-(1/(size(distnfullsorted,1)*2)));
else %speed up by taking advantage of Matlab's capabilities (less need now for multidimensionality, as in the attempt saved below)
    nless = sum(backgrounddistribution < curval);
    nequal = sum(backgrounddistribution == curval);
    perc = 100 * (nless + 0.5*nequal) / length(backgrounddistribution);
end



end



