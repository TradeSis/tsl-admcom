{admcab.i }.
                                        
{setbrw.i}.

disable triggers for load of reccar.

def temp-table tt-reccar like reccar.
def var varquivo as char.
def var vclfcod like clien.clicod.
def var i as int.
def var vdata as date.
def var v-datini as date.
def var v-datfim as date.
def var vdatrec like reccar.datrec.
def var vtitvlcob like reccar.titvlcob.
def var vnumres   like reccar.numres.      
def var vtitvldes like reccar.titvldes.
def var vtitvlpag like reccar.titvlpag.
def var vtotvlcob   like titulo.titvlcob.
def var vtotcar as dec.
def var vtotcob as dec. 
def var vtotvldes   like titulo.titvlcob.
def var vtotvlpag   like titulo.titvlcob.
def var vnumpar     like reccar.numpar.
def var v-desc like reccar.titvlcob.
def var v-liquido like reccar.titvlcob.
def var v-data as date.
def var v-op1 as char format "x(8)" extent 8.
def var v-op2 as char  format "x(15)" extent 8.
def var vindex as int.
def var vnumlote like reccar.lote format ">>>>>>>>9".
def var v-totvl as dec format ">>>,>>9.99".
def var v-totdesc as dec format ">>>,>>9.99".
def var v-totliq  as dec format ">>>,>>9.99".
def var v-rede    as char.
def var v-rede1   as int format "9".
def var vdown as int.
def var vrow as int.
def new shared var ind-alfa as char  init "a=1|b=2|c=3|d=4|e=5|f=6|g=7|h=8|i=9|j=10|k=11|l=12|m=13|n=14|o=15|p=16|q=17|r=1
8|s=19|t=20|u=21|v=22|x=23|y=24|z=25".
 
def new shared temp-table tt-cartao
    field moecod like cartao.moecod
    field rede   as char
    .
    
def var vi as int.
def var va as int.
for each cartao no-lock:
    create tt-cartao.
    tt-cartao.moecod = cartao.moecod.
    do va = 1 to length(cartao.moecod):
        tt-cartao.rede = tt-cartao.rede +
                acha(substr(cartao.moecod,va,1),ind-alfa).
    end.
end.    

def var v-acao as char extent 2 format "x(15)"
    init["MANUTENCAO","IMPORTAR DADOS"].
    
form
    v-datini  label "Inicio"
    v-datfim  label "Fim "
    with frame f-datas
        centered
        1 down
        overlay
        color yellow/cyan
        side-labels
        title " DATAS ".

form
    tt-reccar.etbcod    column-label "Fil" format ">>9"
    tt-reccar.datrec  column-label "Dt.Venda" format "99/99/99"
    tt-reccar.lote     format ">>>>>>>9"
    tt-reccar.numres column-label "Doc." format "x(6)"
    tt-reccar.numpar column-label "Par" format ">>>9"
    tt-reccar.titdtven column-label "Vencto" format "99/99/99"
    tt-reccar.titvlcob column-label "ValVenda" format "->>>>,>>9.99"
    tt-reccar.titvldes column-label "Desconto" format "->>,>>9.99"
    tt-reccar.titvlpag column-label "ValLiquido"  format "->>>,>>9.99"
    with frame f-consulta
       overlay width 80
        color black/cyan
        10 down row 7 .

form
    reccar.numpar column-label "Pc" format ">9"
    reccar.titdtven column-label "Vencimento" format "99/99/9999"
    reccar.titvlcob column-label "ValVenda" format ">>>,>>9.99"
    reccar.titvldes column-label "Desconto" format ">>9.99"
    reccar.titvlpag column-label "ValLiquido"  format ">>>,>>9.99"
    with frame f-mostra
        color black/cyan  column 35 overlay
        9 down row 8.   
        

form
    vclfcod   colon 15 label "Cliente"
    clien.clinom no-label
    vdatrec   colon 15
    vnumlote colon  15
    vnumres   colon 15
    vtitvlcob    format "->>,>>9.99"  colon 15
    vtitvldes column-label "Desconto"   format "->>9.99"  colon 15
    vtitvlpag column-label "Vlr.Liquido"  format "->>,>>9.99"  colon 15
    vnumpar colon 15 label "Parcelas"
    with frame f-inclu
        row 8
        side-labels
        overlay
        color yellow/cyan
        title " RECEBIMENTO DE CONVENIO ".

form
    reccar.datrec
    reccar.numres
    reccar.numpar                                 
    reccar.titdtven
    reccar.titvlcob
    reccar.titvldes column-label "Desconto" 
    reccar.titvlpag column-label "Vlr.Liquido"
    with frame f-impre
        centered
        down
        no-box.

form    vnumlote label "Lote"
        vnumres label "Documento"
     with frame f-exc 1 down centered side-label row 10 overlay
     title " excluir ".

