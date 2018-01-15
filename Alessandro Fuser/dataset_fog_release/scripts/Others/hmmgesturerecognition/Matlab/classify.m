function [winner, winner_mag, LL] = classify(current_gesture)


fprintf(1, 'CLASSIFYING\n');


global gestures;
len = size(gestures);
len = len(2);

LL = zeros(len, 4);

% determine LL of recorded data for all gestures
for i = 1:len
    LL(i,:) = gestures{1, i}.evaluate(current_gesture);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% magnitude classification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

winner_mag = 1;

for i = 2:len
    if (LL(i, 4) > LL(winner_mag, 4))
        winner_mag = i;
    end
end

if (LL(winner_mag, 4) == -Inf)
    % no winner
    winner_mag = 0;
end
   
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x/y/z majority vote
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxMat = [1 1 1];

% determine maxima of LLs
for signal = 1:3
    for i = 1:len
        if (LL(i, signal) > LL(maxMat(1, signal), signal)) 
            maxMat(1, signal) = i;
        end
    end
end

% determine vote of each signal
votes = zeros(1, len);
for signal = 1:3
    ind = maxMat(1, signal);
    if (LL(ind, signal) ~= -Inf)
        votes(1, ind) = votes(1, ind) + 1;
    end
end

% the winner is the first gesture in the list with the maximum number of
% votes, i.e. if there are two gestures A and B with 1 vote each, A is
% chosen
% maybe introduce random selection in the future
winner = 1;
for i = 2:len
    if (votes(1, i) > votes(1, winner))
        winner = i;
    end
end

% if there are no votes for the winner, there is no winner
if (votes(1, winner) == 0)
    winner = 0;
end



% remove all impossible gestures from LL matrix, i.e. rows with infinity
% values!
% LL_clean = zeros(1,3);
% remove_row = zeros(1, len);
% inf_row = [-Inf -Inf -Inf];
% 
% for i = 1:len
%     
%     for k = 1:3
%         if (LL(i, k) == -Inf)
%             remove_row(1, i) = 1;
%         end
%     end
%     
%     if (remove_row(1, i))
%         invalidate row
%         LL_clean(i, :) = inf_row;
%     else
%         add line to cleaned matrix
%         LL_clean(i, :) = LL(i, 1:3);
%     end
%     
% end
% 
% 
% % determine maxima of LLs
% for signal = 1:3
%     for i = 1:len
%     if (LL_clean(i, signal) > LL_clean(max(1, signal), signal)) 
%             max(1, signal) = i;
%         end
%     end
% end
% 
% 
% % determine winning gesture
% winner = 0;
%     
% % if all rows have been removed => no classification possible
% if (sum(remove_row) == len)
%     
%     fprintf(1, 'no classification possible\n');
%     
% else
% 
%     % determine vote of each signal
%     votes = zeros(1, len);
% 
%     for signal = 1:3
%         ind = max(1, signal);
%         votes(1, ind) = votes(1, ind) + 1;
%     end
% 
%     for i = 1:len
%         if (votes(1, i) == 2 || votes(1, i) == 3)
%             winner = i;
%         end
%     end
% 
% end

