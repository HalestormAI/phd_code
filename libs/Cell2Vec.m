function V = Cell2Vec(C)  %#ok<INUSD,STOUT>
% CELL2VEC - Concatenate cell elements to a vector
% The elements of arrays, which are elements of the input cell, are
% concatenated to a vector.
% V = Cell2Vec(C)
% INPUT:
%   C: Cell array of any size. Accepted classes: all numerical types
%      (DOUBLE, SINGLE, (U)INT8/16/32/64), LOGICAL, CHAR.
%      All non-empty cell elements must be the same class.
% OUTPUT:
%   V: [1 x N] vector of all elements. The class of V is the class of the
%      cell elements of C.
%
% NOTE: If the cell elements are vectors, this equals CAT, but is remarkably
% faster for large cells: It seems that CAT does not use pre-allocation?!
% E.g. for a {1 x 5000} cell string with a total of 200.000 CHARs:
%   CAT (Matlab 6.5) => 60 sec
%   CAT (Matlab 7.8) => 5 sec
%   Cell2Vec:        => 1.2 sec   (1.5GHz Pentium-M).
%
% COMPILATION:
%   (mex -setup   % if not done before)
%   mex -O Cell2Vec.c
% Linux: consider C99 comments:
%   mex -O CFLAGS="\$CFLAGS -std=C99" Cell2Vec.c
% Download: http://www.n-simon.de/mex
% Run the unit-test uTest_Cell2Vec after compiling.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
%         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008
% Assumed Compatibility: higher Matlab versions, Mac, Linux, 64bit
% Author: Jan Simon, Heidelberg, (C) 2010 matlab.THISYEAR(a)nMINUSsimon.de
%
% See also CELL2MAT, CStr2String.

% $JRev: R0b V:001 Sum:1lBHVfudhAox Date:01-Oct-2010 15:06:16 $
% $License: NOT_RELEASED $
% $File: Tools\GLSets\Cell2Vec.m $

% This is a dummy to support HELP only.
error(['JSimon:', mfilename, ':NoMEX'], ...
   ['Cannot find Mex file of ', mfilename]);
