def shared var vdti as date.
def shared var vdtf as date.

update vdti at 1 label "Data inicial"
       vdtf label "Data final"
       with frame f1 side-label.

def var v-moeda as char.
def var vdata as date.
def var vi as int.

for each ctb-receb where ctb-receb.datref >= vdti and
                         ctb-receb.datref <= vdtf: 
    delete ctb-receb.
end.
for each ct-cartcl where
         ct-cartcl.datref >= vdti and
         ct-cartcl.datref <= vdtf and
         ct-cartcl.etbcod > 0
         :
    delete ct-cartcl. 
end.             
do vdata = vdti to vdtf:
    for each estab no-lock:
        find first ct-cartcl where
               ct-cartcl.etbcod = estab.etbcod and
               ct-cartcl.datref = vdata
               no-error
               .
        if not avail ct-cartcl
        then do:
            create ct-cartcl.
            assign
                ct-cartcl.etbcod = estab.etbcod
                ct-cartcl.datref = vdata
                .
        end. 
       
        for each opctbval where
             opctbval.etbcod = estab.etbcod and
             opctbval.datref = vdata and
             opctbval.t9 = "" and
             opctbval.t0 = "" 
             no-lock:
 
            /*** VENDA A VISTA ***/
            
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t3 = "VVI" and
               opctbval.t4 = "FISCAL" and
               opctbval.t5 = ""  and
               opctbval.t6 = ""  and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then ct-cartcl.vv_fiscal = ct-cartcl.vv_fiscal + opctbval.valor.
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t3 = "VVI" and
               opctbval.t4 = "OUTRAS" and
               opctbval.t5 = ""  and
               opctbval.t6 = ""  and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then ct-cartcl.vv_outras = ct-cartcl.vv_outras + opctbval.valor.
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t3 = "VVI" and
               opctbval.t4 = "SERVICO" and
               opctbval.t5 = "CARTAO-PRESENTE"  and
               opctbval.t6 = ""  and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then ct-cartcl.vv_cartpre = ct-cartcl.vv_cartpre + opctbval.valor.
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t3 = "VVI" and
               opctbval.t4 = "SERVICO" and
               opctbval.t5 = "RECARGA"  and
               opctbval.t6 = ""  and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then ct-cartcl.vv_recarga = ct-cartcl.vv_recarga + opctbval.valor.
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t3 = "VVI" and
               opctbval.t4 = "VLSERV" and
               opctbval.t5 = ""  and
               opctbval.t6 = ""  and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then ct-cartcl.vv_troca = ct-cartcl.vv_troca + opctbval.valor.
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t3 = "VVI" and
               opctbval.t4 = "SERVICO" and
               opctbval.t5 = "CARTAO PRESENTE"  and
               opctbval.t6 = ""  and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then ct-cartcl.vv_cartpre = ct-cartcl.vv_cartpre + opctbval.valor.
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t3 = "VVI" and
               opctbval.t4 = "FISCAL" and
               opctbval.t5 = "ABATE"  and
               opctbval.t6 = ""  and
               opctbval.t7 = "CHEPRES"  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then ct-cartcl.rec_cartpre = ct-cartcl.rec_cartpre + opctbval.valor.
 
            /*** VENDA A PARAZO ***/

            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "SERVICO" and
               opctbval.t5 = "RECARGA" AND
               opctbval.t6 = "" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.vp_recarga = ct-cartcl.vp_recarga + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ABATE" AND
               opctbval.t6 = "" and
               opctbval.t7 = "TROCA"  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.vp_abate = ct-cartcl.vp_abate + opctbval.valor
                    ct-cartcl.aprazo = ct-cartcl.aprazo + opctbval.valor
                    ct-cartcl.devvista = ct-cartcl.devvista + opctbval.valor
                    .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "SEGURO" AND
               opctbval.t6 = "" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.vp_seguro = ct-cartcl.vp_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "FINANCEIRA" and
               opctbval.t5 = "SEGURO" AND
               opctbval.t6 = "" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.vp_seguro = ct-cartcl.vp_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "PRINCIPAL" AND
               opctbval.t6 = "FISCAL" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                     ct-cartcl.vp_principal_fiscal = 
                        ct-cartcl.vp_principal_fiscal + opctbval.valor
                     ct-cartcl.aprazo = ct-cartcl.aprazo + opctbval.valor   
                        .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "PRINCIPAL" AND
               opctbval.t6 = "OUTRAS" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.vp_principal_outras = 
                        ct-cartcl.vp_principal_outras + opctbval.valor
                    ct-cartcl.aprazo = ct-cartcl.aprazo + opctbval.valor    
                        .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "PRINCIPAL" AND
               opctbval.t6 = "SERVICOS" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.vp_principal_servico = 
                        ct-cartcl.vp_principal_servico + opctbval.valor
                    ct-cartcl.aprazo = ct-cartcl.aprazo + opctbval.valor    
                        .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ACRESCIMO" AND
               opctbval.t6 = "FISCAL" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.vp_acrescimo_fiscal = 
                        ct-cartcl.vp_acrescimo_fiscal + opctbval.valor
                    ct-cartcl.acrescimo = ct-cartcl.acrescimo + opctbval.valor
                        .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ACRESCIMO" AND
               opctbval.t6 = "SERVICOS" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.vp_acrescimo_servico = 
                        ct-cartcl.vp_acrescimo_servico + opctbval.valor
                    ct-cartcl.acrescimo = ct-cartcl.acrescimo + opctbval.valor                      .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ACRESCIMO" AND
               opctbval.t6 = "OUTRAS" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.vp_acrescimo_outras = 
                        ct-cartcl.vp_acrescimo_outras + opctbval.valor
                    ct-cartcl.acrescimo = ct-cartcl.acrescimo + opctbval.valor                       .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ENTRADA" and
               opctbval.t6 = "" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.entrada = ct-cartcl.entrada + opctbval.valor
                    ct-cartcl.aprazo = ct-cartcl.aprazo + opctbval.valor
                    .
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ENTRADA" AND
               opctbval.t6 = "FISCAL" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.vp_entrada_fiscal = 
                        ct-cartcl.vp_entrada_fiscal + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ENTRADA" AND
               opctbval.t6 = "SERVICOS" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.vp_entrada_servico = 
                        ct-cartcl.vp_entrada_servico + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ENTRADA" AND
               opctbval.t6 = "OUTRAS" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.vp_entrada_outras = 
                        ct-cartcl.vp_entrada_outras + opctbval.valor.
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "SERVICO" and
               opctbval.t5 = "CARTAO PRESENTE" AND
               opctbval.t6 = "" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.vp_cartpre = 
                        ct-cartcl.vp_cartpre + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ABATE" AND
               opctbval.t6 = "" and
               opctbval.t7 = "CHEPRES" and
               opctbval.t8 = ""  and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.rec_cartpre = 
                        ct-cartcl.rec_cartpre + opctbval.valor.
            
            /*** RECEBIMENTOS  ***/

            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES" and
               opctbval.t7 = "ACRESCIMO" and
               opctbval.t8 = "" and
               opctbval.t9 = ""  and
               opctbval.t0 = ""  
            then assign
                    ct-cartcl.recacrescimo = 
                            ct-cartcl.recacrescimo + opctbval.valor
                    ct-cartcl.recebimento = 
                            ct-cartcl.recebimento + opctbval.valor.
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES" and
               opctbval.t7 = "PRINCIPAL" and
               opctbval.t8 = "" and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.recebimento = 
                        ct-cartcl.recebimento + opctbval.valor.
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES" and
               opctbval.t7 = "ENTRADA" and
               opctbval.t8 = "" and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then assign
                    ct-cartcl.recentrada = 
                        ct-cartcl.recentrada + opctbval.valor
                    ct-cartcl.recebimento = 
                        ct-cartcl.recebimento + opctbval.valor.
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "JURO ATRASO" and
               opctbval.t8 = "" and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.juro = ct-cartcl.juro + opctbval.valor.
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "SEGURO" and
               opctbval.t8 = "" and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.rec_seguro_l= rec_seguro_l + opctbval.valor.
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "FINANCEIRA"   and
               opctbval.t7 = "SEGURO" and
               opctbval.t8 = "" and
               opctbval.t9 = ""  and
               opctbval.t0 = "" 
            then ct-cartcl.rec_seguro_f= rec_seguro_f + opctbval.valor.

            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "VVI" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "" and
               opctbval.t8 = "CHP-CHEQUE PRESENTE"
            then ct-cartcl.rec_cartpre = ct-cartcl.rec_cartpre + opctbval.valor.
            
            /*** DEVOLUÇÃO DE VENDA ***/
            
            if opctbval.t1 = "VENDA" and
               opctbval.t2 = "A-VISTA" and
               opctbval.t4 = "FISCAL" and
               opctbval.t5 = "ABATE" and
               opctbval.t6 = ""   and
               opctbval.t7 = "TROCA" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.devvista = 
                        ct-cartcl.devvista + opctbval.valor.
            if opctbval.t1 = "DEVOLUCAO" and
               opctbval.t2 = "VENDA" and
               opctbval.t3 = "A-PRAZO" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "" and
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.devprazo = 
                        ct-cartcl.devprazo + opctbval.valor.
            if opctbval.t1 = "DEVOLUCAO" and
               opctbval.t2 = "VENDA" and
               opctbval.t3 = "A-VISTA" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = ""   and
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.devvista = 
                        ct-cartcl.devvista + opctbval.valor.
            if opctbval.t1 = "DEVOLUCAO" and
               opctbval.t2 = "VENDA" and
               opctbval.t3 = "acerto" and
               opctbval.t4 = "DEVOLVIDO-PAG" and
               opctbval.t5 = "" and
               opctbval.t6 = "" and
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.estorno = 
                        ct-cartcl.estorno + opctbval.valor.

            /**** Novação *****/
            
            /*** ACRESCIMO ***/
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ACRESCIMO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_acrescimo = 
                    ct-cartcl.n_acrescimo + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ACRESCIMO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_acrescimo = 
                    ct-cartcl.n_acrescimo + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ACRESCIMO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_acrescimo = 
                    ct-cartcl.n_acrescimo + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ACRESCIMO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_acrescimo = 
                    ct-cartcl.n_acrescimo + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "OUTROS" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ACRESCIMO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.o_acrescimo = 
                    ct-cartcl.o_acrescimo + opctbval.valor.
 
            /*** novação entrada ***/
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ENTRADA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_entrada = 
                    ct-cartcl.n_entrada + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ENTRADA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_entrada = 
                    ct-cartcl.n_entrada + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ENTRADA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_entrada = 
                    ct-cartcl.n_entrada + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ENTRADA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_entrada = 
                    ct-cartcl.n_entrada + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "OUTROS" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ENTRADA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.o_entrada = 
                    ct-cartcl.o_entrada + opctbval.valor.
 
            /*** NOVAÇÃO PRINCIPAL ***/ 
             
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "PRINCIPAL" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_principal = 
                    ct-cartcl.n_principal + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "PRINCIPAL" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_principal = 
                    ct-cartcl.n_principal + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "PRINCIPAL" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_principal = 
                    ct-cartcl.n_principal + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "PRINCIPAL" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_principal = 
                    ct-cartcl.n_principal + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "OUTROS" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "PRINCIPAL" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.o_principal = 
                    ct-cartcl.o_principal + opctbval.valor.
        

            /*** NOVAÇÃO SEGURO ***/

            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO" AND
               opctbval.t5 = "FINANCEIRA" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
        
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO-FEIRAO" AND
               opctbval.t5 = "FINANCEIRA" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO" AND
               opctbval.t5 = "FINANCEIRA" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO-FEIRAO" AND
               opctbval.t5 = "FINANCEIRA" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_seguro = 
                    ct-cartcl.n_seguro + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "OUTROS" AND
               opctbval.t5 = "FINANCEIRA" and
               opctbval.t6 = "SEGURO" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.o_seguro = 
                    ct-cartcl.o_seguro + opctbval.valor.
        

            /*** ORIGEM-LEBES ***/

            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-LEBES" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_l = 
                    ct-cartcl.n_origem_l + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-LEBES" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_l = 
                    ct-cartcl.n_origem_l + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-LEBES" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_l = 
                    ct-cartcl.n_origem_l + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-LEBES" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_l = 
                    ct-cartcl.n_origem_l + opctbval.valor.

            /*** ORIGEM-FINANCEIRA ***/
            
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-FINANCEIRA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_f = 
                    ct-cartcl.n_origem_f + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "NOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-FINANCEIRA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_f = 
                    ct-cartcl.n_origem_f + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-FINANCEIRA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_f = 
                    ct-cartcl.n_origem_f + opctbval.valor.
            if opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "RENOVACAO-FEIRAO" AND
               opctbval.t5 = "LEBES" and
               opctbval.t6 = "ORIGEM-FINANCEIRA" AND
               opctbval.t7 = "" and
               opctbval.t8 = "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then ct-cartcl.n_origem_f = 
                    ct-cartcl.n_origem_f + opctbval.valor.
 
            /**** recebimento moeda ****/                

            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES" and
               opctbval.t7 = "ENTRADA" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, opctbval.t7,
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "ACRESCIMO" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, opctbval.t7,
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
            
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "JURO ATRASO" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, opctbval.t7,
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "PRINCIPAL" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, "PARCELA",
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
                         
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "VVI" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "" and
               opctbval.t8 <> ""
            then do:
                if opctbval.t8 = "REA-REAL"
                then ct-cartcl.avista = ct-cartcl.avista + opctbval.valor.
                run recebimento-moeda(estab.etbcod, vdata, "VENDA A VISTA",
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
            end.                           

            /**** recebimento financeira *****/
            if opctbval.t1 = "RECEBIMENTO" and 
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "FINANCEIRA" and
               opctbval.t7 = "ENTRADA" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, opctbval.t7,
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "FINANCEIRA"   and
               opctbval.t7 = "ACRESCIMO" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, opctbval.t7,
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
            
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "FINANCEIRA"   and
               opctbval.t7 = "JURO ATRASO" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, opctbval.t7,
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
            if opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "FINANCEIRA"   and
               opctbval.t7 = "PRINCIPAL" and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""
            then run recebimento-moeda(estab.etbcod, vdata, "PARCELA",
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor, opctbval.t6).
        end.
    end.
end.                           
            
procedure recebimento-moeda:         
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-data as date.
    def input parameter p-tipo as char.
    def input parameter p-moeda as char.
    def input parameter p-valor as dec.
    def input parameter p-onde as char.
    
    if p-onde = "LEBES"
    then do: 
    find first ctb-receb where
               ctb-receb.etbcod = p-etbcod and
               ctb-receb.rectp = p-tipo and
               ctb-receb.datref = p-data and
               ctb-receb.moecod = p-moeda 
               no-error.
    if not avail ctb-receb
    then do:
        create ctb-receb.
        assign
            ctb-receb.etbcod = p-etbcod 
            ctb-receb.rectp = p-tipo 
            ctb-receb.datref = p-data 
            ctb-receb.moecod = p-moeda
            .
    end.        
    ctb-receb.valor1 = ctb-receb.valor1 + p-valor.

    if p-tipo = "ACRESCIMO" or
       p-tipo = "PARCELA" or
       p-tipo = "ENTRADA"
    then do:    
        if p-moeda = "REA"
        then assign
                ct-cartcl.rec-dinheiro = ct-cartcl.rec-dinheiro + p-valor
                ct-cartcl.rec-caixa = ct-cartcl.rec-caixa + p-valor.
        else if p-moeda = "BCO"
        then ct-cartcl.rec-banco = ct-cartcl.rec-banco + p-valor.
        else if p-moeda = "CHV" or
           p-moeda = "PRE"
        then ct-cartcl.rec-cheque = ct-cartcl.rec-cheque + p-valor.  
        else if  p-moeda = "CAR" or
            p-moeda = "PDM" or
            p-moeda = "-"
            or substr(p-moeda,1,1) = "T"
        then ct-cartcl.rec-cartao = ct-cartcl.rec-cartao + p-valor.  
        else if p-moeda = "CHP"
        then ct-cartcl.recp-cart-pres = ct-cartcl.recp-cart-pres + p-valor.
        else if p-moeda = "BON" 
        then ct-cartcl.recp-ent-bonus = ct-cartcl.recp-ent-bonus + p-valor.  

    end.
    else if  p-tipo = "JURO ATRASO" 
    then do:
        if p-moeda = "REA" 
        then ct-cartcl.rec-juro-dinheiro = 
                    ct-cartcl.rec-juro-dinheiro + p-valor.  
        else if p-moeda = "BCO" 
        then ct-cartcl.rec-juro-banco =
                    ct-cartcl.rec-juro-banco + p-valor.
        else if  p-moeda = "CHV" or p-moeda = "PRE"
        then ct-cartcl.rec-juro-cheque = 
                    ct-cartcl.rec-juro-cheque + p-valor.
        else if  p-moeda = "CAR" or 
                 p-moeda = "PDM" or
                 p-moeda = "-"   or 
                 substr(p-moeda,1,1) = "T"
        then ct-cartcl.rec-juro-cartao =
                   ct-cartcl.rec-juro-cartao + p-valor.     
        else if p-moeda = "CHP"
        then ct-cartcl.recp-cart-pres = ct-cartcl.recp-cart-pres + p-valor. 
    end.
    end.
    else if p-onde = "FINANCEIRA"
    then do:
        if  p-moeda = "CAR" or
            /*p-moeda = "PDM" or
            p-moeda = "-"
            or*/ substr(p-moeda,1,1) = "T"
        then ct-cartcl.recp-fin-cartao = ct-cartcl.recp-fin-cartao + p-valor.  

    end. 
end procedure.                             
                                        
