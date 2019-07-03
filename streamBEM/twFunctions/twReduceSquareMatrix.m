function [MR] = twReduceSquareMatrix(M,subBoundaries1)

%% Assume M comes with boundary notes sorted to the top
%% Also assume M is square

number_of_boundaries = size(subBoundaries1,1);

% generate a vector of the last boundary node each
boundary_keep = [];
accum = 0;
for b=1:number_of_boundaries
    accum = accum+size(subBoundaries1(b).node,1);
    boundary_keep = [boundary_keep accum];
end

matrix_keep = [boundary_keep boundary_keep(end)+1:size(M,1)];
MR = M(matrix_keep,matrix_keep);
