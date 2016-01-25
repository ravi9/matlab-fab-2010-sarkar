function Primitives = ReadEdgeAttsFile (FileName)

NUM = 1; N_line = 0; N_arc = 0;
infile = fopen(FileName, 'r');

flag = 0;
paren = fscanf(infile, ' %c', 1);
if (paren == '(')
    while (flag==0)
        paren = fscanf(infile, ' %c', 1);
        if (paren == ')')     flag = 1; break;
        else
            Primitives(NUM).id =  fscanf(infile, ' %d', 1);
           % fprintf (1, '%d ', Primitives(NUM).id);
            paren = fscanf(infile, ' %c', 1);
            Primitives(NUM).yc = fscanf(infile, ' %f', 1);
            Primitives(NUM).xc = fscanf(infile, ' %f', 1);
            Primitives(NUM).radius = fscanf(infile, ' %f', 1);
            if (Primitives(NUM).radius < 9999.0)
                Primitives(NUM).radius = (-Primitives(NUM).radius);
            else Primitives(NUM).radius = 999999.0;
                if Primitives(NUM).radius > 99999.0
                    Primitives(NUM).mark = 'LINE'; N_line = N_line + 1;
                else
                    Primitives(NUM).mark = 'ARC'; N_arc = N_arc + 1;
                end;
            end;
        end;

        Primitives(NUM).error = fscanf(infile, ' %f', 1);
        paren = fscanf(infile, ' %c', 1); % reads in ( 
        Primitives(NUM).sy = fscanf(infile, ' %d', 1);
        Primitives(NUM).sx = fscanf(infile, ' %d', 1);
        paren = fscanf(infile, ' %c', 1); % reads in )
        
        paren = fscanf(infile, ' %c', 1);
        Primitives(NUM).ey = fscanf(infile, ' %d', 1);
        Primitives(NUM).ex = fscanf(infile, ' %d', 1);
        paren = fscanf(infile, ' %c', 1);

        Primitives(NUM).slope = fscanf(infile, ' %f', 1);
        fscanf(infile, ' %f', 1);
        Primitives(NUM).mag_plus = fscanf(infile, ' %f', 1);
        Primitives(NUM).width_plus = fscanf(infile, ' %f', 1);
        Primitives(NUM).mag_minus = fscanf(infile, ' %f', 1);
        Primitives(NUM).width_minus = fscanf(infile, ' %f', 1);
        
        fscanf(infile, ' %f', 2); % reads in the grad dir
        paren = fscanf(infile, ' %c', 1); %reads in (
        fscanf(infile, ' %f', 2);
        paren = fscanf(infile, ' %c', 1); % reads in )
        fscanf(infile, ' %f', 2);
        
        paren = fscanf(infile, ' %c', 1); % reads in )
        paren = fscanf(infile, ' %c', 1); % reads in (
        flag1 = 0;
        Primitives(NUM).length = 1;
        while (flag1==0) 
            paren = fscanf(infile, ' %c', 1);
            if (paren == ')')    flag1 = 1;
            else
                
                Primitives(NUM).y(Primitives(NUM).length) = fscanf(infile, '%d ', 1);
                Primitives(NUM).x(Primitives(NUM).length) = fscanf(infile, '%d ', 1);
                Primitives(NUM).length = Primitives(NUM).length + 1;
                paren = fscanf(infile, ' %c', 1);
            end;
        end;
        Primitives(NUM).length = Primitives(NUM).length - 1;
        Primitives(NUM).cx = Primitives(NUM).x(round(Primitives(NUM).length/2));
        Primitives(NUM).cy = Primitives(NUM).y(round(Primitives(NUM).length/2));
        paren = fscanf(infile, ' %c', 1);
        if (Primitives(NUM).length > 10), NUM = NUM + 1; end;
    end;
end;
fprintf (1, '\n %d primitives (%d lines, %d arcs) read.\n', NUM-1, N_line, N_arc);