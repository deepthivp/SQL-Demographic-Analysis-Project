select * from Dataset1toimport
select * from Dataset2toimport

--Total no.of Rows
select COUNT(*) from Dataset1toimport
select COUNT(*) from Dataset2toimport

--Dataset for Kerala and Karnataka
select * from Dataset1toimport where State in ('Kerala','Karnataka')

--Population of India
Select SUM(Population) as 'Total Population of India' from Dataset2toimport

--Average Growth of India and State
Select AVG(Growth)*100 As 'Average Growth' from Dataset1toimport
Select State, AVG(Growth)*100 As 'Average Growth' from Dataset1toimport group by State

--Average Sex Ratio
Select State, AVG(Sex_Ratio) As 'Average Sex ratio' from Dataset1toimport group by State
Select State, AVG(Sex_Ratio) As 'Average Sex ratio' from Dataset1toimport group by State order by 'Average Sex ratio' 

--Average Literacy Rate
Select State, round(Avg(Literacy),0) AS 'Avg Literacy' from Dataset1toimport group by State having round(Avg(Literacy),0)>=90 order by round(Avg(Literacy),0) 


Select Top 3 State, round(AVG(Growth)*100, 0) As 'Average Growth' from Dataset1toimport group by State order by 'Average Growth'desc

--Bottom 3 States for Lowest Sex ratio
select top 3 State, Avg(Sex_Ratio) As 'Avg Sex Ratio' from Dataset1toimport group by State order by 'Avg Sex Ratio' asc

--Top 3 States in Literacy Rate

drop table if exists #topstates
create table #topstates
(
State nvarchar(50),
#topstate  float
)
insert into #topstates
select State, ROUND(avg(Literacy),0) as 'Avg Literacy' from Dataset1toimport group by State order by 'Avg Literacy'
select top 3 * from #topstates order by #topstate desc

--Bottom 3 States in Literacy Rate
drop table if exists #bottomstates
create table #bottomstates
(
State nvarchar(50),
#bottomstate  float
)
insert into #bottomstates
select State, ROUND(avg(Literacy),0) as 'Avg Literacy' from Dataset1toimport group by State order by 'Avg Literacy'desc
select top 3 * from #bottomstates order by #bottomstate

