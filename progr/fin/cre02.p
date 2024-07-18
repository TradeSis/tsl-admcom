/* helio 07072022 - ajuste performance e leitura somente LP */
/* helio 25052022 - pacote melhorias cobranca */
/* #1 - 02.06.2017 - Voltou a testar pela acha do titobs[1] se é parcial */
/* #2 - 21.02.2020 - TP 35920071 - Titulo não disponível*/
{admcab.i}
{setbrw.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field etbcod                as int
    field cliente               as LOG
    field dtinicial             as DATE
    field dtfinal               AS DATE
    field relatoriogeral        AS LOG
    field sel-mod               AS CHAR
    field consultalp            AS LOG
    field considerarfeirao      AS LOG.
hentrada =  temp-table ttparametros:HANDLE.


/* variaveis usadas na tela para pedir parametros */    
def var vetbcod like estab.etbcod.
def var vcre as log format "Geral/Facil" initial yes.
def var vdtini      like titulo.titdtemi    label "Data Inicial".
def var vdtfin      like titulo.titdtemi    label "Data Final".
def var v-relatorio-geral as log format "Sim/Nao" label "Relatorio GERAL".
def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vpdf as char no-undo.

def var smodal as log format "Sim/Nao".
def var precestorno as recid.
def var i as int.   

def temp-table tt-cartpre  no-undo
    field seq    as int
    field numero as int
    field valor as dec.

def new shared var vqtdcart       as   int.
def new shared var vconta         as   int.
def new shared var vachatextonum  as char.
def new shared var vachatextoval  as char.
def new shared var vvalor-cartpre as int.

def temp-table wfresumo no-undo
    field etbcod    like estab.etbcod       column-label "Loja"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format "->>,>>>,>>9.99"
    field repar    like titulo.titvlcob    column-label "Reparc."
                                                  format ">>,>>>,>>9.99"
    field vista    like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->,>>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">,>>>,>>9.99"
    field entmoveis   like titulo.titvlcob    column-label "Ent.Movais"
                                                  format ">,>>>,>>9.99"
    field entmoda   like titulo.titvlcob    column-label "Ent.Moda"
                                                  format ">,>>>,>>9.99"             
    field entrep    like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">,>>>,>>9.99"
    field vlpago_etbcobra    like titulo.titvlpag    column-label "Valor Pago"
                                                  format "->>,>>>,>>9.99"
    field vlpago_total    like titulo.titvlpag    column-label "Total Pago"
                                                  format "->>,>>>,>>9.99"
                                                  
    field vlpago_etborigem    like titulo.titvlpag format "->>,>>>,>>9.99" column-label "Pgto.Orig." 
    field vltotal   like titulo.titvlpag    column-label "Valor Total"
                                                  format "->>>,>>>,>>9.99"
    field qtdcont   as   int column-label "Qtd.Cont" format ">>>,>>9"
    field juros     like titulo.titjuro     column-label "Juros"
    field qtdparcial as int format ">>>>>9"  column-label "Parcial"   
    field valparcial as dec             
    index i1 is unique primary etbcod asc.

def var v-parcela-lp as log.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.
def var vetbaux like vetbcod.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
            
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

def var vval-carteira as dec.                                


form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CPN".

for each profin no-lock.
    find modal of profin no-lock no-error.
    if not avail modal
    then next.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.
        
end.

repeat with 1 down side-label width 80 row 3:
  
    empty temp-table wfresumo. 
    
    update vetbcod label "Filial" colon 25.
    update vcre label "Cliente" colon 25 with side-label.

    update vdtini colon 25
           vdtfin colon 25.
           
    for each tt-modalidade-selec: delete tt-modalidade-selec. end.
          
    update v-relatorio-geral colon 25.
    if not v-relatorio-geral
    then do:
        update smodal label "Seleciona Modalidades?" colon 25
               help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
               with side-label width 80.
        if smodal
        then do:
            bl_sel_filiais:
            repeat:
                run p-seleciona-modal.
                                                      
                if keyfunction(lastkey) = "end-error"
                then leave bl_sel_filiais.
            end.
        end.
        else do:
            create tt-modalidade-selec.
            assign tt-modalidade-selec.modcod = "CRE".
        end.
        assign vmod-sel = "".
        for each tt-modalidade-selec.
            assign vmod-sel = vmod-sel + trim(tt-modalidade-selec.modcod) + ",".
        end.
        display vmod-sel format "x(40)" no-label.

        update v-consulta-parcelas-LP label " Considera apenas LP"
             help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"   ~       colon 25.
    
        update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25.
    end.
    else do:
        for each tt-modalidade-padrao:
            create tt-modalidade-selec.
            buffer-copy tt-modalidade-padrao to tt-modalidade-selec.
        end.
        assign vmod-sel = "".
        for each tt-modalidade-selec.
            assign vmod-sel = vmod-sel + trim(tt-modalidade-selec.modcod) + ",".
        end.
        
        display vmod-sel format "x(40)" no-label.
    end.
    
    i = 0.
    for each wfresumo. delete wfresumo. end.

    sresp = yes.
    message "Confirma relatorio?" update sresp.
    if not sresp then next.

    /* RUN */
    CREATE ttparametros.
    ttparametros.etbcod = vetbcod. 
    ttparametros.cliente = vcre.  
    ttparametros.dtinicial = vdtini.           
    ttparametros.dtfinal = vdtfin.              
    ttparametros.relatoriogeral = v-relatorio-geral.        
    ttparametros.sel-mod = vmod-sel.             
    ttparametros.consultalp = v-consulta-parcelas-LP.          
    ttparametros.considerarfeirao = v-feirao-nome-limpo.    
  
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN fin/cre02_run.p (INPUT  lcjsonentrada,
                         OUTPUT vpdf).

end.


procedure p-seleciona-modal:
          
for each tt-modalidade-selec: delete tt-modalidade-selec. end.
release tt-modalidade-padrao.
clear frame f-nome all.
hide frame f-nome no-pause.            
            
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    a-seelst = "".

l1: repeat:
    
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            a-seelst = """".
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
                disp ""* "" @ a-seelst
                    tt-modalidade-padrao.modcod
                    with frame f-nome.
                down with frame f-nome.
                
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
            pause .
            a-recid = -1.
            next .
        end. 
        if keyfunction(lastkey) = ""end-error""    
        then leave keys-loop.
            "
    &Form = " frame f-nome" 
}. 

    leave l1.
end.
hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.

end.
