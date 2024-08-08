/* #1 06.06.17 Helio - Alteracao incluindo colunas por tipo de carteira */
/* #2 16.06.17 Helio - Procedure que retorno rpcontrato vlnominla e saldo */
/* #3 Helio 04.04.18 - Versionamento com Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/

{admcab.i}
{setbrw.i}

/* #2 */
def var par-parcial as log column-label "Par!cial" format "Par/Ori".
def var par-parorigem like titulo.titpar column-label "Par!Ori".
def var par-titvlcob as dec column-label "VlCarteira".
def var par-titdtpag as date column-label "DtPag".
def var par-titvlpag as dec column-label "VlPago".
def var par-saldo as dec column-label "VlSaldo".
def var par-tpcontrato as char format "x(1)" column-label "Tp".
def var par-titdtemi as date column-label "Dtemi".
def var par-titdesc as dec column-label "VlDesc".
def var par-titjuro as dec column-label "VlJuro".
/* #2 */

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","RELATORIO","CLIENTE","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.
            
def var vclinovos as log format "Sim/Nao".
def buffer btitulo for titulo.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tt-modalidade-padrao 
    field modcod as char
    index pk modcod.

def NEW SHARED temp-table tt-modalidade-selec /* #4 */
    field modcod as char.
/*             
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.
*/
def var vval-carteira as dec.                                
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
        with frame f-nome
             centered down title "Modalidades"
             color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.        
end.

form
 esqcom1
    with frame f-com1
                 row 3  no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.

def var etb-tit like titulo.etbcod.

def var vcre as log format "Geral/Facil" initial yes.

/*
def temp-table tt-cli
    field clicod like clien.clicod.
*/

def temp-table tt-clinovo
    field clicod like clien.clicod
    index i1 clicod.

def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for titulo.

def var vdt like titulo.titdtven.
def var vdti like titulo.titdtven.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var varquivo as char format "x(30)".
def var vdtf like titulo.titdtven.
def var wcrenov like titulo.titvlcob.

def temp-table wtit no-undo /* #1 */
    field wetb like titulo.etbcod
    field wvalor like titulo.titvlcob
    /* #1 */
    field fei    like titulo.titvlcob
    field lp     like titulo.titvlcob
    field nov    like titulo.titvlcob
    field cre    like titulo.titvlcob
    /* #1 */
    field wpar   like titulo.titpar format ">>>>>>9"
    index i1 wetb.
                    

    
def temp-table tt-clien no-undo
    field clicod like clien.clicod
    field mostra as log init no
    index ind01 clicod.
    
def temp-table bwtit no-undo
    field bwetbcod like titulo.etbcod
    field bwclifor like titulo.clifor
    field bwtitvlcob like titulo.titvlcob
    field bwtitdtven like titulo.titdtven.

vdti = today - 1.
vdtf = vdti.

def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int. 

repeat:
    
    update vcre label "Cliente" colon 25
           help "Opcao: G=Geral; F=Carteira fácil"
           vdti label "Data Inicial"  colon 25
           vdtf label "Data Final"  colon 25
           skip
           vclinovos label 
           "Somente clientes novos(até 30 pagas) que atrasaram parcela(s)"
           with frame f1 side-label width 80.
           
    assign sresp = false.
           
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with frame f1.

    
    update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
        when vcre = no /* #1 */
           with frame f1.
             
    /************          
    if sresp
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
    
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
        
    display vmod-sel format "x(40)" no-label with frame f1.
    ******/
    if sresp
then run selec-modal.p ("REC"). /* #4 */
else do:
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = "CRE".
end.

assign vmod-sel = "  ".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
end.
display vmod-sel format "x(40)" no-label with frame f1.

       
    if vdti = ? or vdtf = ?
       or vdti > vdtf 
    then do:
         message "Data invalida...".
         Next.
    end.     

    vindex = 0.
    repeat on endkey undo:
         disp v-fil17 with frame f-17 1 down centered row 12 
            no-label title " Filial 17 ".
         choose field v-fil17 with frame f-17.
         vindex = frame-index.  
         leave. 
    end.

    if vcre = no
    then do:
/*    
        for each tt-cli:
            delete tt-cli.
        end.
        
        for each clien where clien.classe = 1 no-lock:
    
            display clien.clicod
                    clien.clinom
                    clien.datexp format "99/99/9999" with 1 down. pause 0.
    
            create tt-cli.
            assign tt-cli.clicod = clien.clicod.
        end.
        */
    end.    

    
    for each wtit.
        delete wtit.
    end.
    
