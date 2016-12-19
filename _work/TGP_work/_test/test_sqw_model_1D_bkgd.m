function weight = test_sqw_model_1D_bkgd (qh,qk,ql,en,p)
% Spin waves for a Heisenberg ferromagnet with nearest
% neighbour exchange only - two modes, rigidly displaced
% Lorentzian broadening.
% Have a linear background in qh as well
%
%   >> weight = test_sqw (qh,qk,ql,en,p)
%
%   p   [scale, JS, gap, gamma, const, slope]
%
scale=p(1);
js=p(2);
gap=p(3);
gam=p(4);
const=p(5);
slope=p(6);

wdisp1 = (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql));
wdisp2 = wdisp1 + gap;

weight = (scale*(gam/pi))*(1./((en-wdisp1).^2+gam^2) + 1./((en-wdisp2).^2+gam^2)) + const + slope*qh;
