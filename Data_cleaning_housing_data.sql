-- Cleaning data in sql queries;
use portfolio;
select * from portfolio.data_cleaning;

-- standardize Date format

update data_cleaning set saledate =replace(saledate,","," ") ;
update data_cleaning set saledate = str_to_date(saledate,"%M %d %Y");

select clean from data_cleaning;

-- Populate property address data
select * from data_cleaning
order by parcelid;
select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress from data_cleaning a
join data_cleaning b on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid;

-- Breaking address into indidual columns (Address,city,state)

select substring_index(propertyaddress,",",1) as propertysplitaddress,
      substring_index(propertyaddress,",",-1) as propertysplitcity
from data_cleaning;

alter table data_cleaning add propertysplitaddress varchar(255);
update data_cleaning set propertysplitaddress = substring_index(propertyaddress,",",1);

alter table data_cleaning add propertysplitcity varchar(255);
update data_cleaning set propertysplitcity =  substring_index(propertyaddress,",",-1);


Select
substring_index(OwnerAddress, ',',1)
From Data_cleaning;
alter table data_cleaning add ownersplitaddress varchar(255);
update data_cleaning set ownersplitaddress = substring_index(owneraddress,",",1);

Select
substring_index(OwnerAddress, ',',-2)
From Data_cleaning;
alter table data_cleaning add dummy varchar(255);
update data_cleaning set dummy = substring_index(owneraddress,",",-2);

Select
substring_index(dummy, ',',1)
From Data_cleaning;
alter table data_cleaning add ownersplitcity varchar(255);
update data_cleaning set ownersplitcity = substring_index(dummy,",",1);

Select
substring_index(dummy, ',',-1)
From Data_cleaning;
alter table data_cleaning add ownersplitstate varchar(255);
update data_cleaning set ownersplitstate = substring_index(dummy,",",-1);

alter table data_cleaning drop column dummy;

-- change y and n to yes and no in "sold as vacant field"
select  distinct soldasvacant,count(soldasvacant) 
from data_cleaning
group by 1 ;

select soldasvacant, case when soldasvacant = "Y" then "Yes"
when soldasvacant = "N" then "No"
else soldasvacant
end 
from data_cleaning;

update data_cleaning set soldasvacant = case when soldasvacant = "Y" then "Yes"
when soldasvacant = "N" then "No"
else soldasvacant
end ;

-- Remove duplicates
with rownumcte as 
(
select *,row_number() over (partition by parcelid,propertyaddress,saleprice,
 saledate,legalreference order by uniqueid ) as row_num from data_cleaning
 )
delete from rownumcte
 where row_num >1;
 -- order by propertyaddress;
 
 -- Delete unused columns
 
 select * from data_cleaning;
 
 alter table  data_cleaning drop column  owneraddress;
 

