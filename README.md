# Contract Efficiency+ (CE+)

## Overview
- $/WAR by MLB team-season, standardized into a single metric: CE+
- Years covered: 2011-2025
- Portfolio / job-application analytics project

## Key Question
- Are teams spending efficiently relative to on-field value (WAR)?
- Quadrant framing: cheap/expensive x good/bad
- Dead money: payroll not producing on-field value (injured/retained/buried)
- Persistence: is front-office efficiency a repeatable skill year to year?

## Repo Structure
```
data/
  Teams.csv
  TeamWAR (Split into all_batting - pitching).xlsx
  all_batting.csv
  all_pitching.csv
  spotrac_payrolls.csv
  CPI-U Data 2011-2025.csv
  Efficiency_Final.csv
sql/
  CE_data_cleaning.sql
notebooks/
  WAR Concat.ipynb
  CE Analysis.ipynb
```

## Pipeline
- `data/TeamWAR (Split into all_batting - pitching).xlsx` -> `notebooks/WAR Concat.ipynb` -> `all_batting.csv` / `all_pitching.csv`
- SQL cleaning + CPI-U adjustment (`efficiency_final` view in `sql/CE_data_cleaning.sql`) -> `data/Efficiency_Final.csv`
- `data/Efficiency_Final.csv` + `data/Teams.csv` (W/L only) -> `notebooks/CE Analysis.ipynb` -> findings
- `data/Teams.csv` (`franchID`/`yearID`/`W`/`L` only) comes from a one-time Lahman DB restore (`lahman2025.bak`, not in repo); the SQL script no longer touches Lahman salary data - the earlier `salaries` / `team_payrolls` / `team_crosswalk` dead-code tables were removed since Spotrac already covers the full 2011-2025 window (see Known Gaps)

## Data Lineage

| File | Source | Produced by | Consumed by |
|---|---|---|---|
| `data/Teams.csv` | Lahman DB | Lahman restore | CE Analysis.ipynb (`franchID`, `yearID`, `W`, `L` only) |
| `data/TeamWAR (Split into all_batting - pitching).xlsx` | FanGraphs (manual pull) | - | WAR Concat.ipynb |
| `data/all_batting.csv` + `data/all_pitching.csv` | FanGraphs via TeamWAR xlsx | WAR Concat.ipynb | SQL cleaning |
| `data/spotrac_payrolls.csv` | Spotrac (manual pull) | - | SQL cleaning |
| `data/CPI-U Data 2011-2025.csv` | BLS CPI-U | - | `efficiency_final` view (SQL) |
| `data/Efficiency_Final.csv` | SQL `efficiency_final` view (constant 2025 dollars) | `sql/CE_data_cleaning.sql` | CE Analysis.ipynb |

## The CE+ Metric
- Base measure: $/WAR (total payroll / total team WAR), per team-season
- Standardized within-season: 100 = that season's league average
- 1 standard deviation = 15 points
- Inverted so higher CE+ = more efficient (fewer dollars per win)
- Floor: team-seasons with total WAR < 7.5 excluded ($/WAR explodes near WAR = 0)

## Highlights
- Payroll + CE+ together explain 65% of variance in team wins (R² = 0.648) - efficiency isn't just noise around spending
- CE+ is moderately persistent year to year (r = 0.57) - front-office efficiency looks like a repeatable skill, not luck
- LAA is the league's single worst team by efficiency across the whole period; NYY/LAD are the rare teams that spend big *and* stay efficient
- Payroll-to-wins returns bend/flatten around $80-120M - the Pareto frontier suggests diminishing value above that range

## Limitations
- CPI-adjustment step is scripted but not yet independently verified (see Known Gaps)
- Team-seasons under 7.5 WAR are dropped from the CE+ metric ($/WAR is unstable near WAR = 0)
- Dead/injured payroll tracking from Spotrac is sparse before 2013, understating early-era injury spending
- WAR source (FanGraphs) and payroll source (Spotrac) are both third-party scrapes/pulls, not official league data

## Reproducing This
1. Load `data/all_batting.csv`, `data/all_pitching.csv`, `data/spotrac_payrolls.csv`, and `data/CPI-U Data 2011-2025.csv` (as `cpi_data`) as tables in a database
2. Run `sql/CE_data_cleaning.sql` end to end, including the `efficiency_final` view
3. Export `efficiency_final` to CSV (see export line at the bottom of the SQL file) and diff against `data/Efficiency_Final.csv`
4. Run `notebooks/CE Analysis.ipynb` (uses `data/Teams.csv` for W/L only, from a one-time Lahman DB restore not included here)

## Known Gaps / TODO
- CPI-adjustment step is scripted (`efficiency_final` view in `sql/CE_data_cleaning.sql`) and spot-checked against the committed `Efficiency_Final.csv` (payroll figures match within ~$25 on multi-million dollar values, $/WAR within $1 - rounding noise, not a logic discrepancy), but not yet verified end-to-end inside a live database run

## Not Included
- `lahman2025.bak` - full raw Lahman DB backup (SQL Server format, ~47MB)
- `Salaries (Early).csv` - raw Lahman player-salary export (1985-2016); unused in the final analysis (see Known Gaps)
- `mlb_payrolls (Recent).csv` - earlier Spotrac pull, same columns as `spotrac_payrolls.csv` plus Wins/Losses/Postseason, but only 2011-2024 (vs. 2011-2025) and values don't match exactly between the two for the same team-year; superseded, and its W/L/Postseason columns are unused anyway since the notebook sources W/L from `Teams.csv` instead
- `archive.zip` - contains an older `mlb_payrolls.csv`, superseded by the above
- `price_of_a_win_dashboard_1.html` - standalone interactive dashboard, kept local only

## Sources
- Lahman Baseball Database
- FanGraphs (WAR)
- Spotrac (payroll breakdowns)
- BLS CPI-U (inflation adjustment)
