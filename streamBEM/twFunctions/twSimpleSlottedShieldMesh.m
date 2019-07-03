function [mesh,node,faces,tri] = twSimpleSlottedShieldMesh(cylinder_radius, cylinder_length, center, mesh_size)
% Generate a cylindrical shield mesh with longitudinal cuts and two
% azimuthal cuts

options.number_of_cuts = 16;
options.endring_width = 0.03; % in centimeter
options.cut_width = 0.005; % not sure its smart to have a cut smaller than the mesh size
options.endring_cut_width = options.cut_width;
% Order for normal pointing outward
options.vertex_order = 'CW';

mesh = twInitMesh();

circumference = 2*pi*cylinder_radius;
% Calculate the arc_length of the cut
arc_length_cut = options.cut_width/circumference * 2*pi;

% Calculate the arc_lengths of the shield strips. There is as many cuts as
% there are shield strips on a closed cylinder.
arc_length_shield = (2*pi-options.number_of_cuts*arc_length_cut)/options.number_of_cuts;

% calculate the strip lengths and offsets
% total_length is 2*cut_length+2*end_ring_width+strip_length;
strip_length = cylinder_length-2*options.endring_cut_width-2*options.endring_width;
endring_center_offset = strip_length/2+options.endring_cut_width+options.endring_width/2;

% Make meshes in the order cut-shield-cut-shield
for segment = 1:options.number_of_cuts
    start_arc = (segment-1)*arc_length_shield+segment*arc_length_cut;
    [nodes,faces,tri] = twRadialCylinderMeshSection(cylinder_radius, start_arc, start_arc+arc_length_shield, strip_length, center, mesh_size);
    mesh = twAccumulateMesh(mesh,nodes,faces);
end

% Make the end-ring mesh
[nodes,faces,tri] = twCylinderMesh(cylinder_radius,options.endring_width,center+[0,0,endring_center_offset] ,mesh_size);
mesh = twAccumulateMesh(mesh,nodes,faces);
[nodes,faces,tri] = twCylinderMesh(cylinder_radius,options.endring_width,center+[0,0,-endring_center_offset] ,mesh_size);
mesh = twAccumulateMesh(mesh,nodes,faces);

disp(sprintf('We have now a total of %d triangles over %d submeshes !',size(mesh.faces,1),mesh.nsub_meshes));

tri = mesh.tri;
node = mesh.nodes;
faces = mesh.faces;

% optional display of the cylinder mesh
%tr1 = triangulation(faces1,node1(:,1),node1(:,2),node1(:,3));
figure(109);
trisurf(mesh.tri)
axis equal;
fn1 = faceNormal(mesh.tri);  
P1 = incenter(mesh.tri);
hold on;
quiver3(P1(:,1),P1(:,2),P1(:,3),fn1(:,1),fn1(:,2),fn1(:,3),1.5, 'color','r');
hold off;

