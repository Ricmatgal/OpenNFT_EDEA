function [solution_in_cm_mirror,solution_in_cm_stimuliscreen,solution_in_pixel_stimuliscreen] = compute_distance_readable_from_screen_center_overt_fmri(distance_mirror_coil_cm,head_circumference_cm, pupillary_distance_cm, ratio_stimuliscreen_mirror)
%put distance in centimeters

%for prisma
%https://www.siemens-healthineers.com/nl/magnetic-resonance-imaging/options-and-upgrades/coils/bio-matrix-head-neck64
%435 mm × 395 mm × 350 mm (L x W x H)


%for instance
%distance_head_chinrest_cm=200 %cm
%pupillary_distance_cm=5 %cm %The average adult's Pupillary Distance (PD) is
%between 54 and 75 mm. The average for children is 43 to 58 mm. PD measurement determines how far one’s pupils are apart.


%%USAGE
%[solution_in_cm_mirror,solution_in_cm_stimuliscreen,solution_in_pixel_stimuliscreen] = compute_distance_readable_from_screen_center_overt_fmri(50,60, 6.45, 3)
% solution_in_cm_mirror =   5.3158
% solution_in_cm_stimuliscreen =   15.9475
% solution_in_pixel_stimuliscreen =  602.7415



%LITERATURE
%A 60 degrees angle is readable for symbol for human (FOV for symbol
%recognition of 60 degrees)
% Taken from https://www.researchgate.net/publication/344509899_Measuring_magnitude_of_change_by_high-rise_buildings_in_visual_amenity_conflicts_in_Brisbane
% 	Adapted from 
% 	Human dimension & interior space: a source book of design reference standards
% 	J Panero, M Zelnik - 1979
% 	<https://scholar.google.com/scholar_lookup?title=Human%20Dimension%20%26%20Interior%20Space%3A%20A%20Source%20Book%20of%20Design%20Reference%20Standards&author=J.%20Panero&publication_year=1979> 


%Theorem
%Thales, tan
%solving
%a y² + b y + c = 0

a=1;
%as tan(30)=1/sqrt(3)
z= distance_mirror_coil_cm - (head_circumference_cm/(2*pi));
b=-(pupillary_distance_cm*10^(-3) + ((2/sqrt(3)) * z *10^(-3)) );
c=0;
p = [a b c];
r = roots(p);

%convert in pixel
pixel_2_meters_conversion=0.0002645833; %in meters %1 Pixels= 0.0002645833 Meters

for i=1:numel(r)
    if r(i) >0
        solution_in_meter_mirror=r(i); %in m
        solution_in_cm_mirror=solution_in_meter_mirror*100;
        solution_in_meter_stimuliscreen=ratio_stimuliscreen_mirror*solution_in_meter_mirror;
        solution_in_pixel_stimuliscreen=solution_in_meter_stimuliscreen/pixel_2_meters_conversion;
        solution_in_cm_stimuliscreen=solution_in_meter_stimuliscreen*100;
    end
end

% syms y positive
% %Assume that the variable x is positive
% eqn = y^2 - 2 * tan(30) * distance_head_chinrest*10^(-3) * y - distance_between_eyes*10^(-3) == 0;
% %S = solve(eqn,x);
% S = solve(eqn,y,'Real',true);

end