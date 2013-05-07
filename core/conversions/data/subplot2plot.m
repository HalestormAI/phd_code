function subplot2plot( fh )

if nargin < 1
    fh = gca;
end 

currSub = fh;

newfig = figure;
% axis;
c = copyobj( currSub, newfig);
set(c,'OuterPosition',[ .05 .05  .9 .9 ]);

end