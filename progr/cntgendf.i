/**
DEFINE  temp-TABLE tbcntgen  
  FIELD campo1     AS CHARACTER EXTENT 5 FORMAT "x(60)"
  FIELD campo2     AS CHARACTER EXTENT 5 FORMAT "x(60)"
  FIELD campo3     AS CHARACTER EXTENT 5 FORMAT "x(60)"
  FIELD datfim     AS DATE      FORMAT "99/99/9999" LABEL "DatFim" COLUMN-LABEL
  "DatFim"
  FIELD datini     AS DATE      FORMAT "99/99/9999" INITIAL today LABEL "DatIni
  " COLUMN-LABEL "DatIni"
  FIELD dtexp      AS DATE      FORMAT "99/99/9999" INITIAL today
  FIELD etbcod     AS INTEGER   FORMAT ">>>9" LABEL "Estabelecimento" 
  COLUMN-LABEL "Estab"
  FIELD numfim     AS CHARACTER LABEL "NumFim" COLUMN-LABEL "NumFim"
  FIELD numini     AS CHARACTER LABEL "NumIni" COLUMN-LABEL "NumIni"
  FIELD quantidade AS DECIMAL   DECIMALS 2 COLUMN-LABEL "Quant"
  FIELD tipcon     AS INTEGER   FORMAT ">>9" LABEL "Tipo" COLUMN-LABEL "Tipo"
  FIELD validade   AS DATE      FORMAT "99/99/9999" COLUMN-LABEL "Validade"
  FIELD valor      AS DECIMAL   DECIMALS 2 FORMAT "->>,>>>,>>9.99" 
  COLUMN-LABEL "Valor"
 INDEX i1 etbcod.

def var varq as char.

if opsys = "UNIX"
then varq = "/admcom/dg/tbcntgen.d".
else varq = "l:\dg\tbcntgen.d".

if search(varq) <> ?
then do:
    input from value(varq) .
    repeat:
        create tbcntgen.
        import tbcntgen.
    end.
    input close.
    for each tbcntgen where
             tbcntgen.tipcon = 0 :
        delete tbcntgen.
    end.         
end.
**/
