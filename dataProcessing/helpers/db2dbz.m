function xo = db2dbz(xi);
% A helper function to convert from dB to dBZ
%
%INPUTS:
% xi: input in dB (array nd)
%
%OUTPUTS:
% xo: output in dBZ (array nd)
%
%SEE ALSO:
% DBZ2DB
%
% Change Log:
% 2023/10/10: function added - Nicholas Barron


xo  = 10.*log10(xi);
