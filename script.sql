unload
(
$$select distinct
s.file_nbr ,
shipment_date ,house_bill_nbr ,service_level ,shipper_name ,consignee_name ,
concat(consignee_addr_1 ,consignee_addr_2 )address,consignee_city ,consignee_zip ,
consignee_st ,origin_port_iata ,destination_port_iata ,current_status ,
shipref.shipper_Ref,conref.consignee_Ref,billtoref.billto_Ref,
pieces ,description ,actual_wght_lbs ,chrg_wght_lbs ,
pod_date ,pod_name ,invoice.Invoice_total
from shipment_info s
left outer join
(select source_system ,file_nbr, sum(total) as Invoice_total from ar_invoice_receivables
group by source_system ,file_nbr
)Invoice
on s.source_system = invoice.source_system
and s.file_nbr = invoice.file_nbr
left outer join
(select SOURCE_system,file_nbr,ref_nbr as shipper_Ref
from shipment_Ref
where customer_type = 'S'
)shipref
on s.source_system = shipref.source_system
and s.file_nbr = shipref.file_nbr
left outer join
(select SOURCE_system,file_nbr,ref_nbr as Billto_Ref
from shipment_Ref
where customer_type = 'B'
)billtoref
on s.source_system = billtoref.source_system
and s.file_nbr = billtoref.file_nbr
left outer join
(select SOURCE_system,file_nbr,ref_nbr as consignee_Ref
from shipment_Ref
where customer_type = 'C'
)conref
on s.source_system = conref.source_system
and s.file_nbr = conref.file_nbr
where bill_to_nbr = '15950'
$$
)
TO 's3://omni-report-email/csv-report/report.csv'
iam_role 'arn:aws:iam::332281781429:role/dms-access-for-endpoint' 
ALLOWOVERWRITE
PARALLEL OFF
CSV
HEADER