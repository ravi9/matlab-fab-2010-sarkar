function [State0 State1 State2 State3]  = VisionCompute (Lines, Layout)

X = Layout.X; Y = Layout.Y;
if (size(X, 2) ~= 1) 
    X = X'; Y = Y';
end;
N = length(X);
Input = -10*ones(N, 1); % No Input Node

% Simulate to compute the states of the disk. Initial state of all disks at
% pi/4 angle. Figure out the disks whose states changed from pi/4, due to
% coupling and report it in State0 as a vector of 1 (changed) and 0 (no
% change)
fprintf(1, '\n With all disk vectors to be at pi/4');
FinalState0 = NanodiskArray (X, Y, 50, 20, Input, 0.25*pi*ones(N,1));
State0 = (abs(FinalState0 - pi/4) > 0.3); 
figure; colormap(gray); 
fprintf(1, '\n Coupled edges are shown with intensity 0 (black) and uncoupled with intensity 120 (gray).');
imagesc(DrawSelectedLines (Lines, Layout, State0));

% Simulate to compute the states of the disk. Initial state of all disks at
% -pi/4 angle. Figure out the disks whose states changed from pi/4, due to
% coupling and report it in State0 as a vector of 1 (changed) and 0 (no
% change)
fprintf(1, '\n With all disk vectors to be at pi/4');
Input(1) = FinalState0(1) + pi/2;
FinalState1 = NanodiskArray (X, Y, 50, 20, Input, FinalState0);
State1 = (abs(FinalState1 + pi/4)> 0.3);
figure; colormap(gray); 
fprintf(1, '\n Coupled edges are shown with intensity 0 (black) and uncoupled with intensity 120 (gray).');
imagesc(DrawSelectedLines (Lines,  Layout, State0)); 

% % Simulate to compute the states of the disk. Initial state of all disks at
% % -3pi/4 angle. Figure out the disks whose states changed from pi/4, due to
% % coupling and report it in State0 as a vector of 1 (changed) and 0 (no
% % change)
% fprintf(1, '\n With all disk vectors to be at pi/4');
% State2 = (abs(NanodiskArray (X, Y, 50, 20, Input, -0.75*pi*ones(N,1)) + 0.75*pi) > 0.3);
% figure; colormap(gray); 
% fprintf(1, '\n Coupled edges are shown with intensity 0 (black) and uncoupled with intensity 120 (gray).');
% imagesc(DrawSelectedLines (Lines,  Layout, State0)); 
% 
% % Simulate to compute the states of the disk. Initial state of all disks at
% % 3pi/4 angle. Figure out the disks whose states changed from pi/4, due to
% % coupling and report it in State0 as a vector of 1 (changed) and 0 (no
% % change)
% fprintf(1, '\n With all disk vectors to be at pi/4');
% State3 = (abs(NanodiskArray (X, Y, 50, 20, Input, 0.75*pi*ones(N,1))  - 0.75*pi) > 0.3);
% figure; colormap(gray); 
% fprintf(1, '\n Coupled edges are shown with intensity 0 (black) and uncoupled with intensity 120 (gray).');
% imagesc(DrawSelectedLines (Lines,  Layout, State0));

close all; 

plot(State0, 'r'); hold on; plot(State1, 'b'); 
plot(State2, 'g');  plot(State3, 'b'); 

%%%%--------------------------------------------
function OutputImage = DrawSelectedLines (Lines, Layout, selected)

N = length(Layout.indices);
for i=1:N
    for j=1:Lines(Layout.indices(i)).length
 %       OutputImage(Lines(Layout.indices(i)).y(j), Lines(Layout.indices(i)).x(j)) = 255*(1-selected(i));
        if (selected (i) == 1)
            OutputImage(Lines(Layout.indices(i)).y(j), Lines(Layout.indices(i)).x(j)) = 255;
        else
            OutputImage(Lines(Layout.indices(i)).y(j), Lines(Layout.indices(i)).x(j)) = 120;
        end;
    end;
end;
OutputImage = 255 - OutputImage;
