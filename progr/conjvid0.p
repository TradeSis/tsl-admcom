{admcab.i}
/*
message "BUSCANDO CONJUNTOS NO WMS....   AGUARDE!".
connect wms -N tcp -S sdrebwms -H server.dep93  .
*/
DEFINE new shared WORK-TABLE wwmsconj 
  FIELD campo-ch AS CHARACTER
  FIELD campo-de AS DECIMAL     DECIMALS 2
  FIELD campo-i  AS INTEGER
  FIELD procod   AS INTEGER     
  FORMAT ">>>>>>9" LABEL "Produto" COLUMN-LABEL "Pro"
  FIELD proean   AS CHARACTER   FORMAT "x(13)" LABEL "EAN" COLUMN-LABEL "EAN"
  FIELD qtd      AS INTEGER     FORMAT ">>>>>>9" LABEL "Qtd" COLUMN-LABEL "Qtd"
  .
 
run conjwms0.p.
/* 
disconnect wms.
*/
HIDE MESSAGE NO-PAUSE.

run conjvid1.p
