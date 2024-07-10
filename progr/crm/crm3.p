{admcab.i}

def var vdata-ini as date format "99/99/9999".
def var vdata-fin as date format "99/99/9999".

def var w1 as int.
def var w2 as int.
def var w3 as int.
def var vpcod as char.
def var vfcod as char.
def var vccod as char.

/* Temps retiradas passamos a utilizar buffer de tabela */
/*
def new shared temp-table tt-fabricantes
    field clicod as int
    field fabcod as int
    index i-prif is primary unique clicod fabcod.
    
def new shared temp-table tt-produtos
    field clicod as int
    field procod as int
    index i-prip is primary unique clicod procod.
    
 def new shared temp-table tt-classes
    field clicod as int
    field clacod as int
    index i-pric is primary unique clicod clacod.
*/

def /*new shared*/ buffer tt-produtos    for crmprodutos.
def /*new shared*/ buffer tt-classes     for crmclasses.
def /*new shared*/ buffer tt-fabricantes for crmfabricantes.

def var vsenha as char format "x(8)". 
def var fre    as dec.
def var val    as dec.

def var rodar-media as log format "Sim/Nao".

/*
do on error undo:
    vsenha = "".
    update vsenha blank  label "Senha"
        with frame f-senha side-labels centered.
    
    if vsenha <> "colorado"
    then undo.
end.
hide frame f-senha no-pause.
*/

def var vcatcod like categoria.catcod.

def new shared var vri as date format "99/99/9999" extent 5.
def new shared var vrf as date format "99/99/9999" extent 5.

def new shared var vfi as inte extent 5 format ">>>>>>>9".
def new shared var vff as inte extent 5 format ">>>>>>>9".

def new shared var vvi as dec format ">>>,>>9.99" extent 5.
def new shared var vvf as dec format ">>>,>>9.99" extent 5.
/*
def new shared temp-table crm
    field clicod     like clien.clicod
    field nome       like clien.clinom format "x(30)"
    field mes-ani     as int
    field email       as log format "Sim/Nao"
    field sexo        as log format "Masculino/Feminino"
    field est-civil   as int 
    field idade       as int
    field dep         as log format "Sim/Nao"
    field cidade      as char
    field bairro      as char 
    field celular     as log format "Sim/Nao"
    field residencia  as log format "Propria/Alugada"
    field profissao   as char
    field renda-mes   as dec
    field renda-tot   as dec
    field spc         as log format "Sim/Nao" 
    field carro       as log format "Sim/Nao"    
    field mostra      as log format "Sim/Nao"    
    field valor      as   dec format ">>>,>>9.99"
    field limite     as   dec format ">,>>9.99"
    field recencia   as   date format "99/99/9999"
    field frequencia as   int label "Freq" format ">>>9"
    field rfv        as   int format "999"
    field produtos   as char
    field classes    as char 
    field fabricantes as char
    index iclicod clicod.
*/

def buffer crm for ncrm.

def new shared var i as i format ">>>>>>>>>>>>9".

def var vdt as date.

def new shared var vetbcod     like estab.etbcod.
def new shared var vetbcodfin  like estab.etbcod. 

def var vdata1  as   date format "99/99/9999".
def var vdata2  as   date format "99/99/9999".

def var iSemana    as   inte                       init 0           no-undo.
def var lProc      as   logi   form "Sim/Nao"      init no          no-undo.
def var dDtaPro    as   date   form "99/99/9999"                    no-undo.
def var dDtaNPr    as   date   form "99/99/9999"                    no-undo.
def new shared var cProce     as char  form "x(12)"        init ""  no-undo. 
def new shared var iseq       as   inte                    init 0   no-undo.
def var laviso     as   logi   form "Sim/Nao"              init no  no-undo.     
repeat:

    assign fre    = 0 
           val    = 0.
    
    find last ncrm no-lock no-error.
    if avail ncrm
    then assign dDtaPro = ncrm.dataProces.
    else assign dDtaPro = ?.
    

    do on error undo:
        disp vetbcod
             skip
             dDtaPro  label "Ultimo Processamento"
             /*lProc    label "     -      Reprocessar Dados" */
             with frame f-dados.
        update vetbcod
               /*lProc  label "     -      Reprocessar Dados"*/
               with frame f-dados width 80 side-labels.
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao Cadastrado".
                undo.
            end.    
            else disp estab.etbnom no-label with frame f-dados.
        end.
        else disp "Todos" @ estab.etbnom
                  with frame f-dados.
        if lProc    = no and
           vetbcod <> 0
        then do:
                find first ncrm where
                           ncrm.etbcod = vetbcod no-lock no-error.
                if not avail ncrm
                then do:
                      message "Nao existem registros para a filial solicitada"                               skip
                              "favor verificar e tente novamente!"
                              view-as alert-box.
                      undo, retry.
                end.
        end.     
             
        if lProc = yes 
        then do:
                message "Atencao se confirmar o processamento, o sistema" skip
                        "efetuara uma operacao que requer bastante tempo" skip
                        "para gravar os registros conforme a sua escolha"
                        view-as alert-box buttons yes-no 
                        title "ATENCAO" update laviso.
                if laviso = no
                then do:
                         undo, retry.    
                end.         
        end.          
    end.

    /*do on error undo:
        update skip
               vcatcod label "Departamento..."
               with frame f-dados.

        if vcatcod <> 0
        then do:
            find categoria  where categoria.catcod = vcatcod no-lock no-error.
            if not avail categoria
            then do:
                message "Departamento nao Cadastrado.".
                undo.
            end.
            else disp categoria.catnom no-label with frame f-dados.
               
        end.    
        else disp "Todos" @ categoria.catnom with frame f-dados.
    end.
    */

    vcatcod = 0.
    hide frame f-dados no-pause.
    
    find rfvparam where rfvparam.setor = vcatcod no-lock no-error.
    if not avail rfvparam 
    then do:
             undo.
    end. 
            
    assign vri[1] = rfvparam.recencia-i[1]
           vrf[5] = rfvparam.recencia-f[5].

    if lProc = yes
    then do:
            /* run crm20-tabe.p (input vetbcod). */
             find last ncrm no-lock no-error.
             if avail ncrm
             then assign i = ncrm.regis.
    end. /* Processar */
    else do:
            if vetbcod <> 0
            then do:
                    assign i = 0.
                    for each ncrm use-index ch03Crm where
                             ncrm.etbcod = /*(if vetbcod <> 0
                                            then vetbcod                 
                                            else ncrm.etbcod):*/ vetbcod
                                            no-lock.
                             assign i  =  i + 1.
                    end.
            end.        
            else do:
                    find last ncrm no-lock no-error.
                    if avail ncrm
                    then assign i = ncrm.regis.
            end.        
    end.
    /*
    for each tt-fabricantes:
        delete tt-fabricantes.
    end.    
    for each tt-produtos:
        delete tt-produtos.
    end.
    for each tt-classes:
        delete tt-classes.
    end.
    */
    
    hide frame fcrm no-pause.
    hide frame f-dados no-pause.
    hide message no-pause.
    
    for each ncrm where ncrm.etbcod = vetbcod 
                    and ncrm.mostra = yes.
        mostra = no.
    end.

    run crm/crm3brw3.p.

end.
