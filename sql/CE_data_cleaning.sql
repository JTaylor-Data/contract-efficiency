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
select w."Team", w."Year", w."total_war", sp."Total_Payroll_Allocations"
from team_total_war w
join spotrac_payrolls sp on w."Team" = sp."Team" and w."Year" = sp."Year"; 

