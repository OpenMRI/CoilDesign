function [node,faces,tri] = twRadialCylinderTeeMeshSection(cylinder_radius, section_arc_start, section_arc_end, section_length, center, mesh_size)
% Generate a radial section of a cylinder mesh of a Tee-shape
% 
% in order to achieve a Tee shaped section section_arc_start,
% section_arc_end and section_length are arrays
% this still needs work

% TODO: if the parameter arrays are of different_length fail

nsegments = size(section_arc_start,2);

% Order for normal pointing outward
vertex_order = 'CW';

% Note, the mesh size should be done differently azimutal and length
% wise, but for now we use the same in this function
azimuth_mesh_size = mesh_size;
length_mesh_size = mesh_size;

total_length = sum(section_length);

% get all the sections setup in the z-direction
zmin(1) = -total_length/2;

for segment =2:nsegments
   zmin(segment) = zmin(segment-1)+section_length(segment-1); 
end

for segment = 1:nsegments
    % if section_arc_end <= section_arc_start, there must be an error

    % if arc_radians >= 2pi there must be an error!!!
    arc_radians(segment) = abs(section_arc_end(segment)-section_arc_start(segment));

    % arclgenth azimuth

    arc_length(segment) = arc_radians(segment)*cylinder_radius;
    narcs(segment) = ceil(arc_length(segment)/azimuth_mesh_size)+1;
    arc_step_size(segment) = arc_radians(segment)/(narcs(segment)-1); % this is in real space

    % stepsize longitudinal
    nzsteps(segment) = ceil(section_length(segment)/length_mesh_size)+1;
    zstep_size(segment) = section_length(segment)/(nzsteps(segment)-1);
end

% For the blending we will always modify the narrower segment, so when a
% narrower and wider segment meet, the corresponding rung of the narrower
% segment will be omitted and replaced by blending

seg_blend_zmin(1) = 0; % we know this to be true for sure
seg_blend_zmax = zeros(1,nsegments);

for segment=2:nsegments
    if arc_length(segment) <= arc_length(segment-1)
        % cover the special case of the segments being same width and
        % aligned
        if (arc_length(segment) == arc_length(segment-1)) && ...
            (section_arc_start(segment) == section_arc_start(segment-1))
            seg_blend_zmin(segment) = 0;
        else
            seg_blend_zmin(segment) = 1;
        end
    else
        seg_blend_zmin(segment) = 0;
        seg_blend_zmax(segment-1) = 1;
    end
end

% tf("There will be %d vertices in the mesh (nzsteps=%d)!",nzsteps*narcs,nzsteps));

% create all the vertices
vertex = 1;
start_vertex = [];
for segment = 1:nsegments
    start_vertex(segment) = vertex;
    if seg_blend_zmin(segment)
        zstart = 2;
    else
        zstart = 1;
    end
    if seg_blend_zmax(segment)
        zend = nzsteps(segment)-1;
    else
        zend = nzsteps(segment);
    end
    
    for zstep = zstart:zend
        for aarc = 1:narcs(segment)
            phi = section_arc_start(segment)+(aarc-1)*arc_step_size(segment);
            z = (zstep-1)*zstep_size(segment)+zmin(segment) + center(3);
            x = cos(phi)*cylinder_radius + center(1);
            y = sin(phi)*cylinder_radius + center(2);
            node(vertex,1) = x;
            node(vertex,2) = y;
            node(vertex,3) = z;
            % enhanced node information
            ehnode(vertex,1) = phi;
            ehnode(vertex,2) = z;
            ehnode(vertex,3) = phi/(2*pi); % u
            ehnode(vertex,4) = (z-zmin(1))/total_length; %v
            vertex = vertex+1;
        end
    end
end

% number of faces is on this cylinder
% per azimut
%ntriag_azimut = narcs*2;
% there is one ring less than steps, so total is
%ntriag = (nzsteps-1)*ntriag_azimut;

