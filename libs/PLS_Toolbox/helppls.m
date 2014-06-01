function helppls(action,a)
%HELPPLS GUI for accessing help on PLS_Toolbox functions
%  HELPPLS is a quick "reference card" for viewing PLS_Toolbox
%  functions. Use the HelpPLS menu to change the listing from
%  alabetical to by functionality.
%
%I/O: helppls
%
%Note: the pls_toolbox must be on the MATLAB path.
%See also: "help pls_toolbox" for additional help

%Copyright Eigenvector Research, Inc. 1998
%nbg 12/98

if nargin<1, action = 'initiate'; end
if nargin<2, a      = 0;          end
switch lower(action)
case 'initiate'
  p    = get(0,'ScreenSize');
  ht   = 285;
  wd   = 390;
  bgc  = [1 1 1]*0.8;
  bgc2 = [1 1 1]*0.95;

  a    = figure('Color',bgc,'NumberTitle','off', ...
	'Position',[p(3)-wd-10 p(4)-ht-40 wd ht], ...
    'Name','PLS_Toolbox Help','Resize','on', ...
    'HandleVisibility','off');
  as   = num2str(a);
  b    = zeros(28,1);
%Scaling and Preprocessing
  b(1,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[10 ht-30 180 25], ...
    'HorizontalAlignment','left');
  b(2,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[10 ht-40 180 20], ...
    'CallBack','helppls(''callback'')');
%Plotting, Analysis Aids, and I/O Functions
  b(3,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[10 ht-70 180 25], ...
    'HorizontalAlignment','left');
  b(4,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[10 ht-80 180 20], ...
    'CallBack','helppls(''callback'')');
%Elementary Statistics, ANOVA, and Experimental Design
  b(5,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[10 ht-110 180 25], ...
    'HorizontalAlignment','left');
  b(6,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[10 ht-120 180 20], ...
    'CallBack','helppls(''callback'')');
%Principal Components, Cluster and Evolving Factor Analysis
  b(7,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[10 ht-150 180 25], ...
    'HorizontalAlignment','left');
  b(8,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[10 ht-160 180 20], ...
    'CallBack','helppls(''callback'')');
%Multiway and Curve Resolution
  b(9,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[10 ht-190 180 25], ...
    'HorizontalAlignment','left');
  b(10,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[10 ht-200 180 20], ...
    'CallBack','helppls(''callback'')');
%Linear Regression
  b(11,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[10 ht-230 180 25], ...
    'HorizontalAlignment','left');
  b(12,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[10 ht-240 180 20], ...
    'CallBack','helppls(''callback'')');
%Non-Linear Regression
  b(13,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[10 ht-270 180 25], ...
    'HorizontalAlignment','left');
  b(14,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[10 ht-280 180 20], ...
    'CallBack','helppls(''callback'')');
%Variable Selection
  b(15,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[200 ht-30 180 25], ...
    'HorizontalAlignment','left');
  b(16,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[200 ht-40 180 20], ...
    'CallBack','helppls(''callback'')');
%Multivariate Instrument Standarization
  b(17,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[200 ht-70 180 25], ...
    'HorizontalAlignment','left');
  b(18,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[200 ht-80 180 20], ...
    'CallBack','helppls(''callback'')');
%MSPC
  b(19,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[200 ht-110 180 25], ...
    'HorizontalAlignment','left');
  b(20,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[200 ht-120 180 20], ...
    'CallBack','helppls(''callback'')');
%FIR
  b(21,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[200 ht-150 180 25], ...
    'HorizontalAlignment','left');
  b(22,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[200 ht-160 180 20], ...
    'CallBack','helppls(''callback'')');
%Demos
  b(23,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[200 ht-190 180 25], ...
    'String','Demonstrations', ...
    'HorizontalAlignment','left');
  s    = str2mat('crdemo','ccordemo','clstrdmo','efa_demo', ...
    'gramdemo','lwrdemo','mddemo','nnplsdmo','parademo', ...
    'pcademo','plsdemo','polydemo','projdemo','pulsdemo', ...
    'ridgdemo','rplcdemo','rsgndemo','sgdemo', ...
    'splndemo','statdemo','stddemo');
  b(24,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[200 ht-200 180 20], ...
	'String',s,'Value',1, ...
    'CallBack','helppls(''callback'')');
