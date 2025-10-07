/* Voorbeeld SQL script om de gegevens op te halen uit EduArte
Oorspronkelijk auteur: Albeda / Hibo Musse
*/

SELECT DISTINCT ct.naam as cohort,
 d.deelnemernummer,
  v.volgnummer, 
-- vooropleiding mbo behaalde diploma
rm.brin,
rm.opleidingcode, 
g.eindcijfer,
g.codegeneriekexamenonderdeel ,
rm.datumuitslag
FROM verbintenis v
inner join cohort ct on ct.BEGINDATUM <= V.BEGINDATUM and ct.EINDDATUM >= V.BEGINDATUM
LEFT JOIN deelnemer d ON d.id = v.DEELNEMER
LEFT JOIN persoon p ON p.id = d.persoon
left join REDENUITSCHRIJVING r on r.id=v.REDENUITSCHRIJVING
INNER JOIN organisatieeenheid oe ON v.ORGANISATIEEENHEID = oe.id
INNER JOIN organisatieeenheid oep ON OE.PARENT = oep.id
INNER JOIN organisatieeenheid oegp ON OEP.PARENT = oegp.id
INNER JOIN opleiding o ON v.opleiding = o.id   
INNER JOIN opleidingcohort oc ON v.cohort = oc.cohort AND v.opleiding = oc.opleiding
INNER JOIN taxonomieelement te ON OC.VERBINTENISGEBIED = te.id
LEFT JOIN plaats pl ON p.GEBOORTEGEMEENTE = pl.id
LEFT JOIN VOOROPLEIDINGDUO vd ON vd.deelnemer = d.id 
LEFT JOIN RESULTAATMBODUO rm ON rm.VOOROPLEIDINGDUO = vd.id
INNER JOIN GENERIEKEXAMENONDERDEELDUO g ON g.DIPLOMAMBO = rm.id
WHERE te.BEROEPSOPLEIDINGID in ('bc113','bc310','bc350') and  ct.naam IN ('2015/2016', '2016/2017', '2017/2018', '2018/2019') and v.status in ('Definitief','Beeindigd','Volledig','Afgedrukt')
and rm.DATUMUITSLAG <= ct.BEGINDATUM 