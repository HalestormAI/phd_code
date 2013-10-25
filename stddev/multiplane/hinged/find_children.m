function [children indices] = find_children( id, parent_graph, maxdepth, depth)
% FIND_CHILDREN Searches the parent_graph for child nodes. If MAXDEPTH is
% given, looks only MAXDEPTH levels deeper than given root node in the
% graph.
%
% Usage:
%   C = FIND_CHILDREN( R, G )   Searches graph G starting at node R for
%                               children, C.
%
%   C = FIND_CHILDREN( R, G, MAXDEPTH )
%                               As above, but only to maximum depth
%                               MAXDEPTH relative to R.
%
% See Also: HINGED_GENERAL_ROTATION

    if nargin < 4
        depth = 0;
    end
    if nargin < 3 || maxdepth < 0
        maxdepth = 9999;
    end
    
    if depth >= maxdepth
        children = [];
        indices = [];
    else
        children = find(parent_graph == id);
        [~,indices] = ismember(children, parent_graph);
        for d=1:length(children)
            [kids idx] = find_children(children(d), parent_graph, maxdepth, depth+1);
            children = [children kids];
            indices = [indices idx];
        end
    end

end