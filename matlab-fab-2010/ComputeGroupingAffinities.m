function Affinity = ComputeGroupingAffinities (Primitives)

N_prim = size (Primitives, 2);

Dist = zeros (N_prim, N_prim);
for (ii=1:N_prim)
    %Affinity(ii,ii) = Primitives(ii).length;
    for (jj=ii+1:N_prim)
        if (Primitives(jj).length > Primitives(ii).length) i = jj; j = ii; 
        else i = ii; j = jj; end;
        
%         P = [Primitives(i).ex Primitives(i).ey
%             Primitives(i).sx Primitives(i).sy];
%         Q = [Primitives(j).ex Primitives(j).ey
%             Primitives(j).sx Primitives(j).sy];
%         TFORM1 = cp2tform(P, Q, 'nonreflective similarity');
%         % Next estimate transformation by exchanging the start and end
%         % points
%         TFORM2 = cp2tform(P, [Q(2,:); Q(1,:)], 'nonreflective similarity');
%         d1 = (sum(log(eig(TFORM1.tdata.T'*TFORM1.tdata.T)).^2));
%         d2 = (sum(log(eig(TFORM2.tdata.T'*TFORM2.tdata.T)).^2));
%         Affinity(i, j) = exp(-(min (d1, d2)/max(Primitives(jj).length, Primitives(ii).length) + 0.1));
%         Affinity(j, i) = Affinity(i, j);
%     end;
% end;
        
        theta = atan2 (Primitives(i).ey - Primitives(i).sy, ...
            Primitives(i).ex - Primitives(i).sx);
        [xei yei] = rotate_axis(Primitives(i).ex - Primitives(i).sx,...
            Primitives(i).ey - Primitives(i).sy, theta);
        [xsj, ysj] = rotate_axis(Primitives(j).sx - Primitives(i).sx,...
            Primitives(j).sy - Primitives(i).sy, theta);
        [xej, yej] = rotate_axis(Primitives(j).ex - Primitives(i).sx,...
            Primitives(j).ey - Primitives(i).sy, theta);

        min_d = min([abs(ysj), abs(yej)])/xei;
        max_d = max([abs(ysj), abs(yej)])/xei;
        overlap = (min([xei, max([xsj, xej])]) - max([0, min([xsj, xej])]))/xei;
        del_theta = atan2 (abs(ysj-yej), abs(xsj-xej));
        Affinity(i, j) = (sqrt(Primitives(j).length*Primitives(i).length)*...
           exp(-min_d)*exp(overlap-1)*cos(2*del_theta)*cos(2*del_theta));
       %Affinity(i, j) = (sqrt(Primitives(j).length*Primitives(i).length)*...
        %   exp(-min_d)*exp(2*(overlap-1))*exp(-(del_theta)^2));
       
       %Affinity(i, j) = (sqrt(Primitives(j).length*Primitives(i).length)*...
        %   exp(-(del_theta)));
       
        %Affinity(i, j) = exp(-min_d)*exp(overlap-1)*cos(2*del_theta)*cos(2*del_theta);
        Affinity(j, i) = Affinity(i, j);
    end;
end;
%---------------------------------------------------------------
function [xo yo] = rotate_axis (x, y, theta)
R = [cos(theta)  sin(theta)
    -sin(theta)  cos(theta)];
p = [x; y];
q = R*p;
xo = q(1); yo = q(2);
%-----------------------------------------------------------------
 

        