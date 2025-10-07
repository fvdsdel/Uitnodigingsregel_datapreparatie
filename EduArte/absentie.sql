/* Voorbeeld SQL script om de gegevens op te halen uit EduArte
Oorspronkelijk auteur: Albeda / Hibo Musse
*/
-- let op 4 periodes in jaar.

SELECT d.deelnemernummer, v.volgnummer, ct.naam as cohort,
       SUM(CASE WHEN DATEPART(WEEK, a.BEGINDATUMTIJD) BETWEEN 34 AND 45 THEN 1 ELSE 0 END) AS periode_1,
       SUM(CASE WHEN (DATEPART(WEEK, a.EINDDATUMTIJD) BETWEEN 1 AND 4) OR ((DATEPART(WEEK, a.BEGINDATUMTIJD) BETWEEN 46 AND 53) AND (YEAR(a.BEGINDATUMTIJD) <> YEAR(ct.EINDDATUM))) THEN 1 ELSE 0 END) AS periode_2,
       SUM(CASE WHEN DATEPART(WEEK, a.BEGINDATUMTIJD) BETWEEN 5 AND 15 THEN 1 ELSE 0 END) AS periode_3,
       SUM(CASE WHEN DATEPART(WEEK, a.BEGINDATUMTIJD) BETWEEN 16 AND 28 THEN 1 ELSE 0 END) AS periode_4,
       count(DISTINCT a.id) as absentie_ids
FROM verbintenis v
left join cohort ct on ct.BEGINDATUM <= V.BEGINDATUM and ct.EINDDATUM >= V.BEGINDATUM
LEFT JOIN DEELNEMER d ON d.id = v.DEELNEMER
LEFT JOIN ABSENTIEMELDING a ON a.DEELNEMER = d.ID
JOIN opleidingcohort oc ON v.cohort = oc.cohort AND v.opleiding = oc.opleiding
JOIN taxonomieelement te ON OC.VERBINTENISGEBIED = te.id
WHERE  te.BEROEPSOPLEIDINGID in ('bc113','bc310','bc350') and  ct.naam IN ('2015/2016', '2016/2017', '2017/2018', '2018/2019') and v.status in ('Definitief','Beeindigd','Volledig','Afgedrukt')
  AND a.BEGINDATUMTIJD BETWEEN ct.begindatum AND ct.einddatum
GROUP BY d.deelnemernummer, v.volgnummer, ct.naam

