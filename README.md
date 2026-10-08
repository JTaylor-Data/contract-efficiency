# Contract Efficiency+ (CE+)

An analysis of MLB payroll efficiency, 2011-2025: which teams get the most
wins-above-replacement per inflation-adjusted dollar, and how that's changed
over time.

## Pipeline

1. **`sql/CE_data_cleaning.sql`** - run against a database loaded with the
   Lahman baseball database (`salaries`, `teams`) plus `all_batting`/
   `all_pitching` and `spotrac_payrolls` tables. Builds team-code crosswalks
   between Lahman IDs and standard abbreviations, a `team_total_war` view
   (batting WAR + pitching WAR per team-season), and a `total_efficiency`
   view joining WAR to Spotrac payroll data.
2. **`notebooks/WAR Concat.ipynb`** - reads `data/TeamWAR.xlsx` (one sheet
   per team-season) and concatenates it into master `all_batting.csv` /
   `all_pitching.csv` files, which feed the SQL step above.
3. **`data/Efficiency_Final.csv`** - the merged, inflation-adjusted
   (constant 2025 dollars via CPI-U) master dataset: one row per team-year
   with total/active/injured payroll and $/WAR splits. This is the direct
   input to the analysis notebook.
4. **`notebooks/CE Analysis.ipynb`** - the analysis itself, in 7 sections:
   league-wide trends, team-year efficiency quadrants, time-series $/WAR,
   dead-money regression, the **CE+ metric** (within-season standardized
   $/WAR), persistence-of-skill check, and a payroll-vs-wins Pareto frontier.

## Data

| File | Source | Used by |
|---|---|---|
| `data/Salaries (Early).csv` | Lahman DB | SQL cleaning |
| `data/Teams.csv` | Lahman DB | SQL cleaning, CE Analysis.ipynb |
| `data/TeamWAR.xlsx` | FanGraphs | WAR Concat.ipynb |
| `data/all_pitching.csv` | WAR Concat.ipynb output | SQL cleaning |
| `data/spotrac_payrolls.csv` | Spotrac | SQL cleaning |
| `data/CPI-U Data 2011-2025.csv` | BLS CPI-U | inflation adjustment into `Efficiency_Final.csv` |
| `data/Efficiency_Final.csv` | merged output | CE Analysis.ipynb |

Note: the step that merges the SQL output with CPI-U data into
`Efficiency_Final.csv` isn't captured in a saved script/notebook.

## Not included

- `lahman2025.bak` - the full raw Lahman DB backup (SQL Server format,
  ~47MB). Restore it yourself to reproduce `sql/CE_data_cleaning.sql`.
- `mlb_payrolls (Recent).csv`, `archive.zip` - earlier/alternate payroll
  pulls superseded by `spotrac_payrolls.csv`.
