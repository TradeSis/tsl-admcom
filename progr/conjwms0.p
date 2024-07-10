{admcab.i}

DEFINE shared WORK-TABLE wwmsconj 
  FIELD campo-ch AS CHARACTER
  FIELD campo-de AS DECIMAL     DECIMALS 2
  FIELD campo-i  AS INTEGER
  FIELD procod   AS INTEGER     
  FORMAT ">>>>>>9" LABEL "Produto" COLUMN-LABEL "Pro"
  FIELD proean   AS CHARACTER   FORMAT "x(13)" LABEL "EAN" COLUMN-LABEL "EAN"
  FIELD qtd      AS INTEGER     FORMAT ">>>>>>9" LABEL "Qtd" COLUMN-LABEL "Qtd"
  .
/** 
for each wmsconj no-lock:
    create wwmsconj.
    buffer-copy wmsconj to wwmsconj.
end.
**/
for each conjunto no-lock:
    create wwmsconj.
    buffer-copy conjunto to wwmsconj.    
end.    

