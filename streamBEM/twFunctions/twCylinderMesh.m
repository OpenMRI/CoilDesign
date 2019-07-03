function [node,faces,tri] = twCylinderMesh(cylinder_radius, cylinder_length, center, mesh_size)
% Generate a mesh of a cylinder in high resolution wanted
% normals should point outward, center is 0.0

% we want regular triangles with two sides = meshsize the third is the
% pythagorean

% Order for normal pointing outward
vertex_order = 'CW';

% Note, the mesh size should be done differently azimutal and length
% wise, but for now we use the same in this function
azimuth_mesh_size = mesh_size;
length_mesh_size = mesh_size;

% arclgenth azimuth
circumference = 2*pi*cylinder_radius;
narcs = ceil(circumference/azimuth_mesh_size);
arc_step_size = 2*pi/narcs;

% stepsize longitudinal
nzsteps = ceil(cylinder_length/length_mesh_size)+1;
zstep_size = cylinder_length/(nzsteps-1);
zmin = -cylinder_length/2;

disp(sprintf("There will be %d vertices in the mesh (nzsteps=%d)!",nzsteps*narcs,nzsteps));

% create all the vertices
vertex = 1;
for zstep = 1:nzsteps
    for aarc = 1:narcs
        phi = (aarc-1)*arc_step_size;
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
    for aarc = 1:narcs
        v = (rung-1)*narcs+aarc;
        faces(triangle,1) = v;
        if strcmp(vertex_order,'CCW')
            faces(triangle,2) = v+narcs;
            %stitch around the last triangle of a rung
            if v==(rung-1)*narcs+narcs
                faces(triangle,3) = (rung-1)*narcs+1;
            else
                faces(triangle,3) = v+1;
            end
        elseif strcmp(vertex_order,'CW')
            if v==(rung-1)*narcs+narcs
                faces(triangle,2) = (rung-1)*narcs+1;
            else
                faces(triangle,2) = v+1;
            end
            faces(triangle,3) = v+narcs;
        end
        triangle = triangle+2;
    end
end

% Now do the first kind of triangle
triangle = 1;
for rung=1:(nzsteps-1)
    for aarc = 1:narcs
        v = (rung-1)*narcs+aarc;
        faces(triangle,1) = v;
        if strcmp(vertex_order,'CCW')
            if aarc==1
                faces(triangle,2) = (rung-1)*narcs+narcs+narcs; 
            else
                faces(triangle,2) = v+narcs-1;
            end
            faces(triangle,3) = v+narcs;
        elseif strcmp(vertex_order,'CW')
            faces(triangle,2) = v+narcs;
            if aarc==1
                faces(triangle,3) = (rung-1)*narcs+narcs+narcs; 
            else
                faces(triangle,3) = v+narcs-1;
            end
        end
        triangle = triangle+2;
    end
end
tri = TriRep(faces,node(:,1),node(:,2),node(:,3));

if 0
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
end
% Note 1:
% Should we generate UV coordinates for this?

% Note 2:
% Because of the very regular mesh the matrix structure is already
% forseeable to be a very diagonal matrix, because the mutual inductance
% between triangles in identical spatial relationship is always going to be
% the same