%Data Sets
  b(25,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[200 ht-230 180 25], ...
    'String','Data Sets', ...
    'HorizontalAlignment','left');
  s    = str2mat('arch','nir_data','nmr_data', ...
    'pcadata','plsdata','pol_data','projdat', ...
    'pulsdata','repdata','ridgdata','simcadat',  ...
    'splndata','statdata','wine');
  b(26,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[200 ht-240 180 20],'String',s, ...
    'Value',1); %,'CallBack','helppls(''callback'')'
%Help
  b(27,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc, ...
    'Position',[200 ht-270 180 25], ...
    'String','Additional Info', ...
    'HorizontalAlignment','left');
  s    = str2mat('pls_toolbox','readme','plslogo');
  b(28,1) = uicontrol('Parent',a,'Style','popupmenu', ...
	'BackgroundColor',bgc2, ...
	'Position',[200 ht-280 180 20],'String',s, ...
    'Value',1,'CallBack','helppls(''callback2'')');
%Menu
  c    = uimenu(a,'Label','&HelpPLS');
  bb(1,1) = uimenu(c,'Label','&View');
  bb(2,1) = uimenu(bb(1,1),'Label','&by function', ...
    'CallBack',['helppls(''setstringf'',',as,');']);
  bb(3,1) = uimenu(bb(1,1),'Label','&alphabetical', ...
    'CallBack',['helppls(''setstringa'',',as,');']);

  set(b(1:end,1),'Interruptible','off', ...
    'BusyAction','cancel','Units','normalized', ...
    'FontName','geneva','Fontsize',10)
  set(a,'UserData',b)
  helppls('setstringf',a)
case 'setstringf'
  b    = get(a,'UserData');
  set(b(1,1),'String','Scaling and Preprocessing')
  s    = str2mat('auto','delsamps','dogscl', ...
    'dogsclr','gscale','gscaler','lamsel','mdauto','mdmncn', ...
    'mdrescal','mdscale','mncn','normaliz','osccalc', ...
    'refoldr','rescale','savgol','savgolcv','scale', ...
    'shuffle','specedit','unfoldm','unfoldmw','unfoldr');
  set(b(2,1),'String',s,'Value',1)
  set(b(3,1),'String','Plot/Analysis Aids and I/O')
  s    = str2mat('areadr1','dp','ellps','gline','highorb','hline', ...
    'plttern','pltternf','rwb','sampidr','vline','xclgetdata', ...
    'xclputdata','xpldst','zoompls');
  set(b(4,1),'String',s,'Value',1)
  set(b(5,1),'String','Stats, ANOVA and Exp Design')
  s    = str2mat('anova1w','anova2w','corrmap', ...
    'factdes','fastnnls','ffacdes1','ftest','ttestp');
  set(b(6,1),'String',s,'Value',1)
  set(b(7,1),'String','PCA, Cluster and EFA')
  s    = str2mat('bigpca','cluster','evolvfa','ewfa', ...
    'gcluster','mdpca','mlpca','pca','pcagui','pcapro', ...
    'pltloads','pltscrs','reslim','resmtx','scrpltr', ...
    'simca','simcaprd','tsqlim','tsqmtx','varcap');
  set(b(8,1),'String',s,'Value',1)
  set(b(9,1),'String','Multiway and Curve Res')
  s    = str2mat('gram','imgpca','mcr','mpca','mwfit','outer', ...
    'outerm','parafac','tld');
  set(b(10,1),'String',s,'Value',1)
  set(b(11,1),'String','Linear Regression')
  s    = str2mat('cr','crcvrnd','crossval','crossvus','figmerit', ...
    'modlgui','modlpred','modlrder','pcr','pls','plsnipal', ...
    'regcon','ridge','ridgecv','rinverse','simpls','ssqtable', ...
    'updatemod');
  set(b(12,1),'String',s,'Value',1)
  set(b(13,1),'String','Non-Linear Regression')
  s    = str2mat('collapse','lwrpred','lwrxy','nnpls', ...
    'nnplsbld','nnplsprd','polypls','polypred','splnfit', ...
    'splnpred','splspred','spl_pls');
  set(b(14,1),'String',s,'Value',1)
  set(b(15,1),'String','Variable Selection')
  s    = str2mat('calibsel','gaselctr','genalg');
  set(b(16,1),'String',s,'Value',1)
  set(b(17,1),'String','Standardization')
  s    = str2mat('baseline','deresolv','mscorr','stdfir','stdgen', ...
    'stdgendw','stdgenns','stdize','stdsslct');
  set(b(18,1),'String',s,'Value',1)
  set(b(19,1),'String','MSPC')
  s    = str2mat('missdat','plsrsgn','plsrsgcv','replace');
  set(b(20,1),'String',s,'Value',1)
  set(b(21,1),'String','FIR Identification')
  s    = str2mat('autocor','crosscor','fir2ss','plspulsm', ...
    'writein2','wrtpulse');
  set(b(22,1),'String',s,'Value',1)
