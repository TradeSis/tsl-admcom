
{admcab.i}

def temp-table ttvend
    field platot    like plani.platot
    field funcod    like movim.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field qtddev    like movim.movqtm
    index valor     platot desc.
    
def temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like movim.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field qtddev    like movim.movqtm
    field procod    like produ.procod
    index valor     platot desc.
    
def var v-totger as dec.
def var v-totdia as dec.
def var v-nome like estab.etbnom.
def var v-titven as char.
def var v-titvenpro as char.
def var v-perc as dec.
def var v-perdia as dec.
def var v-tot as dec.
def var p-vende like func.funcod.
def var i as int.
def var vdti as date format "99/99/9999" no-undo label "Dt.Inicial".
def var vdtf as date format "99/99/9999" no-undo label "Dt.Final".

def var v-valor as dec.

def buffer sclase for clase.
def buffer grupo for clase.
def var p-loja like estab.etbcod.

{anset.i}.

form
    ttvend.numseq   column-label "Rk" format ">>9" 
    ttvend.funcod   column-label "Cod" format ">>9"
    func.funnom    format "x(18)" 
    ttvend.qtd     column-label "Qtd" format ">>>9" 
    ttvend.qtddev  column-label "Q.Dev" format ">>>9" 
    ttvend.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvend.platot  format "->,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vend
        centered
        down 
        title v-titven.
        
form
    ttvenpro.procod
    produ.pronom    format "x(18)" 
    ttvenpro.qtd     column-label "Qtd" format ">>>9" 
    ttvenpro.qtddev  column-label "Q.Dev" format ">>>9" 
    ttvenpro.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down 
        title v-titvenpro.

form
    p-loja label "Lj" 
    estab.etbnom no-label
    vdti
    vdtf
    with frame f-loja
        centered
        1 down side-labels title "Dados Iniciais". 

hide frame f-opcao. clear frame f-opcao all.

