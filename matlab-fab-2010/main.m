function main (ImageFile)

Lines = ReadEdgeAttsFile (sprintf('Data/%s', ImageFile));
%Lines = CreateExampleArrangement (); 

AffinityEnergyMatrix = ComputeGroupingAffinities (Lines);

%[Lines Layout] = MCAVision (Lines, AffinityEnergyMatrix, AffinityThreshold, MinGap, MagnetDiameter, Units, SizeX, SizeY, SaveFlag)
[Lines Layout] = MCAVision (Lines, AffinityEnergyMatrix, 0.2, 10, 100, 5, 1000, 1000, 0);

VisionCompute(Lines, Layout);

sbest = TraditionalVision(Lines, AffinityEnergyMatrix);