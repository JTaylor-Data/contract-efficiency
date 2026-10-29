# Contract Efficiency Breakdown (CE+)
$/WAR by MLB team-season, standardized into a single metric 

**Tampa Bay and Milwaukee don't spend like most contending teams. But they do win like them. This analysis showed them to be the #1 and #2 front offices at turning payroll in performance. Months after the analysis was conducted, they met in the World Series.**

## Notebook Structure

Analysis is broken into seven sections:

1. League Wide Trends
2. Team-Year analysis - most efficient teams relative to results
3. Individual team time series efficiency analysis
4. Dead Money Analysis - Where is the waste?
5. Contract Efficiency+ (CE+) - A standardized spending efficiency metric
6. Pareto Frontier - A theory about the Rays dominance
7. Conclusions

## What is it?

<img width="719" height="355" alt="image" src="https://github.com/user-attachments/assets/cfdacf93-1d72-4b4e-b28f-91f54dfe6759" />

Contract Efficiency+ (CE+) is designed to be an easily interpretable metric answering a question fans, media, and front offices argue about and reference constantly, how well does a team spend its money? It measures how well a team converts payroll into on field value (measured with fWAR), standardized so 100 is league average. A team with a score of 120 is getting much more value from the marginal dollar than their peers, and a team scoring 80 significantly less. The goal is not just to rank the teams, but determine the strategies employed by the most efficient teams and if those strategies are scalable to payrolls of all sizes. 

## Key Findings
- TBR and MIL have a 11/15 & 9/15 seasons with below average payroll and above average win rate, the highest in the sample.
- LAD averages 96.2 Wins (highest in the league) and their average CE+ sits below average (95), but is among the best for high payroll teams, driving success
- LAA have the lowest single season CE+ value of 38 in 2025, the most expensive and bad seasons (11/15), and the lowest average CE+ over the period (seen in graph above).
- +1 SD of total payroll associates with ~3.5 extra wins. +1 SD of dead money % is associated with ~6 fewer wins (R^2 = 0.362). Dead money % has a remarkably strong relationship with Wins.
- CE+ is meaningfully sticky (r = 0.57, R^2 = 0.33) despite capturing volatility of injury luck and other factors.
- HOU and CLE lead in appearances on the Pareto Frontier (the lowest payroll at each win total), with 7 each.
- Clear diminishing returns to payroll beyond $100-120M among frontier (efficient) teams, which doesn't hold among ALL teams in the league.
- Houston, Cardinals, and Braves stand out as moderate-payroll teams sustaining above-average efficiency even as their spending grows.
- Angels, Giants, Rangers, Rockies identified as the league’s least efficient high-spenders.


## Limitations and Next Steps

The dataset is missing many values for injury data pre 2015, thus certain payroll analysis was only possible for the period of 2015-2025.

fWAR was used as the measure of on field value throughout the project. This analysis excludes bWAR and does not account for any differences in a player/team fWAR and bWAR.

The analysis and payroll data have no way to account for deferred money, which can skew a teams current $/WAR metrics, artificially inflating some teams CE+ scores (ex. Dodgers deferred $680M of Ohtani's contract)

Next steps: future work could weight fWAR/bWAR equally, or adjust for deferred-money structures so CE+ scores aren't inflated by contracts like Ohtani's.

## Data and Methodology

- Payroll: Spotrac.com, 2011-2025, inflation-adjusted to real 2025 USD using FRED’s CPI-U.
- WAR: Fangraphs (fWAR), aggregated to the team-year level. Chosen over bWAR because bWAR’s pitching component relies on RA/9, which doesn’t isolate pitcher value well.
- 2020 excluded entirely — the 60-game season distorts any rate-based comparison.
- Pre-2015 seasons dropped from active/injured-payroll analysis. Injury payroll data isn’t available before 2015, and including those years would bias active $/WAR estimates.
- Team-years under 7.5 WAR excluded from CE+ and the diminishing-returns analysis (5 observations). $/WAR mathematically explodes as WAR approaches zero and these cases add noise, not signal.

## How to Recreate it

```
Contract Efficiency/
├── README.md
├── data/
│   ├── CPI-U Data 2011-2025.csv
│   ├── Efficiency_Final.csv
│   ├── TeamWAR (Split into all_batting - pitching with WAR_concat.ipynb).xlsx
│   ├── Teams.csv
│   ├── all_batting.csv
│   ├── all_pitching.csv
│   └── spotrac_payrolls.csv
├── notebooks/
│   ├── CE Analysis.ipynb
│   └── WAR Concat.ipynb
└── sql/
    └── CE_data_cleaning.sql
```

2 options:
1. Download **Efficiency_Final & Teams.csv** in the data folder. Download CE Analysis.ipynb in the notebooks folder and run start to finish.

2. To recreate from the original data, Download **CPI data, Teams, all_batting, all_pitching, spotrac_payrolls, CE Analysis, and CE_data_cleaning**. Ensure all files are in the same folder and run CE_data_cleaning end to end. It will produce "Efficiency_Final.csv". At this point refer to Option 1.

## About

This project is part of an ongoing portfolio exploring data analytics, machine learning, statistics, and my passion for the game of baseball. I'm a third-year Economics student at the University of Toronto (Focus in DA, Statistics Minor). Feel free to reach out if you'd like to talk shop or have feedback on the analysis.

josh.scott.tay@gmail.com |  [Linkedin](https://www.linkedin.com/in/joshua-taylor-86450a32a/)  

