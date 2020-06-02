clear all
close all

subjid_apple=input('Apple id:','s');
subjid_banana=input('Banana id:','s');


datapath=[pwd '\DATA\'];%generates new folder in current dir
congruency = input('Cong_ Fruit: ' ,'s'); %apple, banana
soc_ctx = input('Condition: ' ,'s'); %ind, pos, neg 

% age=input('ptps age: ' ,'s');
% gender=input('ppt gender: ' ,'s');
device=input('device id:','s');

filename=[soc_ctx '_' congruency '_' subjid_apple '_' subjid_banana '_' 'Study5_LH'];
if exist ([datapath filename '.mat'],'file')
    filename =[filename (num2str(round(sum(fix(clock)))))]
end

dem(1).filename=filename;
% dem(1).age=age;
% dem(1).gender=gender;
dem(1).congruency=congruency;
dem(1).soc_ctx=soc_ctx;



%% define the display settings and initialize cogent(toolbox to present stimuli)
global cogent;
global ratingCounting;
%global ratingDetect;

config_keyboard
config_display(1,1,[0 0 0], [1 1 1], 'Arial',20,12,0)
start_cogent

% %% define variables and prepare stuff in the background
% HB_recognition=[];
nhb= 3; % HR estimates will consist the average IBI of the preceeding nhb heartbeats.
%The wider the smoother are the changes
nhbbase=10;%for baseline

rng('Shuffle') %randomises the seed, I only need it once in the script
%randomising the asynch and synch trials 1=synch, 2=asynch

gf_r=[0 1 1 2 2 3 4 5 6];
gf_r=repmat(gf_r,1,200);

     phdata(1).gf=gf_r(randperm(length(gf_r)));    

phdata(1).greens = 0;
phdata(1).blues = 0;
%% Create background Thermometer to be called each time (Sprite 1)

cgmakesprite(1,640,480,0,0,0) %create a diff sheet index numbe 1 here, size,
cgsetsprite(1) %i will use this-write on it
cgpencol(1,1,1)
cgpencol(1,1,1)
cgpenwid(2)
cgdraw(-12,-102,-12,102)%this draws lines in positions, this give the structure to the TM
cgdraw(12,-102,12,102)
cgdraw(-12,-102,12,-102)
cgdraw(-12,102,12,102)

cgdraw(-20,100,-15,100) %ticks on the termometer
cgdraw(-20,75,-15,75)
cgdraw(-20,50,-15,50)
cgdraw(-20,25,-15,25)
cgdraw(-40,0,-15,0)
cgdraw(-20,-100,-15,-100)
cgdraw(-20,-75,-15,-75)
cgdraw(-20,-50,-15,-50)
cgdraw(-20,-25,-15,-25)

cgsetsprite(0)%index zero>>blank

%% This is to inatialize the communication protocol with the parallel port

if device=='g'    
    s=daq.createSession('ni');
    s.addDigitalChannel('Dev1','Port1/Line0','InputOnly');
    s.addDigitalChannel('Dev1','Port0/Line6','OutputOnly');%Output channel 1
    s.addDigitalChannel('Dev1','Port0/Line4','OutputOnly'); %Output channel2
    s.outputSingleScan([0 0]); %needs equal numbers of coloumns as outputchannels    
else
    s=daq.createSession('ni');
    s.addDigitalChannel('Dev2','Port1/Line0','InputOnly');
    s.addDigitalChannel('Dev2','Port0/Line6','OutputOnly');%Output channel 1
    s.addDigitalChannel('Dev2','Port0/Line4','OutputOnly'); %Output channel2
    s.outputSingleScan([0 0]); %needs equal numbers of coloumns as outputchannels
end
% 

%% Instructions
cgpencol(1,1,1)
cgfont('Helvetica',20)
cgtext('Please count the number of times YOUR assigned colour appeared!',0,100)
cgtext('For your reference, here are the colours that can appear:',0,80)
cgpencol(1,0,0)
cgtext('RED',0,40)
cgpencol(1,0.5,0)
cgtext('ORANGE',0,20)
cgpencol(1,1,0)
cgtext('YELLOW',0,0)
cgpencol(0,0.8,0)
cgtext('GREEN',0,-20)
cgpencol(0,0.5,1)
cgtext('BLUE',0,-40)
cgpencol(0,1,1)
cgtext('CYAN',0,-60)
cgpencol(1,0,1)
cgtext('MAGENTA',0,-80)

cgflip(0,0,0)
clearkeys;
readkeys;
[key ktime pressed]=waitkeydown(inf, 71); % wait infinite time for a spacebar press
clearkeys;

%measure baseline
cgpencol(1,1,1)
cgfont('Helvetica',20)
cgtext('Please wait a few seconds.',0,0)
cgtext('Please remember to be very still',0,-50)
cgflip(0,0,0)

%% this will estimate the first HB
% it works like this: heartbeats are communicated from the Powerlab to Matlab
%through a parallel port
% this script reads the state of the input of the parallel port to know
% if it is currently "on" (heartbeat (R-wave) detected) or "off" (between
% hearbeats (R-waves)).
% if it is "on" the port will be active (binary 1)and have a value of 144
%(this changes from PC to PC and parellel card to parallel card)
% if it is "off" the port will be inactive (binary 0)a value of 128
%(this changes from PC to PC and parellel card to parallel card)
% remeber that the port will be active for the entire legnth of the pulse
% defined in powerlab (e.g. 20ms)

heart=0; % the input parallel port state %128 no HB
while heart==0  %% it will continuosly check the port state until it is not longer 128 (= binary 0). when this happens an hearbeat was detected
    heart=inputSingleScan(s); % check input port state and assign it to "heart"
end
t0=time; % an hearbeat was detected. get timestamp for this heartbeat
s.outputSingleScan([1 0]); wait(10); s.outputSingleScan([0 0]); %sends trigger - visualises trigger % send a pulse to powerlab just to visualize it (this is not necessary)

while heart~=0 %% wait for the pulse to finnish 144 is hb %%it will continuosly check the port state until it is not longer 144 (binary 1). when this happens the hearbeat pulse has finished
    heart=inputSingleScan(s);
end

%% measure thermomether for the first time without any signal to generate ibi
%series for non-contingent trials and first baseline
for b=1:nhbbase %% the variable "b" will track the number of heartbeats
    while heart==0
        heart=inputSingleScan(s); %% wait for an heartbeat
    end
    tHB(b)=time-t0; % calculate and save in the tHB variable the interbeat interval of heartbeat(b)
    t0=time; %save time of last heartbeat
    s.outputSingleScan([1 0]); wait(40); s.outputSingleScan([0 0]); %sends trigger - visualises trigger % send a pulse to powerlab just to visualize it (this is not necessary)
    
    while heart~=0
        heart=inputSingleScan(s);
    end
    
    meanIBI(b)=mean(tHB(1:b));  %estimate average interbeat interval for the previous n heartbeats
    meanHR(b)=60000/meanIBI(b); %estimate average heartrate for the previous n heartbeats
    previous_trial_IBI(b)=meanIBI(b); % for first time
    
end

    phdata(1).meanIBI(1)=meanIBI(b);
    phdata(1).level(1)=NaN;

%% main part

 trial_number = 1
 Contingency=1      
    
%% sets the bar in the back ground and the scales for visualisin BF
    
    %if Contingency==1
       phdata(trial_number).baseline=round(mean(previous_trial_IBI));  %estimate baseline, i.e. participants heart-rate in the beggining of the trial
    
    scalemax=phdata(trial_number).baseline+(phdata(trial_number).baseline/2); %steps should be scaled to IBI
    scalemin=phdata(trial_number).baseline-(phdata(trial_number).baseline/4);
    steps=200/(phdata(trial_number).baseline);
    
    startscale=0; %% this is the initial value for the scale (min=0; max=200)
    
    cgdrawsprite(1,0,0)
    cgpencol(1,0,0) %RED COLOUR
    cgpenwid(20)
    cgdraw(0,-90,0,-10);
    cgflip(0,0,0)
    
    startTime=time;
    clearkeys;
    nHBnc=1;
    nHBc=1;
    k=0; %this variable will code for the space barpress (see below)
    
    heart=0; 
    while heart==0  %% it will continuosly check the port state until it is not longer 128 (= binary 0). when this happens an hearbeat was detected
        heart=inputSingleScan(s); % check input port state and assign it to "heart"
    end
    t0=time; % an hearbeat was detected. get timestamp for this heartbeat
    s.outputSingleScan([1 0]); wait(2); s.outputSingleScan([0 0]);
    
    while heart~=0
        heart=inputSingleScan(s);
    end
    
    tcont2=time;
    while k<10        
        contin=1; %continue
        while contin==1
            %% it will continuosly check the port state until it is not longer 0.

            heart=inputSingleScan(s); % check input port state and assign it to "heart"
            if heart~=0 && time-t0>100
                b=b+1; % increase number of detected heartbeats by one                               
                tHB(b)=time-t0;% calculate and save in the tHB variable the interbeat interval of heartbeat(b)
                phdata(trial_number).HBctime(nHBc)=time; 
                phdata(trial_number).HBcIBI(nHBc)=time-t0;                 
                nHBc=nHBc+1;
                t0=time;
                s.outputSingleScan([1 0]); wait(2); s.outputSingleScan([0 0]); ;% send a pulse to powerlab just to visualize it (this is not necessary)
                
                if Contingency==1
                    contin=0;
                end
                
            end
        end
      
        meanIBI(b)=mean(tHB(b-nhb+1:b)); % average interbeat interval of the previous nhb heartbeats(nhb is defined at the top o fthe script)
        meanHR(b)=60000/meanIBI(b); % average heart rate of the previous nhb heartbeats(nhb is defined at the top o fthe script)
        phdata(trial_number).meanIBI(nHBc)=meanIBI(b);
        %in labchart, but this way we do not have to smooth it before feeding it in the thermometer level changes
        %so we don't need to transform tHB to meanIBI based on n=nhb consecutive heartbeats
        
            level=(round((meanIBI(b)-phdata(trial_number).baseline)*steps)*(-1)); %the scale is inverted (i.e, *(-1)) such that longer ibi= lower levels            
             phdata(trial_number).level(nHBc)=level;
        
        %% visualises the pulses of different colour
        %I think this needs to be conditional/linked to the condition
            pulse= phdata(trial_number).gf(nHBc);

            cgdrawsprite(1,0,0)
        if  pulse==0
            cgpencol(1,0.5,0)%orange
        elseif pulse==1
            cgpencol(0,0.8,0)%green
            phdata(1).greens = phdata(1).greens +1
        elseif pulse==2
            cgpencol(0,0.5,1)%blue
            phdata(1).blues = phdata(1).blues + 1
        elseif pulse==3
            cgpencol(0.9,0.9,0.9)%white
        elseif pulse==4
            cgpencol(1,0,1)%magenta
        elseif pulse==5
            cgpencol(0,1,1)%cyan
        elseif pulse==6
            cgpencol(1,1,0)%yellow
        end
        
        cgpenwid(20)
        cgdraw(0,-90,0,startscale+level-10);
        cgflip(0,0,0)
        twait=time;
        while time-twait<150
            heart=inputSingleScan(s);
            if heart~=0 && time-t0>100
                b=b+1; % increase number of detected heartbeats by one
                tHB(b)=time-t0;% calculate and save in the tHB variable the interbeat interval of heartbeat(b)
                phdata(trial_number).HBctime(nHBc)=time; 
                phdata(trial_number).HBcIBI(nHBc)=time-t0;                 
                nHBc=nHBc+1;
                t0=time;
                s.outputSingleScan([1 0]); wait(2); s.outputSingleScan([0 0]); ;% send a pulse to powerlab just to visualize it (this is not necessary)
                      
            end
        end
        
        cgdrawsprite(1,0,0)
        cgpencol(1,0,0) %red
        cgpenwid(20)
        cgdraw(0,-90,0,startscale+level-10);
        cgflip(0,0,0)
          
        meanIBI(b)=mean(tHB(b-nhb+1:b)); % average interbeat interval of the previous nhb heartbeats(nhb is defined at the top o fthe script)
        meanHR(b)=60000/meanIBI(b); % average heart rate of the previous nhb heartbeats(nhb is defined at the top o fthe script)
        phdata(trial_number).meanIBI(nHBc)=meanIBI(b);
        
        readkeys;
        [key ktime pressed] = getkeydown; %check if any key was pressed
        clearkeys;
        
        if time-startTime>=300*1000 %10 seconds
            k=100 ;
        end
        if key==71  % if the spacebar was pressed end the loop
            k=100 ;
        end
    end
    %%%%%%%%%%%%%% end of trial %%%%%%%%%%%%%%
    
    s.outputSingleScan([1 0]); wait(100); s.outputSingleScan([0 0]);% thicker trigger to labchart as it ends
     %% behavioural response part   
    
%         take_ratings_count
%         count_rating(1,1) = ratingCounting;
%         phdata(1).selfresponse_green = count_rating(1,1);
%         ratingCounting = 0;
%         clearpict;
%                 
%         take_ratings_count2
%         count_rating2(1,1) = ratingCounting;
%         phdata(1).selfresponse_blue = count_rating2(1,1);
%         ratingCounting = 0;
%         clearpict; 
        

%     
%     cgpencol(1,1,1) %text is presented in white
%     cgfont('Helvetica',20)
%     cgtext('Whose heart was the feedback representing?',0,0)
%     cgtext('Not my heart                                         My heart',0,-60)
%     cgflip(0,0,0)
%     clearkeys;
%     readkeys;
%     [key ktime pressed]=waitkeydown(inf); % wait infinite time for any key to be pressed
%     
%     if key==4  % if any buton on the right was pressed on responsebox
%         phdata(trial_number).HB_recognition=1; %1 is self
%     elseif key==6
%         phdata(trial_number).HB_recognition=1;
%     elseif key==19 % if any buton on the left was pressed
%         phdata(trial_number).HB_recognition=2; %2 is other
%     elseif key==1 % if any buton on the left was pressed
%         phdata(trial_number).HB_recognition=2;
%     end
%     
%     take_ratings_Detection
%     rating(1,1) = ratingDetect;
%     phdata(trial_number).HB_confidence=rating(1,1);
%     ratingDetect=0;
%     clearpict;
    
    save([datapath filename],'phdata','dem');
    
%     if trial_number == round(totalN/2)% to have break at half way through
%         cgpencol(1,1,1)
%         cgfont('Helvetica',20)
%         cgtext('We are half way through the study.',0,0)
%         cgtext('Please let the experimenter know you are ready to continue.',0,-20)
%         cgflip(0,0,0)
%         
%         clearkeys;
%         readkeys;
%         [key ktime pressed]=waitkeydown(inf, 71); % wait infinite time for a spacebar press
%         clearkeys;
%     end
%     
%     cgfont('Helvetica',60)
%     cgtext('+',0,0)
%     cgflip(0,0,0)
%     random_jitter=[750, 1250, 1750]
%     index=randperm(length(random_jitter));
%     wait(random_jitter(index))%jitter between random trials


% for i=1:length(phdata) %1:correct 0:incorrect
%     if phdata(i).Contingency_cond==phdata(i).HB_recognition
%         phdata(i).correct_response(i)=1;
%     else
%         phdata(i).correct_response(i)=0;
%     end
% end

cgpencol(1,1,1)
cgfont('Helvetica',20)
cgtext('Thank you',0,0)
cgflip(0,0,0)
wait(3000)
%%
stop_cogent
close all

phdata(1).selfresponse_green=input('counted green:','s');
phdata(1).selfresponse_blue=input('counted blue:','s');


        greens = phdata(1).greens;
        blues = phdata(1).blues;
         
        phdata(1).performance_green_apple = 1-(abs(greens-str2double(phdata(1).selfresponse_green))/greens);
    
        phdata(1).performance_blue_banana = 1-(abs(blues-str2double(phdata(1).selfresponse_blue))/blues);
    
save([datapath filename],'phdata','dem');