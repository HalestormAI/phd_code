echo off
%NNPLSDMO Routine to demonstrate NNPLS code.

%Copyright Thomas J. Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95
echo on

% The data we are going to work with was published by S. Wold in his
% paper on nonlinear PLS.  The data involves the response of 17 women 
% in terms of 11 qualities (outputs) of face cream formulations.  Each 
% formulation had a different combination of 8 ingredients, which are 
% the inputs. Lets start by loading the data.  Hit a key when you are ready.
echo off
pause


cosmetic
echo on
% The cosmetic data set has a small number of samples, 17.  Test set
% validation is used and 6 samples are used for the test set. The
% remaining 11 samples are used for training.
pause


% In this demonstration a maximum of 4 factors will be used.  The plot
% option is set to 1.0 so that each individual factor will be displayed. 
% The NNPLS function uses either the supplied conjugate gradient 
% optimization routine or the Optimization Toolbox routine "leastsq"
% if it is found on the search path. The function will tell you if
% "leastsq" is found. For some inner relationships a warning flag may 
% be printed indicating convergence has not been achieved in parameterizing
% the inner relationship. In these cases , which often involve nearly linear 
% inner relationships, it is important to plot the inner relationships. 
% From the plots one can see if a good fit has been obtained. The first 
% NNPLS plot gives the PLS fit.  Subsequent plots give the results for 1, 
% 2,  3, etc sigmoids respectively. The default settings is that a maximum 
% of 6 sigmoids is used by the routine. Hit any key to proceed.
pause

[W,Q,P,NEURAL,ssqdif] = nnpls(ax,ay,sxtest,sytest,4,[1 6 .01]);
echo off
pause
echo on
% The Matrix NEURAL gives the architecture of the inner neural nets
% models.  The first element gives the number of sigmoids and the
% remaining elements are the network weights.  W and Q give the 
% input and output PLS weights.  The routine collapse.m can be used to
% collapse the extended neural net structure down to a standard neural
% network. W12, W23, B2, B3 are the weights and biases in the collapsed
% neural network.  The minimum press occurs at 2 factors.  Thus, a
% 2 factor model will be collapsed to a standard neural network.
pause
disp([NEURAL])
pause 
 
[W12,W23,B2,B3]=collapse(NEURAL,W,Q,P,2);

% The weights and biases can now be used with the function
% nnplsprd to make new predictions. In this case, we don't have
% any additional data, so instead, lets "predict" the total data
% set that we do have.

ynpredc = nnplsprd(W12,W23,B2,B3,ax);
ynpredt = nnplsprd(W12,W23,B2,B3,sxtest);
synpredc = rescale(ynpredc,my,sy);
synpredt = rescale(ynpredt,my,sy);

echo off
plot(y,synpredc,'o',ytest,synpredt,'+'), dp
title('Actual vs. Predicted Face Cream Quality')
xlabel('Actual Quality')
ylabel('Predicted Quality')
pause

echo on

% So yes, this doesn't look like real great prediction, but this
% is typical of cases where human responses are being considered.
pause

% We will now consider an application in non-linear dynamic model
% identification. Let's look at the input/output behavior of a
% non-linear surge tank system. 

echo off

load pol_data
plot(caldata)
xlabel('Time')
ylabel('Process Input and Output')
title('Dynamic Input/Output Response of Non-linear Surge Tank')
axis([0 450 1 12]), hold on
plot([25 50],[11.5 11.5],'-b') 
plot([25 50],[10.8 10.8],'-g')
text(60,11.5,'Process Input')
text(60,10.8,'Process Output')
hold off

pause
echo on

% We will now use this data and some additional data to develop
% a NNPLS model and a poly-PLS model. You will be able to see the
% inner relationship fits as they are calculated.

echo off
[acal,mcal,scal] = auto(caldata);
stest = scale(testdata,mcal,scal);
[newu1,newy1] = wrtpulse(acal,acal(:,2),[5 1],[1 1]);
[newu2,newy2] = wrtpulse(stest,stest(:,2),[5 1],[1 1]);
[mu1,nu1] = size(newu1);
[mu2,nu2] = size(newu2); 
ucc = [newu1(1:250,:); newu2(1:250,:)];
ycc = [newy1(1:250,:); newy2(1:250,:)];
uct = [newu1(251:350,:); newu2(251:350,:)];
yct = [newy1(251:350,:); newy2(251:350,:)];
ut  = [newu1(351:mu1,:); newu2(351:mu2,:)];
yt  = [newy1(351:mu1,:); newy2(351:mu2,:)];
[W,Q,P,NEURAL,ssqdif] = nnpls(ucc,ycc,uct,yct,5,[1 2 0]);
[W12,W23,B2,B3] = collapse(NEURAL,W,Q,P,3);
ynpred = nnplsprd(W12,W23,B2,B3,ut);
synpred = rescale(ynpred,mcal(2),scal(2));
syt = rescale(yt,mcal(2),scal(2));
echo on

% Here is the prediction of our new test set that was not used
% in the calibration.

pause
echo off

[mt,nt] = size(ut);
plot(1:mt,syt,1:mt,synpred)
axis([0 200 0 12])
title('Actual and Predicted Output for Non-linear Surge Tank Process')
xlabel('Time')
ylabel('Actual and Predicted Output')
hold on
plot([110 120],[5 5],'-b')
plot([110 120],[4.3 4.3],'-g')
text(125,5,'Actual Output')
text(125,4.3,'NNPLS Prediction')
pause
echo on

% We will now develop the poly PLS model. This model has been 
% cross-validated before, so we will just pick 4 factors.

echo off
[p,q,w,t,u,b,ssqdif] = polypls(ucc,ycc,5,2);
ypredp = polypred(ut,b,p,q,w,4);
sypredp = rescale(ypredp,mcal(2),scal(2));
pause
echo on

% We can also develop a linear PLS model for this data
echo off
b = pls(ucc,ycc,6);
ypredpls = ut*b(5,:)';
sypredpls = rescale(ypredpls,mcal(2),scal(2));

pause
% Now we will add the predictions from the poly-PLS and linear
% PLS models to the plot.

echo off
plot(1:mt,sypredp,'-r',1:mt,sypredpls,'-m')
plot([110 120],[3.6 3.6],'-r')
plot([110 120],[2.9 2.9],'-m')
text(125,3.6,'Poly-PLS Prediction')
text(125,2.9,'Linear-PLS Prediction')
hold off
echo on
pause

% The prediction errors can also be compared
echo off
ssqn = sqrt(sum((ynpred-yt).^2)/205);
ssqp = sqrt(sum((ypredp-yt).^2)/205);
ssqpls = sqrt(sum((ypredpls-yt).^2)/205);
disp('  ')
disp('Root Mean Square Error of Prediction')
disp('  NNPLS      Poly-PLS   Linear PLS')
disp('  ------      ------      ------')
format = '  %6.4f      %6.4f      %6.4f  ';
tab = sprintf(format,[ssqn ssqp ssqpls]); disp(tab);

echo on
% So in this case, both non-linear models did
% better than the linear model.
 



