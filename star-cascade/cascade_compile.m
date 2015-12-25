function cascade_compile(opt, verb)
% Build the star-cascade code
%   All compiled binaries are placed in the bin/ directory.
%
%   Windows users: Windows is not yet supported. You can likely 
%   get the code to compile with some modifications, but please 
%   do not email to ask for support.
%
% Arguments
%   opt   Compile with optimizations (default: on)
%   verb  Verbose output (default: off)

%if ispc
 % error('This code is not supported on Windows.');
%end

if nargin < 1 %nargin = number of function input arguments- so if it is less than one, the software can be optimised
  opt = true;
end

if nargin < 2 %if there is one input argument, then it has to be done with verbose output
  verb = false;
end

mexcmd = 'mex -outdir bin';

if verb %if verb was enabled, then this happens
  mexcmd = [mexcmd ' -v'];
end

if opt
  mexcmd = [mexcmd ' -O'];
  mexcmd = [mexcmd ' CXXOPTIMFLAGS="-O3 -DNDEBUG -fomit-frame-pointer"'];
  mexcmd = [mexcmd ' LDOPTIMFLAGS="-O3"'];
else
  mexcmd = [mexcmd ' -g'];
end

mexcmd = [mexcmd ' CXXFLAGS="\$CXXFLAGS -Wall"'];
mexcmd = [mexcmd ' LDFLAGS="\$LDFLAGS -Wall"'];
mexcmd = [mexcmd ' voc-release5\star-cascade\cascade.cpp voc-release5\star-cascade\model.cpp'];
eval(mexcmd);
