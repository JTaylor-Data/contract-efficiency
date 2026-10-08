SELECT * 
FROM salaries 
LIMIT 10;

create table team_payrolls as
select "teamID", "yearID", SUM(salary) as total_payroll
from salaries 
group by "yearID", "teamID"
order by "yearID" desc, total_payroll desc;

CREATE TABLE team_crosswalk (
    lahman_id TEXT,
    standard_id TEXT);
insert into team_crosswalk (lahman_id, standard_id) values
('NYA', 'NYY'),
('NYN', 'NYM'),
('LAN', 'LAD'),
('SFN', 'SFG'),
('CHN', 'CHC'),
('SLN', 'STL'),
('WAS', 'WSN'),
('KCA', 'KCR'),
('CHA', 'CHW'),
('SDN', 'SDP'),
('TBA', 'TBR'),
('FLO', 'MIA'),
('ML4', 'MIL'),
('CAL', 'LAA'),
('MON', 'WSN'),
('OAK', 'ATH'),
('ANA', 'LAA'),
('TBD', 'TBR')

SELECT "Year", COUNT(*) 
FROM spotrac_payrolls sp 
GROUP BY "Year"
ORDER BY "Year";

SELECT DISTINCT "Team" FROM spotrac_payrolls sp  ORDER BY "Team";

select "Team", "Year", "WAR"
from all_batting
limit 10;

select "Team","Year", "WAR"
from all_pitching ap 
limit 10;

select *
from all_batting b
join all_pitching p on b."Team" = p."Team" and b."Year" = p."Year";

select b."Team", b."Year", (b."WAR" + p."WAR") as total_WAR
from all_batting b
join all_pitching p on b."Team" = p."Team" and b."Year" = p."Year";

UPDATE all_batting SET "Team" = 'LAA' WHERE "Team" = 'ANA';
UPDATE all_batting SET "Team" = 'ATH' WHERE "Team" = 'OAK';
UPDATE all_batting SET "Team" = 'WSN' WHERE "Team" = 'MON';
UPDATE all_batting SET "Team" = 'MIA' WHERE "Team" = 'FLA';
UPDATE all_batting SET "Team" = 'TBR' WHERE "Team" = 'TBD';

UPDATE all_pitching SET "Team" = 'LAA' WHERE "Team" = 'ANA';
UPDATE all_pitching SET "Team" = 'ATH' WHERE "Team" = 'OAK';
UPDATE all_pitching SET "Team" = 'WSN' WHERE "Team" = 'MON';
UPDATE all_pitching SET "Team" = 'MIA' WHERE "Team" = 'FLA';
UPDATE all_pitching SET "Team" = 'TBR' WHERE "Team" = 'TBD';

select b."Team", b."Year", (b."WAR" + p."WAR") as total_WAR
from all_batting b
join all_pitching p on b."Team" = p."Team" and b."Year" = p."Year";

CREATE VIEW team_total_war AS
SELECT b."Team", b."Year", ROUND((b."WAR" + p."WAR")::NUMERIC, 1) AS total_war
FROM all_batting b
JOIN all_pitching p ON b."Team" = p."Team" AND b."Year" = p."Year";

SELECT "Year", COUNT(*) AS team_count
FROM team_total_war
GROUP BY "Year"
ORDER BY "Year";

create view total_efficiency as
select w."Team", w."Year", w."total_war",
       sp."Total_Payroll_Allocations" as total_payroll_nominal,
       sp."Active_26_Man" as active_payroll_nominal,
       sp."Injured" as injured_payroll_nominal
from team_total_war w
join spotrac_payrolls sp on w."Team" = sp."Team" and w."Year" = sp."Year";

-- ============================================================
-- CPI-adjustment -> Efficiency_Final
-- ============================================================
-- Requires a `cpi_data` table loaded from `data/CPI-U Data 2011-2025.csv`
-- (columns: "Year" INTEGER, cpi_value NUMERIC).
--
-- Converts nominal payroll into constant 2025 dollars:
--   real = nominal * (CPI_2025 / CPI_year)
-- then recomputes $/WAR on the inflation-adjusted dollars.
-- Verified against Efficiency_Final.csv's existing ATH/2024 row
-- (nominal $63,503,127 -> real $65,176,042 using this exact formula).

create view efficiency_final as
with base as (
    select cpi_value as base_cpi from cpi_data where "Year" = 2025
)
select
    te."Team",
    te."Year",
    round(te.total_payroll_nominal   * (base.base_cpi / cpi.cpi_value)) as total_payroll_real,
    round(te.active_payroll_nominal  * (base.base_cpi / cpi.cpi_value)) as active_payroll_real,
    round(te.injured_payroll_nominal * (base.base_cpi / cpi.cpi_value)) as injured_payroll_real,
    te."total_war",
    round(te.total_payroll_nominal   * (base.base_cpi / cpi.cpi_value) / te."total_war") as total_dollar_per_war,
    round(te.active_payroll_nominal  * (base.base_cpi / cpi.cpi_value) / te."total_war") as active_dollar_per_war,
    round(te.injured_payroll_nominal * (base.base_cpi / cpi.cpi_value) / te."total_war") as injured_dollar_per_war
from total_efficiency te
join cpi_data cpi on cpi."Year" = te."Year"
cross join base;

-- Export, e.g.: \copy (select * from efficiency_final order by "Team", "Year") to 'Efficiency_Final_rebuilt.csv' with csv header
