function [mesh,node,faces,tri] = twSimpleHighpassBCMesh(cylinder_radius, cylinder_length, center, mesh_size)
% Generate a cylindrical shield mesh with longitudinal cuts and two
% azimuthal cuts

options.number_of_rungs = 16;
options.endring_width = 0.04; % in centimeter
options.cut_width = 0.005; % not sure its smart to have a cut smaller than the mesh size
options.endring_cut_width = options.cut_width;
% Order for normal pointing outward
options.vertex_order = 'CW';
options.rung_width = 0.02; % in centimeter

mesh = twInitMesh();

circumference = 2*pi*cylinder_radius;
% Calculate the arc_length of the cut
arc_length_cut = options.cut_width/circumference * 2*pi;
arc_length_rung = options.rung_width/circumference * 2*pi;

% Calculate the arc_lengths of the shield strips. There is as many cuts as
% there are shield strips on a closed cylinder.
arc_length_endring = (2*pi-options.number_of_rungs*arc_length_cut)/options.number_of_rungs;

% calculate the strip lengths and offsets
% total_length is 2*end_ring_width+strip_length;
strip_length = cylinder_length-2*options.endring_width;


% Make meshes in the order cut-rung-cut-rung
rad_start = [0 (arc_length_endring-arc_length_rung)/2 0];
rad_end = [arc_length_endring arc_length_endring-(arc_length_endring-arc_length_rung)/2 arc_length_endring];
strip_length = [options.endring_width cylinder_length-2*options.endring_width options.endring_width];
for segment = 1:options.number_of_rungs
    start_arc = (segment-1)*arc_length_endring+segment*arc_length_cut;
    [nodes,faces,tri] = twRadialCylinderTeeMeshSection(cylinder_radius, rad_start+start_arc, rad_end+start_arc, strip_length, [0 0 0], mesh_size);
    mesh = twAccumulateMesh(mesh,nodes,faces);
end
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
