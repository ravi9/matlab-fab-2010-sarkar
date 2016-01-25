function sbest = TraditionalVision(Lines, AffinityEnergyMatrix)

[sbest ebest] = iquadprog (AffinityEnergyMatrix, 10000);
OutputImage = DrawSelectedLines(Lines, sbest);
figure; imagesc(OutputImage);


function OutputImage = DrawSelectedLines (Lines, selected)
N = length(Lines);
for i=1:N
    for j=1:Lines(i).length
        if (selected (i) == 1)
            OutputImage(Lines(i).y(j), Lines(i).x(j)) = 255;
        else
            OutputImage(Lines(i).y(j), Lines(i).x(j)) = 120;
        end;
    end;
end;
OutputImage = 255 - OutputImage;
