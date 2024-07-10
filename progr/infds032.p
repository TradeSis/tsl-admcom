{admcab.i}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var vforne as int.
def var vdocum as int format ">>>>>>>>>9".
def var esqascend     as log initial yes.
def var vesqcom as char.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  CONSULTA","  PROCURA","  ESTORNA","  RELATORIO"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  LANCTB","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["",
            "",
            "",
            "",
            ""].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


def buffer bmodal for modal.

form fatudesp.fatnum  format ">>>>>>>>9"  column-label "Documento"
     fatudesp.etbcod  format ">>9"        column-label "Fil"
     fatudesp.modcod  format "x(3)"       column-label "MFin"
     modal.modnom     format "x(15)"      no-label
     fatudesp.modctb  format "x(3)"       column-label "MCtb"
     bmodal.modnom    format "x(14)"      no-label
     fatudesp.inclusao                    column-label "Inclusao"
     fatudesp.val-total  format ">>>,>>9.99"  column-label "Valor"
     fatudesp.situacao   format "x" no-label
     with frame f-linha 12 down color with/cyan /*no-box*/
      title " DESPESAS LIBERADAS " width 78.

def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color  = with/cyan
        &file   = fatudesp   
        &cfield = fatudesp.fatnum
        &noncharacter = /* 
        &ofield = " fatudesp.fatnum
                    fatudesp.etbcod
                    fatudesp.modcod
                    modal.modnom when avail modal
                    fatudesp.modctb
                    bmodal.modnom when avail bmodal
                    fatudesp.inclusao
                    fatudesp.val-total
                    fatudesp.situacao
                    "  
        &aftfnd1 = " find modal where modal.modcod = fatudesp.modcod
                        no-lock no-error.
                     find bmodal where bmodal.modcod = fatudesp.modctb
                        no-lock no-error.
   
                        "
        &where  = " fatudesp.situacao = ""F"" "
        &aftselect1 = " 
                        run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  LANCTB"" or
                           esqcom2[esqpos1] = ""  LIBERA""
                        then do:
                            next l1.
                        end.
                        else do:
                            if esqcom1[esqpos1] = ""  CONSULTA""
                            then disp esqcom2 with frame f-com2.
                            next keys-loop. 
                        end.
                            "
                    
        &go-on = " TAB p P "
        &naoexiste1 = "  " 
        &otherkeys1 = " 
                        if keyfunction(lastkey) = ""p"" or
                           keyfunction(lastkey) = ""P""
                        then do:
                            vesqcom = esqcom1[esqpos1].
                            esqcom1[esqpos1] = ""  PROCURA"".
                            run aftselect.
                            esqcom1[esqpos1] = vesqcom.
                            next keys-loop.
                        end.
                        run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    
    def var vtitsit like titulo.titsit.

    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  CONSULTA"
    THEN DO on error undo:

        disp fatudesp.fatnum format ">>>>>>>>9"
         fatudesp.emissao
         fatudesp.val-total 
         fatudesp.val-icms
         fatudesp.val-ipi
         fatudesp.val-acr
         fatudesp.val-des
         fatudesp.val-iR    
         fatudesp.val-iss
         fatudesp.val-inss
         fatudesp.val-pis
         fatudesp.val-cofins
         fatudesp.val-csll
         fatudesp.val-liq
         fatudesp.qtd-par
         with frame f-doc 1 down side-label 1 column
         row 5 overlay 
         .

        for each titulo where titulo.empcod = 19 and
                              /*titulo.titnat = yes       and */
                              /*titulo.modcod = fatudesp.modcod and*/
                              titulo.etbcod = fatudesp.etbcod and
                              titulo.clifor = fatudesp.clicod and
                              titulo.titnum = string(fatudesp.fatnum) and
                              titulo.titdtemi = fatudesp.inclusao
                           NO-LOCK .
            disp titulo.titnum   format "x(10)"
                 titulo.titpar   format ">>9"
                 titulo.titdtven format "99/99/99"
                 titulo.titvlcob format ">>>,>>9.99"  column-label "Valor"
                 titulo.titbanpag column-label "Set"
                 titulo.titsit column-label "Sit" format "x(3)"
                 with frame f-tit column 33 row 5 down width 47.              
        end.

    END.
    def var vestorna as log.
    if esqcom1[esqpos1] = "  ESTORNA"
    THEN DO:
        if fatudesp.situacao = "F"
        then do:
            
            vestorna = yes.
            
            for each titulo where
                    titulo.empcod = 19 and
                    titulo.etbcod = fatudesp.etbcod and
                    titulo.clifor = fatudesp.clicod and
                    titulo.titnum = string(fatudesp.fatnum) and
                    titulo.titdtemi = fatudesp.inclusao 
                    no-lock:
                    
                if titulo.titsit <> "LIB" and
                   titulo.titsit <> "BLO"
                then assign
                        vtitsit = titulo.titsit
                        vestorna = no.
            end.
            if vestorna = no
            then do:
                bell.
                message color red/with
                "Situaçao " vtitsit " não permite ESTORNO"
                view-as alert-box.
            end.        
            else do:
             sresp = no.
            Message "Confirma ESTORNAR?" update sresp.
            if sresp
            then do on error undo:
                for each titulo where
                    titulo.empcod = 19 and
                    /*titulo.titnat = yes and
                    titulo.modcod = fatudesp.modcod and*/
                    titulo.etbcod = fatudesp.etbcod and
                    titulo.clifor = fatudesp.clicod and
                    titulo.titnum = string(fatudesp.fatnum) and
                    titulo.titdtemi = fatudesp.inclusao
                    :
                    titulo.titsit = "BLO".
                end.   
                fatudesp.situacao = "A".
                create tbcntger.
                assign
                    tbcntger.tipo_cnt = 3
                    tbcntger.data_cnt = today
                    tbcntger.hora_cnt = time 
                    tbcntger.documento_cnt = "DESPESA"
                    tbcntger.tabela_cnt = "fatudesp"
                    tbcntger.id_tabela_cmt = recid(fatudesp)
                    tbcntger.dtinclu_cnt = today
                    tbcntger.int1 = setbcod
                    tbcntger.int2 = sfuncod
                    .  
            end.
            end.
        end.
    END.
    if esqcom1[esqpos1] = ""
    THEN DO:
        /*
        sresp = no.
        message "Confirma EXCLUIR documento?"
        update sresp.
        if sresp
        then run exclui-documento(recid(fatudesp)).
        */
    END.
    if esqcom1[esqpos1] = "  PROCURA"  
    then do:
        vforne = 0.
        vdocum = 0.
        
        update vforne label "Fornecedor"
               vdocum label "Documento"
               with frame f-procura
               1 down side-label centered row 10 OVERLAY.
               .
        HIDE FRAME F-PROCURA.
        
        find first fatudesp where 
              (if vforne > 0 then
             fatudesp.clicod = vforne else true) and
              (if vdocum > 0 then fatudesp.fatnum = vdocum   else true)
              and fatudesp.situacao = "F"
             no-lock no-error.
        if avail fatudesp
        then    assign
                a-seeid = -1
                a-recid = recid(fatudesp).
        else do:
            bell.
            message color red/with
            "Documento não encontrato!"
            view-as alert-box.
        end.     
    end.
    if esqcom1[esqpos1] = "  RELATORIO"
    then do:
        sresp = no.
        message "Confirma relatorio?" update sresp.
        if sresp
        then run relatorio.
    end.
    if esqcom2[esqpos2] = "  LANCTB"
    THEN DO on error undo:
        run infds031.p(recid(fatudesp)).
    END.
                      
