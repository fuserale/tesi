function Hd = hpfilter
% All frequency values are in Hz.
Fs = 64;  % Sampling Frequency

Fstop = 0.4;    % Stopband Frequency
Fpass = 0.8;       % Passband Frequency
Astop = 60;      % Stopband Attenuation (dB)
Apass = 1;       % Passband Ripple (dB)
match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its ELLIP method.
h  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
Hd = design(h, 'cheby2', 'MatchExactly', match);