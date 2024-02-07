%%Some commands for making nice figures
%These should be run before any publication-quality figure is produced
%Derived from brief tutorial at https://dgleich.wordpress.com/2013/06/04/...
    %creating-high-quality-graphics-in-matlab-for-papers-and-presentations/
    
%It doesn't matter how things look in the Matlab window, only once they're viewed in the final format

%Outline for the script that calls this one:
%1. create the blank figure
%2. curpart=1;highqualityfiguresetup;
%3. plot whatever is going to be plotted
%4. curpart=2;figloc='/a/b/c/';figname='XXXX';highqualityfiguresetup;

exist thiswidth;if ans==0;thiswidth=12;end %default page width
exist thisheight;if ans==0;thisheight=7;end %default page height
alw=0.75;fsz=12;lw=1.5;msz=7;
if curpart==1 %initial figure set-up
    pos=get(gcf,'Position');
    set(gcf,'Position',[pos(1) pos(2) thiswidth*100 thisheight*100]);
    %Line below is a default setting but if necessary can be commented out to eliminate the blank axes that it creates
    %set(gca,'FontSize',fsz,'LineWidth',alw,'FontName','Arial','FontWeight','bold');
elseif curpart==2 %preparation for saving, & saving itself
    curaxiscolor=get(gca,'color');
    if curaxiscolor(1)==1 && curaxiscolor(2)==1 && curaxiscolor(3)==1 %i.e. white
        set(gcf,'InvertHardcopy','on');
    else
        set(gcf,'InvertHardcopy','off');
    end
    set(gcf,'PaperUnits','inches');
    papersize=get(gcf,'PaperSize');
    left=(papersize(1)-thiswidth)/2;
    bottom=(papersize(2)-thisheight)/2;
    myfiguresize=[left,bottom,thiswidth,thisheight];
    
    set(gcf,'PaperPosition',myfiguresize);
    %set(gcf,'PaperPositionMode','auto'); %mostly so custom subaxes don't get moved around -- apply only as necessary
    
    %used only for creation of figures in NCC paper, March 2020
    %set(gcf,'PaperPosition',myfiguresize,'PaperOrientation','landscape','PaperSize',[20 10]);
    
    
    printedalready=0;
    exist saveaseps;
    if ans==1;print(gcf,strcat(figloc,figname,'.eps'),'-depsc','-r600','-cmyk');printedalready=1;end
    exist saveaspdf;
    if ans==1;print(gcf,strcat(figloc,figname,'.pdf'),'-dpdf','-r600','-cmyk');printedalready=1;end
    exist saveasjpg;
    if ans==1;print(gcf,strcat(figloc,figname,'.jpg'),'-djpeg','-r600','-cmyk');printedalready=1;end

    %Note Sep 2023:
    %print() is no longer saving text labels added onto figure with text()
    %To save such a figure, instead using export_fig
    %Equivalent calls:
    %print('testfigure.png','-dpng','-r600');
    %export_fig testfigure2.png -nocrop -r600;

    %NOTE DEC 2023:
    %EXPORT_FIG IS NOT WORKING EITHER!! NO SOLUTION IN SIGHT
    
    %Default is .png
    if printedalready==0;print(strcat(figloc,figname),'-dpng','-r600');end
    fprintf('Figure name is %s\n',strcat(figloc,figname));

    %exportgraphics(gcf,strcat(figloc,figname,'.png'),'Resolution',300,'ContentType','vector');
    %saveas(gcf,strcat(figloc,figname,'.png'));
    %imwrite(gcf,strcat(figloc,figname,'.png'));
    
    
    %Clear after-market text so that the next figure includes or excludes the right phrases
    clear fullcontoursdescr;clear fullshadingdescr;clear windbarbsdescr;
    clear refval;clear normrefveclength;
    %Also clear width & height so defaults are used when variables are not specified
    clear thiswidth;clear thisheight;
    
    clear saveaseps;clear saveaspdf;
end
    
