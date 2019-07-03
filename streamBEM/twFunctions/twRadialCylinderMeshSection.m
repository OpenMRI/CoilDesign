function [node,faces,tri] = twRadialCylinderMeshSection(cylinder_radius, section_arc_start, section_arc_end, section_length, center, mesh_size)
% Generate a radial section of a cylinder mesh
% this section is not closed azimuthally, and therefore distinct from a
% true cylindermesh function

% Order for normal pointing outward
vertex_order = 'CW';

% Note, the mesh size should be done differently azimutal and length
% wise, but for now we use the same in this function
azimuth_mesh_size = mesh_size;
length_mesh_size = mesh_size;

% if section_arc_end <= section_arc_start, there must be an error

% if arc_radians >= 2pi there must be an error!!!
arc_radians = abs(section_arc_end-section_arc_start);

% arclgenth azimuth

arc_length = arc_radians*cylinder_radius;
narcs = ceil(arc_length/azimuth_mesh_size)+1;
arc_step_size = arc_radians/(narcs-1); % this is in real space

% stepsize longitudinal
nzsteps = ceil(section_length/length_mesh_size)+1;
zstep_size = section_length/(nzsteps-1);
zmin = -section_length/2;

disp(sprintf("There will be %d vertices in the mesh (nzsteps=%d)!",nzsteps*narcs,nzsteps));

% create all the vertices
vertex = 1;
for zstep = 1:nzsteps
    for aarc = 1:narcs
        phi = section_arc_start+(aarc-1)*arc_step_size;
        z = (zstep-1)*zstep_size+zmin + center(3);
        x = cos(phi)*cylinder_radius + center(1);
        y = sin(phi)*cylinder_radius + center(2);
        node(vertex,1) = x;
        node(vertex,2) = y;
        node(vertex,3) = z;
        vertex = vertex+1;
    end
end

% number of faces is on this cylinder
% per azimut
ntriag_azimut = narcs*2;
% there is one ring less than steps, so total is
ntriag = (nzsteps-1)*ntriag_azimut;

disp(sprintf("There will be %d triangles in the mesh !",ntriag));


% now create all the faces (triangles)
% since this is a regular mesh, this should work with straight forward
% rules
% First triangle should be (1 narc+1 2)
% Second triangle should be (2 narc+1 narc+2)

% Do the second kind of triangle first
triangle = 2;
for rung=1:(nzsteps-1)
    for aarc = 1:(narcs-1)
        v = (rung-1)*narcs+aarc;
        faces(triangle,1) = v;
        if strcmp(vertex_order,'CCW')
            faces(triangle,2) = v+narcs;
            faces(triangle,3) = v+1;
        elseif strcmp(vertex_order,'CW')
            faces(triangle,2) = v+1;
            faces(triangle,3) = v+narcs;
        end
        triangle = triangle+2;
    end
end

% Now do the first kind of triangle
triangle = 1;
for rung=1:(nzsteps-1)
    for aarc = 2:narcs
        v = (rung-1)*narcs+aarc;
        faces(triangle,1) = v;
        if strcmp(vertex_order,'CCW')
            faces(triangle,2) = v+narcs-1;
            faces(triangle,3) = v+narcs;
        elseif strcmp(vertex_order,'CW')
            faces(triangle,2) = v+narcs;
            faces(triangle,3) = v+narcs-1;
        end
        triangle = triangle+2;
    end
end
tri = TriRep(faces,node(:,1),node(:,2),node(:,3));

% optional display of the cylinder mesh
tr = triangulation(faces,node(:,1),node(:,2),node(:,3));
figure(99);
trisurf(tr)
axis equal;
fn = faceNormal(tr);  
P = incenter(tr);
hold on;
quiver3(P(:,1),P(:,2),P(:,3),fn(:,1),fn(:,2),fn(:,3),1.5, 'color','r');
hold off;