/* Banfin */

    if vcre 
    then do:
        
        for each estab no-lock:
        
            do vdt = vdti to vdtf:
                for each tt-modalidade-selec no-lock,
                
                    each titulo
                    where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = tt-modalidade-selec.modcod and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtven = vdt no-lock:

                    if titulo.etbcod = 17 and
                        vindex = 2 and
                        titulo.titdtemi >= 10/20/2010
                    then next.  
                    else if titulo.etbcod = 17 and
                        vindex = 1 and
                        titulo.titdtemi < 10/20/2010
                    then next.

                    etb-tit = titulo.etbcod.
                    run muda-etb-tit.

                    /** {filtro-feiraonl.i} #1 */
                    
                    if vclinovos = yes
                    then do:
                        run cli-novo.
                    end.

                    find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
                    if not avail tt-clinovo 
                    and vclinovos
                    then next. 
                    
                    find first wtit where wtit.wetb = etb-tit 
                        no-error.
                    if not avail wtit
                    then do:
                        create wtit.
                        assign wtit.wetb = etb-tit.
                    end.    

                    par-tpcontrato = titulo.tpcontrato.
                        /* #2
                    run fbtituloposicao.p 
                        (recid(titulo), 
                         vdtf,
                         output par-parcial,
                         output par-parorigem,
                         output par-titdtemi,
                         output par-tpcontrato,
                         output par-titvlcob,
                         output par-titdtpag,
                         output par-titvlpag ,
                         output par-titdesc ,
                         output par-titjuro,
                         output par-saldo).
                      */

                    wtit.wvalor = wtit.wvalor + titulo.titvlcob.
                    wtit.wpar   = wtit.wpar   + 1.
                    
                    /* #1 */
                    /* #3 - regra esta correta */
                    if  /* #3 se FEIRAO ou TPCONTRATO = "L"
                              nao pertence a carteira
                        */      
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" or
                       titulo.tpcontrato = "L"  /* #3 */
                    then do:
                        /* #3  PRIORIZA FEIRAO */
                        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then 
                          wtit.fei = wtit.fei + titulo.titvlcob.
                        else
                          wtit.lp  = wtit.lp  + titulo.titvlcob.
                    end.
                    else do:
                        if titulo.tpcontrato = "N"  /* #3 */
                        then
                           wtit.nov  = wtit.nov + titulo.titvlcob.
                        else
                           wtit.cre  = wtit.cre + titulo.titvlcob.
                    end.                
                    /* #3 */
                    /* #1 */

                    display wtit.wetb titulo.clifor wtit.wvalor wtit.wpar
                            vdt with 1 down. 
                    create bwtit.
                    assign bwtit.bwetbcod = etb-tit
                           bwtit.bwclifor = titulo.clifor
                           bwtit.bwtitvlcob = titulo.titvlcob
                           bwtit.bwtitdtven = titulo.titdtven.
                    pause 0.
                end.
            end.
        end.
    end.
    else do:
        for each /* tt-cli */ clien where clien.classe = 1 NO-LOCK,
        
            each tt-modalidade-selec,
        
            each titulo use-index iclicod where 
                              titulo.clifor = clien.clicod and
                              titulo.empcod = 19    and
                              titulo.titnat = no    and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtven >= vdti and
                              titulo.titdtven <= vdtf     
                                   no-lock: 
            
                if titulo.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.  
                else if titulo.etbcod = 17 and
                     vindex = 1 and
                     titulo.titdtemi < 10/20/2010
                then next.

                etb-tit = titulo.etbcod.
                
                run muda-etb-tit.

                par-tpcontrato = titulo.tpcontrato.
                /* #2
                    run fbtituloposicao.p 
                        (recid(titulo), 
                         vdtf,
                         output par-parcial,
                         output par-parorigem,
                         output par-titdtemi,
                         output par-tpcontrato,
                         output par-titvlcob,
                         output par-titdtpag,
                         output par-titvlpag ,
                         output par-titdesc ,
                         output par-titjuro,
                         output par-saldo).
                */

 
                {filtro-feiraonl.i}

                if vclinovos = yes
                then do:
                    run cli-novo.
                end.

                find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
                if not avail tt-clinovo 
                    and vclinovos
                then next. 
            
                find first wtit where wtit.wetb = etb-tit no-error.
                if not avail wtit
                then do:
                    create wtit.
                    assign wtit.wetb = etb-tit.
                end.    
                wtit.wvalor = wtit.wvalor + titulo.titvlcob.
                wtit.wpar   = wtit.wpar   + 1.
                display wtit.wetb wtit.wvalor wtit.wpar with 1 down.
                create bwtit.
                assign bwtit.bwetbcod = etb-tit
                       bwtit.bwclifor = titulo.clifor
                       bwtit.bwtitvlcob = titulo.titvlcob
                       bwtit.bwtitdtven = titulo.titdtven.  
                pause 0.
            end.
    end.
   
    /*Adri*/
    run p-montabrow.
    
            
