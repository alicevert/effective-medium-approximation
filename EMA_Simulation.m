%% Last updated: 2026-07-21 by Alice Calvert
%% This is a program to calculate the dielectric permittivity tensor of a composite medium using the Effective Medium Approximation (EMA).
%% The inputs are the core size (b), shell thickness (d), and planar number density [1/m^2] of the nanoparticles, as well as the magnetic flux density (B).
%% The outputs are the components εxx and εxy of the permittivity tensor at each wavelength. For εzz, run the function again with B=0. [1]
%% The simulation is adapted from the Absorption Simulation function by Kenzie Lewis and Raaja Rajeshwari Manickam, based off algorithm by Dani et al. [3]
%% Make sure fitted parameters are up to date with the most recent experimental data.
%% All units are SI. Angles are in rads.

%% -------------------------------------------------------------------------- %%
%% ------------------------------- References ------------------------------- %%
%% -------------------------------------------------------------------------- %%
%% [1] T.K. Xia, P.M. Hui, and D. Stroud, "Theory of Faraday rotation in granular magnetic materials," Journal of Applied Physics 67(6), 2736–2741 (1990).
%% [2] R.K. Dani et al., “Supplemental Material for "Faraday rotation enhancement 
%%     of gold coated Fe2O3 nanoparticles: Comparison of experiment and theory” "
%%     J. Chem. Phys, vol. 135, no. 224502, 2011. 
%% [3] A. Ibrahim, “Synthesis and Characterization of Magnetic Nanoparticles 
%%     to Incorporate into Silicon Waveguides to be Used as Optical Isolators,” 
%%     M.S. thesis, Eng. Phys., McMaster Univ., Hamilton, Ontario, 2019. [Online]. Available: https://macsphere.mcmaster.ca/bitstream/11375/24720/2/Ibrahim_Amr_E_201908_MASc.pdf 

%% -------------------------------------------------------------------------- %%
%% ------------------------------ EMA Function ------------------------------ %%
%% -------------------------------------------------------------------------- %%
function [wavelength,eps_XX_lambda,eps_XY_lambda]=EMA_Simulation(core_radius,shell_thickness,planar_density,magnetic_flux) 

%The program will starting timing the run.
%tic

%% General Parameters & Constants

c = 3e8;
T=20+273.15;                       % temperature
kb=1.38064852e-23;                 % Boltzmann constant
me=9.10938356e-31;                 % effective mass of electron
e=1.60217662e-19;                  % elementary charge
mu0=4*pi*1e-7;                     % vacuum permeability
Bz=magnetic_flux;                  % applied magnetic field along z [T] 
B=magnetic_flux;                   % applied magnetic field [T] 

b=core_radius*1e-9;             % core radius  
d=shell_thickness*1e-9;         % shell thickness
a=b+d;                             % particle radius
c_Vs=(4/3)*pi*b^3;                 % core volume
ns=planar_density/(2*a);          % number density
Vs=(4/3)*pi*a^3;                   % particle volume
fs=ns*Vs;                          % volume fraction of particles in medium

% permittivity=[];                   % variable that will store permittivity values
wavelength = 200e-9:1e-9:900e-9;    % sweep (comment out fixed wavelength)
% wavelength = 532e-9;               % fixed (comment out wavelength sweep)
eps_XX_lambda = zeros(length(wavelength),1);
eps_XY_lambda = zeros(length(wavelength),1);


%% -------------------------- Parameters of shell --------------------------- %%

%% Gold parameters (fitted using 17 nm diameter gold NPs in water; interband transitions are neglected)
% Based off Drude-Sommerfeld Theory [2]

g_tau=9.1e-15;                     % scattering time 
vf =1.4e6;                         % Fermi velocity
g_wp=1.37e16;                      % plasma frequency
g_gammap=(1/g_tau)+(vf/d);         % damping frequency
g_g0=4.43e15;                      % fitted parameter for gold absorption [2], CHANGE
g_w0=3.86e15;                      % fitted parameter for gold absorption [2], CHANGE
g_gamma0=6.22e14;                  % fitted parameter for gold absorption [2], CHANGE
g_wB=(e*Bz)/me;                    % cyclotron frequency

%% Effective Medium Parameter (dielectric function of medium)
%epsa=1.777;                       % water
epsa=1.0005;                       % air

