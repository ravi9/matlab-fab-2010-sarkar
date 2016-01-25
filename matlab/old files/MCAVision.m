function [Lines Layout] = MCAVision (Lines, AffinityEnergyMatrix, AffinityThreshold, MinGap, MagnetDiameter, Units, SizeX, SizeY, SaveFlag)
% This function produces the Magnet mask for OOMMF simulations. It produces bmp file 
% called VisionDots.bmp can be included in the *.mif file.

% AffinityThreshold: an number between 0 and 1, used to threshold out the
% weak afinities. It is used to control the size of the problem. The number 
% of disconnected components increase as we threshold the graph. Each
% component gets its own layout. If the value is 0 then no affinities are deleted.
%
% MagnetDiameter: -- Diagmeter of the magnet (nm)
%
% MinGap: Minimum gap between the magnets (nm)
%
% Units: Length of each pixel in nm. By choosing
%        large values of this parameter (i.e. 2, 5, 10, etc)
%        one can reduce the size of the output image (bmp)
%
% SizeX and SizeY: size of the layout bitmap in nm 
%
% SaveFlag == 1 to save bitmap output
% 
% Output: 
% Files VisionDots*.bmp is created, one corresponding to each component. Each pixel is 1nm
% Files Coords*.txt is created, listing the (x y) locations of the center of the magnets
% for each component
% 

% Example: MCAVision (Lines, AffinityEnergyMatrix, 0.2, 30, 100, 10)
%  Creates a design with 100 nm diameter magnets, with minimum spacing of
%  30nm and each pixel in the bmp file representing 10nm. It thresholds the
%  affinity matrix by 0.2.

MinGap = MinGap/Units;
MagnetDiameter = MagnetDiameter/Units;

%Compute Layout
Layout = LayoutAffinityMatch(AffinityEnergyMatrix, AffinityThreshold, 5);

k = length(Layout);
for i=1:k % for each connected component
    [X Y MaskImage] = CreateNanoMagnetMaskImage([Layout(i).X'], [Layout(i).Y'], MagnetDiameter, MinGap, SizeX, SizeY, SaveFlag);
    Layout(i).X = X*Units; Layout(i).Y = Y*Units;
    plot(X, Y, 'o'); hold on; plot(X(1), Y(1), 'ro'); hold off;
   
    
    if SaveFlag
        fprintf(1, '\n Writing coordinates of magnets in text file Coords.txt');
        fp = fopen (sprintf('Coords_%s_%f_%d_g_%d_d_%d_u_%d.txt', ImageFile, AffinityThreshold, i, MinGap*Units, MagnetDiameter*Units, Units), 'w');
        fprintf(fp, 'Material = 80Co20Pt');
        fprintf(fp, '\nRadius = %f um', MagnetDiameter*Units/1000);
        fprintf(fp, '\nThickness = %f um', 40/1000);
        fprintf(fp, '\nmagnet       X (um)    Y (um)');
        for (ii=1:length(X)) fprintf(fp, '\nm%d = (%f, %f)', ii, X(ii)/1000, Y(ii)/1000); end;
        fclose (fp);
        fprintf(1, '\n Image mask in VisionDots.bmp');
        imwrite(mat2gray(MaskImage), sprintf('VisionDots_%s_%f_%d_g_%d_d_%d_u_%d.bmp', ImageFile, AffinityThreshold, i, MinGap*Units, MagnetDiameter*Units, Units), 'bmp');
        figure; imagesc(MaskImage'); colormap('gray');
    end;
    
end;

%------------------------------------------------------------------
