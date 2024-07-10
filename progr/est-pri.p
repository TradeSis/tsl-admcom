{admcab.i}

def var vetbcod  like estab.etbcod.
def var varquivo as char.
def var vmes     as int format "99".
def var vano     as int format "9999".
def var vqtd     as int.
def var fila     as char.

def temp-table tt-est
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field procod like produ.procod
    field pronom like produ.pronom
    field qtd    as   int.

repeat:

    for each tt-est: delete tt-est. end.
    
    do on error undo:
        update vetbcod
               help "Informe o codigo do estabelecimento ou zero para todos"
               with frame f-dados width 80 side-labels.
        if vetbcod = 0
        then disp "TODOS" @ estab.etbnom with frame f-dados.
        else do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.    
    end.

    do on error undo:

        assign vmes = 12
               vano = year(today) - 1.

        update skip
               vmes   label "Mes" at 13
               vano   label "Ano"
               with frame f-dados.

    end.

    for each produ where produ.catcod = 31 no-lock:

      for each estab where (if vetbcod <> 0
                            then estab.etbcod = vetbcod
                            else true) no-lock:
                            
        vqtd = 0.
        find hiest where hiest.etbcod = estab.etbcod 
                     and hiest.procod = produ.procod 
                     and hiest.hiemes = vmes 
                     and hiest.hieano = vano no-lock no-error.
        if avail hiest 
        then do:
         
            assign
                vqtd = hiest.hiestf.
                
        end.
        else do:
            find last hiest where hiest.etbcod = estab.etbcod 
                              and hiest.procod = produ.procod 
                              and hiest.hiemes <= vmes        
                              and hiest.hieano = vano no-lock no-error.
            if avail hiest 
            then do: 

                assign
                    vqtd = hiest.hiestf. 
                    
            end.
            else do: 
                find last hiest where hiest.etbcod = estab.etbcod 
                                  and hiest.procod = produ.procod 
                                  and hiest.hieano = vano - 1 no-lock no-error.
                if avail hiest 
                then do: 

                    assign
                        vqtd = hiest.hiestf.
                        
                end.
                else do:
                    find last hiest where hiest.etbcod = estab.etbcod 
                                      and hiest.procod = produ.procod 
                                      and hiest.hieano = vano - 2 
                                      no-lock no-error.
                    if avail hiest
                    then do: 

                        assign 
                            vqtd = hiest.hiestf.
                            
                    end.
                    else do: 
                        find last hiest where hiest.etbcod = estab.etbcod 
                                          and hiest.procod = produ.procod 
                                          and hiest.hieano < vano 
                                          no-lock no-error.
                        if avail hiest 
                        then do: 

                            assign 
                                vqtd = hiest.hiestf.
                                
                        end.
                    end.
                end.
            end.
        end.

        if vqtd <= 0
        then next.
        
        /*disp hiest.procod produ.pronom vqtd.*/

        find tt-est where tt-est.etbcod = estab.etbcod
                      and tt-est.procod = produ.procod no-error.
        if not avail tt-est
        then do:
            create tt-est.
            assign tt-est.etbcod = estab.etbcod
                   tt-est.etbnom = estab.etbnom
                   tt-est.procod = produ.procod
                   tt-est.pronom = produ.pronom.
        end.
                
        tt-est.qtd = tt-est.qtd + vqtd.

      end.
    end.

    if opsys = "UNIX"
    then assign varquivo = "/admcom/relat/est-pri" + string(time).
    else assign varquivo = "l:\relat\est-pri" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""rdg010""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """LISTGEM ESTOQUE - MES "" 
                   + string(vmes) + "" ANO ""
                   + string(vano)  "
        &Width     = "120"
        &Form      = "frame f-cabcab"}
    

        for each tt-est break by tt-est.etbcod
                              by tt-est.pronom:

            if first-of(tt-est.etbcod)
            then
                disp skip(2)
                     tt-est.etbcod label "Filial"
                     tt-est.etbnom no-label
                     with frame f-etb side-labels.
        
            disp space(3)
                 tt-est.procod column-label "Produto" 
                 tt-est.pronom column-label "Descricao" 
                 tt-est.qtd    column-label "Qtd" format ">>>>>9"
                    (total by tt-est.etbcod).
                        
        end.
    
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}.
    end.
    
end.


