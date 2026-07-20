close all;
clc
clear 

% Parameters of SnO2@Au nanoparticles

b = 12.4; %core radius [nm]
d = 2.5; %shell thickness [nm]
n = 25e12; %planar density [m^-2]
B = 0; %magnetic flux density at sample [T]

% Wavelength-dependent dielectric permittivity

[wavelength,eps_XX_lambda,eps_XY_lambda]=EMA_Simulation(b,d,n,B)

% Create excel table

wavelength_um = wavelength * 1e6;

T = table( ...
    wavelength_um(:), ...
    real(eps_XX_lambda(:)), ...
    wavelength_um(:), ...
    imag(eps_XX_lambda(:)), ...
    real(eps_XY_lambda(:)), ...
    imag(eps_XY_lambda(:)), ...
    'VariableNames', ...
    {'wavelength (um)','eps_XX_real','wl (um)','eps_XX_imag','eps_XY_real','eps_XY_imag'});

writetable(T, "EMA_Output.xlsx");

% Plot
% 
% figure
% 
% plot(wavelength_um, real(eps_XX_lambda), ...
%     'b-', 'LineWidth', 2)
% 
% xlabel('Wavelength (\mum)')
% ylabel('Re(\epsilon_{XX})')
% title('Real Effective Permittivity vs Wavelength for SnO2@Au')
% 
% box on
