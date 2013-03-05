%APCLUSTERMEX Affinity Propagation Clustering (Frey/Dueck, Science 2007)
% [idx,netsim,dpsim,expref]=APCLUSTERMEX(s,p) clusters data, using a set 
% of real-valued pairwise data point similarities as input. Clusters 
% are each represented by a cluster center data point (the "exemplar"). 
% The method is iterative and searches for clusters so as to maximize 
% an objective function, called net similarity.
% 
% For N data points, there are potentially N^2-N pairwise similarities; 
% this can be input as an N-by-N matrix 's', where s(i,k) is the 
% similarity of point i to point k (s(i,k) needn’t equal s(k,i)).  In 
% fact, only a smaller number of relevant similarities are needed; if 
% only M similarity values are known (M < N^2-N) they can be input as 
% an M-by-3 matrix with each row being an (i,j,s(i,j)) triple.
% 
% APCLUSTERMEX automatically determines the number of clusters based on 
% the input preference 'p', a real-valued N-vector. p(i) indicates the 
% preference that data point i be chosen as an exemplar. Often a good 
% choice is to set all preferences to median(s); the number of clusters 
% identified can be adjusted by changing this value accordingly. If 'p' 
% is a scalar, APCLUSTERMEX assumes all preferences are that shared value.
% 
% The clustering solution is returned in idx. idx(j) is the index of 
% the exemplar for data point j; idx(j)==j indicates data point j 
% is itself an exemplar. The sum of the similarities of the data points to 
% their exemplars is returned as dpsim, the sum of the preferences of 
% the identified exemplars is returned in expref and the net similarity 
% objective function returned is their sum, i.e. netsim=dpsim+expref.
% 
% 	[ ... ]=apclustermex(s,p,'NAME',VALUE,...) allows you to specify 
% 	  optional parameter name/value pairs as follows:
% 
%   'maxits'     maximum number of iterations (default: 500)
%   'convits'    if the estimated exemplars stay fixed for convits 
%          iterations, APCLUSTERMEX terminates early (default: 50)
%   'dampfact'   update equation damping level in [0.5, 1).  Higher 
%        values correspond to heavy damping, which may be needed 
%        if oscillations occur.
%   'plot'       (no value needed) Plots netsim after each iteration
%   'details'    (no value needed) Outputs iteration-by-iteration 
%      details (greater memory requirements)
%   'nonoise'    (no value needed) APCLUSTERMEX adds a small amount of 
%      noise to 's' to prevent degenerate cases; this disables that.
%   'callback'   provide a callback m-function invoked each iteration
%                   0=action=fn(a,r,idx,netsim,dpsim,expref,iter)
% 
% Copyright (c) B.J. Frey & D. Dueck (2006). This software may be 
% freely used and distributed for non-commercial purposes.
function [idx,netsim,dpsim,expref] = apclustermex(s,p,varargin)
start = clock;
if ~issparse(s) && size(s,1)==size(s,2), % full+square matrix
	si=[]; sj=[]; sij=s(:); [I,J]=size(s); sij(sub2ind([I J],1:I,1:I))=p(:)';
else % non-full+square matrix
	if size(s,2)==3, si=s(:,1);sj=s(:,2); sij=s(:,3); elseif issparse(s), [si,sj,sij]=find(s); end;
    	I=max(si); J=max(sj);
	ii=find(si==sj); if isempty(ii), si=[si; (1:max(I,J))']; sj=[sj; (1:max(I,J))']; ii=find(si==sj); end; % if no diagonal elements are given, add the full set
	[junk,order]=sort(si(ii)); sij(ii(order))=p; % set "all" diagonal elements to the preference(s)
	if isempty(find(si<sj,1,'first')) || isempty(find(si>sj,1,'first')), warning('s(i,j) does not imply s(j,i) -- check if all desired (i,j) pairs are included'); end;
end;
N=length(sij);

% set up apcluster options (including computing platform)
options.cbSize=40;
options.lambda=0.9;
options.minimum_iterations=1;
options.converge_iterations=50;
options.maximum_iterations=500;
options.details=0;
options.nonoise=0;
options.progressfunction=[];
options.kcc=0; options.vsh=0;
switch(computer),
	case {'PCWIN'}, options.cbSize=40; kccoptions.cbSize=32;
	case {'GLNXA64'}, options.cbSize=48; kccoptions.cbSize=40;
	case {'GLNX86'}, options.cbSize=36;
	otherwise, error('Affinity Propagation not supported on %s platform [yet]',computer);
