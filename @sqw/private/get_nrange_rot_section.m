function [nstart,nend] = get_nrange_rot_section (urange,rot,trans,nelmts,varargin)
% Get indicies that define ranges of contiguous elements from an n-dimensional
% array of bins of elements, where the bins partially or wholly lie
% inside a hypercuboid volume that on the first three axes can be rotated and
% translated w.r.t. to the hypercuboid that is split into bins.
%
%   >> [nstart,nend] = get_nrange (urange,rot,trans,nelmts,p1,p2,p3,...)
% 
% Input:
% ------
%   urange  Range to cover: 2 x ndim (ndim>=3) array of upper and lower limits
%          [urange_lo; urange_hi] (in units of a coordinate frame
%          that is rotated and shifted with respect to that frame in
%          which the bin boundaries p1,p2,p3 are expressed, see below)
%
%   rot     Matrix, A     --|  (3x3 array)
%   trans   Translation, T--|  (column vector length 3)
%           These relate the two coordinate frames of the bin boundary
%          arrays and of urange:
%              r'(i) = A(i,j)(r(j) - T(j))
%          where r(j) are the coordinates of a vector in the frame of the
%          bin boundaries p1,p2,p3 (below), and r'(i) are the coordinates
%          of the frame in which urange is expressed.
%           Note that T is given in coordinates of the axes of the bin
%          boundaries.
%
%   nelmts  Array of number of points in n-dimensional array of bins
%          e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in
%          (i,j,k)th bin. If the number of dimensions defined by urange,
%          ndim=size(urange,2), is greater than the number of dimensions
%          defined by nelmts, n=numel(size(nelmts)), then the excess
%          dimensions required of nelmts are all assumed to be singleton
%          following the usual matlab convention.
%
%   p1(:)   Bin boundaries along first axis (column vector)
%   p2(:)   Similarly axis 2
%   p3(:)   Similarly axis 3
%    :              :
%   pndim   Similarly axis ndim
%           It is assumed that each array of bin boundaries has
%          at least two values (i.e. at least one bin), and that
%          the bin boundaries are monotonic increasing.
%
% Output:
% -------
%   nstart  Column vector of starting values of contiguous blocks in
%          the array of values with the number of elements in a bin
%          given by nelmts(:).
%   nend    Column vector of finishing values.
%
%           nstart and nend have column length zero if there are no
%          elements i.e. have the value zeros(0,1).


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Check input arguments
ndim=numel(varargin);
if ndim<3
    error('Must give at least three bin boundary arrays')
elseif numel(size(urange))~=2 || size(urange,1)~=2 || size(urange,2)~=ndim
    error('Check urange is a 2 x ndim array where ndim is the number of bin boundary arrays')
elseif any(urange(1,:)>urange(2,:))
    error('Must have urange_lo <= urange_hi for all dimensions')
end

sz = size(nelmts);
if isempty(nelmts)
    error('Number array ''nelmts'' cannot be empty')
elseif ~(ndim>=numel(sz))
    error('Size of number array ''nelmts'' is inconsistent with the number of bin boundary arrays')
end

% Get contiguous arrays
[istart,iend,irange,inside,outside] = get_irange_rot(urange,rot,trans,varargin{:});
if ~outside
    [nstart,nend] = get_nrange_rot(nelmts,istart,iend,irange);
else
    nstart=zeros(0,1);
    nend=zeros(0,1);
end
