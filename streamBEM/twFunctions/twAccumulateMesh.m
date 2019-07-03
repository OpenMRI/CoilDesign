function [mesh] = twAccumulateMesh(mesh,nodes,faces)
% Simple function to accumulate meshes
% using the mesh object for simplification
% The mesh object keeps track of the submeshes as well
% - there is no checking if meshes intersect, for now it should be assumed
%   that submeshes DO NOT intersect

number_of_new_nodes = size(nodes,1)
number_of_new_faces = size(faces,1)

face_offset = size(mesh.faces,1);
node_offset = size(mesh.nodes,1);
mesh.nodes = cat(1,mesh.nodes,nodes);

% add the node_offset to new faces
mesh.faces = cat(1,mesh.faces,faces+node_offset);
mesh.nsub_meshes = mesh.nsub_meshes+1;

mesh.sub_nodes_idx(mesh.nsub_meshes) = node_offset+1;
mesh.sub_nodes_n(mesh.nsub_meshes) = number_of_new_nodes;
mesh.sub_faces_idx(mesh.nsub_meshes) = face_offset+1;
mesh.sub_faces_n(mesh.nsub_meshes) = number_of_new_faces;

% update the current triangulation
% for computational speed, perhaps that should be made optional
mesh.tri = triangulation(mesh.faces,mesh.nodes(:,1),mesh.nodes(:,2),mesh.nodes(:,3));
