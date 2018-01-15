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


classdef Gesture
    
    
    properties
        
        Name;
        Recorded_data;
        States;
        It_bw;
        It_sp;
        Type;
        Discrete_data;
        Compressed_data;
        Units;
        Signal_count;
        
        Transition_matrix;
        Observation_matrix;
        Prior_matrix;
        LL;
      
    end
    
    
    methods
        
        % constructor
        function obj = Gesture(name, recorded_data, discrete_data, states, it_sp, it_bw, type)
       
            obj.Name = name;
            obj.States = states;
            obj.It_sp = it_sp;
            obj.It_bw = it_bw;
            obj.Recorded_data = recorded_data;
            obj.Type = type;
            obj.Discrete_data = discrete_data;
            
            obj.Units = size(discrete_data);
            obj.Units = obj.Units(1);
            
            len = size(discrete_data);
            len = len(2);
            obj.Signal_count = len;
            
            obj.Transition_matrix = cell(1, len);
            obj.Observation_matrix = cell(1, len);
            obj.Prior_matrix = cell(1, len);
            obj.LL = zeros(1, len);
            
            for i = 1:4

                obj.Transition_matrix{1,i} = zeros(states, states);
                obj.Prior_matrix {1,i} = zeros(states, 1);
               
                global feature_count_mag;
                global feature_count;
                count = feature_count;
            
                if (i == 4)
                    count = feature_count_mag;
                end
                
                obj.Observation_matrix{1,i} = zeros(states, count);

            end
            
        end
        
        function obj = set_prior_matrix(obj, i, k, matrix)
           obj.Prior_matrix{i, k} = matrix;
        end
        
        function obj = set_obs_matrix(obj, i, k, matrix)
            obj.Observation_matrix{i, k} = matrix;
        end
        
        function obj = set_trans_matrix(obj, i, k, matrix)
            obj.Transition_matrix{i, k} = matrix;
        end
        
        
        % train the HMM with the given parameters
        function obj = train(obj)
            
            global feature_count_mag;
            global feature_count;
            
            global ONLY_MAG;
            lower = 1;
            
            if (ONLY_MAG == 1)
                lower = 4;
            end
            
            for i = lower:obj.Signal_count
                
                count = feature_count;
            
                if (i == 4)
                    count = feature_count_mag;
                end
                
                fprintf(1, 'started training %s (%d)\n', obj.Name, i);
                
                [obj.LL(1, i), obj.Prior_matrix{1, i}, obj.Transition_matrix{1, i}, obj.Observation_matrix{1, i}] = ...
                    train_HMM(obj.Discrete_data(1:obj.Units, i), obj.States, count, obj.It_sp, obj.It_bw, obj.Type);
                
                fprintf(1, 'finished training %s (%d)\n', obj.Name, i);

            end
            
        end
        
        
        % evaluate HMM for the given observed data
        function x = evaluate(obj, observed_data)
            
            x = zeros(1, obj.Signal_count);
            
            for i = 1:obj.Signal_count
                x(1, i) = log_lik_dhmm(observed_data{i, 1}, obj.Prior_matrix{1, i}, obj.Transition_matrix{1, i}, obj.Observation_matrix{1, i});
            end
            
        end
        
        
        
        % normalize HMM matrices
        function obj = normalize(obj)

            for i = 1:obj.Signal_count
                
                obj.Prior_matrix{1, i} = mk_stochastic(obj.Prior_matrix{1, i});
                
                transmat = obj.Transition_matrix{1, i};
                obsmat = obj.Observation_matrix{1, i};
                
                for k = 1:obj.States
                    transmat(k,:) = mk_stochastic(transmat(k,:));
                    obsmat(k,:) = mk_stochastic(obsmat(k,:));
                end

                obj.Transition_matrix{1, i} = transmat;
                obj.Observation_matrix{1, i} = obsmat;
                
            end
        end

    end
       
    
    
end