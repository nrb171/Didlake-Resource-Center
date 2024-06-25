function xo = dbz2db(xi);
% A helper function to convert from dBZ to dB
%
%INPUTS:
% xi: input in dBZ (array nd)
%
%OUTPUTS:
% xo: output in dB (array nd)
%
%SEE ALSO:
% DB2DBZ
%
% Change Log:
% 2023/10/10: function added - Nicholas Barron

xo=10.^(xi./10);
