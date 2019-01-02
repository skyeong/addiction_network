function behavioralprediction_seedfc(idx_edges,all_mats,all_behav)

no_sub = size(all_mats,2);
behav_pred_pos = zeros(no_sub,1);
behav_pred_neg = zeros(no_sub,1);
behav_pred_all = zeros(no_sub,1);

for leftout = 1:no_sub
    %fprintf('\n Leaving out subj # %d',leftout);
    
    % leave out subject for training
    train_mats = all_mats;
    train_mats(:,leftout) = [];
    
    train_behav = all_behav;
    train_behav(leftout) = [];
    
    % select one subject for testing
    test_mat = all_mats(:,leftout);
    
    
    % Prediction Model using Positive Correlation
    %----------------------------------------------------------------------
    if sum(idx_edges.pos)>1
        train_sumpos = zeros(no_sub-1,1);
        for ss = 1:size(train_sumpos)
            train_sumpos(ss) = nansum(train_mats(idx_edges.pos,ss));
        end
        lm_pos = fitlm([train_sumpos],train_behav,'RobustOpts','on');
        fit_pos = lm_pos.Coefficients.Estimate([2 1])';
        %figure; plot(train_behav,train_sumpos,'o')
        
        % run model on TEST sub
        test_sumpos = nansum(test_mat(idx_edges.pos));
        behav_pred_pos(leftout) = fit_pos*[test_sumpos 1]';
    else
        behav_pred_pos(leftout)=nan;
    end
    
    
    % Prediction Model using Negative Correlation
    %----------------------------------------------------------------------
    if sum(idx_edges.neg)>1
        train_sumneg = zeros(no_sub-1,1);
        for ss = 1:size(train_sumneg)
            train_sumneg(ss) = nansum(train_mats(idx_edges.neg,ss));
        end
        lm_neg = fitlm([train_sumneg],train_behav,'RobustOpts','on');
        fit_neg = lm_neg.Coefficients.Estimate([2 1])';
        %figure; plot(train_behav,train_sumneg,'o')
        
        % run model on TEST sub
        test_sumneg = nansum(test_mat(idx_edges.neg));
        behav_pred_neg(leftout) = fit_neg*[test_sumneg 1]';
    else
        behav_pred_neg(leftout)=nan;
    end
    
    
    % Prediction Model using Both Correlations
    %----------------------------------------------------------------------
    if sum(idx_edges.pos)*sum(idx_edges.neg)>1
        lm_all = fitlm([train_sumpos train_sumneg],train_behav,'RobustOpts','on');
        fit_all = lm_all.Coefficients.Estimate([2 3 1])';
        behav_pred_all(leftout) = fit_all*[test_sumpos test_sumneg 1]';
    else
        behav_pred_all(leftout)=nan;
    end
    
    %     fprintf('beh=%.2f, pred_pos=%.2f, pred_neg=%.2f, pred_all=%.2f\n',...
    %         all_behav(leftout),...
    %         behav_pred_pos(leftout),...
    %         behav_pred_neg(leftout),...
    %         behav_pred_all(leftout));
end
%
% bias_pos = sum((behav_pred_pos-all_behav).^2)/(no_sub-1);
% bias_neg = sum((behav_pred_neg-all_behav).^2)/(no_sub-1);
% bias_all = sum((behav_pred_all-all_behav).^2)/(no_sub-1);
% variance_pos =  var(behav_pred_pos);
% variance_neg =  var(behav_pred_neg);
% variance_all =  var(behav_pred_all);

% compare predicted and observed scores
[R_pos, P_pos] = corr(all_behav,behav_pred_pos,'tail','both');
[R_neg, P_neg] = corr(all_behav,behav_pred_neg,'tail','both');
[R_all, P_all] = corr(all_behav,behav_pred_all,'tail','both');

if P_pos<0.05 && R_pos>0
    fprintf('[Posi] R=%.2f, p=%.4f\n',R_pos,P_pos);
end
if P_neg<0.05 && R_neg>0
    fprintf('[Nega] R=%.2f, p=%.4f\n',R_neg,P_neg);
end
if P_all<0.05 && R_all>0
    fprintf('[All ] R=%.2f, p=%.4f\n',R_all,P_all);
end
fprintf('\n');

if (P_pos<0.05 && R_pos>0)|| (P_neg<0.05 && R_neg>0)|| (P_all<0.05 && R_all>0)
    figure;
    subplot(131) ;plot(all_behav,behav_pred_pos,'r.'); lsline
    subplot(132); plot(all_behav,behav_pred_neg,'b.'); lsline
    subplot(133); plot(all_behav,behav_pred_all,'k.'); lsline
end