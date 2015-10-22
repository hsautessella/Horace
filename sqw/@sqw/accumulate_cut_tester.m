function [s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut_tester(sqw,urange_step_pix, keep_pix,proj, pax)
	% service routine used in tests only to allow testing private mex/nomex routines without changing working folder

% $Revision$ ($Date$)
data = sqw.data;
[s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut(data.s, data.e, data.npix, urange_step_pix, keep_pix,...
    data.pix,proj, pax);