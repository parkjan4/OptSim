function plotHistogram(data, worse_case_max)

% ============================================================================
% DESCRIPTION
%
% usage: plotStatistics(data)
%
% Plot statistics of a data vector
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% data              (vector) data vector
% worst_case_max    (bool) If true, worst case is defined as max
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
%
% ============================================================================

% Plot the histogram of the maximum queue length
figure;histogram(data);
ylabel('Frequency');
set(get(gca,'child'),'FaceColor',[0.4,0.4,0.4]);

% Add mean
ylim=get(gca,'ylim');
l1=line([mean(data) mean(data)], ylim,'Color','r','LineWidth',2.0); % mean
% And percentile
l2=line([prctile(data,5) prctile(data,5)], ylim,'LineStyle','--','Color','r','LineWidth',2.0); %  5 percentile
line([prctile(data,95) prctile(data,95)], ylim,'LineStyle','--','Color','r','LineWidth',2.0); % 95 percentile
% Add worst case
if worse_case_max
    l3=line([max(data) max(data)], ylim,'LineStyle',':','Color','r','LineWidth',2.0); %  5 percentile
else
    l3=line([min(data) min(data)], ylim,'LineStyle',':','Color','r','LineWidth',2.0); %  5 percentile
end

% Legend
legend([l1 l2 l3],'mean','5 and 95 percentile','worst case','Location','Best');
