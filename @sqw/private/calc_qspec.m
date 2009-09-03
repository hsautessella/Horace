function qspec=calc_qspec (efix,k_to_e, emode, data, det)
% Calculate the components of Q in reference frame fixed w.r.t. spectrometer
%
%   >> qspec = calc_qspec (efix, emode, data, det)
%
%   efix    Fixed energy (meV)
%   k_to_e  constant of the neutron energy transformation into the the
%           neutron wave vector
%   emode   Direct geometry=1, indirect geometry=2, elastic=0
%   data    Data structure of spe file (see get_spe)
%   det     Data structure of par file (see get_par)
%
%   qspec(4,ne*ndet)    Momentum and energy transfer in spectrometer coordinates
%
%  Note: We sometimes use this routine with the energy bin boundaries replaced with 
%        bin centres i.e. have fudged the array data.en

% T.G.Perring 15/6/07

% *** May benefit from translation to fortran, partly for speed but mostly to reduced
% internal storage; could improve things in Matlab by unpacking the line that
% files qspec(1:3,:)

% Get components of Q in spectrometer frame (x || ki, z vertical)
[ne,ndet]=size(data.S);
qspec=zeros(4,ne*ndet);
if emode==1
    ki=sqrt(efix/k_to_e);
    if length(data.en)==ne+1
        eps=(data.en(2:end)+data.en(1:end-1))/2;    % get bin centres
    else
        eps=data.en;        % just pass the energy values as bin centres
    end
    kf=sqrt((efix-eps)/k_to_e); % [ne x 1]
    detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
    qspec(1:3,:) = repmat([ki;0;0],[1,ne*ndet]) - ...
        repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    qspec(4,:)=repmat(eps',1,ndet);
    
elseif emode==2
    kf=sqrt(efix/k_to_e);
    if length(data.en)==ne+1
        eps=(data.en(2:end)+data.en(1:end-1))/2;    % get bin centres
    else
        eps=data.en;        % just pass the energy values as bin centres
    end
    ki=sqrt((efix+eps)/k_to_e); % [ne x 1]
    detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
    qspec(1:3,:) = repmat([ki';zeros(1,ne);zeros(1,ne)],[1,ndet]) - ...
        repmat(kf,[3,ne*ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    qspec(4,:)=repmat(eps',1,ndet);
    
elseif emode==0
    % The data is assumed to have bin boundaries as the logarithm of wavelength
    if length(data.en)==ne+1
        lambda=(exp(data.en(2:end))+exp(data.en(1:end-1)))/2;    % get bin centres
    else
        lambda=exp(data.en);        % just pass the values as bin centres
    end
    k=(2*pi)./lambda;   % [ne x 1]
    Q_by_k = repmat([1;0;0],[1,ndet]) - [cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
    qspec(1:3,:) = repmat(k',[3,ndet]).*reshape(repmat(reshape(Q_by_k,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    
else
    error('EMODE must =1 (direct geometry), =2 (indirect geometry), or =0 (elastic)')
    
end