end;
while numel(varargin),
	switch(varargin{1}),
        case {'nokcc','pure','nofixup','nocleanup'}, options.kcc=0; varargin(1)=[];
        case {'novsh'}, options.vsh=0; varargin(1)=[];
        case {'vsh'}, options.vsh=1; varargin(1)=[];
        case {'kcc','fixup','cleanup'}, options.kcc=1; varargin(1)=[];
		case {'details','det'}, options.details=1; varargin(1)=[];
		case {'nodetails','nodet'}, options.details=0; varargin(1)=[];
        case {'noise','plusnoise','+noise','addnoise'}, options.nonoise=0;
        case {'nonoise','-noise'}, options.nonoise=1; varargin(1)=[];
        case {'plot','plt'}, warning('plotting not supported within compiled MEX-files'); varargin(1)=[];
        case {'convits','cnvits','conv','cnv'}, options.converge_iterations=varargin{2}; varargin(1:2)=[];
		case {'dampfact','damping','dmpfact','lambda'}, options.lambda=varargin{2}; varargin(1:2)=[];
		case {'maxiter','mxiter','maxits','mxits'}, options.maximum_iterations=varargin{2}; varargin(1:2)=[];
        case {'callback','callbackfunction','callbackfcn','callbackfn','progressfn','progressfcn','progressfunction','progress','function'}, options.progressfunction=varargin{2}; varargin(1:2)=[];
		otherwise, varargin(1)=[];
	end;
end;
if isa(options.progressfunction,'function_handle'), options.progressfunction=func2str(options.progressfunction); end;
if strcmp(options.progressfunction,''), options.progressfunction=[]; end;
if exist(options.progressfunction), if exist(options.progressfunction)~=2, options.progressfunction=[]; warning('nonexistent callback function specified'); end; end;

if I<2^16-1, si=uint16(si-1); sj=uint16(sj-1); else si=uint32(si-1); sj=uint32(sj-1); end;

if options.details, % set up return arguments (reference parameters)
	idx = -ones(I,options.maximum_iterations,'int32');
    netsim = zeros(1,options.maximum_iterations);
    dpsim = zeros(1,options.maximum_iterations);
    expref = zeros(1,options.maximum_iterations);
else
    idx=-ones(I,1,'int32');
    netsim = 0;
    dpsim = 0;
    expref = 0;
end; netsim(1)=1e-38; dpsim(1)=1e-38; expref(1)=1e-38; % this makes sure the memory is allocated (compatibility reasons)

ret=apclustermex_(sij,si,sj,idx,netsim,dpsim,expref,options);
if ret<0, error('apclustermex returned error code %d',ret); end;

T = max([find(netsim,1,'last'),find(dpsim,1,'last'),find(expref,1,'last')]);
netsim=netsim(1:T); dpsim=dpsim(1:T); expref=expref(1:T); idx=idx(:,1:T);

finish = clock;
if options.details,
    fprintf('\nNumber of exemplars identified: %d  (for %d data points)\n',length(unique(idx(:,end))),I);
    fprintf('Fitness (net similarity): %f\n',netsim(end));
    fprintf('  Similarities of data points to exemplars: %f\n',dpsim(end));
    fprintf('  Preferences of selected exemplars: %f\n',expref(end));
    fprintf('Number of iterations: %d\n',T);
%     if options.kcc, fprintf(' + KCC cleanup\n'); else fprintf('\n'); end;
    fprintf('Elapsed time: %f sec\n',etime(finish,start));
end;

if options.kcc,
    kccoptions.use_input_exemplars=1; kccoptions.number_of_restarts=1;
    temp=unique(idx(:,end)); temp=temp(temp>0); kccidx=zeros(I,1,'int32'); kccidx(temp)=1;
    kccnetsim=1e-10; kccdpsim=2e-10; kccexpref=3e-10;
    ret=kcentersmex_(sij,si,sj,sum(kccidx),kccidx,kccnetsim,kccdpsim,kccexpref,kccoptions);
    if ret<0, error('kcentersmex returned error code %d',ret); end;
    idx=[idx kccidx]; netsim=[netsim kccnetsim]; dpsim=[dpsim kccdpsim]; expref=[expref kccexpref];
    fprintf('   KCC cleanup:  netsim=%f, dpsim=%f, expref=%f\n',netsim(end),dpsim(end),expref(end));
    fprintf('   Additional Elapsed time: %f sec\n',etime(clock,finish));
