function y = shiftLeft(x, offset)

len = size(x, 2);

y = shiftRight(x, len - offset);