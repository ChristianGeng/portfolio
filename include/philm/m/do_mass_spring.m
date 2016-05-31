function do_mass_spring 
% do_mass_spring Run mass_spring demo
% do_mass_spring: Version 22.12.2011


timesteps=[0:0.1:10];
initial_position=-2;
initial_velocity=0;
odeoptions='';
resting_length=-1;
stiffness=5;
damping=3;
mass=1;
myline='-';
mywidth=2;
mycolor='r';
mymarker='none';

cs=cell(6,1);

finished=0;

omode=0;
while ~finished
disp('In keyboard mode set new parameter values.');
disp('');
disp('Hints:');
disp('Critical damping corresponds to 2*sqrt(stiffness) (when mass is 1)');
disp('(For critical damping, damping ratio = damping/(2*sqrt(mass * stiffness)) = 1)');
disp('Frequency in radians/s = sqrt(stiffness) (when mass is 1)');
disp('');
disp('type ''finished=1'' to exit');

[t,y]=ode45(@mass_spring,timesteps,[initial_position;initial_velocity],odeoptions,resting_length,stiffness,damping,mass);

if omode==-1 hf=figure; end;
if omode==1 hold on; end;

hl=plot(t,y(:,1));		%just plot position
set(hl,'linestyle',myline,'linewidth',mywidth,'color',mycolor,'marker',mymarker);

cs{1}=['mass             = ' num2str(mass)];
cs{2}=['damping          = ' num2str(damping)];
cs{3}=['stiffness        = ' num2str(stiffness)];
cs{4}=['resting_length   = ' num2str(resting_length)];
cs{5}=['initial_position = ' num2str(initial_position)];
cs{6}=['initial_velocity = ' num2str(initial_velocity)];

disp(cs);

ymax=max(get(gca,'ylim'));
xmax=max(get(gca,'xlim'));

ht=text(xmax,ymax,cs,'verticalalignment','top','horizontalalignment','right','fontsize',12,'fontweight','bold','interpreter','none');
xlabel('Time (s x 2pi)','fontsize',12,'fontweight','bold');
hold off


keyboard;

end;

function dy=mass_spring(t,y,rest_length,stiffness,damping,mass);
% MASS_SPRING: Demo to use with ode45 differential equation solver
% function dy=mass_spring(t,y,flag,rest_length,stiffness,damping,mass);
% mass_spring: Version 21.12.2011
%
%   Syntax
%       t: vector of time steps at which to evaluate
%       y: column vector of initial conditions (position, velocity)
%       Use calling program to set appropriate defaults for remaining
%       inputs
%
%   Updates
%       21.12.2011 Integrated into calling function using function handle.
%       No longer sure where the original demo came from

dy=[y(2);(-damping*y(2)-stiffness*(y(1)-rest_length)/mass)];
