unload
(
$$select distinct
coalesce(pickup_date , rev_recognition_date )as "Shipment Date Time",
s.file_nbr as "Shipment#",
s.handling_stn "Handling Station",
s.house_bill_nbr "AirBill",
shipper_name as "Shipper Name",
consignee_name as "Consignee Name",
origin_port_iata as "Origin Port",
destination_port_iata as "Destination Port",
s.shipper_cntry "Shipper Country",
s.consignee_cntry "Consignee Country",
billtoref.billto_Ref as "BillTo Ref#",
shipref.shipper_Ref as "Shipper Ref#",
Pieces as "Total Pieces",
chrg_wght_lbs as "Chargeable Weight",
description as "Description",
s.schd_delv_Date as "Scheduled Date Time",
(DATEDIFF('day', rev_recognition_date,pod_Date))
-(DATEDIFF('week',rev_recognition_date,pod_Date) * 2)
-(CASE WHEN DATE_PART(dow, pod_Date) = 0 THEN 1 ELSE 0 END)
-(CASE WHEN DATE_PART(dow, rev_recognition_date) = 6 THEN 1 ELSE 0 END) AS Transit_Days,

service_level as "Service",
pod_name as "PODName",
pod_date as "PODDateTime",
invoice.Invoice_total as "Total Charges",
insurance as "Insurance Amount"

from shipment_info s
left outer join
(select source_system ,file_nbr, sum(total) as Invoice_total from ar_invoice_receivables
group by source_system ,file_nbr
)Invoice
on s.source_system = invoice.source_system
and s.file_nbr = invoice.file_nbr
left outer join
(select SOURCE_system,file_nbr,listagg(ref_nbr,' ,') within group (order by pk_ref_nbr) as shipper_Ref
from shipment_Ref
where customer_type = 'S'
group by source_system,file_nbr
)shipref
on s.source_system = shipref.source_system
and s.file_nbr = shipref.file_nbr
left outer join
(select SOURCE_system,file_nbr,listagg(ref_nbr,' ,') within group (order by pk_ref_nbr) as Billto_Ref
from shipment_Ref
where customer_type = 'B'
group by source_system,file_nbr
)billtoref
on s.source_system = billtoref.source_system
and s.file_nbr = billtoref.file_nbr
left outer join
(select SOURCE_system,file_nbr,listagg(ref_nbr,' ,') within group (order by pk_ref_nbr) as consignee_Ref
from shipment_Ref
where customer_type = 'C'
group by source_system,file_nbr
)conref
on s.source_system = conref.source_system
and s.file_nbr = conref.file_nbr
where --s.file_nbr = '3618538'
bill_to_nbr = '16461'
and coalesce(pickup_date , rev_recognition_date ) >= CURRENT_DATE -30
$$
)
TO 's3://omni-report-email/csv-report-starry/report.csv'
iam_role 'arn:aws:iam::332281781429:role/dms-access-for-endpoint' 
ALLOWOVERWRITE
PARALLEL OFF
CSV
HEADER