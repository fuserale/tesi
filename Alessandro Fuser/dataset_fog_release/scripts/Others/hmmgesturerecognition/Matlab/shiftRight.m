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


function y = shiftRight(x, offset)

len = size(x, 2);

y = zeros(1, len);

for k=1:len

    swap_index = mod((k - 1 - offset), len) + 1;
    y(k) = x(swap_index);
        
end


