% ************** SET THE NECESSARY VARIABLES FROM THE WORKSPACE ************** %
loadBool = 1;
if loadBool == 1
    wrf_runSettings
    wrf_plotSettings
    load(strcat(P.simulationPPdir, 'trackedUpdraft_skip-32.mat'));

    %load USA
    USATemp = wrf_extractVariables_TU(trackedUpdraft, 'USA', "none", "none", "all", "raw");
    USA = USATemp.USA;

    %load Circulation classification
    CCTemp = wrf_extractVariables_TU(trackedUpdraft, 'CC', "none", "none", "all", "raw");
    CC = CCTemp.CC;

    %load updraft velocity statistics
    UMTemp = wrf_extractVariables_TU(trackedUpdraft, 'URMS', "none", "none", "all", "raw");
    UM = UMTemp.URMS;

    %load updraft top statistics
    UTTemp = wrf_extractVariables_TU(trackedUpdraft, 'UT', "none", "none", "all", "raw");
    UT = UTTemp.UT;

    %load updraft base statistics
    UBTemp = wrf_extractVariables_TU(trackedUpdraft, 'UB', "none", "none", "all", "raw");
    UB = UBTemp.UB;

    %load updraft depth statistics
    DETemp = wrf_extractVariables_TU(trackedUpdraft, 'DE', "none", "none", "all", "raw");
    DE = DETemp.DE;

    %load the mask
    maskTemp = wrf_extractVariables_TU(trackedUpdraft, 'mask', "none", "none", "all", "raw");
    wrf_mask = maskTemp.mask;
    clear UMTemp UTTemp UBTemp DETemp CCTemp USATemp maskTemp
end




%!todo: make this a function and move the above to the figure script.
% &&&&&&&&&&&&&&&&&&&&&&&&&&&&& END OF USER INPUT &&&&&&&&&&&&&&&&&&&&&&&&&&&& %
%fig = figure()
sizey = 3;
sizex = 7.5;
figure_size = [0.1, 0.1, sizex, sizey]; %assigning size of figure
fig = figure('DefaultAxesFontSize', 1, 'Units', 'Inches','Position', figure_size);

%add in the mask


azi_cuts = -180:20:180;
CSR_cut = 0.4;
%azi_mid = ;

%number of rows for the plot
%sy = 3;
sx = 4;
for i = 1:4 %loop over each of the circulation classes
    subplot(1,sx,i)
    set(gca,'fontsize',8)
    set(gca, 'xdir', 'reverse')



    for j = 1:numel(azi_cuts)
        azi_range = 30; %size of the moving, azimuthal average
        cut_1 = azi_cuts(j) - azi_range;
        cut_2 = azi_cuts(j) + azi_range;

        if cut_1 < 0 && azi_cuts(j)~=-180 %fixes for looping over boundaries
            USA_temp = wrapTo180(USA);
            mask = wrf_mask&(USA_temp >= cut_1)&(USA_temp<cut_2)&(CC == i);
        elseif cut_2 > 360
            wrapTo360(cut_2)
            mask = wrf_mask&((USA >= cut_1)|(USA<cut_2))&(CC == i);

        elseif (azi_cuts(j) == 180)||(azi_cuts(j) == -180)
            mask = wrf_mask&(USA >= 150)&(USA<=210)&(CC == i);
        else
            mask = wrf_mask&(USA >= cut_1)&(USA<cut_2)&(CC == i);
        end

        percentile_diff = 15;

        %calculating the size statistics and 95% confidence intervals
        %Depth
        uDE(i, j) = nanmean(DE(mask));
        ts = tinv([0.05, 0.95], nnz(~isnan(DE(mask)))-1);
        SEM = nanstd(DE(mask))/sqrt(nnz(~isnan(DE(mask))));
        uDElo(i, j) = uDE(i, j) + ts(1)*SEM;
        uDEhi(i, j) = uDE(i, j) - ts(1)*SEM;
        %base height
        uUB(i, j) = nanmean(UB(mask));
        ts = tinv([0.05, 0.95], nnz(~isnan(UB(mask)))-1);
        SEM = nanstd(UB(mask))/sqrt(nnz(~isnan(UB(mask))));
        uUBlo(i, j) = uUB(i, j) + ts(1)*SEM;
        uUBhi(i, j) = uUB(i, j) - ts(1)*SEM;
        %updraft top altitude
        uUT(i, j) = nanmean(UT(mask));
        ts = tinv([0.05, 0.95], nnz(~isnan(UT(mask)))-1);
        SEM = nanstd(UT(mask))/sqrt(nnz(~isnan(UT(mask))));
        uUTlo(i, j) = uUT(i, j) + ts(1)*SEM;
        uUThi(i, j) = uUT(i, j) - ts(1)*SEM;
        %updraft max vertical velocity (not currently being used)