%% --------------------------- Parameters of core --------------------------- %%

%% Option 1: SnO2 (comment out Fe2O3 parameters) [3]

Keff=5e3;                                   % effective anisotropy constant, 5-9e3 [3]
Ms=250e3;                                   % saturation magnetization, 250-300e3 [3]
c_wp=0;                                     % plasma frequency
c_gammap = (2.75e14/(0.347e-15))+vf/b;      % damping frequency, CHANGE
c_g0=1.2e15;                                % fitted parameter for tin oxide absorption 
c_w0=6.7e15;                                % fitted parameter for tin oxide absorption 
c_gamma0=9e15;                              % fitted parameter for tin oxide absorption  

% %% Option 2: Fe2O3 (comment out SnO2 parameters) [2]

% Keff=4700;%9e3;                           % effective anisotropy constant, 5-9e3
% Ms=414e3;%250e3;                          % saturation magnetization, 250-300e3
% c_wp=0;                                   % plasma frequency
% c_gammap=1/(0.347e-15)+vf/b;              % damping frequency
% c_g0=5.2e15;                              % fitted parameter for iron oxide absorption [2]
% c_w0=5.06e15;                             % fitted parameter for iron oxide absorption [2]
% c_gamma0=2.89e15;                         % fitted parameter for iron oxide absorption [2]

%% All Options (do not comment out)
Bzint=(((2/9)*mu0*c_Vs*Ms^2)/(kb*T))*B;     % internal magnetic field
c_wB=(e*Bzint)/(me);                        % cyclotron frequency, assuming bulk effective mass of 9.5me^2 

%% -------------------- Permittivity tensor calculation --------------------- %%

for i = 1:length(wavelength)

    lambda = wavelength(i);
    w=(2*pi*c)/lambda;             	 % optical frequency
    
    % -------- Gold shell contribution to dielectric function (eps_b) -------- %

    eps_bL= 1-(g_g0^2)/(w^2-g_w0^2+1i*g_gamma0*w-w*g_wB)-(g_wp^2)/(w^2+1i*g_gammap*w-w*g_wB); % dielectric function, gold, left polarization
    eps_bR= 1-(g_g0^2)/(w^2-g_w0^2+1i*g_gamma0*w+w*g_wB)-(g_wp^2)/(w^2+1i*g_gammap*w+w*g_wB); % dielectric function, gold, right polarization
    

    % -------- Core contribution to dielectric function (eps_c) [2] ---------- %

    eps_cL= 1-(c_g0^2)/(w^2-c_w0^2+1i*c_gamma0*w-w*c_wB); % dielectric function, metal oxide, left polarization
    eps_cR= 1-(c_g0^2)/(w^2-c_w0^2+1i*c_gamma0*w+w*c_wB); % dielectric function, metal oxide, right polarization
    
    % ------------------ Core/shell permittivity (eps_s) --------------------- %
    % Based off Maxwell-Garnet Theory, with shell as effective medium [2]

    fc=(b/a)^3;                                   % volume fraction of core in shell
 
    beta_cL=fc*(eps_cL-eps_bL)/(eps_cL+2*eps_bL);
    beta_cR=fc*(eps_cR-eps_bR)/(eps_cR+2*eps_bR);
    eps_sL=eps_bL*((1+2*beta_cL)/(1-beta_cL));
    eps_sR=eps_bR*((1+2*beta_cR)/(1-beta_cR));

   
    % ----------------- Effective permittivity (eps_final) ------------------- %
    % Based off Maxwell-Garnet Theory, with water medium [2]

    beta_sL=fs*(eps_sL-epsa)/(eps_sL+2*epsa);
    beta_sR=fs*(eps_sR-epsa)/(eps_sR+2*epsa);
    eps_finalL=epsa*(1+2*beta_sL)/(1-beta_sL);
    eps_finalR=epsa*(1+2*beta_sR)/(1-beta_sR);
    eps_XX = 0.5*(eps_finalR+eps_finalL);
    eps_XY=(1i/2)*(eps_finalR-eps_finalL);

    eps_XX_lambda(i) = eps_XX;
    eps_XY_lambda(i) = eps_XY;

    %The program will stop timing the run
    %toc 
end
end
