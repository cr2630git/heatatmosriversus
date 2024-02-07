function [cmaplt1,cmapgt1,cbtickslt1,cbticksgt1,cbticklabelslt1] = fractionalcolormap(maxf,inputcolormap)
%Makes colorbar ranging from 1/maxfactor to maxfactor in equal increments on both sides of 1

cmaplt1=inputcolormap(1:size(inputcolormap,1)/2,:);
bottomcolor=cmaplt1(1,:);
if maxf==6
    cmap_020color=cmaplt1(round(((1/5-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    cmap_025color=cmaplt1(round(((1/4-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    cmap_033color=cmaplt1(round(((1/3-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    cmap_050color=cmaplt1(round(((1/2-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    topcolor=cmaplt1(size(cmaplt1,1),:);
    %Adjust colormap to reflect nonlinearities within the 0-1 range
    clear cmapnewpart1;clear cmapnewpart2;clear cmapnewpart3;clear cmapnewpart4;clear cmapnewpart5;
    for i=1:3;cmapnewpart1(:,i)=linspace(bottomcolor(i),cmap_020color(i),20);end
    for i=1:3;cmapnewpart2(:,i)=linspace(cmap_020color(i),cmap_025color(i),20);end
    for i=1:3;cmapnewpart3(:,i)=linspace(cmap_025color(i),cmap_033color(i),20);end
    for i=1:3;cmapnewpart4(:,i)=linspace(cmap_033color(i),cmap_050color(i),20);end
    for i=1:3;cmapnewpart5(:,i)=linspace(cmap_050color(i),topcolor(i),20);end
    newcmaplt1=[cmapnewpart1;cmapnewpart2;cmapnewpart3;cmapnewpart4;cmapnewpart5];
    cbtickslt1=[1/maxf 3/maxf 4/maxf 5/maxf];cbticklabelslt1={'1/6','1/4','1/3','1/2'};
    cbticksgt1=[1 2 3 4 6];
elseif maxf==5
    cmap_025color=cmaplt1(round(((1/4-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    cmap_033color=cmaplt1(round(((1/3-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    cmap_050color=cmaplt1(round(((1/2-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    topcolor=cmaplt1(size(cmaplt1,1),:);
    %Adjust colormap to reflect nonlinearities within the 0-1 range
    clear cmapnewpart1;clear cmapnewpart2;clear cmapnewpart3;clear cmapnewpart4;
    for i=1:3;cmapnewpart1(:,i)=linspace(bottomcolor(i),cmap_025color(i),20);end
    for i=1:3;cmapnewpart2(:,i)=linspace(cmap_025color(i),cmap_033color(i),20);end
    for i=1:3;cmapnewpart3(:,i)=linspace(cmap_033color(i),cmap_050color(i),20);end
    for i=1:3;cmapnewpart4(:,i)=linspace(cmap_050color(i),topcolor(i),20);end
    newcmaplt1=[cmapnewpart1;cmapnewpart2;cmapnewpart3;cmapnewpart3];
    cbtickslt1=[1/maxf 2/maxf 3/maxf 4/maxf];cbticklabelslt1={'1/5','1/4','1/3','1/2'};
    cbticksgt1=[1 2 3 4 5];
elseif maxf==4
    cmap_033color=cmaplt1(round(((1/3-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    cmap_050color=cmaplt1(round(((1/2-1/maxf)/(1-1/maxf))*size(cmaplt1,1)),:);
    topcolor=cmaplt1(size(cmaplt1,1),:);
    %Adjust colormap to reflect nonlinearities within the 0-1 range
    clear cmapnewpart1;clear cmapnewpart2;clear cmapnewpart3;
    for i=1:3;cmapnewpart1(:,i)=linspace(bottomcolor(i),cmap_033color(i),20);end
    for i=1:3;cmapnewpart2(:,i)=linspace(cmap_033color(i),cmap_050color(i),20);end
    for i=1:3;cmapnewpart3(:,i)=linspace(cmap_050color(i),topcolor(i),20);end
    newcmaplt1=[cmapnewpart1;cmapnewpart2;cmapnewpart3];
    cbtickslt1=[1/maxf 2/maxf 3/maxf];cbticklabelslt1={'1/4','1/3','1/2'};
    cbticksgt1=[1 2 3 4];
elseif maxf==3
    cmap_050color=cmaplt1(round(((1/2-1/3)/(1-1/maxf))*size(cmaplt1,1)),:);
    topcolor=cmaplt1(size(cmaplt1,1),:);
    %Adjust colormap to reflect nonlinearities within the 0-1 range
    clear cmapnewpart1;clear cmapnewpart2;
    for i=1:3;cmapnewpart1(:,i)=linspace(bottomcolor(i),cmap_050color(i),20);end
    for i=1:3;cmapnewpart2(:,i)=linspace(cmap_050color(i),topcolor(i),20);end
    newcmaplt1=[cmapnewpart1;cmapnewpart2];
    cbtickslt1=[1/maxf 2/maxf];cbticklabelslt1={'1/3','1/2'};
    cbticksgt1=[1 2 3];
elseif maxf==2
    topcolor=cmaplt1(size(cmaplt1,1),:);
    %Adjust colormap to reflect nonlinearities within the 0-1 range
    clear cmapnewpart1;
    for i=1:3;cmapnewpart1(:,i)=linspace(bottomcolor(i),topcolor(i),20);end
    newcmaplt1=[cmapnewpart1];
    cbtickslt1=[1/maxf];cbticklabelslt1={'1/2'};
    cbticksgt1=[1 2];
else
    disp('Need to update fractionalcolormap.m');return;
end

cmapgt1=inputcolormap(size(inputcolormap,1)/2+1:size(inputcolormap,1),:);


end

