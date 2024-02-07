function p = fillbetween(x,y1,y2,linecolor)
%Fills area between two lines
p=patch([x fliplr(x)],[y1 fliplr(y2)],linecolor,'EdgeColor','none');

end