form vnumlote label "Lote"
     vnumres label  "Documento"
     with frame f-proc 1 down centered side-label row 10 overlay
     title " procurar ".

def var vdti as date.
def var vdtf as date.

def var vbandeira like cartao.moecod.
def var vetbcod like estab.etbcod.
vetbcod = setbcod.
FORM vetbcod at 1 label "Filial" 
     estab.etbnom no-label  format "x(40)"
     vbandeira at 1 label "Bandeira"
     cartao.moenom no-label
     vdti at 1 label "Periodo de"
     vdtf label "Ate"
     with frame f-loja width 80  side-label  row 3
     title " " + string(v-acao[vindex]) + " ".
      
form
    with frame f-opcao
        centered
        1 down
        no-labels
        title " CONVENIOS "
        color yellow/blue.

DEF VAR VOK AS LOG.
FOR EACH cartao NO-LOCK:
    vi = vi + 1.
    v-op1[vi] = cartao.moecod.
    v-op2[vi] = cartao.moenom.
END.
disp v-acao with no-label with frame f-acao.
choose field v-acao with frame f-acao.
vindex = frame-index.

hide frame f-opcao no-pause.
def var vrede as char.
 
if vindex = 1
then run manutencao.
else run importacao.

return.

def var vb as char extent 3 format "x(10)"
        init["  VISA  "," MASTER "," BANRI "] 
    .
procedure importacao:
    VETBCOD = 0.
    /****
    update vetbcod with frame f-loja.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            bell.
            message "Loja nao Cadatrada".
            undo.
        end.
        display estab.etbnom with frame f-loja.
    end.
    DO on error undo:    
        vrede = "".
        update vbandeira with frame f-loja.    
        if vbandeira <> ""
        then do:
            find cartao where cartao.moecod = vbandeira no-lock.
            disp cartao.moenom with frame f-loja.
            do vi = 1 to length(vbandeira):
                vrede = vrede +
                    acha(substr(vbandeira,vi,1),ind-alfa).
            end.
        end.
    end.
    **/
    update vdti vdtf with frame f-loja.
    if vdti = ? or vdtf = ? or
        vdti > vdtf
    then return.
    disp vb with frame f-b 1 down centered no-label.
    choose field vb with frame f-b.
    vrede = vb[frame-index].      
    run imp_sitef.p ( input vrede, input vdti, input vdtf, 
                output varquivo, output vok ).
    
    if not vok
    then do:
            bell.
            message color red/with
            varquivo skip    
            "Arquivo nao encontrado."
            view-as alert-box.
            undo. 
    end.
