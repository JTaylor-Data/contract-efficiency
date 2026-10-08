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
  TeamWAR.xlsx
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
- Lahman DB (`lahman2025.bak`, restored by hand, archived not in repo) -> `sql/CE_data_cleaning.sql`
  - `salaries` / `team_payrolls` / `team_crosswalk`: built in the SQL script but **not used downstream** - Spotrac covers the full 2011-2025 window, so Lahman salary data is dead weight for this analysis (see Known Gaps)
  - `teams` (-> `data/Teams.csv`): the one Lahman table actually used, for `franchID`/`yearID`/`W`/`L` only
- `data/TeamWAR.xlsx` -> `notebooks/WAR Concat.ipynb` -> `all_batting.csv` / `all_pitching.csv`
- SQL cleaning output + CPI-U adjustment -> `data/Efficiency_Final.csv` (merge step not scripted - see Known Gaps)
- `data/Efficiency_Final.csv` + `data/Teams.csv` (W/L only) -> `notebooks/CE Analysis.ipynb` -> findings

## Data Lineage

| File | Source | Produced by | Consumed by |
|---|---|---|---|
| `data/Teams.csv` | Lahman DB | Lahman restore | CE Analysis.ipynb (`franchID`, `yearID`, `W`, `L` only) |
| `data/TeamWAR.xlsx` | FanGraphs (manual pull) | - | WAR Concat.ipynb |
| `data/all_pitching.csv` (+ `all_batting.csv`) | FanGraphs via TeamWAR.xlsx | WAR Concat.ipynb | SQL cleaning |
| `data/spotrac_payrolls.csv` | Spotrac (manual pull) | - | SQL cleaning |
| `data/CPI-U Data 2011-2025.csv` | BLS CPI-U | - | Efficiency_Final.csv merge (undocumented) |
| `data/Efficiency_Final.csv` | merged SQL output + CPI-U | **missing/unscripted step** | CE Analysis.ipynb |

## The CE+ Metric
- Base measure: $/WAR (total payroll / total team WAR), per team-season
- Standardized within-season: 100 = that season's league average
- 1 standard deviation = 15 points
- Inverted so higher CE+ = more efficient (fewer dollars per win)
- Floor: team-seasons with total WAR < 7.5 excluded ($/WAR explodes near WAR = 0)

## Findings
- Gap between total and active $/WAR widened post-2020 (~$1.48M/WAR pre-2020 vs ~$1.86M/WAR after)
- League-wide injury payroll has risen sharply over the last 5 years
- Quadrant leaders: cheap-and-good teams (e.g. PIT, MIA) are efficient but not consistent winners
- Quadrant laggards: LAA is the league's worst by efficiency - high spend, low return, across nine seasons
- Expensive-and-good quadrant dominated by NYY and LAD
- Dead-money regression: payroll + dead-money% explain wins, R² = 0.362
- Payroll + CE+ regression explains wins better, R² = 0.648
- Persistence: CE+ this year vs. next year correlation = 0.57 (moderate - some repeatable skill)
- Pareto frontier: payroll-to-wins relationship bends/flattens around $80-120M

## Reproducing This
1. Restore `lahman2025.bak` into a database (not included - SQL Server backup, ~47MB)
2. Load `all_batting`/`all_pitching` (via `notebooks/WAR Concat.ipynb` output) and `spotrac_payrolls.csv` as tables in the same database
3. Run `sql/CE_data_cleaning.sql`
4. Merge SQL output with `data/CPI-U Data 2011-2025.csv` to produce `data/Efficiency_Final.csv` (step not currently scripted - see Known Gaps)
5. Run `notebooks/CE Analysis.ipynb`

## Known Gaps / TODO
- CPI-U merge / inflation-adjustment step into `Efficiency_Final.csv` is not captured in any script or notebook
- `all_batting.csv` (produced by `WAR Concat.ipynb`) is not retained in this repo
- `salaries` / `team_payrolls` / `team_crosswalk` built in `sql/CE_data_cleaning.sql` are dead code - never consumed downstream, since Spotrac already covers the full 2011-2025 analysis window

## Not Included
- `lahman2025.bak` - full raw Lahman DB backup (SQL Server format, ~47MB)
- `Salaries (Early).csv` - raw Lahman player-salary export (1985-2016); unused in the final analysis (see Known Gaps)
- `mlb_payrolls (Recent).csv`, `archive.zip` - earlier/alternate payroll pulls superseded by `spotrac_payrolls.csv`
- `price_of_a_win_dashboard_1.html` - standalone interactive dashboard, kept local only

## Sources
- Lahman Baseball Database
- FanGraphs (WAR)
- Spotrac (payroll breakdowns)
- BLS CPI-U (inflation adjustment)
