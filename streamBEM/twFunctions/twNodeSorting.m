function [node2,triangle2,subBoundary] = twNodeSorting(node,triangle)
%% First find the boundary vertices

% number of vertices N
N = size(node,1);

% this computes the adjacency matrix
A = min(sparse(triangle(:,1),triangle(:,2),1,N,N)+sparse(triangle(:,2),triangle(:,3),1,N,N)+sparse(triangle(:,3),triangle(:,1),1,N,N),1);
A = min(A+A',1);
% this finds the boundary points, whose indexes are stored in Ibord
B = A^2.*A==1;
Ibord = find(sum(B,2)>0);
    
%% Now extract the sub boundaries
% TW: this looks pretty clunky, but should work pretty well
sbidx = 1;
bvec = Ibord;
visited = sparse(Ibord,1,0);
while length(bvec) > 0
    start = bvec(1);
    n = 1;
    sub_boundary{sbidx}(n) = start;
    visited(start) = 1;
    n = n+1;
    idx = start;
    closed = false;
    while ~closed
        neighbors = find(B(:,idx));
        if length(neighbors) ~= 2
            error('big problem: vertex has more than two neighbors on boundary'); 
        end
        
        % this checks if either neighbor is the starting point, and we
        % aren't just returning. I believe this could be done easier, by
        % concluding we are closed if both neighbors have been visited
        if (neighbors(1) == start || neighbors(2) == start) && (length(sub_boundary{sbidx}) > 2)
            closed = true;
            break;
        end
        
        % figure out which way to walk
        if visited(neighbors(1),1) == 1
            idx = neighbors(2);
        else
            idx = neighbors(1);
        end
        
        visited(idx) = 1;
        sub_boundary{sbidx}(n) = idx; 
        n = n+1;
    end
    
    % delete this sub_boundary from the list of boundary vertices
    bvec = setxor(bvec,sub_boundary{sbidx}(:));
    sbidx = sbidx+1;
end
    
%disp(sprintf('Found %d sub boundaries',size(sub_boundary,2))); 
 
%% resort everything so that the boundary nodes are first

% Now, resort the nodes, so that border nodes are on top
new_idx = [Ibord' setxor(1:N,Ibord')];
% Find the new mapping for the triangles
vertex_map(new_idx) = 1:N;

node2(1:N,:) = node(new_idx,:);
% Convert all the triangles to have the new indices
for t=1:size(triangle,1)
    triangle2(t,1) = vertex_map(triangle(t,1));
    triangle2(t,2) = vertex_map(triangle(t,2));
    triangle2(t,3) = vertex_map(triangle(t,3));
end

%% Generate a compatible output to the bringout function
for s=1:size(sub_boundary,2)
    subBoundary(s,1).node = sub_boundary{s}(:);
end