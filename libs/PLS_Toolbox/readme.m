echo on
% README Release notes for PLS_Toolbox 2.0.1f
% March 20, 2000
% Copyright Eigenvector Research, Inc. 2000
%
% Installing the PLS_Toolbox for PC
%
% The PLS_Toolbox files are in a self extracting archive, 
% PLS_Toolbox.exe, on the disk provided. Simply double click 
% on the disk provided and install it into the MATLABR11\TOOLBOX
% directory (default is C:\MATLABR11\TOOLBOX). The MATLAB path 
% must then be adjusted so that it can find the files, i.e. 
% the directory that the PLS_Toolbox routines are in must be 
% part of the search path. For help with adding to the search 
% path, type help path at the MATLAB prompt. (Note that the 
% installer on toolboxes purchased from The MathWorks does 
% this automatically. For the PLS_Toolbox you will have to 
% adjust the path yourself.)  NOTE: The PLS_Toolbox.exe
% archive is a 32-bit application and will not run under 
% Windows 3.1 (but neither will MATLAB 5). It must be expanded
% in Windows 95/98 or Windows NT.
%
% Installing the PLS_Toolbox for Macintosh
%
% The PLS_Toolbox files are in a self extracting archive,
% PLS_Toolbox.sea, on the disk provided. Simply move
% the archive to your hard drive and double click on it. 
% The PLS_Toolbox is then installed in MATLAB just like all 
% other standard MATLAB toolboxes. Simply copy the entire 
% PLS_Toolbox folder to the desired location. 
% It is convenient to place the PLS_Toolbox in the same folder 
% with the other MATLAB toolboxes, which is typically a folder 
% entitled "Toolbox" in the same directory as the MATLAB 
% application. The MATLAB path must then be adjusted so that 
% it can find the files, i.e. the folder that the PLS_Toolbox 
% routines are in must be part of the search path. For help 
% with adding to the search path, type help path at the MATLAB 
% prompt. (Note that the installer on toolboxes purchased from 
% The MathWorks does this automatically. For the PLS_Toolbox
% you will have to adjust the path yourself.)
%
% Upgrading from Versions 1.5.x or Earlier
%
% PLS_Toolbox 2.0 may be incompatible with existing user 
% routines based on PLS_Toolbox 1.5.x or earlier versions due to 
% changes in input/output syntax of some functions. In particular,
% the I/O syntax of PLS and PCR were changed to make them more 
% convenient and consistent with other routines. Some routines 
% have entirely disappeared, though in all cases their 
% functionality has been incorporated into new routines. For 
% instance, all of the functions that did cross-validation of 
% PLS and PCR models in PLS_Toolbox 1.5 have been replaced with 
% a single function, CROSSVAL in PLS_Toolbox 2.0. It is 
% recommended that you keep the previous version of the 
% PLS_Toolbox but place it at the end of your MATLAB path (type 
% help path at the MATLAB prompt for more information) until you 
% are certain that no incompatibilities exist. 
%
% Upgrading from Version 2.0.0x or 2.0.1
%
% PLS_Toolbox 2.0.1d is completely compatible with earlier versions
% 2.0.0x, 2.0.1, 2.0.1a, 2.0.1b and 2.0.1c. Simply replace the 
% PLS_Toolbox folder with this one. Note, however, that an updater is
% available which contains ONLY the files changed since 2.0.0.
% If you have the updater, only the changed files will be replaced.
%
% Registering Your Copy of the PLS_Toolbox
%
% A registration card has been provided with the PLS_Toolbox 2.0. 
% Please take the time to fill it out and return it. User support 
% and future minor upgrades will be made available to registered 
% users only. Registered users can also subscribe to the PLS_Toolbox
% discussion/support list at pls_toolbox@lists.eigenvector.com.
%
%
% User Support and Bug Reports
%
% Support questions should be directed towards 
% helpdesk@eigenvector.com or by fax to (509)687-7033. We can 
% generally solve problems via e-mail within several hours and make 
% every effort to provide a solution within 24 hours. Faxed 
% responses take a little longer, in part because there are times 
% where there is no-one home to receive the fax. As the 
% PLS_Toolbox 2.0 evolves, a searchable data base of user problems 
% and solutions will be provided on our web site at 
% www.eigenvector.com. We do not offer phone support for the 
% PLS_Toolbox.
%
% There are several things that you can do to help us help you. 
% If you encounter an error while using the PLS_Toolbox, please copy 
% the relevant text of your MATLAB session into an e-mail or fax. 
% Please provide the dimensions of the input variables and any 
% information that you can about their structure. Also, please 
% indicate your version of MATLAB and the PLS_Toolbox. (Typing VER 
% at the command line in MATLAB will give you all relevant version 
% information for MATLAB and any toolboxes installed.) It is 
% particularly useful if you can reproduce the error using one of the 
% data sets included with the toolbox. When using the graphical 
% interfaces, please note the exact sequence of button clicks and 
% menu selections. In general, we will try to recreate the error, and 
% any information about how it came about will aid us greatly.
%
% We have also created a MATLAB User Area on our web site. User 
% contributed functions can be found here, along with additional 
% functions of our own that we think may be of use to our users. 
% In some cases these functions may be beta code for future toolboxes.
%
%
% Future Upgrades and Bug Fixes
%
% The most up to date version of the PLS_Toolbox will be kept available 
% to registered users on our web site, www.eigenvector.com. Registered 
% users (those that have returned their registration card) can download 
% new copies of the toolbox which incorporate the latest bug fixes. 
% A username and password will be required for access to the upgrades. 
% Usernames and passwords will be available from helpdesk@eigenvector.com.
%
%
% Help and Further Information
%
% A listing of PLS_Toolbox 2.0.1e files can be found in the contents.m 
% file included in the PLS_Toolbox folder. This file is printed to the
% command window by typing 'help pls_toolbox' at the MATLAB command 
% prompt. Type helppls to activate a graphical user interface for
% bowsing the available functions.
%
% Changes, additions and Bug Fixes in 2.0.1f
%  Bug Fixes
%  MODLPLTS fixed Q and T^2 contribution plots for mean centered data
%  PCAPLOTS fixed Q and T^2 contribution plots for mean centered data
%
% Changes, additions and Bug Fixes in 2.0.1e
%  Bug Fixes
%  MODLPLTS fixed limit plot when Q on x-axis
%  MODLPRED fixed single sample T^2 calculation
%  PCAPLOTS fixed contribution plots for non-autoscaled data
%
%
% Changes, additions and Bug Fixes in 2.0.1d
%  Changes and Bug Fixes
%  MODLGUI residual limits modified and limit plots fixed
%  PCA     fixed case where no. PCs = no. of samples for T^2
%  GENALG  fixed plot of evolving population
%  GASELCTR fixed plot of evolving population
%  CROSSVUS fixed no subset problem
%  CORRMAP  colormap used in plot changed, now outputs order
%  New Functions
%  RWB       red, white and blue color map for CORRMAP
%  UPDATEMOD updates 2.0.1c MODLGUI models to 2.0.1d format
%
%
% Changes, additions and Bug Fixes in 2.0.1c
%  Changes and Bug Fixes:
%  MODLGUI  fixed to run under MATLAB 5.3
%  CLUSTER  fixed to remove non-fatal warnings
%
%
% Changes, additions and Bug Fixes in 2.0.1b
%  Changes and Bug Fixes:
%  ANOVA2W  fixed bug
%  MODLGUI  fixed labels for test in scores plot
%  REGCON   fixed bug related to scaling
%  OSCCALC  fixed to work with rank deficient Y-block
%  ANOVA1W  modified output
%  AUTOCOR  modified to have 'no plots' option
%  CROSSCOR modified to have 'no plots' option
%  EWFA     modified to output a 'scale' to plot against
%  MCR      modified to allow initial guess of S as well as C
%  MSCORR   modified to allow vector and matrix input
%  PCA      modified to print variance info when nargin<4 and plots==0
%  SAVGOLCV modified help file
%  STATDEMO modified mistake to show 2-sided test from 1-sided
%  STDDEMO  modified to include OSC
%  XCLGETDATA modified help file
%
%
% Changes, additions and Bug Fixes in 2.0.1a
%  New Functions:
%  XCLGETDATA extracts a matrix from an Excel spreadsheet for PC
%  XCLPUTDATA writes a matrix to an Excel spreadsheet for PC
%  Changes and Bug Fixes:
%  OSCCALC  improved
%  CROSSVAL modified to work with new OSCCALC
%  STDGEN   fixed non-fatal divide by zero error
%  MODLGUI/PCAGUI preferences now saves to PLS_Toolbox directory
%  PCAPRO   use with structure models bug fixed
%
% Changes, additions and Bug Fixes in 2.0.1
%  New Functions:
%  IMGPCA   function for PCA of multivariate images
%  OSCCALC  added orthogonal signal correction preprocessing
%  CROSSVUS added user defined subset selection for cross validation
%  SSQTABLE prints formatted PLS/PCA variance captured table
%  GLINE    adds line to a plot using the mouse
%  PLTTERN  plots a 2D ternary diagram
%  PLTTERNF plots a 3D ternary diagram with frequency of occurence
%  Changes and Bug Fixes:
%  PCAGUI   preferences and print model info added to menu
%           fixed bug that appeared when deleting samples multiple times
%  MODLGUI  preferences and print model info added to menu
%           fixed bug that appeared when deleting samples multiple times
%           PRESS curve now has additional options with LV info
%           added rank test, so can't have more LVs than Rank(X)
%  ANOVA1W  changed calculations to be less sensitive to round off error
%  ANOVA2W  changed calculations to be less sensitive to round off error
%  MWFIT    now fits image PCA models
%  STDGEN   changed tolerance in model formation to be relative
%           removed CLCs
%  STDGENDW changed tolerance in model formation to be relative
%           removed CLCs
%  CROSSVAL OSC correction can be specifed
%           RMSEC and RMSECV now included in output
%  CALIBSEL no longer requires stats toolbox
%  PLS      added rank check
%  SIMPLS   added rank check
%  CR       added support for powers 0 (MLR) and inf (PCR)
%  CRCVRND  added support for powers 0 (MLR) and inf (PCR)
%  MODLPRED can now make predictions from PLS function models
%  MCR      changed how it handles constraints
%  HELPPLS  now displays functions alphbetically
%
% Changes and Bug Fixes in 2.0.0c
%  MODLGUI fixed studentized y residuals on 'apply'
%  HELPPLS 'HandleVisibility' 'off'
%
% Changes and Bug Fixes in 2.0.0b
%  GRAMDEMO, missing in 2.0 and 2.0.0a now included
%  Bug in PLSLOGO fixed
%  SIMCA changed to do 10 splits of the data when cross validating models
%    when there are more than 20 samples in a class (instead of 'loo')
%  PCA and MODLGUI handle visibility turned off to prevent new plots from
%    appearing behind the interface.
%  MODLGUI fixed error on 'apply' when samples were deleted.
%  MODLGUI fixed RMSEC/RMSECV error after using 'apply' more than once.
%  MODLPRED 'resn' for 'simples' fixed
%  Help file in SIMCAPRD fixed, removed reference to MODLRDER
%  Help file in PCAPRO fixed to match PCA I/O
%
% Changes and Bug Fixes in 2.0.0a
%  Plot data buttons fixed in PCAGUI and MODLGUI for test data 5/1/98
%  Call to cross-validation routine in GENALG and GASELCTR fixed 4/30/98
echo off



