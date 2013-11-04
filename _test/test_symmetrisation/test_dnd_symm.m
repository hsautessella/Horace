function test_dnd_symm(varargin)
%
% Validate the dnd symmetrisation, combination and rebin routines


%% Copied from template in test_multifit_horace_1

banner_to_screen(mfilename)

testdir=fileparts(mfilename('fullpath'));

%% Use sqw file on RAE's laptop to perform tests. Data saved to a .mat file on SVN server for validation by others.
% data_source='C:\Russell\PCMO\ARCS_Oct10\Data\SQW\ei140.sqw';
% proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr';
% 
% w3d_sqw=cut_sqw(data_source,proj,[-2,0.03,2],[-1,0.03,1],[-Inf,Inf],[0,1.4,100]);
% w3d_d3d=d3d(w3d_sqw);
% 
% w2d_qe_sqw=cut_sqw(data_source,proj,[-2,0.03,2],[-0.1,0.1],[-Inf,Inf],[0,1.4,100]);
% w2d_qe_d2d=d2d(w2d_qe_sqw);
% 
% w2d_qq_sqw=cut_sqw(data_source,proj,[-2,0.03,2],[-1,0.03,1],[-Inf,Inf],[30,40]);
% w2d_qq_d2d=d2d(w2d_qq_sqw);
% 
% w1d_sqw=cut_sqw(data_source,proj,[-2,0.03,2],[-0.1,0.1],[-Inf,Inf],[30,40]);
% w1d_d1d=d1d(w1d_sqw);
% 
% save(w3d_sqw,[testdir,filesep,'w3d_sqw.sqw']);
% save(w3d_d3d,[testdir,filesep,'w3d_d3d.sqw']);
% save(w2d_qe_sqw,[testdir,filesep,'w2d_qe_sqw.sqw']);
% save(w2d_qe_d2d,[testdir,filesep,'w2d_qe_d2d.sqw']);
% save(w2d_qq_sqw,[testdir,filesep,'w2d_qq_sqw.sqw']);
% save(w2d_qq_d2d,[testdir,filesep,'w2d_qq_d2d.sqw']);
% save(w1d_sqw,[testdir,filesep,'w1d_sqw.sqw']);
% save(w1d_d1d,[testdir,filesep,'w1d_d1d.sqw']);

%The above can now be read into the test routine directly.
w3d_sqw=read_sqw(fullfile(testdir,'w3d_sqw.sqw'));
w3d_d3d=read_dnd(fullfile(testdir,'w3d_d3d.sqw'));
w2d_qe_sqw=read_sqw(fullfile(testdir,'w2d_qe_sqw.sqw'));
w2d_qe_d2d=read_dnd(fullfile(testdir,'w2d_qe_d2d.sqw'));
w2d_qq_sqw=read_sqw(fullfile(testdir,'w2d_qq_sqw.sqw'));
w2d_qq_d2d=read_dnd(fullfile(testdir,'w2d_qq_d2d.sqw'));
w1d_sqw=read_sqw(fullfile(testdir,'w1d_sqw.sqw'));
w1d_d1d=read_dnd(fullfile(testdir,'w1d_d1d.sqw'));

%% Symmetrisation tests

%sqw symmetrisation:
w3d_sqw_sym=symmetrise_sqw(w3d_sqw,[0,0,1],[-1,1,0],[0,0,0]);
w2d_qe_sqw_sym=symmetrise_sqw(w2d_qe_sqw,[0,0,1],[-1,1,0],[0,0,0]);

cc=cut(w3d_sqw_sym,[-2,0.03,2],[-0.1,0.1],[0,1.4,100]);

equal_to_tol(cc,w2d_qe_sqw_sym,-1e-8)
why;