end;

if options.vsh,
    init=unique(double(idx(:,end))); K=length(init);
    if isempty(si), S=reshape(sij,[I I]); else S=zeros(I,I); S(sub2ind([I I],double(si),double(sj)))=sij; end;
    [idx,netsim,dpsim,expref]=vshmex(S,K,'pref',p,'init',init);
end;

return

% sample callback function
function action = progressfunction(a,r,curridx,currnetsim,currdpsim,currexpref,iter)
    hold on; plot(iter,currnetsim,'ro');
    action = 0; % returning zero means to continue
return

% VSHMEX Vertex Substitution Heuristic for the p-median problem
%  [idx,netsim,dpsim,expref] = vshmex(S,K)
%   Input: S, an N-by-N similarity matrix
%          K, the number of clusters
%
function [idx,netsim,dpsim,expref] = vshmex(S,K,varargin)
    start = clock;
    [I,J] = size(S);
    if (I==J) N=I; else error('Input similarity matrix S must be square'); end;
    K=double(K); if (K>N || K<1) error('K must be in range [1..N]'); end;
    if ~isa(S,'double'), S=double(S); warning('converting unknown S-matrix format to double-precision floating point'); end;
    
    p=diag(S); details=true; init=[]; T=[]; % number of restarts
    while numel(varargin),
    	switch(varargin{1}),
    		case {'details','det'}, details=true; varargin(1)=[];
        	case {'nodetails','nodet'}, details=false; varargin(1)=[];
            case {'nruns','restarts'}, T=varargin{2}; varargin(1:2)=[];
            case {'init','initialization'}, init=varargin{2}; if isempty(T), T=1; end; varargin(1:2)=[];
            case {'pref','preference','p'}, p=varargin{2}; varargin(1:2)=[];
        	otherwise, varargin(1)=[];
    	end;
    end;
    if isempty(T), T=20; end;
    if numel(p)==1, p=repmat(p,[1 I]); end;

    T=double(floor(T)); if T<1, error('Number of restarts out of range (must be positive integer)'); end;
    if numel(init)==K, init=init(:)'; init=[init, setdiff(1:I,init)]; end; init=double(init);

    M=max(max(S)); if M<=0, M=0; end; S=S-M; for i=1:N, S(i,i)=0; end; % make negative for algorithm to work
    idx = zeros(N,T);
    netsim = zeros(1,T);
    dpsim = zeros(1,T);
    expref = zeros(1,T);
    for t=1:T,
        if isempty(init), [idx(:,t),netsim(:,t),dpsim(:,t),expref(:,t)] = vshmex1(S,K);
        else [idx(:,t),netsim(:,t),dpsim(:,t),expref(:,t)] = vshmex1(S,K,init); end;
        dpsim(:,t)=dpsim(:,t)+(N-K)*M;
        expref(:,t)=sum(p(unique(idx(:,t))));
        netsim(:,t)=dpsim(:,t)+expref(:,t);
        fprintf('dpsim=%f for VSH restart #%d (%f sec total)\n',dpsim(t),t,etime(clock,start));
    end;
return

function [idx,netsim,dpsim,expref] = vshmex1(S,varargin)
    ret = vshmex_(S,varargin{:}); ret=double(ret);
    T = size(ret,2);
    N = length(S);
    
    idx = zeros(N,T);
    dpsim = zeros(1,T);
    expref = zeros(1,T);
    for t=1:T,
        exs = ret(:,t);
        if length(unique(exs))<length(exs) || min(exs)<1 || max(exs)>N,
            error('something wrong with set of exemplars');
        end;
        expref(t) = sum(S(sub2ind([N N],double(exs),double(exs))));
        notexs = setdiff((1:N)',exs);
        [temp,idx_] = max(S(notexs,exs),[],2);
        dpsim(t) = sum(temp);
        idx(exs,t)=exs; idx(notexs,t)=exs(idx_);
    end;
    netsim = dpsim + expref;
return