%        uUMH(i, j) = nanmean(UMH(mask));
%        uUMH20(i, j) = prctile(UMH(mask), 50-percentile_diff);
%        uUMH80(i, j) = prctile(UMH(mask), 50+percentile_diff);
        uUM(i, j) = nanmean(UM(mask));
        %number in calculation
        udata(i,j) = nnz(mask);
        %average normalized radius
        %uUN(i,j) = nanmean(UN(mask));
        %ts = tinv([0.05, 0.95], nnz(~isnan(UN(mask)))-1);
        %SEM = nanstd(UN(mask))/sqrt(nnz(~isnan(UN(mask))));
        %uUNlo(i, j) = uUN(i, j) + ts(1)*SEM;
        %uUNhi(i, j) = uUN(i, j) - ts(1)*SEM;

        %    mUN(i,j) = mode(UN(mask));

    end

    %flipping the x-coordinates for the fill() function
    x2 = [azi_cuts, fliplr(azi_cuts)];


    hold on
    %plotting the above variables and associated confidence intervals

    plot(azi_cuts ,uUB(i, :), 'g');
    in_between = [uUBlo(i,:), fliplr(uUBhi(i,:))];
    mask = ~isnan(in_between);
    p1= fill(x2(mask), in_between(mask), 'g', 'LineStyle' ,'none');
    set(p1, 'facealpha', 0.3)

    plot(azi_cuts ,uUT(i, :), 'b');
    in_between = [uUTlo(i,:), fliplr(uUThi(i,:))];
    mask = ~isnan(in_between);
    p2= fill(x2(mask), in_between(mask), 'b', 'LineStyle' ,'none');
    set(p2, 'facealpha', 0.3)

    plot(azi_cuts ,uDE(i, :), 'r')
    in_between = [uDElo(i,:), fliplr(uDEhi(i,:))];
    mask = ~isnan(in_between);
    p3= fill(x2(mask), in_between(mask), 'r', 'LineStyle' ,'none');
    set(p3, 'facealpha', 0.3)
    %{
    plot(azi_cuts, uUN(i, :), 'y')
    in_between = [uUNlo(i,:), fliplr(uUNhi(i,:))];
    p5 = fill(x2, in_between, 'y');
    set(p5, 'facealpha', 0.3);
    %}
    %  plot(azi_cuts, uUM(i, :), 'c');

    ylim([0, 18])
    yticks([1:18])

    %xlabel('Shear Relative Angle (deg)')

    grid on
    xlim([-180,180])




    xticks(sort(-180:90:180))
    xticklabels(string(wrapTo360(-180:90:180)))
    %  if i == 1; legend('Up. De.','Up. Top', 'Up. Bot.'); end



    title("Circ. Type = "+string(i));


    %plot the number in the average along the right y-axis.
    yyaxis right
    p4 = plot(azi_cuts, udata(i,:));
    ylim([0,max(udata(:))])

    %{
    if i == 1
        ylabel('Vertical Extent of Updrafts (km)');
        lgd = legend([p1,p2,p3, p4], 'Base Altitude','Top altitude','Depth', 'Frequency', 'Location', 'southeast')
        lgd.FontSize = 10;
    end
    %}

