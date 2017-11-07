clear; clc

T = readtable('/home/alessandro/Scrivania/S01R01.csv');
[m,n] = size(T);
A = load('../../dataset/TXT/S01R01.txt');

t = A(:,1);
x1 = A(:,2);
y1 = A(:,3);
z1 = A(:,4);

figure
plot(t , [x1 y1 z1]);
legend('X', 'Y', 'Z');

mag = sqrt(sum(x1.^2 + y1.^2 + z1.^2, 2));

figure
plot(t, mag);
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');

magNoG = mag - mean(mag);

plot(t, magNoG);
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');

minPeakHeight = std(magNoG);
[pks, locs] = findpeaks(magNoG, 'MINPEAKHEIGHT', minPeakHeight);
numSteps = numel(pks);

hold on;
plot(t(locs), pks, 'r', 'Marker', 'v', 'LineStyle', 'none');
title('Counting Steps');
xlabel('Time (s)');
ylabel('Acceleration Magnitude, No Gravity (m/s^2)');
hold off;
