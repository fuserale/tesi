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


% computes the new index in an array (first index: 1) of the current position is to be
% modified by an offset
function x = new_buffer_index(current_index, buffer_len, offset, debug)

if (debug)
    offset
end

x = mod( (current_index - 1 + offset), buffer_len) + 1;



if (debug == 1)
    current_index
    offset
    buffer_len

    current_index - 1 + offset

    mod( (current_index - 1 + offset), buffer_len)

    mod( (current_index - 1 + offset), buffer_len) + 1

    x
end