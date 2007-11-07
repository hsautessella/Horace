function [u_to_rlu, ucoords] = ...
    calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
% Label pixels in an spe file with coords in the 4D space defined by crystal Cartesian coordinates
% and energy transfer. 
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [u_to_rlu, ucoords] = ...
%    calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
%
% Input:
%   efix        Fixed energy (meV)
%   emode       Direct geometry=1, indirect geometry=2
%   alatt       Lattice parameters (Ang^-1)
%   angdeg      Lattice angles (deg)
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%   psi         Angle of u w.r.t. ki (rad)
%   omega       Angle of axis of small goniometer arc w.r.t. notional u
%   dpsi        Correction to psi (rad)
%   gl          Large goniometer arc angle (rad)
%   gs          Small goniometer arc angle (rad)
%   data        Data structure of spe file (see load_spe)
%   det         Data structure of par file (see load_par)
%
% Output:
%   u_to_rlu    Matrix (3x3) of projection axes in reciprocal lattice units
%              i.e. u(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in the
%              projection axes to r.l.u.: v_rlu = u * v_proj
%   ucoords     [4 x npix] array of coordinates of pixels in crystal Cartesian
%              coordinates and energy transfer

% T.G.Perring   28 June 2007


% Check input parameters
% -------------------------
ndet=size(data.S,2);
% Check length of detectors in spe file and par file are same
if ndet~=length(det.phi)
   disp(['.spe file ' data.filename ' and .phx file ' det.filename ' not compatible']);
   disp(['Number of detectors is different: ' num2str(ndet) ' and ' num2str(length(det.phi))]);
   return
end

% Check incident energy consistent with energy bins
if emode==1 && data.en(end)>=efix
    disp(['Incident energy ' num2str(efix) ' and energy bins incompatible'])
    return
elseif emode==2 && data.en(1)<=-efix
    disp(['Final energy ' num2str(efix) ' and energy bins incompatible'])
    return
end

% Create matrix to convert from spectrometer axes to coords along projection axes
[spec_to_proj, u_to_rlu] = calc_proj_matrix (alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

% Calculate Q in spectrometer coordinates for each pixel
qspec = calc_qspec (efix, emode, data, det);

% Convert to projection axes
try
    % (Fortran advantage: combine calc_qspec and calc_proj_fortran to
    %  avoid extra intermediate variable qspec)
    ucoords = calc_proj_fortran (spec_to_proj, qspec);
catch
    ucoords = calc_proj_matlab (spec_to_proj, qspec);
    %warning('problem with fortran code compilation');
end