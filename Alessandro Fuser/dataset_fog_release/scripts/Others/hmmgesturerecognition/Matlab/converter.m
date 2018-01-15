load('data.mat')

file = 'data/default.mat';

window_size = 64;
window_offset = 32;
ENERGY_TH = 10000;
DISTANCE_TH = 6400;
gesture_rest_position = [-Inf -Inf -Inf];
baseline = 20;
feature_count = 3;
int_width = 10;
feature_count_mag = 3;
int_width_mag = 11;
TYPE_HMM = 0;
STATES = 4;
IT_SP = 10;
IT_BW = 10;




% BOOK
[book_recorded, book_discrete] = create_units(book, feature_count_mag, int_width_mag);
book = Gesture('book', book_recorded, book_discrete, STATES, IT_SP, IT_BW, TYPE_HMM);

priorbook = [1.0 0 0 0 0]';

transmatbook = zeros(5,5);
transmatbook(1,:) = [0.5 0.49 0.005 0.005 0];
transmatbook(2,:) = [0.005 0.5 0.49 0.005 0];
transmatbook(3,:) = [0.005 0.005 0.5 0.49 0];
transmatbook(4,:) = [0.49 0.005 0.005 0.5 0];
transmatbook(5,:) = [0 0 0 0 0];

obsmatbook = [0.2 0.79 0.01;
              0.3  0.4 0.3;
              0.05 0.9 0.05;
              0.01 0.79 0.2;
              0 0 0
              ];

for i = 1:4
    book = book.set_prior_matrix(1, i, priorbook);
    book = book.set_trans_matrix(1, i, transmatbook);
    book = book.set_obs_matrix(1, i, obsmatbook);
end
         



% DRINK          
[drink_recorded, drink_discrete] = create_units(drink, feature_count_mag, int_width_mag);
drink = Gesture('drink', drink_recorded, drink_discrete, STATES, IT_SP, IT_BW, TYPE_HMM);

priordrink = [1.0 0 0 0 0]';

transmatdrink = zeros(5,5);
transmatdrink(1,:) = [0.5 0.485 0.005 0.005 0.005];
transmatdrink(2,:) = [0.001 0.5 0.497 0.001 0.001];
transmatdrink(3,:) = [0.005 0.005 0.5 0.485 0.005];
transmatdrink(4,:) = [0.005 0.005 0.005 0.5 0.485];
transmatdrink(5,:) = [0.485 0.005 0.005 0.005 0.5];

obsmatdrink = [0.2 0.79 0.01;
               0.05 0.9 0.05;
               0.3  0.4 0.3;
               0.05 0.9 0.05;
               0.01 0.79 0.2;
               ];

for i = 1:4
    drink = drink.set_prior_matrix(1, i, priordrink);
    drink = drink.set_trans_matrix(1, i, transmatdrink);
    drink = drink.set_obs_matrix(1, i, obsmatdrink);
end
           


% save gestures
gestures = cell(1, 2);
gestures{1, 1} = book;
gestures{1, 2} = drink;

save(file, 'gestures', 'window_size', 'window_offset', 'ENERGY_TH', 'DISTANCE_TH', 'gesture_rest_position', 'baseline', ...
    'feature_count', 'int_width', 'feature_count_mag', 'int_width_mag', 'TYPE_HMM', 'STATES', 'IT_SP', 'IT_BW');