{admcab.i}
def var vetbcod like estab.etbcod.
def var vdata as date.
def var vdtini as date.
def var vdtfin as date.
def var varquivo as char.
def var vtotvlpag like titluc.titvlpag.
def buffer bestab for estab.

format vetbcod label "Filial" estab.etbnom no-label skip
       vdtini label "Data Pagamento" vdtfin
       with frame f-1  width 80 side-label.
   
update vetbcod with frame f-1.       

if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom with frame f-1 no-label.
end.
else
    display "GERAL "  with frame f-1 .

    do on error undo, retry:
          update vdtini vdtfin with frame f-1.
          if vdtini = ? or vdtfin = ?
          then do:
              message color red/with 
                "Data inválida" view-as alert-box.
                undo.
          end.
          if  vdtini > vdtfin
          then do:
                message color red/with 
                "Data inválida" view-as alert-box.
                undo.
          end.
    end.
    
       
       
message "Confirma relatorio?" update sresp.
if not sresp then return.
       
        if opsys = "UNIX"
        then varquivo = "../relat/geral" + string(time).
        else varquivo = "..\relat\geral" + string(time).
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "66"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """RELATORIO DE DESPESAS PAGAS"""
            &Width     = "100"
            &Form      = "frame f-cabcab"}

    DISP WITH FRAME F-1.

for each estab where
            (if vetbcod > 0 then estab.etbcod = vetbcod else true)
             no-lock .

    for each titluc where titluc.etbcobra = estab.etbcod and
                          titluc.titdtpag >= vdtini      and
                          titluc.titdtpag <= vdtfin 
                          no-lock
                          break by titluc.etbcobra:
                          
        if first-of(titluc.etbcobra)
        then vtotvlpag = 0.

            find first foraut where foraut.forcod = titluc.clifor no-lock
                    no-error.
            display titluc.etbcod column-label "Filial"
                    titluc.titnum
                    titluc.clifor column-label "Codigo"
                    foraut.fornom when avail foraut
                        format "x(30)"
                    titluc.titdtpag 
                    titluc.titvlpag
                    with frame f-titluc down width 140.

        vtotvlpag = vtotvlpag + titluc.titvlpag.
                    
        if last-of(titluc.etbcobra)
        then DISP vtotvlpag no-label at 74 
        with frame f-total width 140.
    end.
end.                            
    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
 