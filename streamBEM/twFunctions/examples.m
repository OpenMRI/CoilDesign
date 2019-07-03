
% super coarse birdcage
[n,f,t]= twSimpleHighpassBCMesh(17.5,40,[0 0 0], 4);

% little bit finer one
[n,f,t]= twSimpleHighpassBCMesh(17.5,40,[0 0 0], 0.5);

% coarse shield
[n,f,t] = twSimpleSlottedShieldMesh(20,40,[0 0 0],4);

% somewhat finer shield
[n,f,t] = twSimpleSlottedShieldMesh(20,40,[0 0 0],0.5);

% try combined
[shield_mesh,shield_n,shield_f,shield_t] = twSimpleSlottedShieldMesh(20,40,[0 0 0],0.5);
[hp_mesh,hp_n,hp_f,hp_t]= twSimpleHighpassBCMesh(17.5,40,[0 0 0], 0.5);
figure(300); clf;
trisurf(hp_f,hp_n(:,1),hp_n(:,2),hp_n(:,3),100); colorbar
hold on;
trisurf(shield_f,shield_n(:,1),shield_n(:,2),shield_n(:,3),shield_n(:,3)*3); colorbar
axis equal

addpath('../../../DXFLib_v0.9.1/');

% Open DXF File.
FID = dxf_open('shield_polymesh.dxf');
FID = dxf_set(FID,'Color',[1 1 0],'Layer',10);

% fvc is a structure containing vertices and faces. We use these matrices
% to create a polymesh.
dxf_polymesh(FID, shield_n, shield_f);

dxf_close(FID);
% Open DXF File.
FID = dxf_open('highpass_polymesh.dxf');
FID = dxf_set(FID,'Color',[1 0 0],'Layer',10);

% fvc is a structure containing vertices and faces. We use these matrices
% to create a polymesh.
dxf_polymesh(FID, hp_n, hp_f);

dxf_close(FID);