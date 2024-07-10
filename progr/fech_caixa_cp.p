{admcab.i}

def var vdti        as date.
def var vdtf        as date.

def var vdt  as date.

def var vetbi as integer.
def var vetbf as integer.

def var varquivo as char.

def var vlimite-disponivel as char.
def var vtotal-venda       as decimal.
def var vval-venda         as decimal.


def buffer bestab for estab.

assign vetbi = 1
        vetbf = 999
        vdti = 09/01/2016
        vdtf = 09/30/2016.

update vetbi format ">>9" label "Filial............" colon 25 
with frame f-filtros side-labels.

find estab where estab.etbcod = vetbi no-lock.
display estab.etbnom format "x(15)" no-label with frame f-filtros width 78.
    
display " a " with frame f-filtros.
update  vetbf format ">>9" no-label with frame f-filtros .

find bestab where bestab.etbcod = vetbf no-lock.
display bestab.etbnom format "x(15)" no-label with frame f-filtros.

update vdti label "Periodo de........" format "99/99/9999" colon 25 
 with frame f-filtros side-labels.

display " a " with frame f-filtros.

update  vdtf no-label format "99/99/9999"  with frame f-filtros.

assign vtotal-venda = 0.
        
    if opsys = "UNIX"
    then varquivo = "../relat/rel_fecha_caixa_cp." + string(time).
    else varquivo = "..\relat\rel_fecha_caixa_cp." + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""fech_caixa_cp""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
      &Tit-Rel   = """FECHAMENTO DE CAIXA - CRÉDITO PESSOAL - ""
                   + ""FILIAL "" + string(vetbi, "">>9"") 
                   + "" A "" + string(vetbf, "">>9"")
                   + "" - PERIODO DE ""
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "110"
        &Form      = "frame f-cabcab"}

for each estab where estab.etbcod >= vetbi
                 and estab.etbcod <= vetbf
                      no-lock.
                   
    do vdt = vdti to vdtf:
                         
        for each contrato where contrato.etbcod = estab.etbcod
                            and contrato.dtinicial = vdt
                                no-lock,
                                
            each contnf where contnf.contnum = contrato.contnum
                          and contnf.etbcod = contrato.etbcod
                                no-lock,
            
            each plani where plani.etbcod = contnf.etbcod
                         and plani.placod = contnf.placod
                         and plani.serie  = contnf.notaser
                          no-lock.
                    
            if contrato.banco <> 13
            then next.
            
            if acha("Deposito",plani.notobs[1]) <> ""
            then next.
            
            assign vval-venda = 0.
            
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat
                                        no-lock,
                                        
                first profin where profin.procod = movim.procod
                                   no-lock.
                                        
                assign vval-venda = movim.movctm * movim.movqtm.
                                        
            end.                            
                      
            assign vtotal-venda = vtotal-venda + vval-venda.          
                      
            find first clien where clien.clicod = plani.desti 
                                    no-lock no-error.

            display
                   plani.etbcod format ">>9" column-label "Fil"
                   plani.pladat format "99/99/9999" label "Data"
                   string(plani.horincl,"HH:MM:SS") label "Hora"
                   contrato.contnum format ">>>>>>>>>>9" label "Contrato"
                   plani.desti  format ">>>>>>>>>>>9" column-label "Cod. Cli"
                   clien.clinom format "x(40)" label "Cliente" when avail clien
                   vval-venda   format "->>,>>>,>>9.99" label "Valor Contratado"
                    skip 
                    with width 115.

        end.                         
                         
    end.                     
                     
end.
display "Total........:" vtotal-venda format "->>>,>>>,>>>,>>>,>>9.99" no-label.

output close.


if opsys = "UNIX"
then do:
    run visurel.p (input varquivo,
                   input "").
end.
else do:
    {mrod.i}.
end.
                                                           


