function plotTrajInnerSpds( estTraj, gtTraj )

eLengths = cellfun( @(x) vector_dist(x), estTraj,'uniformoutput',false);
gLengths = cellfun( @(x) vector_dist(traj2imc(x,1,1)), gtTraj,'uniformoutput',false);
figure
for i=1:length(eLengths)
    subplot(3,4,i);
    bar([gLengths{i}./max(gLengths{i});eLengths{i}./max(eLengths{i})]');
end