end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

/****
procedure relatorio:
    def input parameter p-recid as recid.
    
    /*
    def var vdata as date.
    def var vdti  as date.
    def var vdtf  as date.
    def var vsetcod like setaut.setcod.
    def var vetbcod like estab.etbcod.
    def var vforcod like forne.forcod.
    def var vfatnum like fatudesp.fatnum format ">>>>>>>>9".
    */

    def var vtotal-tit as dec.
    
    def var vetbfun as int.
    def var vfuncod as int.
    def var varquivo as char.

    varquivo = "/admcom/relat/infds030." + string(time).

    {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "80" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""tablan"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LISTAGEM DESPESAS SETOR"""
                        &Width     = "80"  
                        &Form      = "frame f-cabcab"}
                        .
 
    for each fatudesp where recid(fatudesp) = p-recid
         no-lock:

        find forne where forne.forcod = fatudesp.clicod no-lock.    
        find modal where modal.modcod = fatudesp.modcod no-lock. 
    
        vetbfun = int(acha("FIL", fatudesp.char1)).
        vfuncod = int(acha("FUN", fatudesp.char1)). 
        find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.
        disp fill("=",80) format "x(80)"
         fatudesp.etbcod to 40 label "Filial"
         fatudesp.setcod to 40
         func.funcod to 40 when avail func
         func.funnom no-label when avail func
         fatudesp.modcod to 40 label "Modalidade FIN"
         fatudesp.modctb to 40 label "Modalidade CTB"
         fatudesp.fatnum  to 40
         fatudesp.clicod  to 40
         forne.fornom    no-label
         fatudesp.emissao   to 40
         fatudesp.inclusao  to 40 label "Data Inclusao"
         fatudesp.val-total to 40 label "Valor Total"
         fatudesp.val-icms  to 40 label "Valor ICMS"
         fatudesp.val-ipi   to 40 label "Valor IPI"
         fatudesp.val-acr   to 40 label "Valor Acrescimo"
         fatudesp.val-des   to 40 label "Valor Desconto"
         fatudesp.val-ir    to 40 label "Valor IRRF"
         fatudesp.val-iss   to 40 label "Valor ISS" 
         fatudesp.val-inss  to 40 label "Valor INSS"
         fatudesp.val-pis   to 40 label "Valor PIS" 
         fatudesp.val-cofins to 40 label "Valor COFINS"
         fatudesp.val-csll   to 40  label "Valor CSLL"
         fatudesp.val-liquido to 40 label "Valor Liquido" 
         fatudesp.qtd-parcela to 40 label "Quantidade Parcelas"
         with frame f-disp  side-label
         width 100
             .
        vtotal-tit = 0.
        for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and*/
             titulo.etbcod = fatudesp.etbcod and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp .fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titnum:

             vtotal-tit = vtotal-tit + titulo.titvlcob.
            
            if last-of(titulo.titnum)
            then do:  
                disp titulo.titnum
                    titulo.titpar
                    titulo.titdtemi
                    titulo.titdtven
                    vtotal-tit  format ">,>>>,>>9.99"
                    with frame ftit-t width 100 down
                    .
                vtotal-tit = 0.
            end.
            down with frame ftit-t.
        end.         
    end.             

    put skip(60).
    page.
    put skip(5).
    for each fatudesp where recid(fatudesp) = p-recid
         no-lock:
        
        find forne where forne.forcod = fatudesp.clicod no-lock.    
        find modal where modal.modcod = fatudesp.modcod no-lock. 
        
        vetbfun = int(acha("FIL", fatudesp.char1)).
        vfuncod = int(acha("FUN", fatudesp.char1)). 
        find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.
        
        vtotal-tit = 0.
        
        for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and*/
             titulo.etbcod = fatudesp.etbcod and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp .fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titulo.titnum:
             
             vtotal-tit = vtotal-tit + titulo.titvlcob.
             
             if last-of(titulo.titnum)
             then do:
                disp 
                fatudesp.etbcod at 1 label "Filial"
                fatudesp.setcod
                func.funcod when avail func
                func.funnom no-label when avail func
                fatudesp.modcod
                modal.modnom no-label 
                fatudesp.fatnum
                fatudesp.clicod
                forne.fornom    no-label
                fatudesp.emissao   
                fatudesp.inclusao  
                with frame f-disp1  side-label
                width 100
                .
                disp titulo.titnum
                    titulo.titpar
                    titulo.titdtemi
                    titulo.titdtven
                    vtotal-tit  format ">,>>>,>>9.99"
                     with frame ftit1 width 100 down
                 .
                down with frame ftit1.
                vtotal-tit = 0.
                put skip(20).
            end.
        end.         
    end.  
    OUTPUT CLOSE.
    run visurel.p(varquivo,"").
 
