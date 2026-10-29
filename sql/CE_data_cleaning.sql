SELECT "Year", COUNT(*) 
FROM spotrac_payrolls sp 
GROUP BY "Year"
ORDER BY "Year";

SELECT DISTINCT "Team" FROM spotrac_payrolls sp  ORDER BY "Team";

select "Team","Year", "WAR"
from all_pitching ap 
limit 10;

select *
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

create view total_efficiency as
select w."Team", w."Year", w."total_war",
       sp."Total_Payroll_Allocations" as total_payroll_nominal,
       sp."Active_26_Man" as active_payroll_nominal,
       sp."Injured" as injured_payroll_nominal
from team_total_war w
join spotrac_payrolls sp on w."Team" = sp."Team" and w."Year" = sp."Year";

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

