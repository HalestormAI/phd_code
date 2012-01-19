DEFAULT_FOLDER = datestr(now,'dd-mm-yy_HH-MM-SS');

if ~exist('expdir','var')
    if exist('setdefaultbutton') == 2
        expdir = timedinputdlg('Enter Experiment Title:','Enter Experiment Title',1,{DEFAULT_FOLDER},struct('TimeOut',10));
    else
        expdir = inputdlg('Enter Experiment Title:','Enter Experiment Title',1,{DEFAULT_FOLDER});
    end
    if isempty( expdir )
        expdir = DEFAULT_FOLDER;
    elseif iscell(expdir)
        expdir = cell2mat(expdir);
    end
end
clear DEFAULT_FOLDER;
if ~exist(expdir,'dir')
    mkdir(expdir);
end
cd(expdir);