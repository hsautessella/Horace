function wout=recompute_bin_data(w)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents of pix array
%
%   >> wout=recompute_bin_data(w)

% See also average_bin_data, which uses en essentially the same algorithm. Any changes
% to the one routine must be propagated to the other.

% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)

wout=w;

% Get the bin index for each pixel
nend=cumsum(w.data.npix(:));
nbeg=nend-w.data.npix(:)+1;
nbin=numel(w.data.npix);
npixtot=nend(end);
ind=zeros(npixtot,1);
for i=1:nbin
    ind(nbeg(i):nend(i))=i;
end

% Accumulate signal
wout.data.s=accumarray(ind,w.data.pix.signals,[nbin,1])./w.data.npix(:);
wout.data.s=reshape(wout.data.s,size(w.data.npix));
wout.data.e=accumarray(ind,w.data.pix.errors,[nbin,1])./(w.data.npix(:).^2);
wout.data.e=reshape(wout.data.e,size(w.data.npix));
nopix=(w.data.npix(:)==0);
wout.data.s(nopix)=0;
wout.data.e(nopix)=0;

