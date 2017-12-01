% Gesture recognition with Matlab.
% Copyright (C) 2008  Thomas Holleczek, ETH Zurich
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


function [ll, prior_matrix, transition_matrix, observation_matrix] = train_HMM(data, states, count, it_sp, it_bw, type)

% current log likelihood
ll = -Inf;
           
for k = 1:it_sp
        
    prior_matrix_0          = rand(1, states);
    transition_matrix_0     = rand(states, states);
    observation_matrix_0    = rand(states, count);
    
    if (type == 1) % left-right model
        for i = 1:states
            for j = 1:(i - 1)
                transition_matrix_0(i, j) = 0;
            end
        end
    end
    
            
    prior_matrix_0          = mk_stochastic(prior_matrix_0);
    transition_matrix_0     = mk_stochastic(transition_matrix_0);
    observation_matrix_0    = mk_stochastic(observation_matrix_0);
             
    % train HMM
    [LL, prior_matrix_0, transition_matrix_0, observation_matrix_0] = learn_dhmm(data, prior_matrix_0, transition_matrix_0, observation_matrix_0, it_bw, 1e-4, 0);
               
    % if current log likelihood is better than previous maximum
    if (LL(end) > ll)
        % store matrices
        ll = LL(end);
        prior_matrix = prior_matrix_0;
        transition_matrix = transition_matrix_0;
        observation_matrix = observation_matrix_0;
    end
            
end

