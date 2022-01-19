create materialized view bgc_phyto_aggregation as
select taxon_name, count(*) as aggr_count, round(sum(biovolume_um3l),3) as aggr_abundance
from bgc_phyto_raw
group by taxon_name