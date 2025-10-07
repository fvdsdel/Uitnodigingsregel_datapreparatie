/* Voorbeeld SQL script om de gegevens van de vooropleiding op te halen uit EduArte
Oorspronkelijk auteur: Albeda / Hibo Musse
*/

select 
  d.DEELNEMERNUMMER,
  rd.CIJFERCE, 
  rd.CIJFERIE,
  rd.EINDCIJFER, 
  od.OPLEIDINGCODE, 
  rd.RESULTAATVOLGNUMMER 
from 
  deelnemer d
left join 
  VOOROPLEIDINGDUO vd on vd.deelnemer= d.id 
left join 
  RESULTAATMBODUO rd on rd.VOOROPLEIDINGDUo=vd.id 
left join 
  ONDERWIJSDEELNAMEDUO od on od.VOOROPLEIDINGDUo=vd.id
where 
  rd.EINDCIJFER is not null
  
