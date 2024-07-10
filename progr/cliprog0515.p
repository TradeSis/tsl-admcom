def shared var vdti as date.
def shared var vdtf as date.

disp vdti vdtf.

def var v-moeda as char.
def var vdata as date.
def var vi as int.

for each ninja.ctbreceb where ctbreceb.datref >= vdti and
ctbreceb.datref <= vdtf: 
    delete ctbreceb.
end.
for each ninja.ctcartcl where
         ctcartcl.datref >= vdti and
         ctcartcl.datref <= vdtf and
         ctcartcl.etbcod > 0
         :
    delete ctcartcl.
end.             
do vdata = vdti to vdtf:
    for each tabdicem where tabdicem.datref = vdata no-lock:

        find first ninja.ctcartcl where
               ctcartcl.etbcod = tabdicem.etbcod and
               ctcartcl.datref = tabdicem.datref
               no-error
               .
        if not avail ctcartcl
        then do:
            create ninja.ctcartcl.
            assign
                ctcartcl.etbcod = tabdicem.etbcod
                ctcartcl.datref = tabdicem.datref
                .
        end.     

        vi = 0.
        do vi = 1 to 15:
            if tabdicem.define_venda_moeda[vi] begins "REA"
            then do:
                ctcartcl.ecfvista = ctcartcl.ecfvista +
                    tabdicem.venda_moeda[vi].
                leave.    
            end. 
            
        end.

        do vi = 1 to 15:
            if tabdicem.define_venda_moeda[vi] <> ""
            then do:
                find first ninja.ctbreceb where
                           ctbreceb.etbcod = tabdicem.etbcod and
                           ctbreceb.rectp = "VENDA" and
                           ctbreceb.datref = tabdicem.datref and
                           ctbreceb.moecod = 
                           substr(tabdicem.define_venda_moeda[vi],1,3)
                           no-error.
                if not avail ninja.ctbreceb
                then do:
                    create ninja.ctbreceb.
                    assign
                        ctbreceb.etbcod = tabdicem.etbcod 
                        ctbreceb.rectp = "VENDA" 
                        ctbreceb.datref = tabdicem.datref 
                        ctbreceb.moecod =
                        substr(string(tabdicem.define_venda_moeda[vi]),1,3)
                        
                        .
                end.        
                ctbreceb.valor1 = ctbreceb.valor1 + tabdicem.venda_moeda[vi].
            end.
        end.                

        assign
            ctcartcl.ecfprazo = ctcartcl.ecfprazo + tabdicem.venda_prazo_lebes
            ctcartcl.acrescimo = ctcartcl.acrescimo + tabdicem.acrescimo_lebes
            ctcartcl.acr-novacao = ctcartcl.acr-novacao + 
                        tabdicem.acrescimo_novacao
            ctcartcl.devprazo = ctcartcl.devprazo + tabdicem.devolucao_prazo
            ctcartcl.estorno  = ctcartcl.estorno + tabdicem.estorno_devolucao
            ctcartcl.devolucao = ctcartcl.devolucao + tabdicem.devolucao_vista
            ctcartcl.emis-financeira = 
                    ctcartcl.emis-financeira + tabdicem.venda_prazo_fdrebes
            ctcartcl.canc-financeira = 
                    ctcartcl.canc-financeira + tabdicem.cancelamentos_fdrebes
            ctcartcl.acrescimo-novacao-fdrebes = 
            ctcartcl.acrescimo-novacao-fdrebes +  tabdicem.acrescimo_fdrebes
            .
    end.
    vi = 0.
    for each tabdicre where tabdicre.datref = vdata no-lock:
        find first ninja.ctcartcl where
               ninja.ctcartcl.etbcod = tabdicre.etbcod and
               ninja.ctcartcl.datref = tabdicre.datref
               no-error
               .
        if not avail ninja.ctcartcl
        then do:
            create ninja.ctcartcl.
            assign
                ninja.ctcartcl.etbcod = tabdicre.etbcod
                ninja.ctcartcl.datref = tabdicre.datref
                .
        end. 
        
        do vi = 1 to 15:   
            if tabdicre.define_recebimento_moeda[vi] <> ""
            then do:
                v-moeda = substr(tabdicre.define_recebimento_moeda[vi],1,3).
                if v-moeda = " -"
                then v-moeda = "REA".
                find first ninja.ctbreceb where
                           ninja.ctbreceb.etbcod = tabdicre.etbcod and
                           ninja.ctbreceb.rectp = "RECEBIMENTO" and
                           ninja.ctbreceb.datref = tabdicre.datref and
                           ninja.ctbreceb.moecod = v-moeda
                           /*substr(tabdicre.define_recebimento_moeda[vi],1,3)
                           */
                           no-error.
                if not avail ninja.ctbreceb
                then do:
                    create ninja.ctbreceb.
                    assign
                        ninja.ctbreceb.etbcod = tabdicre.etbcod
                        ninja.ctbreceb.rectp = "RECEBIMENTO" 
                        ninja.ctbreceb.datref = tabdicre.datref 
                        ninja.ctbreceb.moecod = v-moeda
                            /*substr(tabdicre.define_recebimento_moeda[vi],1,3)
                            */
                        .
                end.        
                ninja.ctbreceb.valor1 = ninja.ctbreceb.valor1 + 
                    tabdicre.recebimento_moeda_lebes[vi].
            end.
        end.
        do vi = 1 to 15:
            if tabdicre.define_recebimento_moeda[vi] <> ""
            then do:
                find first ninja.ctbreceb where
                           ninja.ctbreceb.etbcod = tabdicre.etbcod and
                           ninja.ctbreceb.rectp = "RECFINAN" and
                           ninja.ctbreceb.datref = tabdicre.datref and
                           ninja.ctbreceb.moecod = 
                           substr(tabdicre.define_recebimento_moeda[vi],1,3)
                           no-error.
                if not avail ninja.ctbreceb
                then do:
                    create ninja.ctbreceb.
                    assign
                        ninja.ctbreceb.etbcod = tabdicre.etbcod
                        ninja.ctbreceb.rectp = "RECFINAN" 
                        ninja.ctbreceb.datref = tabdicre.datref 
                        ninja.ctbreceb.moecod =
                        substr(tabdicre.define_recebimento_moeda[vi],1,3)
                        .
                end.        
                ninja.ctbreceb.valor1 = ctbreceb.valor1 + 
                        tabdicre.recebimento_moeda_fdrebes[vi].
            end.
            release ninja.ctbreceb.
        end.
        do vi = 1 to 15:
            if tabdicre.define_recebimento_entrada_moeda[vi] <> ""
            then do:
                find first ninja.ctbreceb where
                           ninja.ctbreceb.etbcod = tabdicre.etbcod and
                           ninja.ctbreceb.rectp = "ENTRADA" and
                           ninja.ctbreceb.datref = tabdicre.datref and
                           ninja.ctbreceb.moecod = 
                    substr(tabdicre.define_recebimento_entrada_moeda[vi],1,3)
                           no-error.
                if not avail ninja.ctbreceb
                then do:
                    create ninja.ctbreceb.
                    assign
                        ninja.ctbreceb.etbcod = tabdicre.etbcod 
                        ninja.ctbreceb.rectp = "ENTRADA" 
                        ninja.ctbreceb.datref = tabdicre.datref 
                        ninja.ctbreceb.moecod =
                    substr(tabdicre.define_recebimento_entrada_moeda[vi],1,3)
                        .
                end.        
                ninja.ctbreceb.valor1 =  ninja.ctbreceb.valor1 + 
                            tabdicre.recebimento_entrada_moeda[vi].
            end.
            release ninja.ctbreceb.
        end.

        assign
            ninja.ctcartcl.entrada  = ninja.ctcartcl.entrada  + 
                        tabdicre.recebimento_entrada
            ninja.ctcartcl.recebimento = ninja.ctcartcl.recebimento + 
                        tabdicre.recebimento_lebes
            ninja.ctcartcl.juro = ninja.ctcartcl.juro + tabdicre.juros_lebes
            ninja.ctcartcl.esto-financeira = ninja.ctcartcl.esto-financeira +                     tabdicre.estorno_cancelamento_fdrebes
            ninja.ctcartcl.rece-fosaldo = 0 
            ninja.ctcartcl.rece-financeira = ninja.ctcartcl.rece-financeira + 
                    tabdicre.recebimento_fdrebes
            .
        
    end.
    release ninja.ctcartcl.
end.