end.

procedure muda-etb-tit.

    if etb-tit = 10 and
        titulo.titdtemi < 01/01/2014
    then etb-tit = 23.
    
end procedure.
                    
procedure p-montabrow:

disp "                              CONTROLE DE CARTEIRA  " 
            with frame f3 1 down width 80                                       
            color message no-box no-label row 4 centered.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    assign a-seeid= -1 a-recid = -1 a-seerec = ? 
           esqpos1 = 1 esqpos2 = 1. 
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = wtit 
        &cfield = wtit.wetb
        &noncharacter = /* 
        &ofield = "wvalor wpar "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " run aftselect.
                       /*a-seeid = -1.*/
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
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

end procedure. /*p-montabrow*/  

procedure relatorio:

    if opsys = "UNIX"
    then  varquivo = "../relat/frrescart" + string(day(today)) + "_" +
                                            string(time) + ".txt".
    else  varquivo = "..\relat\cartw" + string(day(today)).
 
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""frrescart1801"" /* #1 */
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """MOVIMENTO DA CARTEIRA POR FILIAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "140"
            &Form      = "frame f-cabcab"}

    for each wtit use-index i1:
        wcrenov = wtit.nov + wtit.cre. /* #1 */
        disp wtit.wetb column-label "Filial"
             wtit.wvalor(total) column-label "(1+2+3+4) Vl.Total"
             wtit.wpar(total) column-label "Tot.Par"
              /* #1 */
             wtit.fei (total) column-label "(1) Feirao"
             wtit.lp  (total) column-label "(2) LP" 
             wtit.nov (total) column-label "(3) Novacao"
             wtit.cre (total) column-label "(4) Venda"
             wcrenov (total) column-label "(3+4) Crediario"
             /* #1 */
             with frame f2 down width 140.
    end.            
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.     
    
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

procedure aftselect:

    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "RELATORIO"
    THEN DO on error undo:
       run relatorio.
    END.
    if esqcom1[esqpos1] = "CLIENTE"
    THEN DO:
        run p-cliente.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure p-cliente:

    if opsys = "UNIX"
    then  varquivo = "../relat/cartlc" + string(day(today)).
    else  varquivo = "..\relat\cartwc" + string(day(today)).
 
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""CARTE1c""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """CARTEIRA CLIENTES POR FILIAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "80"
            &Form      = "frame f-cabcab"}

    for each bwtit where
             bwtit.bwetbcod = wtit.wetb
             no-lock:
        disp bwtit.bwetbcod   column-label "Filial"
             bwtit.bwclifor   column-label "Cliente"
             bwtit.bwtitvlcob column-label "Valor Parc." 
             bwtit.bwtitdtven   column-label "Data Vencto."
             with frame f2 down width 130.
    end.            
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
        /*dos silent value("type " + varquivo + " > prn").
        */
    end.     
    
end procedure.

procedure cli-novo:
    find first tt-clinovo where
               tt-clinovo.clicod = titulo.clifor
               no-error.
    if not avail tt-clinovo
    then do:
        par-paga = 0.
        pag-atraso = no.

        for each ctitulo where
                 ctitulo.clifor = titulo.clifor 
                 no-lock:
            if ctitulo.titpar = 0 then next.
            if ctitulo.modcod = "DEV" or
                ctitulo.modcod = "BON" or
                ctitulo.modcod = "CHP"
            then next.
 
            if ctitulo.titsit = "LIB"
            then next.

            par-paga = par-paga + 1.
            if par-paga = 31
            then leave.
            if ctitulo.titdtpag > ctitulo.titdtven 
            then pag-atraso = yes.   
            
        end.
        find first posicli where posicli.clicod = titulo.clifor
               no-lock no-error.
        if avail posicli
        then par-paga = par-paga + posicli.qtdparpg.
            
        find first credscor where credscor.clicod = titulo.clifor
                        no-lock no-error.
        if avail credscor
        then  par-paga = par-paga + credscor.numpcp.
        
        if par-paga <= 30 and pag-atraso = yes
        then do:   
            create tt-clinovo.
            tt-clinovo.clicod = titulo.clifor.
        end.
    end. 
end procedure.



procedure p-seleciona-modal:
            
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
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

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




