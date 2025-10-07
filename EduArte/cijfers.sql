/* Voorbeeld SQL script om de gegevens op te halen uit EduArte
Oorspronkelijk auteur: Albeda / Hibo Musse
*/
-- Let op, 4 periodes in jaar.

SELECT distinct ct.naam as cohort, 
d.deelnemernummer, 
v.volgnummer,
       AVG(CASE WHEN DATEPART(WEEK, r.datumbehaald) BETWEEN 34 AND 45 THEN r.cijfer END) AS periode_1_gemiddelde,
       AVG(CASE WHEN (DATEPART(WEEK, r.datumbehaald) BETWEEN 1 AND 4) OR ((DATEPART(WEEK, r.datumbehaald) BETWEEN 46 AND 53) AND (YEAR(r.datumbehaald) <> YEAR(ct.EINDDATUM))) THEN r.cijfer END) AS periode_2_gemiddelde,
       AVG(CASE WHEN DATEPART(WEEK, r.datumbehaald) BETWEEN 5 AND 15 THEN r.cijfer END) AS periode_3_gemiddelde,
       AVG(CASE WHEN DATEPART(WEEK, r.datumbehaald) BETWEEN 16 AND 28 THEN r.cijfer END) AS periode_4_gemiddelde
FROM verbintenis v
INNER JOIN DEELNEMER d ON d.id = v.DEELNEMER
inner join cohort ct on ct.BEGINDATUM <= V.BEGINDATUM and ct.EINDDATUM >= V.BEGINDATUM
INNER JOIN organisatieeenheid oe ON v.organisatieeenheid = oe.id
INNER JOIN onderwijsproductafnamecontext oac ON oac.verbintenis = v.id 
INNER JOIN onderwijsproductafname oa ON oac.onderwijsproductafname = oa.id 
INNER JOIN onderwijsproduct op ON oa.onderwijsproduct = op.id
INNER JOIN SOORTONDERWIJSPRODUCT sop ON op.soortproduct = sop.id
INNER JOIN productregel pr ON oac.productregel = pr.id
INNER JOIN soortproductregel spr ON pr.soortproductregel = spr.id 
LEFT JOIN resultaatstructuur rs ON rs.onderwijsproduct = op.id
LEFT JOIN toets t ON t.resultaatstructuur = rs.id AND t.parent IS NULL
LEFT JOIN resultaat r on r.toets=t.id
INNER JOIN opleiding o ON v.opleiding = o.id   
INNER JOIN opleidingcohort oc ON v.cohort = oc.cohort AND v.opleiding = oc.opleiding
INNER JOIN taxonomieelement te ON OC.VERBINTENISGEBIED = te.id
WHERE pr.opleiding = v.opleiding and r.datumbehaald BETWEEN ct.begindatum AND ct.einddatum and r.geldend = 1 and  te.BEROEPSOPLEIDINGID in ('bc113') and  ct.naam IN ('2017/2018') and v.status in ('Definitief','Beeindigd','Volledig','Afgedrukt')
GROUP BY d.deelnemernummer, v.volgnummer, ct.naam
