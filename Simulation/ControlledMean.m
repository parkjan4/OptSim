
function [avg, variance, newData] =  ControlledMean(data, controlData, expectedControl)

% ============================================================================
% DESCRIPTION
%
% usage: [mean, variance, newData] = ControlledMean(data, controlData, expectedControl)
%
% Computes the average of "data", using "controlData" as a control variate,
% where "expectedControl" is the expectation of "controlData". Returns the
% resulting average value "avg", its "variance", the optimal linear
% combination "newData" of "data" and "controlData"
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% data             a row vector of data points
%                  (called X in the lecture)
% controlData      a row vector of control variates; must have the same
%                  dimension as "data"
%                  (called Y in the lecture)
% expectedControl  the scalar expectation of "controlData"
%                  (called mu in the lecture)
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% avg          the controlled mean of the data
% variance     the variance of "mean"
% newData      a row vector of the same dimension as "data" that contains
%              the optimal linear combination of "data" and "controlData"
%              (called Z in the lecture)
%
% ============================================================================


% Qual eh o output X da simulacao?
% R.: X=max(queues).
% Qual eh o output Y da simulacao?
% R.: Y=meanServiceTimes.
if length(data)==1 % And controlData as well
    cstar=0;
else
    covXY=1/(length(data)-1);
    varY=1/(length(controlData)-1);
    meanX=mean(data);
    meanY=mean(controlData);
    auxvarY=0;
    auxcovXY=0;
    for i=1:length(controlData)
        auxvarY=auxvarY+(controlData(i)-meanY)^2;
        auxcovXY=auxcovXY+(data(i)-meanX)*(controlData(i)-meanY);
    end
    varY=varY*auxvarY;
    covXY=covXY*auxcovXY;
    cstar=-covXY/varY;
end

newData=data+cstar*(controlData-expectedControl);
avg=mean(newData);
varZ=1/(length(newData)-1);
auxvarZ=0;
for i=1:length(newData)
    auxvarZ=auxvarZ+(newData(i)-avg)^2;
end
variance=varZ*auxvarZ;
end