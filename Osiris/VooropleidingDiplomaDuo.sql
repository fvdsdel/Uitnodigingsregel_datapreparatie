WITH dipl_vo AS ( 
    SELECT --DISTINCT svuv.niveau
    svod.studentnummer
    ,MAX(DECODE(svuv.niveau,'HAVO',1,0)) AS VooroplNiveau_HAVO
    ,MAX(DECODE(svuv.niveau,'VMBO_TL',1,0)) AS VooroplNiveau_VMBO_TL
    ,MAX(DECODE(svuv.niveau,'VMBO_BB',1,0)) AS VooroplNiveau_VMBO_BB
    ,MAX(DECODE(svuv.niveau,'VMBO_KB',1,0)) AS VooroplNiveau_VMBO_KB
    ,MAX(DECODE(svuv.niveau,'VMBO_GL',1,0)) AS VooroplNiveau_VMBO_GL
    ,MAX(DECODE(SUBSTR(svuv.niveau,1,3),'VWO',1,0)) AS VooroplNiveau_VWO
    --* 
    FROM ost_student_vooropleiding_duo svod
    LEFT JOIN ost_student_vopl_uitsl_vo_duo svuv ON (svuv.studentnummer = svod.studentnummer)
    WHERE 1=1 
    AND svuv.uitslag_code = 'G' --Diploma
    GROUP BY svod.studentnummer
)
,dipl_mbo AS (SELECT DISTINCT
    svrm.studentnummer
    ,1 AS VooroplNiveau_MBO
    FROM ost_student_vopl_res_mbo_duo svrm
    WHERE svrm.type = 'D'
),dipl_ho AS (
    SELECT DISTINCT svod.studentnummer,1 AS  VooroplNiveau_HO
    FROM ost_student_vooropleiding_duo svod
    LEFT JOIN ost_student_vopl_oord_ho_duo svoh ON (svod.studentnummer = svoh.studentnummer)
    WHERE 1=1 AND svoh.studentnummer IS NOT NULL)
,vopl_dipl AS (
  SELECT 
    stud.studentnummer
    ,DECODE(dipl_vo.studentnummer,NULL,DECODE(dipl_mbo.studentnummer,NULL,DECODE(dipl_ho.studentnummer,NULL,1,0),0),0) AS VooroplNiveau_nan
    ,NVL(dipl_vo.VooroplNiveau_HAVO,0)  VooroplNiveau_HAVO
    ,NVL(dipl_vo.VooroplNiveau_VMBO_BB,0)   VooroplNiveau_VMBO_BB
    ,NVL(dipl_vo.VooroplNiveau_VMBO_GL,0)   VooroplNiveau_VMBO_GL
    ,NVL(dipl_vo.VooroplNiveau_VMBO_KB,0)   VooroplNiveau_VMBO_KB
    ,NVL(dipl_vo.VooroplNiveau_VMBO_TL,0)   VooroplNiveau_VMBO_TL
    ,NVL(dipl_vo.VooroplNiveau_VWO,0)   VooroplNiveau_VWO
    ,NVL(dipl_mbo.vooroplniveau_mbo,0) AS vooroplniveau_mbo
    ,NVL(dipl_ho.vooroplniveau_ho,0) AS vooroplniveau_ho
  FROM ost_student stud
  LEFT JOIN dipl_vo ON (stud.studentnummer = dipl_vo.studentnummer)
  LEFT JOIN dipl_mbo ON (stud.studentnummer = dipl_mbo.studentnummer)
  LEFT JOIN dipl_ho ON (stud.studentnummer = dipl_ho.studentnummer)
  WHERE 1=1
  AND EXISTS (SELECT 1 FROM ost_student_vooropleiding_duo svod WHERE svod.studentnummer = stud.studentnummer)
  -- Alleen studenten met een actieve inschrijving in de afgelopen 5 jaar. Evt weghalen indien langere periode gewenst is
  AND EXISTS (SELECT 1 FROM ost_student_ook sook WHERE sook.studentnummer = stud.studentnummer AND sook.afsluitdatum_ook > (sysdate-(5*365)))
)

SELECT * FROM vopl_dipl
WHERE 1=1

