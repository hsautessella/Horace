function urange = rundata_find_urange(run_files)
% Find range of data in crystal Cartesian coordinates
%
%   >> [urange,u_to_rlu] = rundata_find_urange(run_files)
%
% Input:
% ------
%   run_files 	Cell array of initiated rundata objects
%
% Output:
% -------
%   urange    	2x4 array, describing min-max values in momentum/energy
%              transfer, in crystal Cartesian coordinates and meV.

nfiles = numel(run_files);

disp('--------------------------------------------------------------------------------')
disp(['Calculating limits of data from ',num2str(nfiles),' spe files...'])

% Get the maximum limits along the projection axes across all spe files
data.filename='';
data.filepath='';
urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
for i=1:nfiles
    [efix,en,emode,ndet,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=get_rundata(run_files{i},...
        'efix','en','emode','n_detectors','alatt','angldeg','u','v','psi','omega','dpsi','gl','gs','det_par',...
        '-hor','-rad');
    eps=(en(2:end)+en(1:end-1))/2;
    if length(eps)>1
        data.S=zeros(2,ndet);
        data.E=zeros(2,ndet);
        data.en=[eps(1);eps(end)];
    else
        data.S=zeros(1,ndet);
        data.E=zeros(1,ndet);
        data.en=eps;
    end
    [u_to_rlu, ucoords] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
    urange = [min(urange(1,:),min(ucoords,[],2)'); max(urange(2,:),max(ucoords,[],2)')];
end
