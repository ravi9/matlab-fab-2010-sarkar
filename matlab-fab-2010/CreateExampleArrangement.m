function Primitives = CreateExampleArrangement ()

load arrangement.dat
hold off;

F = arrangement/10;
N = size(F, 1);
for (i=1:N)
    plot([F(i,1) F(i, 3)], [F(i, 2) F(i, 4)]);
    text(F(i,1)-2, F(i, 2)-2, sprintf('%d', i), 'FontSize',18);
    Primitives(i).id =  i;
    Primitives(i).yc = (F(i,1)+F(i, 2))/2;
    Primitives(i).xc = (F(i,3)+F(i, 4))/2;
    Primitives(i).mark = 'LINE';
    Primitives(i).sy = F(i,1);
    Primitives(i).sx = F(i,2);
    Primitives(i).ey = F(i,3);
    Primitives(i).ex = F(i,4);
    Primitives(i).cx = Primitives(i).xc;
    Primitives(i).cy = Primitives(i).yc;
    [Primitives(i).x, Primitives(i).y] = GenerateLineCoordinates(Primitives(i).sx, Primitives(i).sy, Primitives(i).ex, Primitives(i).ey);
     Primitives(i).length = size(Primitives(i).x, 2);
    hold on;
end;
   
%-------------------------------------------------------
function [x y] = GenerateLineCoordinates(sx, sy, ex, ey)

if (abs(ex - sx) > abs(ey - sy))
    if (sx > ex) % exchange start and end points
        t = ey; ey = sy; sy = t; t = sx; sx = ex; sx = t;
    end;
    for (i=1:(ex-sx))
        x(i) = floor(sx+i);
        y(i) = floor((x(i) - sx)*(ey - sy)/(ex - sx) + sy);
    end;
else
    if (sy > ey) % exchange start and end points
         t = ey; ey = sy; sy = t; t = sx; sx = ex; sx = t;
    end;
    for (i=1:(ey-sy))
        y(i) = floor(sy+i);
        x(i) = floor((y(i) - sy)*(ex - sx)/(ey - sy) + sx);
    end;
end;
        
    
        
