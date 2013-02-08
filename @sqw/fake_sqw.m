function [tmp_file, grid_size, urange] = fake_sqw (sqw, en, par_file, sqw_file, efix, emode, alatt, angdeg,...
                    u, v, psi, omega, dpsi, gl, gs, varargin)
% Create an output sqw file with dummy data using array(s) of energy bins instead spe file(s).
%
%   >> fake_sqw (sqw, en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs)
%
%   >> fake_sqw (sqw, en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
%   >> [tmp_file, grid_size, urange] = fake_sqw (...)
%
% Input:
% ------
%   en              Energy bin boundaries (must be monotonically increasing and equally spaced)
%               or  cell array of arrays of energy bin boundaries, one array per spe file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions. Default is [50,50,50,50]
%   urange_in       [Optional] Range of data grid for output. If not given, then uses smallest hypercuboid
%                                       that encloses the whole data range.
%
% Output:
% --------
%   tmp_file        List of temporary files
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid
%
%
% Use to generate an sqw file that can be used for creating simulations. Syntax very similar to
% gen_sqw: the only difference is that the input spe data is replaced by energy bin boundaries.

% T.G.Perring  18 May 2009


% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if ~(nargin>=15 && nargin<=17)
    error('Check number of input arguments')
end

% Check input arguments
% ------------------------
% Input energy bins
if iscellnum(en) || isnumeric(en)
    if isnumeric(en)
        en={en};
    end
    en_lo=zeros(1,numel(en));
    en_hi=zeros(1,numel(en));
    for i=1:numel(en)
        if ~isvector(en{i}) || numel(en{i})<2
            error('Energy bins must numeric vectors')
        else
            de=diff(en{i});
            if any(de)<=0 || any(diff(de))~=0
                error('Energy bins widths must all be the same and non-zero')
            end
            en_lo(i)=(en{i}(1)+en{i}(2))/2;
            en_hi(i)=(en{i}(end-1)+en{i}(end))/2;
        end
    end
else
    error('Energy bins must be an array of equally spaced energy bin boundaries')
end

% Check par file exists
if ischar(par_file) && size(par_file,1)==1
    if ~exist(par_file,'file')
        error(['File ',par_file,' not found'])
    end
else
    error('Input detector par file must be a character string')
end

% Check that output file does not appear in input file name list
if strcmpi(par_file,sqw_file)
    error('Detector parameter file and output sqw file name match')
end

% Do some checks that will be able to write sqw file
pathsqw=fileparts(sqw_file);
if ~isempty(pathsqw) && ~exist(pathsqw,'dir')
    error('Cannot find folder into which to output the sqw file')
end

% Check emode, alatt, angdeg, u, v
if ~isnumeric(emode) || ~(emode==1 || emode==2)
    error('Emode must equal 1 (direct geometry) or 2 (indirect geometry)')
end
if ~(isnumeric(alatt) && isvector(alatt) && numel(alatt)==3 && all(alatt>0))
    error('Check lattice parameters')
end
if ~(isnumeric(angdeg) && isvector(angdeg) && numel(angdeg)==3 && all(angdeg>0))
    error('Check lattice angles')
end
if ~(isnumeric(u) && isvector(u) && numel(u)==3 && ~all(u==0))
    error('Check vector u')
end
if ~(isnumeric(v) && isvector(v) && numel(v)==3 && ~all(v==0))
    error('Check vector v')
end

% Check efix, psi, omega, dpsi, gl, gs
if ~(isnumeric(efix) && all(efix)>0)
    error('Check fixed energy/energies are greater than zero')
end
if ~isnumeric(psi)
    error('Check psi angle(s) are numeric')
end
if ~isnumeric(omega)
    error('Check omega angle(s) are numeric')
end
if ~isnumeric(dpsi)
    error('Check dpsi angle(s) are numeric')
end
if ~isnumeric(gl)
    error('Check gl angle(s) are numeric')
end
if ~isnumeric(gs)
    error('Check gs angle(s) are numeric')
end

ndata=[numel(en),numel(efix),numel(psi),numel(omega),numel(dpsi),numel(gl),numel(gs)];
if ~all(ndata==1 | ndata==max(ndata))
    error('Check that the number of sets of bin boundaries and number of efix, psi, omega, dpsi, gl, gs are consistent')
end

nfile=max(ndata);
if nfile>1
    if numel(en)==1
        en=repmat(en,1,nfile);
        en_lo=en_lo*ones(1,nfile);
        en_hi=en_hi*ones(1,nfile);
    end
    if numel(efix)==1, efix=repmat(efix,1,nfile); end
    if numel(psi)==1, psi=repmat(psi,1,nfile); end
    if numel(omega)==1, omega=repmat(omega,1,nfile); end
    if numel(dpsi)==1, dpsi=repmat(dpsi,1,nfile); end
    if numel(gl)==1, gl=repmat(gl,1,nfile); end
    if numel(gs)==1, gs=repmat(gs,1,nfile); end
end


% Create tmp files
% ------------------
% Read par file
det=get_par(par_file,'-hor');
ndet=size(det.x2,2);

% Make temp file names
str=str_random;     % for use in constructing file name
tmp_file=cell(1,nfile);
for i=1:nfile
    tmp_file{i}=['dummy_',str,'_',num2str(i),'.tmp'];
end

% Determine a grid size if not given one on input
if numel(varargin)<1
    av_npix_per_bin=1e4;
    ne=0;
    for i=1:nfile
        ne=ne+numel(en{i});
    end
    npix=ne*ndet;
    grid_size=ceil(sqrt(sqrt(npix/av_npix_per_bin)));
else
    grid_size=varargin{1};
end

% Determine urange
if numel(varargin)<2
    urange = calc_sqw_urange (sqw, efix, emode, en_lo, en_hi, det, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
else
    urange = varargin{2};
end

% Construct data structure with spe file information
disp('--------------------------------------------------------------------------------')
disp('Creating intermediate .tmp file(s):')
for i=1:nfile
    data=fake_spe(ndet,en{i},psi(i));
    calc_and_write_sqw(tmp_file{i}, efix(i), emode, alatt, angdeg, u, v, psi(i)*(pi/180),...
        omega(i)*(pi/180), dpsi(i)*(pi/180), gl(i)*(pi/180), gs(i)*(pi/180), data, det, det, grid_size, urange);
end


% Create single sqw file combining all intermediate sqw files
% ------------------------------------------------------------
disp('--------------------------------------------------------------------------------')
disp('Creating output sqw file:')
write_nsqw_to_sqw (tmp_file, sqw_file);

% Delete tmp files
for i=1:numel(tmp_file)
    try
        delete(tmp_file{i})
    catch
        if delete_error==false
            delete_error=true;
            disp('One or more .tmp files not deleted')
        end
    end
end
disp('--------------------------------------------------------------------------------')
