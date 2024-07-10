{admcab.i}

def var vdtini-promo as date format "99/99/9999".
def var vdtfin-promo as date format "99/99/9999".

def var vetbcod  like estab.etbcod.
def var varquivo as char.
def var vcatcod  like categoria.catcod.
def var vmes     as int format "99".
def var vano     as int format "9999".
def var vqtd     as int.
def var fila     as char.


    
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
        update skip vcatcod at 7
               help "Informe o codigo do departamento"
               with frame f-dados width 80 side-labels.
               
        find categoria where categoria.catcod = vcatcod no-lock no-error.
        if not avail categoria
        then do:
            message "Departamento nao cadastrado".
            undo.
        end.
        else disp categoria.catnom no-label with frame f-dados.
end.


do on error undo:

        assign vmes = 12
               vano = year(today) - 1.

        update skip
               vmes   label "Mes" at 13
               vano   label "Ano"
               with frame f-dados.

end.

/*
update vdtini-promo label "Data Inicial"
       vdtfin-promo label "Data Final"
       with frame f-dados2 centered side-labels title " * Promocao * ".
*/       

message "Atualizando...".

for each produ where produ.catcod = categoria.catcod no-lock:
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
        
        find estoq where estoq.etbcod = estab.etbcod
                     and estoq.procod = produ.procod no-error.
        if avail estoq
        then assign estoq.estideal = vqtd
                    /*estoq.datexp = today*/ .
                
                
        /*
        find promdreb where promdreb.etbcod    = estab.etbcod
                        and promdreb.procod    = produ.procod
                        and promdreb.mes-estoq = vmes
                        and promdreb.ano-estoq = vano no-error.
        if not avail promdreb
        then do:
            create promdreb.
            assign promdreb.etbcod       = estab.etbcod
                   promdreb.procod       = produ.procod
                   promdreb.mes-estoq    = vmes
                   promdreb.ano-estoq    = vano
                   promdreb.qtd-estoq    = vqtd
                   promdreb.dt-promo-ini = vdtini-promo
                   promdreb.dt-promo-fin = vdtfin-promo
                   promdreb.departamento = categoria.catcod.
                   
                   
        end.
        */
        
      end.
      
end.
