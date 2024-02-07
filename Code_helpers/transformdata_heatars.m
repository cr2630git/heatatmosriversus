function transformedvec = transformdata(origvec,maxratio)
%Transforms data to make a figure, instead of scaling axes
%   Useful for making figures where ratios are plotted and even intervals on either side of 1 are desired

clear y;clear x;


%maxratio needs to be a member of 2^n
if maxratio==16
    y=[1/maxratio;1/8;1/4;1/2;1;2;4;8;maxratio];
elseif maxratio==8
    y=[1/maxratio;1/4;1/2;1;2;4;maxratio];
elseif maxratio==4
    y=[1/maxratio;1/2;1;2;maxratio];
elseif maxratio==2
    y=[1/maxratio;1;maxratio];
else
    disp('transformdata needs help!');
end

x=[1:size(y,1)]';

clear transformedvec;
if size(origvec,1)>1;dimtouse=1;else;dimtouse=2;end
for i=1:size(origvec,dimtouse)
    transformedvec(i)=interp1(y,x,origvec(i),'spline');
end


end
