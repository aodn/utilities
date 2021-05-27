create materialized view bgc_zoop_aggregation as
select taxon_name, count(*) as aggr_count, round(sum(zoop_abundance_m3),3) as aggr_abundance
from bgc_zoop_raw
group by taxon_name