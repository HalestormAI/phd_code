function f=fun1(x)
%FUN1 Objective function calculation for NNPLS
%  Function calculation for use with optimization routine
%  for determining weights in backprop network.
%
%I/O: f = fun1(x);

%Copyright Thomas Mc Avoy 1994
%  Distributed by Eigenvector Research, Inc.
%  Modified by BMW 5-8-95
global Tscores Uscores
% Lambda=penalty used for large weights
	t=Tscores;
	u=Uscores;
	n=(length(x)-1)/3;
	Lambda=.0002;
	Lam=sqrt(Lambda/2);
	beta=x(1:n+1);
	kin=[x(n+2:2*n+1)';x(2*n+2:3*n+1)'];
	[upred,usig]=bckprpnn(t,kin,beta);
%	f=norm(u-upred)^2+Lambda*norm(x)^2;
	f=[(u-upred);Lam*x];
