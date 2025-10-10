WITH stud_inschr AS (
SELECT 
    sinh.studentnummer
    ,tmbo.externe_code
    ,sook.niveau
    ,sook.leerweg
    ,sook.organisatieonderdeel
    ,sook.ook_nummer
    ,MIN(sinh.ingangsdatum) AS ingangsdatum
    ,MAX(sinh.afloopdatum) AS afloopdatum
    ,MIN(sinh.collegejaar) AS min_collegejaar
    ,MAX(sinh.collegejaar) AS max_collegejaar
    ,MIN(sook.afsluitdatum_ook) AS inschrijfdatum
    ,MIN(sook.cohort) AS cohort
    ,ROUND(MONTHS_BETWEEN(MAX(sinh.afloopdatum),MIN(sinh.ingangsdatum))) inschrijfduur_maanden
    ,MAX(NVL((SELECT 1 FROM ost_student_ook sook2 WHERE sook2.studentnummer = sook.studentnummer AND sook2.opleiding = sook.opleiding AND sook2.actueel_blad_filter = 'J' AND rownum=1),0)) AS actueel
    ,MAX(NVL((SELECT 1 FROM ost_student_ook sook2 WHERE sook2.studentnummer = sook.studentnummer AND sook2.opleiding = sook.opleiding AND sook2.beeindigingsreden = 'S111' AND rownum=1),0)) AS dipl
FROM ost_student_inschrijfhist sinh
    LEFT JOIN ost_student_ook sook ON (sinh.referentie_id = sook.sook_id)
    LEFT JOIN ost_opleiding_taxonomie otax ON (otax.opleiding = sinh.opleiding)
    LEFT JOIN ost_taxonomie_mbo tmbo ON (otax.tmbo_id = tmbo.tmbo_id)
WHERE 1=1
    AND sinh.referentietabel = 'sook'
    AND sook.leerweg IN ('BOL','BBL')
    AND sook.instellingstatus NOT IN ('AFGEMELD','AFGEWEZEN')
GROUP BY
    sinh.studentnummer
    ,tmbo.externe_code
    ,sook.niveau
    ,sook.leerweg
    ,sook.organisatieonderdeel
    ,sook.ook_nummer
-- Voor 2018 is de data sowieso niet betrouwbaar
HAVING MIN(sinh.collegejaar)>2018
-- Minimaal 1 maand ingeschreven
AND MONTHS_BETWEEN(MAX(sinh.afloopdatum),MIN(sinh.ingangsdatum))>=1
ORDER BY sinh.studentnummer
)

SELECT 
stud_inschr.studentnummer
,stud.geslacht
,FLOOR(MONTHS_BETWEEN(stud_inschr.ingangsdatum,stud.geboortedatum)/12) AS lftijd_aanvang
,stud_inschr.externe_code AS sopl_crebo
,NULL AS dossier --dummy waarde
,stud_inschr.leerweg
,stud_inschr.niveau
,'mbo'||TO_CHAR(stud_inschr.niveau) As mbo_niveau -- voor automatisch categorisch maken
,stud_inschr.cohort AS sopl_cohort
,stud_inschr.ingangsdatum
,EXTRACT(YEAR FROM stud_inschr.ingangsdatum) -1 + FLOOR(EXTRACT(MONTH FROM stud_inschr.ingangsdatum)/8) AS startjaar
,stud_inschr.afloopdatum
,stud_inschr.organisatieonderdeel AS team
,(SELECT bovenliggend_onderdeel FROM ost_organisatieonderdeel WHERE organisatieonderdeel = stud_inschr.organisatieonderdeel AND rownum=1) AS college
,stud_inschr.inschrijfdatum
,stud_inschr.inschrijfduur_maanden
,stud_inschr.actueel AS actuele_ook
,stud_inschr.dipl AS diploma
,DECODE(actueel+dipl,0,1,0) AS uitval
,DECODE(actueel+dipl+FLOOR(stud_inschr.inschrijfduur_maanden/12),0,1,0) AS uitval_j1
FROM stud_inschr
LEFT JOIN ost_student stud ON (stud.studentnummer = stud_inschr.studentnummer)
WHERE 1=1
--AND stud_inschr.inschrijfdatum > TO_DATE('01-08-2022','dd-mm-yyyy')
AND cohort > 2021

