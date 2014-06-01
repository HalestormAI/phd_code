function svdlgpls(varin,message,action)
%SVDLPLS save variable to workspace dialog.
%  The input (varin) is a variable to be passed
%  out from a function to the workspace. The
%  dialog box allows the user to name (varin)
%  to a new workspace variable.
%
%I/O: svdlgpls(varin,message)

%Copyright Eigenvector Research, Inc. 1997-2000
%nbg 4/97,6/97,11/99

if nargin<3
  if nargin<2
    message = [];
  end
  bgc0    = [1 1 1];
  fsiz    = 10;
  switch lower(computer)
  case 'pcwin'
    fnam = 'arial';
  case 'mac2'
    fnam = 'geneva';
  otherwise
    fnam = 'geneva';
  end
  fwt     = 'bold';

  units0   = get(0,'Units');
  set(0,'Units','pixels')
  p       = get(0,'ScreenSize');          
  a = dialog('Color',bgc0, ...
    'Name','Save', ...
    'Position',[p(3)/2-150 p(4)/2 300 170], ...
    'Resize','off'); %dialog
  b = zeros(6,1);
  evalin('base','assignin(''caller'',''s'',who)')
  b(1,1) = uicontrol('Parent',a, ...
    'Position',[3 58 201 109], ...
    'String',s, ...
    'CallBack','svdlgpls([],[],''listact'')', ...
    'Style','listbox','Value',[1], ...
    'Selected','off');
  b(2,1) = uicontrol('Parent',a, ...
    'FontWeight',fwt, ...
    'Position',[3 3 201 25], ...
    'HorizontalAlignment','left', ...
    'Style','edit','String','var');
  b(3,1) = uicontrol('Parent',a, ...
    'FontWeight',fwt, ...
    'Position',[5 30 199 20], ...
    'HorizontalAlignment','left', ...
    'String','Save to Workspace as:', ...
    'Style','text');
  b(4,1) = uicontrol('Parent',a, ...
    'Position',[215 33 75 25],'FontWeight',fwt, ...
    'String','Cancel', ...
    'FontName',fnam,'FontSize',fsiz,'FontWeight',fwt, ...
    'CallBack','close(gcf)');
  b(5,1) = uicontrol('Parent',a, ...
    'Position',[215 3 75 25],'FontWeight',fwt, ...
    'String','Save','UserData',varin, ...  
    'CallBack','svdlgpls([],[],''actsav'');', ...  
    'Tag','PushSaveSVDLG');
  if ~isempty(message)
    message = ['save: ',message];
  end
  b(6,1) = uicontrol('Parent',a,'Style','text', ...
    'Position',[215 71 75 96], ...
    'HorizontalAlignment','left', ...
    'String',message,'FontWeight',fwt);
  set(a,'UserData',b)
  for jj=1:6
    set(b(jj,1),'FontName',fnam,'FontSize',fsiz, ...
      'Units','points','BackgroundColor',bgc0)
  end
  set(0,'Units',units0)
else
  b = get(gcf,'UserData');
  if strcmp(action,'actsav')
  c = get(b(2,1),'string');
    if ~isempty(c)
      s = [c,' = get(findobj(''tag'',''PushSaveSVDLG''),''UserData'');'];
      evalin('base',s)     
     close(gcf)
    else
      s = ['save variable name empty'];
      erdlgpls(s,'Error on Save!')
    end
  elseif strcmp(action,'listact')
    c = get(b(1,1),'value');
    s = get(b(1,1),'string');
    c = s{c};
    set(b(2,1),'string',c);
  end
end