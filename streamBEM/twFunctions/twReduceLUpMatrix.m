function [MR] = twReduceLUpMatrix(M,subBoundariesVertical,subBoundariesHorizontal)

%% Keep horizontals and verticals seperately

%% Assume M comes with boundary notes sorted to the top
%% Also assume M is square

number_of_boundariesV = size(subBoundariesVertical,1);
number_of_boundariesH = size(subBoundariesHorizontal,1);

% verticals
boundary_keepV = [];
accumV = 0;
for b=1:number_of_boundariesV
    accumV = accumV+size(subBoundariesVertical(b).node,1);
    boundary_keepV = [boundary_keepV accumV];
end

matrix_keepV = [boundary_keepV boundary_keepV(end)+1:size(M,1)];

% horizontals
boundary_keepH = [];
accumH = 0;
for b=1:number_of_boundariesH
    accumH = accumH+size(subBoundariesHorizontal(b).node,1);
    boundary_keepH = [boundary_keepH accumH];
end

matrix_keepH = [boundary_keepH boundary_keepH(end)+1:size(M,2)];

MR = M(matrix_keepV,matrix_keepH);