repeat :
    clear frame f-loja all.
    
    find first func where func.funcod = sfuncod no-error.
    
    
    update
        p-loja 
        with frame f-loja.

        if p-loja = 0 and func.etbcod <> 0
        then do :
          bell. bell. message "Codigo do Estabelecimento digitado invalido".
          pause. clear frame f-loja all. leave.
        end.

    
    if p-loja = 0 
    then disp "GERAL" @ estab.etbnom with frame f-loja.
    else do :
        find first estab where estab.etbcod = p-loja no-lock.
        disp estab.etbnom with frame f-loja.
    end.    

    update vdti
           vdtf with frame f-loja.

    for each plani where (plani.movtdc = 5 or plani.movtdc = 12 )
                     and  plani.etbcod = (if p-loja = 0 
                                          then plani.etbcod 
                                          else p-loja ) and
                           plani.pladat >= vdti              and
                           plani.pladat <= vdtf and 
                           plani.notsit <> "C"          
                           use-index histo no-lock  :
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f1 
                    centered row 10 1 down no-labels. pause 0.
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod no-lock : 
                     
                v-valor = (movim.movpc * movim.movqtm).
                if plani.movtdc = 5
                then do :
                    if plani.protot < plani.platot
                    then v-valor = v-valor +  (((movim.movpc * movim.movqtm)
                        * 100) / plani.protot / 100) *  
                        (plani.platot -  plani.protot ). 
                    if plani.platot < plani.protot
                    then v-valor = v-valor - (((movim.movpc * movim.movqtm)
                        * 100) /  plani.protot / 100) * (plani.protot -                         plani.platot). 
                end.        
                else do :
                if plani.platot > plani.protot
                then v-valor = v-valor - (((movim.movpc * movim.movqtm) * 100)
                      / plani.protot / 100) *  (plani.platot - plani.protot).
                if plani.protot > plani.platot 
                then v-valor = v-valor +  (((movim.movpc * movim.movqtm) * 100) 
                      /  plani.protot / 100) * (plani.protot - plani.platot).
                end.
        
                find first ttvenpro where ttvenpro.procod = movim.procod
                                      and ttvenpro.funcod = movim.funcod
                                    no-error.
                if not avail ttvenpro
                then do:
                    create ttvenpro.
                    assign 
                        ttvenpro.procod = movim.procod
                        ttvenpro.funcod = movim.funcod.
                end.
                if (plani.movtdc = 5 or
                    plani.movtdc = 2)
                then do :
                    assign  ttvenpro.qtd = ttvenpro.qtd + movim.movqtm
                            ttvenpro.platot = ttvenpro.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttvenpro.pladia = ttvenpro.pladia + v-valor.
                end.    
                if (plani.movtdc = 12 or
                    plani.movtdc = 10)
                then do :
                    assign  ttvenpro.qtddev = ttvenpro.qtddev + movim.movqtm
                            ttvenpro.platot = ttvenpro.platot - v-valor.
                    if plani.pladat = vdtf
                    then ttvenpro.pladia = ttvenpro.pladia - v-valor.
                end.   
        
                find first ttvend where ttvend.funcod = movim.funcod
                                  no-error.
                if not avail ttvend
                then do:
                    create ttvend.
                    ttvend.funcod = movim.funcod.
                end.
                if plani.movtdc = 5 
                then do :
                    ttvend.platot = ttvend.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttvend.pladia = ttvend.pladia + v-valor.
                end.    
                    
                if plani.movtdc = 12 
                then do :
                    ttvend.platot = ttvend.platot - v-valor.
                    if plani.pladat = vdtf
                    then  ttvend.pladia = ttvend.pladia - v-valor.
                end.    
            end.
    end.

    hide frame f1.
    
    repeat :
        if p-loja <> 0 
        then do :
            find first estab where estab.etbcod = p-loja no-lock.
            v-nome = estab.etbnom. 
        end.
        else v-nome = "EMPRESA".
       
        assign an-seeid = -1 an-recid = -1 an-seerec = ?
               v-titven  = "VENDEDORES DA LOJA " + string(v-nome)
            v-totger = 0 v-totdia = 0 i = 1.

        for each ttvend break by ttvend.platot desc :
            ttvend.numseq = i.
            i = i + 1.
            assign  v-totdia = v-totdia + ttvend.pladia
                    v-totger = v-totger + ttvend.platot.
        end.                            
            
        {anbrowse.i
            &File   = ttvend
            &CField = ttvend.funcod
            &Ofield = " ttvend.platot func.funnom ttvend.pladia ttvend.numseq 
                        v-perc v-perdia ttvend.qtd ttvend.qtddev "
            &Where = "true"
            &NonCharacter = /*
            &AftFnd = " find first func where 
                            func.funcod = ttvend.funcod no-lock. 
                assign   v-perc = ttvend.platot * 100 / v-totger
                         v-perdia = ttvend.pladia * 100 / v-totdia. "
            &AftSelect1 = "p-vende = ttvend.funcod. 
                           leave keys-loop. "
            &LockType = "use-index valor"           
            &Form = " frame f-vend" 
        }.
        
        if keyfunction(lastkey) = "END-ERROR"
        then leave.

        repeat :
            find first func where func.funcod = p-vende no-lock.
            
            assign an-seeid = -1 an-recid = -1 an-seerec = ?
               v-titvenpro = "PRODUTOS DO VENDEDOR " + string(func.funnom)
               v-totger = 0 v-totdia = 0.
            
            for each ttvenpro where ttvenpro.funcod = p-vende:
                assign v-totdia = v-totdia + ttvenpro.pladia
                       v-totger = v-totger + ttvenpro.platot.
            end.                            
            
            {anbrowse.i
                &File   = ttvenpro
                &CField = ttvenpro.procod
                &Ofield = "ttvenpro.platot produ.pronom ttvenpro.pladia 
                       v-perc v-perdia ttvenpro.qtd ttvenpro.qtddev "
                &Where =  "ttvenpro.funcod = p-vende "
                &NonCharacter = /*
                &AftFnd = " find first produ where 
                            produ.procod = ttvenpro.procod no-lock. 
                        v-perc = ttvenpro.platot * 100 / v-totger.
                        v-perdia = ttvenpro.pladia * 100 / v-totdia. "
                &AftSelect1 = "p-vende = ttvend.funcod. 
                                   leave keys-loop. "
                &LockType = "use-index valor"           
                &Form = " frame f-vendpro " 
            }.
        
            if keyfunction(lastkey) = "END-ERROR"
            then leave.
        end.
    end.
end.
 