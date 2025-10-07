/* Voorbeeld SQL script om de gegevens op te halen uit EduArte
Oorspronkelijk auteur: Albeda / Hibo Musse
*/
  
SELECT distinct 
ct.naam as cohort,
d.deelnemernummer,
v.volgnummer,
v.begindatum,
v.einddatum,
-- persoonlijke gegevens
DATEDIFF(YEAR, p.geboortedatum, ct.BEGINDATUM) AS leeftijd,
p.geslacht,
--opleiding
o.leerweg,
te.externecode as crebo,
te.naam,
CASE WHEN v.MBONIVEAU IS NULL THEN te.niveau ELSE v.mboniveau END AS niveau,
te.BEROEPSOPLEIDINGID,
--uitgevallen
case when v.EINDDATUM < ct.EINDDATUM then 1 else 0 end as uitgevallen_eerste_jaar
FROM verbintenis v
left join opleiding o on o.id=v.opleiding
left join cohort ct on ct.BEGINDATUM <= V.BEGINDATUM and ct.EINDDATUM >= V.BEGINDATUM
left JOIN deelnemer d ON d.id = v.DEELNEMER
left JOIN persoon p ON p.id = d.persoon
join REDENUITSCHRIJVING r on r.id=v.REDENUITSCHRIJVING
JOIN opleidingcohort oc ON v.cohort = oc.cohort AND v.opleiding = oc.opleiding
JOIN taxonomieelement te ON OC.VERBINTENISGEBIED = te.id
WHERE  te.BEROEPSOPLEIDINGID in ('bc113','bc310','bc350') and  ct.naam IN ('2015/2016', '2016/2017', '2017/2018', '2018/2019') and v.status in ('Definitief','Beeindigd','Volledig','Afgedrukt')