%disp(sprintf("There will be %d triangles in the mesh !",ntriag));


% now create all the faces (triangles)
% since this is a regular mesh, this should work with straight forward
% rules
% First triangle should be (1 narc+1 2)
% Second triangle should be (2 narc+1 narc+2)

start_triangle = 0;

for segment=1:nsegments
    
    % Now do the first kind of triangle
    triangle = start_triangle+1;
    for rung=1:(nzsteps(segment)-1-seg_blend_zmax(segment)-seg_blend_zmin(segment))
        for aarc = 2:narcs(segment)
            v = (rung-1)*narcs(segment)+aarc+(start_vertex(segment)-1);
            faces(triangle,1) = v;
            if strcmp(vertex_order,'CCW')
                faces(triangle,2) = v+narcs(segment)-1;
                faces(triangle,3) = v+narcs(segment);
            elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = v+narcs(segment);
                faces(triangle,3) = v+narcs(segment)-1;
            end
            triangle = triangle+2;
        end
    end 
    
    % Then do the second kind of triangle 
    triangle = 2+start_triangle;
    for rung=1:(nzsteps(segment)-1-seg_blend_zmax(segment)-seg_blend_zmin(segment))
        for aarc = 1:(narcs(segment)-1)
            v = (rung-1)*narcs(segment)+aarc+(start_vertex(segment)-1);
            % fuse the two meshes
            faces(triangle,1) = v;
            if strcmp(vertex_order,'CCW')
                faces(triangle,2) = v+narcs(segment);
                faces(triangle,3) = v+1;
            elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = v+1;
                faces(triangle,3) = v+narcs(segment);
            end
            triangle = triangle+2;
        end
    end
    
    start_triangle = triangle-2;
    
end

%keyboard
triangle = start_triangle+1;