end procedure.
DEF VAR VCARTAO AS CHAR.
procedure manutencao:
repeat :
    /*
    clear frame f-datas all.
    hide frame f-datas.
    clear frame f-consulta all.
    hide frame f-consulta.
    clear frame f-inclu all.
    hide frame f-inclu.
    clear frame f-opcao all.
    hide frame f-opcao no-pause.
    clear frame f-loja all.
    */
    VETBCOD = 0.
    /*
    update vetbcod with frame f-loja.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            bell.
            message "Loja nao Cadatrada".
            undo.
        end.
        display estab.etbnom with frame f-loja.
    end.
    DO on error undo:    
        vrede = "".
        update vbandeira with frame f-loja.    
        if vbandeira <> ""
        then do:
            find cartao where cartao.moecod = vbandeira no-lock.
            disp cartao.moenom with frame f-loja.
            do vi = 1 to length(vbandeira):
                vrede = vrede +
                    acha(substr(vbandeira,vi,1),ind-alfa).
            end.
        end.
    end.
    */
    do on error undo:
    update vdti vdtf with frame f-loja.
    if vdti = ? or vdtf = ? or
        vdti > vdtf
    then undo.    
    disp vb with frame f-b 1 down centered no-label.
    choose field vb with frame f-b.
    vrede = vb[frame-index].  
    find first  reccar where          
                reccar.titdtven >= vdti and
                reccar.titdtven <= vdtf 
                no-lock no-error.
    if not avail reccar
    then do:  
        bell.
        message color red/with
           "Nenum registro ENCONTRADO." skip
           "IMPORTAR ARQUIVO SITEF. "
            view-as alert-box.
        return.
        
    end.
    def var vmoeda as char.
    vcartao = trim(vrede).
    vrede = "".
    if vcartao = "VISA"
    then vmoeda = "RCV".
    else if vcartao = "MASTER"
        then vmoeda = "RCM".
        else if vcartao = "BANRI"
            then vmoeda = "RCB".
            else vmoeda = "".
        
    do va = 1 to length(vmoeda):
        vrede = vrede + acha(substr(vmoeda,va,1),ind-alfa).
    end. 
    
    vbandeira = vrede.
    l1: REPEAT:
        assign
            v-totdesc = 0
            v-totvl = 0
            v-totliq = 0.
        for each tt-reccar:
            delete tt-reccar.
        end.    
        for each reccar where 
                 reccar.titdtven >= vdti and
                 reccar.titdtven <= vdtf
                 no-lock:
            if vetbcod > 0 and
               vetbcod <> reccar.etbcod
            then next.
            if vbandeira <> "" and
                reccar.rede <> int(vrede)
            then next.    
            if reccar.titvlcob < 0
            then next.
                     
            assign
                v-totdesc = v-totdesc + reccar.titvldes
                v-totliq = v-totliq + reccar.titvlpag
                v-totvl = v-totvl + reccar.titvlcob.
            create tt-reccar.
            buffer-copy reccar to tt-reccar.
        end.        

        disp
            v-totvl     format "->>>>,>>9.99"  at 45
            v-totdesc   format "->>,>>9.99"
            v-totliq    format "->>>,>>9.99"
            with frame f-totais 1 down no-box 
                row 21 no-label.
                
        pause 0.
        CLEAR FRAME F-CONSULTA ALL.
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.
        {sklcls.i
            &help  = 
            "ENTER=Altera  F4=Sair  F8=Relatorio  "
            &color = normal
            &color1 = normal
            &File   = tt-reccar
            &CField = tt-reccar.datrec
            &OField = " tt-reccar.etbcod
                        tt-reccar.lote
                        tt-reccar.numres
                        tt-reccar.numpar
                        tt-reccar.titdtven
                        tt-reccar.titvlcob
                        tt-reccar.titvldes
                        tt-reccar.titvlpag "
            &naoexiste1 = "
                bell.
                message color red/with
                ""Nenum registro encontrado."".
                leave l1.
                "
            &color = "black/cyan"
            &Where = " true "
            &NonCharacter = /*
            &Aftselect1 = "
                if keyfunction(lastkey) = ""RETURN""
                then do:
                    update tt-reccar.titvlcob
                           tt-reccar.titvldes
                           tt-reccar.titvlpag
                           with frame f-consulta.
                    find reccar where 
                         reccar.etbcod = tt-reccar.etbcod and
                         reccar.rede   = tt-reccar.rede   and
                         reccar.lote   = tt-reccar.lote   and
                         reccar.numres = tt-reccar.numres and
                         reccar.numpar = tt-reccar.numpar
                         no-error.
                    if avail reccar
                    then do:
                        reccar.titvlcob = tt-reccar.titvlcob.
                        reccar.titvldes = tt-reccar.titvldes.
                        reccar.titvlpag = tt-reccar.titvlpag.
                    end.        
                    a-seeid = -1.
                    a-recid = recid(tt-reccar).
                    next keys-loop.
                end.
                "
            &otherkeys1 = "
                if keyfunction(lastkey) = ""GO""   or
                   keyfunction(lastkey) = ""CLEAR""
                then leave keys-loop.
                         "
            &Form = " frame f-consulta "
        }.
        if keyfunction(lastkey) = "end-error"
        then leave l1.
        if keyfunction(lastkey) = "GO"
        then do:
            run exporta-ctb.
        end.
        if keyfunction(lastkey) = "CLEAR"
        then do:
            run relatorio.
        end.
    END.                          
    hide frame f-totais no-pause.
    HIDE FRAME F-CONSULTA NO-PAUSE.
    end.
    leave.
end.
end procedure.
procedure exporta-ctb:
             
end procedure.
procedure relatorio:
    def var varquivo as char.
    if opsys = "unix"
    then varquivo = "/admcom/relat/reccar." + string(time).
    else varquivo = "l:\relat\reccar." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""rcartao""
        &Nom-Sis   = """SISTEMA FINANCEIRO/CONTABIL"""
        &Tit-Rel   = """ RECEBIMENTOS DE CARTAO - "" + VCARTAO" 
       &Width     = "100"
       &Form      = "frame f-cabcab"}
 
    disp with frame f-loja.
    
    for each tt-reccar:
        /*find first tt-cartao where 
                tt-cartao.rede =  string(tt-reccar.rede)
                .
        */        
        disp /*tt-reccar.etbcod   column-label "Fil"
             tt-cartao.moecod   column-label "Car"*/
             tt-reccar.lote     column-label "Nsu" format ">>>>>>>9"
             tt-reccar.numpar   column-label "Par" format ">>>>>9"
             tt-reccar.titdtven column-label "Vencto"
             tt-reccar.titvlcob(total) column-label "Valor" 
                            format "->>,>>>,>>9.99"
             tt-reccar.titvldes(total) column-label "Desc"
                            format "->>>,>>9.99"
             tt-reccar.titvlpag(total) column-label "Total"
                            format "->>,>>>,>>9.99"
             with frame f-disp down.
             
    end.
    output close.
    if opsys = "unix"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.