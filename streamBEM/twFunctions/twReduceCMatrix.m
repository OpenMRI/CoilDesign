function [MR] = twReduceCMatrix(M,subBoundaries)

%% Assume M comes with boundary notes sorted to the top
%% This function cuts out only columns, and keeps all rows
number_of_boundaries = size(subBoundaries,1);

% generate a vector of the last boundary node each
boundary_keep = [];
accum = 0;
for b=1:number_of_boundaries
    accum = accum+size(subBoundaries(b).node,1);
    boundary_keep = [boundary_keep accum];
end

matrix_keep = [boundary_keep boundary_keep(end)+1:size(M,2)];
MR = M(:,matrix_keep);