end procedure.
***/

procedure exclui-documento:
    def input parameter p-recid as recid.
    def var deletou-lancxa as log.
    def buffer btitulo for titulo.
    def buffer bfatudesp for fatudesp.
    
    
    find first bfatudesp where
            recid(bfatudesp) = p-recid
            no-error.
    if avail bfatudesp
    then do:
        
        
        for each titulo where

                 titulo.empcod = 19 and
                 /*titulo.titnat = yes and
                 titulo.modcod = bfatudesp.modcod and*/
                 titulo.etbcod = bfatudesp.etbcod and
                 titulo.clifor = bfatudesp.clicod and
                 titulo.titnum = string(int(bfatudesp.fatnum)) and
                 titulo.titdtemi = bfatudesp.inclusao
                 :
                {ctb02.i}
                
                run pi-elimina-titcircui(recid(titulo)).
                delete titulo.
                recatu1 = recatu2.
                hide frame fitulo no-pause.

        end.
        deletou-lancxa = no.
        for each lancxa where 
                 lancxa.datlan = bfatudesp.inclusao and
                 lancxa.titnum = string(int(bfatudesp.fatnum))    and
                 lancxa.modcod = bfatudesp.modctb and
                 lancxa.etbcod = bfatudesp.etbcod
                                      :
            delete lancxa.
            deletou-lancxa = yes.
        end.
        
        delete bfatudesp.

        if deletou-lancxa = no
        then do:
            message color red/with
                "Nao Excluiu lancamento na contabilidade"
                view-as alert-box.
        end.

    end.    
 
