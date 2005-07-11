function writeheader (data, fout)
% Writes a header structure out to the binary file called fout.
%
%       data.grid: type of binary file (4D grid, blocks of spe file, etc)
%       data.title: title label
%       data.a: a axis
%       data.b: b axis
%       data.c c axis
%       data.alpha: alpha
%       data.beta: beta
%       data.gamma: gamma
%       data.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%       data.ulen  Length of vectors in Ang^-1, energy
%       data.nfiles: number of spe files contained within the binary file
%   if data is in grid:
%       data.p0    Offset of origin of projection [ph; pk; pl; pen]
%       data.pax   Index of plot axes in the matrix din.u
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes
%                               are x,y   in any plotting
% if dimension<3D
%   data.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   data.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo;
%               u3_hi, u1_hi]

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


disp('Writing header information ');
fid = fopen(fout,'w');
n=length(data.grid);
fwrite(fid,n,'int32');
fwrite(fid,data.grid,'char');
n=length(data.title);
fwrite(fid,n,'int32');
fwrite(fid,data.title,'char');
fwrite(fid,data.a,'float32');
fwrite(fid,data.b,'float32');
fwrite(fid,data.c,'float32');
fwrite(fid,data.alpha,'float32');
fwrite(fid,data.beta,'float32');
fwrite(fid,data.gamma,'float32');
fwrite(fid,data.u,'float32');
fwrite(fid,data.ulen,'float32');
if strcmp(data.grid,'spe'),
    fwrite(fid,data.nfiles,'int32');
    % we don't yet know what p0 and pax will be. Data needs to be sliced first
else
    label=char(data.label);
    n=size(label);
    fwrite(fid,n,'int32');
    fwrite(fid,label, 'char');
    fwrite(fid,data.p0,'float32');
    fwrite(fid,length(data.pax),'int32');
    fwrite(fid,data.pax,'int32');
    if ~isempty(data.iax),
        fwrite(fid,length(data.iax),'int32');
        fwrite(fid,data.iax,'int32');
        fwrite(fid,data.uint,'float32');
    end
end
fclose(fid);
