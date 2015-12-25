function compile(opt, verb, mex_file)
% Build MEX source code.
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
%  error('This code is not supported on Windows.');
%end

if nargin < 1
  opt = true;
end

if nargin < 2
  verb = false;
end

% Start building the mex command
%puts all files in bin folder that is built
mexcmd = 'mex -outdir bin';

% Add verbosity if requested
if verb
  mexcmd = [mexcmd ' -v'];
end

% Add optimizations if requested
if opt
  mexcmd = [mexcmd ' -O'];
  mexcmd = [mexcmd ' CXXOPTIMFLAGS="-O3 -DNDEBUG"'];
  mexcmd = [mexcmd ' LDOPTIMFLAGS="-O3"'];
else
  mexcmd = [mexcmd ' -g'];
end

% Turn all warnings on
mexcmd = [mexcmd ' CXXFLAGS="\$CXXFLAGS -Wall"'];
mexcmd = [mexcmd ' LDFLAGS="\$LDFLAGS -Wall"'];

if nargin < 3
  % Build feature vector cache code
  fv_compile(opt, verb);
  % Build the star-cascade code
  cascade_compile(opt, verb); %cascade compile works(?) now because of edits

  eval([mexcmd ' voc-release5\features\resize.cpp']);
  eval([mexcmd ' voc-release5\features\features.cpp']);
  eval([mexcmd ' voc-release5\gdetect\dt.cpp']);
  eval([mexcmd ' voc-release5\gdetect\bounded_dt.cpp']);
  %eval([mexcmd ' voc-release5\gdetect\get_detection_trees.cc']);
  eval([mexcmd ' voc-release5\gdetect\get_detection_trees.cpp']);
  %eval([mexcmd ' voc-release5\gdetect\compute_overlap.cc']);
  eval([mexcmd ' voc-release5\gdetect\compute_overlap.cpp']);
  
  % Convolution routine
  %   Use one of the following depending on your setup
  %   (0) is fastest, (2) is slowest 

  % 0) multithreaded convolution using SSE
  %eval([mexcmd ' voc-release5\gdetect\fconvsse.cpp -o fconv']);
  % 1) multithreaded convolution
  %eval([mexcmd ' gdetect/fconv_var_dim_MT.cc -o fconv']);
  %eval([mexcmd ' voc-release5\gdetect\fconv_var_dim_MT.cc -output fconv']);
  % 2) basic convolution, very compatible
  %eval([mexcmd ' voc-release5\gdetect\fconv_var_dim.cc -o fconv']);
  %changed to compile- used -output instead of -o to have it save as
  % fconv.mexw64
  eval([mexcmd ' voc-release5\gdetect\fconv_var_dim.cc -output fconv']);
  
  % Convolution routine that can handle feature dimenions other than 32
  % 0) multithreaded convolution
  %eval([mexcmd ' voc-release5\gdetect\fconv_var_dim_MT.cc -output fconv_var_dim']);
  % 1) single-threaded convolution
  %eval([mexcmd ' voc-release5\gdetect\fconv_var_dim.cc -o fconv_var_dim']);
  %workaround below; see above
  eval([mexcmd ' voc-release5\gdetect\fconv_var_dim.cc -output fconv_var_dim']);
else
  eval([mexcmd ' ' mex_file]);
end