end procedure.

Procedure pi-elimina-titcircui.

def input parameter p-recatu1 as recid.

def buffer btitulo for titulo.

find first btitulo where recid(btitulo) = p-recatu1 no-lock no-error.

for each titcircui where titcircui.titnum = titulo.titnum:
    delete titcircui.
end.

end procedure.

procedure relatorio:

    def var vdata_libera as date init today format "99/99/9999".
    
    update vdata_libera label "Informe a data"
        help "Informe a data da liberacao"
        with frame f-rel 1 down centered row 10 side-label.

    def var varquivo as char.

    varquivo = "/admcom/relat/infds032." + string(time).
    {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "80" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""tablan"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LIBERACAO DESPESAS SETOR"""
                        &Width     = "80"  
                        &Form      = "frame f-cabcab"}
                        .
 
    put "Data Libera: " vdata_libera skip.
            
    for each tbcntger where
             tbcntger.tipo_cnt = 1 and
             data_cnt = vdata_libera
             no-lock:
                  
        find fatudesp where recid(fatudesp) = tbcntger.id_tabela_cmt
                      no-lock no-error.
 
        if not avail fatudes or fatudesp.situacao <> "F"
        then next.
        
        disp fatudesp.fatnum      column-label "Documento"  format ">>>>>>>>9"
             fatudesp.clicod      column-label "Fornecedor" format ">>>>>>>>9"
             fatudesp.emissao     column-label "Emissao"  format "99/99/9999"
             fatudesp.inclusao    column-label "Inclusao" format "99/99/9999"
             fatudesp.val-liq     column-label "Val Liquido" 
                                format ">>,>>>,>>9.99"
             fatudesp.qtd-parcelas     column-label "Parcelas" format ">>>9"
             string(tbcntger.hora_cnt,"hh:mm:ss")  column-label "Hora"
             with frame f-disp down
             .
             
    end.    
    output close.
    run visurel.p(varquivo,"").
    
end procedure.