% Now do the blending of the meshes
for segment = 1:nsegments
    if seg_blend_zmin(segment)
        % first vertex of this segment
        v = start_vertex(segment);
        % edge of the previous segment for search range
        vprev_range = (v-1-narcs(segment-1)):(v-1);
        vclosest_euclidian = twFindClosestNodeFromRange(node,v,vprev_range);
        
        % Check if we have to add a leading triangle of the third kind
        % we'll add a leading triangle if its concave more than 1/5
        % arclength
        if (ehnode(vclosest_euclidian,1) - ehnode(v,1)) > arc_step_size(segment)/3
            faces(triangle,1) = vclosest_euclidian-1;
             if strcmp(vertex_order,'CCW')
                faces(triangle,2) = v;
                faces(triangle,3) = vclosest_euclidian;
            elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = vclosest_euclidian;
                faces(triangle,3) = v;
             end
            triangle = triangle+1;
        end
        
        % Mark idx for first triangle of second kind
        first_s_triangle = triangle;
        
        triangle = triangle+1;
        vs = vclosest_euclidian;
    
        % Do the triangles of the first kind
        for aarc=1:narcs(segment)-1
            faces(triangle,1) = vs+aarc;
            if strcmp(vertex_order,'CCW')
                faces(triangle,2) = v+aarc-1;
                faces(triangle,3) = v+aarc;
            elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = v+aarc;
                faces(triangle,3) = v+aarc-1;
            end
            
            triangle = triangle+2;
        end
        % Do the triangles of the second kind
        triangle = first_s_triangle;
        for aarc=1:narcs(segment)-1
           faces(triangle,1) = vs+aarc-1;
           if strcmp(vertex_order,'CCW')
                faces(triangle,2) = v+aarc-1;
                faces(triangle,3) = vs+aarc;
           elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = vs+aarc;
                faces(triangle,3) = v+aarc-1;
           end
           triangle = triangle+2;
        end
        % Check if we have to add a trailing triangle of the third kind
        if (ehnode(v+narcs(segment)-1,1) - ehnode(vclosest_euclidian+narcs(segment)-1,1) ) > arc_step_size(segment)/3
           faces(triangle,1) = vclosest_euclidian+narcs(segment)-1;
           if strcmp(vertex_order,'CCW')
                faces(triangle,2) = v+narcs(segment)-1;
                faces(triangle,3) = vclosest_euclidian+narcs(segment);
           elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = vclosest_euclidian+narcs(segment);
                faces(triangle,3) = v+narcs(segment)-1;
           end 
           triangle = triangle+1; 
        end
    end
    
    % Do a blending operation on the other end of the mesh
    if seg_blend_zmax(segment)
        % first vertex of the last rung of this segment
        v = start_vertex(segment+1)-narcs(segment);
        % edge of the next segment for search range
        vnext_range = start_vertex(segment+1):start_vertex(segment+1)+narcs(segment+1);
        vclosest_euclidian = twFindClosestNodeFromRange(node,v,vnext_range);
        
        % Check if we have to add a leading triangle of the third kind
        % we'll add a leading triangle if its concave more than 1/5
        % arclength
        if ehnode(vclosest_euclidian,1) - ehnode(v,1) > arc_step_size(segment)/3
            faces(triangle,1) = v;
             if strcmp(vertex_order,'CCW')
                faces(triangle,2) = vclosest_euclidian-1;
                faces(triangle,3) = vclosest_euclidian;
            elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = vclosest_euclidian;
                faces(triangle,3) = vclosest_euclidian-1;
             end
            triangle = triangle+1;
        end
        
        % Mark idx for first triangle of second kind
        first_s_triangle = triangle;
        
        triangle = triangle+1;
        vs = vclosest_euclidian;
    
        % Do the triangles of the first kind
        for aarc=1:narcs(segment)-1
            faces(triangle,1) = v+aarc;
            if strcmp(vertex_order,'CCW')
                faces(triangle,2) = vs+aarc-1;
                faces(triangle,3) = vs+aarc;
            elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = vs+aarc;
                faces(triangle,3) = vs+aarc-1;
            end
            
            triangle = triangle+2;
        end
        % Do the triangles of the second kind
        triangle = first_s_triangle;
        for aarc=1:narcs(segment)-1
           faces(triangle,1) = v+aarc-1;
           if strcmp(vertex_order,'CCW')
                faces(triangle,2) = vs+aarc-1;
                faces(triangle,3) = v+aarc;
           elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = v+aarc;
                faces(triangle,3) = vs+aarc-1;
           end
           triangle = triangle+2;
        end
        % Check if we have to add a trailing triangle of the third kind
        % TW: note this is copied from the *zmin blend, might be not the
        % same triangle order though, correct order direction
        if (ehnode(v+narcs(segment)-1,1) - ehnode(vclosest_euclidian+narcs(segment)-1,1) ) > arc_step_size(segment)/3
           faces(triangle,1) = vclosest_euclidian+narcs(segment)-1;
           if strcmp(vertex_order,'CCW')
                faces(triangle,2) = v+narcs(segment)-1;
                faces(triangle,3) = vclosest_euclidian+narcs(segment);
           elseif strcmp(vertex_order,'CW')
                faces(triangle,2) = vclosest_euclidian+narcs(segment);
                faces(triangle,3) = v+narcs(segment)-1;
           end 
           triangle = triangle+1; 
        end
    end
end

tri = TriRep(faces,node(:,1),node(:,2),node(:,3));

% optional display of the cylinder mesh
tr = triangulation(faces,node(:,1),node(:,2),node(:,3));
figure(99);
%trisurf(tr)
trisurf(faces,node(:,1),node(:,2),node(:,3),ehnode(:,1)); colorbar
axis equal;
fn = faceNormal(tr);  
P = incenter(tr);
hold on;
quiver3(P(:,1),P(:,2),P(:,3),fn(:,1),fn(:,2),fn(:,3),1.5, 'color','r');
hold off;
