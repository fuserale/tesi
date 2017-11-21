T = readtable('../../dataset/CSV/S01R01.csv');
[m,n] = size(T);
A = table2array(T);

seconds = A(:,1);
accx1 = A(:,2);

[pks,locs,w,p] = findpeaks(accx1, seconds, 'MinPeakProminence', 1000);
xlabel('Seconds');
ylabel('AccX1');
title('All Peaks');

figure
[pks,locs,w,p] = findpeaks(accx1, seconds, 'MinPeakProminence', 1000);
peakInterval = diff(locs);
hist(peakInterval);
grid on
xlabel('Seconds Interval');
ylabel('Frequency of Occurence');
title('Histogram of Peak Intervals');

AverageDistance_Peaks = mean(diff(locs));