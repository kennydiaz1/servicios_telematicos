;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	diazmunoz2024.com. root.diazmunoz2024.com. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns.diazmunoz2024.com.
ns	IN	A	192.168.50.3
esclavo IN 	A	192.168.50.2
visitante 	IN 	CNAME esclavo
maestro	IN	CNAME	ns
server IN	CNAME	ns
www	IN	CNAME	ns
mail	IN	CNAME	ns

