
-- Split column City_Country on City and Country in Crime Index table

select *
from [Cities Ranking]..['Crime Index']


alter table [Cities Ranking]..['Crime Index']
add City nvarchar(255), Country nvarchar(255)


update [Cities Ranking]..['Crime Index']
set City = case
when charindex(',', substring(City_Country, charindex(',', City_Country) + 1, len(City_Country))) > 0 then PARSENAME(replace(City_Country, ',', '.'), 3)
else PARSENAME(replace(City_Country, ',', '.'), 2)
end
from [Cities Ranking]..['Crime Index']


update [Cities Ranking]..['Crime Index']
set Country = SUBSTRING(PARSENAME(replace(City_Country, ',', '.'), 1), 2, LEN(City_Country))
from [Cities Ranking]..['Crime Index']


alter table [Cities Ranking]..['Crime Index']
drop column City_Country



-- Split City_Country column on City and Country in Pollution Index table

select *
from [Cities Ranking]..['Pollution Index']


alter table [Cities Ranking]..['Pollution Index']
add City nvarchar(255), Country nvarchar(255)


update [Cities Ranking]..['Pollution Index']
set City = case
when charindex(',', substring(City_Country, charindex(',', City_Country) + 1, len(City_Country))) > 0 then PARSENAME(replace(City_Country, ',', '.'), 3)
else PARSENAME(replace(City_Country, ',', '.'), 2)
end
from [Cities Ranking]..['Pollution Index']


update [Cities Ranking]..['Pollution Index']
set Country = SUBSTRING(PARSENAME(replace(City_Country, ',', '.'), 1), 2, LEN(City_Country))
from [Cities Ranking]..['Pollution Index']


alter table [Cities Ranking]..['Pollution Index']
drop column City_Country



-- Split City_Country column on City and Country in Quality of Life Index table

select *
from [Cities Ranking]..['Quality of Life Index']


alter table [Cities Ranking]..['Quality of Life Index']
add City nvarchar(255), Country nvarchar(255)


update [Cities Ranking]..['Quality of Life Index']
set City = case
when charindex(',', substring(City_Country, charindex(',', City_Country) + 1, len(City_Country))) > 0 then PARSENAME(replace(City_Country, ',', '.'), 3)
else PARSENAME(replace(City_Country, ',', '.'), 2)
end
from [Cities Ranking]..['Quality of Life Index']


update [Cities Ranking]..['Quality of Life Index']
set Country = SUBSTRING(PARSENAME(replace(City_Country, ',', '.'), 1), 2, LEN(City_Country))
from [Cities Ranking]..['Quality of Life Index']


alter table [Cities Ranking]..['Quality of Life Index']
drop column City_Country



-- Split City_Country column on City and Country in Sunshine hours by City table

select *
from [Cities Ranking]..['sunshine hours by city']


alter table [Cities Ranking]..['sunshine hours by city']
add ['Sunshine Index by City'] float


alter table [Cities Ranking]..['sunshine hours by city']
add ['Sunshine Index by Country'] float


update [Cities Ranking]..['sunshine hours by city']
set ['Sunshine Index by City'] = round(Year/12 ,2)
from [Cities Ranking]..['sunshine hours by city']


select *
from [Cities Ranking]..['sunshine hours by city']
--where Country = 'Belarus'
order by Country, ['Sunshine Index by City'] desc


update [Cities Ranking]..['sunshine hours by city']
set ['Sunshine Index by Country'] = Sunshine_TemporaryTable.z
from
(
select (sum(['Sunshine Index by City']) over (partition by Country) / count(['Sunshine Index by City']) over (partition by Country)) as z, Country
from [Cities Ranking]..['sunshine hours by city']
) as Sunshine_TemporaryTable
where ['sunshine hours by city'].Country = Sunshine_TemporaryTable.Country



-- Joining tables with indexes ranking as well as view creation

create view Cities_Ranking as
select a.Country, a.City, a.[Purchasing Power Index], a.[Health Care Index], a.[Property Price to Income Ratio], b.[Safety Index],
c.[Pollution Index], d.['Sunshine Index by City'],
rank() over (order by a.[Purchasing Power Index] asc) as rank1,
rank() over (order by a.[Health Care Index] asc) as rank2, 
rank() over (order by a.[Property Price to Income Ratio] desc) as rank3,
rank() over (order by b.[Safety Index] asc) as rank4,
rank() over (order by c.[Pollution Index] desc) as rank5,
rank() over (order by d.['Sunshine Index by City'] asc) as rank6,

(rank() over (order by a.[Purchasing Power Index] asc) +
rank() over (order by a.[Health Care Index] asc) + 
rank() over (order by a.[Property Price to Income Ratio] desc) +
rank() over (order by b.[Safety Index] asc) +
rank() over (order by c.[Pollution Index] desc) +
rank() over (order by d.['Sunshine Index by City'] desc)) as TotalRank

from [Cities Ranking]..['Quality of Life Index'] a
inner join [Cities Ranking]..['Crime Index'] b
on a.City = b.City and a.Country = b.Country
inner join [Cities Ranking]..['Pollution Index'] c
on b.City = c.City and b.Country = c.Country
inner join [Cities Ranking]..['sunshine hours by city'] d
on c.City = d.City and c.Country = d.Country
--where d.['Sunshine Index by City'] > 200 and a.[Purchasing Power Index] > 70
--order by TotalRank desc