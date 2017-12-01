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


function discretized = discretize(data, baseline, features, int_width)


dataSize = size(data);
discretized = zeros(dataSize);


for i = 1:dataSize(2)
   
    % determine discretization interval of value
    
    if (mod(features, 2) == 0)
        
        k = features / 2;
        lowest = baseline - (k - 1) * int_width;
        
%         %   (-N/2)                 (-1)     (1)      (2)             (N/2)
%         % ]-00; -(N/2)*dR], ... ]-dR; 0[, [0; dR[, [dR;2dR[, ... [(N/2)*dR;+00[
%         
%         tmp = (data(i) - baseline) / int_width;
%         if (tmp >=  0)
%             tmp = floor(tmp) + 1;
%         else
%             tmp = -(floor(-tmp) + 1); % symmetric to positive approach
%         end
%     
%         % last intervals are open
%         if (tmp > features / 2)
%             tmp = features / 2;
%         elseif (tmp < - features / 2)
%             tmp = - features / 2;
%         end
%         
%         % shift interval (such that first interval has index 1)
%         if (tmp > 0) 
%             tmp = tmp + features/2;
%         else
%             tmp = tmp + features/2 + 1;
%         end
        
    else
        
        k = floor(features / 2);
        lowest = baseline - int_width / 2.0 - (k - 1) * int_width;
        
        %         %     (-(N-1)/2)                (-1)            (0)           (1) 
%         % ]-00;-(N-1)/2*dR], ..., ]-dR/2-dR,-dR/2[, [-dR/2,dR/2[, [dR/2,dR/2+R[,
%         %           ((N-1)/2)
%         % ... [dR/2+(N-1)/2*dR,+00[
%         tmp = (data(i) - (baseline - int_width/2.)) / int_width
%         if (tmp > 0)
%             tmp = ceil(tmp);            
%         else
%             tmp = floor(tmp);
%         end
%         
%         % last intervals are open
%         boundary = (features - 1) / 2;
%         if (tmp > boundary)
%             tmp = boundary;
%         elseif (tmp < - boundary)
%             tmp = - boundary;
%         end
%         
%          % shift interval (such that first interval has index 1)
%         tmp = tmp + (features - 1)/2 + 1;
%     
        
    end 
    
    diff = data(i) - lowest;
    tmp = 1;

    if (diff > 0)
        tmp = diff / int_width;
        tmp = floor(tmp);
        tmp = tmp + 2;

        if (tmp > features)
            tmp = features;
        end
    end

    discretized(i) = tmp;
    
end