end

%print out the top part of the graph
print(fig, '-dpng', char("/rita/s0/scratch/nrb171/figures/harvey/azimuthalSizeAnalysis/sizeanalysis_top.png"))

%now, plot by looking at the variables with all of the circulations plotted

%colors for each plot. The red, green, and blue coordinates of the colors
%are listed here.

%!!!!!!! Colors are not good enough yet work on this!

%for k = [1,2] % make two different bottoms
    fig = figure('DefaultAxesFontSize', 1, 'Units', 'Inches','Position', figure_size);

    darkener = 1/255;
    linedarkness = 0.5;
    %colorsr = fliplr([255,51,51, 255]*darkener);
    %colorsg = fliplr([192,255,114, 51]*darkener);
    %colorsb = fliplr([51,90,255, 216]*darkener);
    colorsr = [88, 252, 169, 171]*darkener;
    colorsg = [251, 89, 252, 88]*darkener;
    colorsb = [252, 88, 88, 252]*darkener;
    alpha = 0.5;
    indices = [2,3;1,4];
for k = [1,2]
    k
    %Depth
    subplot(1,4,1+2*(k-1))
    set(gca,'fontsize',8)
    hold on
    set(gca, 'xdir', 'reverse')
    for i = indices(k,:)
        ylabel('Depth')
        in_between = [uDElo(i,:), fliplr(uDEhi(i,:))];
        p(i)= fill(x2, in_between,  [colorsr(i), colorsg(i), colorsb(i)]);%, 'LineStyle' ,'none');
        set(p(i), 'facealpha', alpha)
        plot(azi_cuts, uDE(i,:), 'color', [colorsr(i), colorsg(i), colorsb(i)]*linedarkness)
        grid on
        xlim([-180,180])
        ylim([0, 18])
    end
    yticks([1:18])
    xticks(sort(-180:90:180))
    xticklabels(string(wrapTo360(-180:90:180)))
    %xlabel('Shear Relative Angle (deg)')
%    lgd = legend([p(1), p(2), p(3), p(4)], "Type 1", "Type 2", "Type 3", "Type 4");
%    lgd.FontSize = 6;


    % Base altitude and top altitude
    %alpha = 0.5;
    subplot(1,4,2+2*(k-1))
    set(gca,'fontsize',8)
    hold on
    set(gca, 'xdir', 'reverse')
    for i = indices(k,:)
        ylabel('Base | Top Altitude')
        in_between = [uUBlo(i,:), fliplr(uUBhi(i,:))];
        p(i)= fill(x2, in_between, [colorsr(i), colorsg(i), colorsb(i)]);%, 'LineStyle' ,'none');
        set(p(i), 'facealpha', alpha)
        plot(azi_cuts, uUB(i,:), 'color', [colorsr(i), colorsg(i), colorsb(i)]*linedarkness)
        grid on
        xlim([-180,180])
        ylim([0, 18])
    end

    plot([-180, 180], [5,5], '-k')

    for i = indices(k,:)
        %ylabel('Top Altitude')
        in_between = [uUTlo(i,:), fliplr(uUThi(i,:))];
        p(i)= fill(x2, in_between, [colorsr(i), colorsg(i), colorsb(i)]);%, 'LineStyle' ,'none');
        set(p(i), 'facealpha', alpha)
        plot(azi_cuts, uUT(i,:),'color', [colorsr(i), colorsg(i), colorsb(i)]*linedarkness)
        grid on
        xlim([-180,180])
        ylim([0, 18])
    end
    yticks([1:18])
    xticks(sort(-180:90:180))
    xticklabels(string(wrapTo360(-180:90:180)))
    %xlabel('Shear Relative Angle (deg)')

end
    print(fig, '-dpng', char("/rita/s0/scratch/nrb171/figures/harvey/azimuthalSizeAnalysis/sizeanalysis_bot.png"))