--Union Operator
select * from(select top 3 * from #bottomstates order by #bottomstate) a
union
select * from (select top 3 * from #topstates order by #topstate desc) b

--States starting with letter 'a' or 'b'
select distinct State from Dataset1toimport where lower(State) like 'a%'or LOWER(State) like 'b%'

--States starting with letter 'a' or ending with'd'
select distinct State from Dataset1toimport where lower(State) like 'a%'or LOWER(State) like '%d'

--States starting with letter 'a' or ending with'm'
select distinct State from Dataset1toimport where lower(State) like 'a%'and LOWER(State) like '%m'

--Joining both table
select a.District, a.State,round((a.Sex_Ratio/1000),3), b.Population from Dataset1toimport a
inner join Dataset2toimport b
on a.District = b.District

/* females/males= Sex_Ratio ----1
females+males= Population ----2
females = Population - males  ----3
(Population - males) = (Sex_Ratio) * males
Population = ((Sex_Ratio) * males) + males
Population = males(Sex_Ratio+1) 
males = Population/(Sex_Ratio+1) ---males
females =  Population - (Population/(Sex_Ratio+1))
		=Population(1-1/(Sex_Ratio+1))
		=(Population*Sex_Ratio)/(Sex_Ratio+1)
		*/
--Finding no. of Males and Females
select c.District, c.State,round((c.Population/(c.Sex_Ratio+1)),0) Males, round((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) Females from 
(select a.District, a.State, a.Sex_Ratio/1000 Sex_Ratio, b.Population from Dataset1toimport a
inner join Dataset2toimport b
on a.District=b.District) c

--Finding no. of Males and Females by States
select d.State, sum(d.Males) TotalMales,sum(d.Females) TotalFemales from 
(select c.District, c.State,round((c.Population/(c.Sex_Ratio+1)),0) Males, round((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) Females from 
(select a.District, a.State, a.Sex_Ratio/1000 Sex_Ratio, b.Population from Dataset1toimport a
inner join Dataset2toimport b
on a.District=b.District) c) d group by d.State

--Total Literacy Ratio
select a.District,a.State,a.Literacy/100 Literacy_Ratio,b.Population from Dataset1toimport a
inner join Dataset2toimport b
on a.District=b.District
/*
Total Literate People/Population = Literacy Ratio
Total Literate People=Population*Literacy Ratio
Total Iliterate People=(1-Literacy Ratio)* Population
*/
select c.District,c.State,round(c.Literacy_Ratio*c.Population,0) Total_LiteratePeople , round((1-c.Literacy_Ratio)* c.Population,0) Total_IliteratePeople,c.Population from 
(select a.District,a.State,a.Literacy/100 Literacy_Ratio,b.Population from Dataset1toimport a
inner join Dataset2toimport b
on a.District=b.District)c

--Total Literacy by State
select d.State,sum(d.Total_LiteratePeople) Total_LiteratePeople, sum(d.Total_IliteratePeople) Total_IliteratePeople, sum(d.Population) Population from  
(select c.District,c.State,round(c.Literacy_Ratio*c.Population,0) Total_LiteratePeople , round((1-c.Literacy_Ratio)* c.Population,0) Total_IliteratePeople,c.Population from 
(select a.District,a.State,a.Literacy/100 Literacy_Ratio,b.Population from Dataset1toimport a
inner join Dataset2toimport b
on a.District=b.District)c)d group by d.State

--Previous_Census_Population 
select c.District,c.State, round(c.Population/(1+c.Growth),0) Previous_Census_Population,c.Population from
(select a.District,a.State,a.growth Growth, b.Population from Dataset1toimport a
inner join Dataset2toimport b
on b.District=a.District)c

--Previous_Census_Population by State
select d.State, sum(d.Previous_Census_Population) Previous_Census_Population, sum(d.Population)Population from 
(select c.State, round(c.Population/(1+c.Growth),0) Previous_Census_Population,c.Population from
(select a.District,a.State,a.growth Growth, b.Population from Dataset1toimport a
inner join Dataset2toimport b
on b.District=a.District)c)d group by State

/*Previous_Census+Growth*Previous_Census=Population
(1+Growth)Previous_Census=Population
Previous_Census=Population/(1+Growth)
*/

--Total Population of Previous year and current year
select sum(m.Previous_Census_Population) Total_Previous_Census_Population, sum(m.Current_Population) Total_Current_Population from
(select d.State, sum(d.Previous_Census_Population) Previous_Census_Population, sum(d.Population) Current_Population from 
(select c.State, round(c.Population/(1+c.Growth),0) Previous_Census_Population,c.Population from
(select a.District,a.State,a.growth Growth, b.Population from Dataset1toimport a
inner join Dataset2toimport b
on b.District=a.District)c)d group by State)m

--Population Vs Area
select sum(Area_km2) from Dataset2toimport

select '1' as 'Keyy',n.* from
(select sum(m.Previous_Census_Population) Total_Previous_Census_Population, sum(m.Current_Population) Total_Current_Population from
(select d.State, sum(d.Previous_Census_Population) Previous_Census_Population, sum(d.Population) Current_Population from 
(select c.State, round(c.Population/(1+c.Growth),0) Previous_Census_Population,c.Population from
(select a.District,a.State,a.growth Growth, b.Population from Dataset1toimport a
inner join Dataset2toimport b
on b.District=a.District)c)d group by State)m)n

select '1' as 'Keyy', f.* from 
(select sum(Area_km2) as 'Total Area' from Dataset2toimport)f

--Joining two queries
select p.*,q.* from
(select '1' as 'Keyy',n.* from
(select sum(m.Previous_Census_Population) Total_Previous_Census_Population, sum(m.Current_Population) Total_Current_Population from
(select d.State, sum(d.Previous_Census_Population) Previous_Census_Population, sum(d.Population) Current_Population from 
(select c.State, round(c.Population/(1+c.Growth),0) Previous_Census_Population,c.Population from
(select a.District,a.State,a.growth Growth, b.Population from Dataset1toimport a
inner join Dataset2toimport b
on b.District=a.District)c)d group by State)m)n)p
inner join
(select '1' as 'Keyy', f.* from 
(select sum(Area_km2) as 'Total Area' from Dataset2toimport)f)q
on q.keyy=p.keyy

--Current and Previous Population Vs Area
select 
    r.Total_Area / r.Total_Previous_Census_Population as 'Previous Population Vs Area',
	r.Total_Area / r.Total_Current_Population as 'Current Population Vs Area'
from (
    select 
        p.Total_Previous_Census_Population, 
        p.Total_Current_Population, 
        q.Total_Area
    from (
        select 
            '1' as Keyy,
            n.Total_Previous_Census_Population,
            n.Total_Current_Population 
        from (
            select 
                sum(m.Previous_Census_Population) as Total_Previous_Census_Population, 
                sum(m.Current_Population) as Total_Current_Population 
            from (
                select 
                    d.State, 
                    sum(d.Previous_Census_Population) as Previous_Census_Population, 
                    sum(d.Current_Population) as Current_Population 
                from (
                    select 
                        c.State, 
                        round(c.Population / (1 + c.Growth), 0) as Previous_Census_Population,
                        c.Population as Current_Population 
                    from (
                        select 
                            a.District,
                            a.State,
                            a.Growth,
                            b.Population 
                        from Dataset1toimport a
                        inner join Dataset2toimport b on b.District = a.District
                    ) c
                ) d 
                group by d.State
            ) m
        ) n
    ) p
    inner join (
        select 
            '1' as Keyy, 
            f.Total_Area 
        from (
            select 
                sum(Area_km2) as Total_Area 
            from Dataset2toimport
        ) f
    ) q on q.Keyy = p.Keyy
) r

--Windows function
select x.* from
(select State,District,Literacy,RANK()over(partition by State order by Literacy desc) as'Rankk'from Dataset1toimport)x
where x.Rankk in(1,2,3)order by State

