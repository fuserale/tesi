function [training_units, discrete] = create_units(object, feature_count_mag, int_width_mag)

segments = object.segments;
speed = object.anglespeed01;

len = size(segments);
len = len(2);

units = len / 2;

training_units = cell(units, 4);
discrete = cell(units, 4);

for i = 1:units
    for k = 1:4
        start_index = segments(1, 2 * i - 1);
        end_index = segments(1, 2 * i);
        seg = speed(start_index:end_index);
        training_units{i, k} = (seg + 2) * 10;
        discrete{i, k} = discretizePositive(training_units{i, k}, feature_count_mag, int_width_mag);
    end
end



