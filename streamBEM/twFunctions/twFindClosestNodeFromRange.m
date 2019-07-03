function vsub = twFindClosestNodeFromRange(nodes,v,range)
%
% find the closest node "vsub" to a node "v" from the range of nodes "range"
%

% if v is in range, this should throw an error

for n = 1:length(range)
   dist = sqrt((nodes(v,1)-nodes(range(n),1))^2+ ...
               (nodes(v,2)-nodes(range(n),2))^2+ ...
               (nodes(v,3)-nodes(range(n),3))^2);
   
   if n==1
       mindist = dist;
       vsub = range(1);
   elseif dist < mindist
       mindist = dist;
       vsub = range(n);
   end
end