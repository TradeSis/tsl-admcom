def shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot 
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.        

def shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def var v-totger as dec.
def var v-totdia as dec.
def var v-nome like estab.etbnom.
def var v-perc as dec format "->>9.99".
def var v-perdia as dec format "->>9.99".
def var v-titven as char.
def var v-titvenpro as char.
def var v-tot as dec.
def var p-vende like func.funcod.
def var i as int.
def shared var vdti as date format "99/99/9999" no-undo.
def shared var vdtf as date format "99/99/9999" no-undo.
def var v-valor as dec.

def buffer sclase for clase.
def buffer grupo for clase.

def input parameter p-loja like estab.etbcod.

{anset.i}.
{admcab.i}.

form
    ttvend.numseq   column-label "Rk" format ">>9" 
    help " F8 = Imprime"
    ttvend.funcod   column-label "Cod" format ">>>9"
    func.funape    format "x(9)" 
    ttvend.qtd     column-label "Qtd" format "->>9" 
    ttvend.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvend.platot   column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vend
        centered
        down color white/cyan 
        title v-titven overlay row 7.
        
form
    ttvenpro.procod
    produ.pronom    format "x(18)" 
    clase.clasup    column-label "S" format ">9" 
    ttvenpro.qtd     column-label "Qtd" format "->>9" 
    ttvenpro.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down 
        title v-titvenpro.

repeat :
    if p-loja <> 99 then do :
    find first estab where estab.etbcod = p-loja no-lock.
    v-nome = estab.etbnom. end.
    else v-nome = "EMPRESA".
       
    assign an-seeid = -1 an-recid = -1 an-seerec = ?
           v-titven  = "VENDEDORES DA LOJA " + string(v-nome)
           v-totger = 0 v-totdia = 0 i = 1.

    for each ttvend where ttvend.etbcod = p-loja break by ttvend.platot desc :
        ttvend.numseq = i.
        i = i + 1.
        assign  v-totdia = v-totdia + ttvend.pladia
                v-totger = v-totger + ttvend.platot.
    end.                            
            
    {anbrowse.i
        &File   = ttvend
        &help   = " F8 - Imprime"
        &CField = ttvend.funcod
        &color  = write/cyan
        &Ofield = " ttvend.platot func.funape when avail func
                    ttvend.pladia ttvend.numseq 
                    v-perc v-perdia ttvend.qtd "
        &Where = "ttvend.etbcod = p-loja"
        &NonCharacter = /*
        &AftFnd = " find first func where 
                        func.etbcod = p-loja and
                        func.funcod = ttvend.funcod no-lock no-error. 
            
            assign   
            v-perc = 0 
                   v-perdia = ( if ttvend.pladia > 0
                                then ttvend.pladia * 100 / v-totdia
                                else 0). "
        &AftSelect1 = " next keys-loop. " 
        &LockType = "use-index valor"           
        &Form = " frame f-vend" 
    }.
        
    if keyfunction(lastkey) = "END-ERROR"
    then leave.

    repeat :
        find first func where func.etbcod = p-loja
                          and func.funcod = p-vende no-lock.
            
        assign an-seeid = -1 an-recid = -1 an-seerec = ?
               v-titvenpro = "PRODUTOS DO VENDEDOR " + string(func.funnom)
               v-totger = 0 v-totdia = 0.
            
        for each ttvenpro where ttvenpro.etbcod = p-loja
                            and ttvenpro.funcod = p-vende:
            assign v-totdia = v-totdia + ttvenpro.pladia
                   v-totger = v-totger + ttvenpro.platot.
        end.                            
            
        {anbrowse.i
            &File   = ttvenpro
            &CField = ttvenpro.procod
            &color  = write/cyan
            &Ofield = "ttvenpro.platot produ.pronom ttvenpro.pladia 
                       v-perc v-perdia ttvenpro.qtd clase.clasup "
            &Where = "ttvenpro.etbcod = p-loja and
                      ttvenpro.funcod = p-vende "
            &NonCharacter = /*
            &AftFnd = " find first produ where 
                            produ.procod = ttvenpro.procod no-lock. 
                        find first clase where clase.clacod = produ.clacod
                                no-lock.
                        v-perc = (if ttvenpro.platot > 0
                                  then ttvenpro.platot * 100 / v-totger
                                  else 0).
                        v-perdia = (if ttvenpro.pladia > 0
                                    then ttvenpro.pladia * 100 / v-totdia
                                    else 0). "
            &AftSelect1 = "p-vende = ttvend.funcod.
                           leave keys-loop."
            &LockType = "use-index valor"           
            &Form = " frame f-vendpro " 
        }.
        
        if keyfunction(lastkey) = "END-ERROR"
        then leave.
    end.
end.
return. 
 