function [indx,ok]=get_contributing_pix_ind_(this,v)

%[rot_ustep,trans_bott_left,ebin,trans_elo,urange_step] = this.get_pix_transf_();
%TODO re-align
ez = this.ez;
ex = this.ex;
trans =  this.data_upix_to_rlu_\(this.ucentre-this.data_uoffset_(1:3));
rs = this.data_upix_to_rlu_*[(v(1,:)-trans(1));(v(2,:)-trans(2));(v(3,:)-trans(3))];
[phi,theta,r] = cart2sph(rs(1,:),rs(2,:),rs(3,:));
ubin          = this.usteps;
urange_offset = this.urange_offset;
% convert to radian as coordinates are in radians
urange_offset(2)=urange_offset(2)*(pi/180);
urange_offset(3)=urange_offset(3)*(pi/180);
urange_step   = this.urange_step;
%new_coord=[r;theta*(180./pi);phi*(180./pi)];
% Transform the coordinates u1-u4 into the new projection axes, if necessary
% *** TGP 9 Dec 2012: this looks as if the case of energy being a plot axis that rounding errors will in general be a problem.
if ubin(4)==1 && urange_offset(4)==0   % Catch special (and common) case of energy being an integration axis to save calculations
    indx=[(r'-urange_offset(1))/ubin(1),(theta'-urange_offset(2))*(180./pi/ubin(2)),(phi'-urange_offset(3))*(180./pi/ubin(3)),v(4,:)'];  % nx4 matrix
else
    indx=[(r'-urange_offset(1))/ubin(1),(theta'-urange_offset(2))*(180./pi/ubin(2)),(phi'-urange_offset(3))*(180./pi/ubin(3)),(v(4,:)'-urange_offset(4))*(1/ubin(4))];  % nx4 matrix
end

% Find the points that lie inside or on the boundary of the range of the cut
% TGP 9 Dec 2012: fix the problem with rounding energy bins away *** Do not think it is a full fix: indx(:,4) will have rounding errors in general (see above)
ok = indx(:,1)>=urange_step(1,1) & indx(:,1)<=urange_step(2,1) & indx(:,2)>=urange_step(1,2) & indx(:,2)<=urange_step(2,2) & ...
    indx(:,3)>=urange_step(1,3) & indx(:,3)<=urange_step(2,3) & indx(:,4)>=urange_step(1,4) & indx(:,4)<=urange_step(2,4);
indx=indx(ok,:);    % get good indices (including integration axes and plot axes with only one bin)