case 'setstringa'
  b    = get(a,'UserData');
  set(b(1,1),'String','A - B')
  s    = str2mat('anova1w','anova2w','areadr1','auto','autocor', ...  
    'baseline','bigpca');
  set(b(2,1),'String',s,'Value',1)
  set(b(3,1),'String','C - D')
  s    = str2mat('calibsel','cluster','collapse ','contents', ...
    'corrmap','cr','crcvrnd','crosscor','crossval','crossvus', ...
    'delsamps','deresolv','dogscl','dogsclr','dp');   
  set(b(4,1),'String',s,'Value',1)
  set(b(5,1),'String','E - F')
  s    = str2mat('ellps','evolvfa','ewfa','factdes','fastnnls', ...
    'ffacdes1','figmerit','fir2ss','ftest');
  set(b(6,1),'String',s,'Value',1)  
  set(b(7,1),'String','G - J')
  s    = str2mat('gaselctr','gcluster','genalg','gline','gram','gscale', ...
    'gscaler','helppls','highorb','hline','imgpca');
  set(b(8,1),'String',s,'Value',1)
  set(b(9,1),'String','K - M')
  s    = str2mat('lamsel','lwrpred','lwrxy','mcr','mdauto','mdmncn', ...
    'mdpca','mdrescal','mdscale','missdat','mlpca','mncn','modlgui', ...
    'modlrder','mpca','mscorr','mwfit');
  set(b(10,1),'String',s,'Value',1)
  set(b(11,1),'String','N - O')
  s    = str2mat('nnpls','nnplsbld','nnplsprd','normaliz','osccalc', ...
    'outer','outerm');
  set(b(12,1),'String',s,'Value',1)
  set(b(13,1),'String','P - Q')
  s    = str2mat('parafac','pca','pcagui','pcapro','pcr','pls', ...
    'plslogo','plsnipal','plspulsm','plsrsgcv','plsrsgn','pltloads', ... 
    'pltscrs','plttern','pltternf','polypls','polypred');
  set(b(14,1),'String',s,'Value',1)
  set(b(15,1),'String','R')
  s    = str2mat('readme','refoldr','regcon','replace','rescale', ...
    'reslim','resmtx','ridge','ridgecv','rinverse','rwb');
  set(b(16,1),'String',s,'Value',1)
  set(b(17,1),'String','S')
  s    = str2mat('sampidr','savgol','savgolcv','scale','scrpltr', ...
    'shuffle','simca','simcaprd','simpls','specedit','splnfit', ...
    'splnpred','splspred','spl_pls','ssqtable','stdfir','stdgen', ...
    'stdgendw','stdgenns','stdize','stdsslct');
  set(b(18,1),'String',s,'Value',1)
  set(b(19,1),'String','T - U')
  s    = str2mat('tld','tsqlim','tsqmtx','ttestp','unfoldm', ...
    'unfoldmw','unfoldr','updatemod');
  set(b(20,1),'String',s,'Value',1)
  set(b(21,1),'String','V - Z')
  s    = str2mat('varcap','vline','writein2','wrtpulse','xclgetdata', ...
    'xclputdata','xpldst','zoompls');
  set(b(22,1),'String',s,'Value',1)
case 'callback'
  s    = get(gcbo,'String');
  evalin('base',['help ',s(get(gcbo,'Value'),:)])
case 'callback2'
  s    = get(gcbo,'String');
  switch get(gcbo,'Value')
  case 1
    evalin('base',['help ',s(get(gcbo,'Value'),:)])
  case 2
    evalin('base',['help ',s(get(gcbo,'Value'),:)])
  case 3
    evalin('base',[s(get(gcbo,'Value'),:)])
  end
end