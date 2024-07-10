{admcab.i}
 
prompt-for complpmo.mescomp label "Competencia Mes/Ano" format "99"
        validate(input complpmo.mescomp > 0 ,"Informe o mes de competencia.")
           "/"
           complpmo.anocomp no-label  format "9999"
           validate(input complpmo.anocomp > 0,"Informe o ano de competencia.")
           with frame f-ma side-label width 80
           .
 
{setbrw.i}                                                                      
{seltpmo.i " " "PREMIO"}
def temp-table tt-contacor like contacor.

def var vsitbiss as char.

def var vpct as dec.
def var vtotal as dec.
def var vtipo as char.

def temp-table tt-previa no-undo
    field etbcod like estab.etbcod
    field funcod like estab.etbcod
    field funnom as char
    field meta as dec
    field meta-31 as dec
    field meta-41 as dec
    field venda as dec
    field venda-31 as dec
    field venda-41 as dec
    field premio like titluc.titvlcob
    field libera as log format "Lib/Blo"
    field funfol as char
    index i1 etbcod funcod funnom.

def buffer ztt-previa for tt-previa.

def temp-table tt-modal
    field modcod like foraut.modcod.

def buffer bmodgru for modgru.
def buffer bfunc for func.

find first modgru where modgru.modcod = "PEM" and
        modgru.mogsup = 0
        no-lock no-error.
if avail modgru
then for each bmodgru where 
              bmodgru.mogsup = modgru.mogcod  no-lock:
        create tt-modal.
        tt-modal.modcod = bmodgru.modcod.
    end.                        

find first tt-modal where tt-modal.modcod = "COM" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "COM".
end.
find first tt-modal where tt-modal.modcod = "PBM" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "PBM".
end. 
find first tt-modal where tt-modal.modcod = "PBC" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "PBC".
end.
find first tt-modal where tt-modal.modcod = "PMO" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "PMO".
end.      

def buffer bestab    for estab.
def buffer bcontacor for contacor. 

def var v-tem-parc-atraso as logical. 
def var v-tem-cont-ativo  as logical.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","Marca/Desmarca","  Previa","  Libera",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
def var vfunnom like func.funnom.

def var vm as char format "x".

form vm no-label
     complpmo.dtlanini column-label "DtLanIni"
     complpmo.dtlanfim column-label "DtLanFim"
     complpmo.etbcod   column-label "Filial"
     complpmo.forcod   column-label "Fornecedor"
     complpmo.vencod   column-label "Consultor"
     complpmo.setcod   column-label "Setor"
     complpmo.modcod   column-label "Modal"
     complpmo.situacao column-label "Sit"
     with frame f-linha 8 down color with/cyan /*no-box*/
     centered.
 
disp space(20) "LIBERACAO PAGAMENTO DE PREMIOS" space(20)  
            with frame f1 1 down centered width 80                                         color message no-box no-label row 7.
              
/*                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
*/
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var v-aux-numcor as int.

def temp-table tt-marca no-undo
    field rec as recid
    index i1 rec.
        
l1: repeat:
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
        &color = with/cyan
        &file = complpmo  
        &cfield = complpmo.dtlanini
        &noncharacter = /* 
        &ofield = " vm
                    complpmo.dtlanfim
                    complpmo.etbcod  when complpmo.etbcod > 0
                    complpmo.forcod  when complpmo.forcod > 0
                    complpmo.vencod  when complpmo.vencod > 0
                    complpmo.setcod  when complpmo.setcod > 0
                    complpmo.modcod  
                    complpmo.situacao
                    "  
        &aftfnd1 = " find first tt-marca where
                               tt-marca.rec = recid(complpmo) no-error.
                     if avail tt-marca
                     then vm = ""*"".
                     else vm = """".          
                               "
        &where  = " complpmo.anocomp = input frame f-ma complpmo.anocomp and
                    complpmo.mescomp = input frame f-ma complpmo.mescomp 
                    "
        &aftselect1 = " run aftselect.
                        /**
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  Exclui"" or
                           esqcom1[esqpos1] = ""  Altera""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. 
                        **/
                        
                        "
        &go-on = TAB 
        &naoexiste1 = " message color red/with
                        ""Nenhum registro.""
                        view-as alert-box.
                        leave l1.
                        "
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

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "marca/desmarca"
    THEN DO on error undo:
        find first tt-marca where
                   tt-marca.rec = recid(complpmo) no-error.
        if avail tt-marca
        then do:
            delete tt-marca.
            vm = "".
            disp vm with frame f-linha.
            pause 0.
        end.
        else do:           
            create tt-marca.
            tt-marca.rec = recid(complpmo).
            vm = "*".
            disp vm with frame f-linha.
            pause 0.
        end.    
    END.
    if esqcom1[esqpos1] = "  Libera"
    THEN DO:
        if complpmo.situacao = "F"
        then run libera("libera").
        else do:
            bell.
            message color red/with
            "Situacao " complpmo.situacao " nao permite liberar."
            view-as alert-box.
        end.    
    END.
    if esqcom1[esqpos1] = "  Previa"
    THEN DO:
        run libera("previa").
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

procedure relatorio:
    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

def var vmetaloja as log.
def temp-table tt-func
    FIELD ETBCOD LIKE ESTAB.ETBCOD
    field funcod like func.funcod
    field valven as dec.
    .
def var vmeta-mov as log.

procedure libera:
    find first tt-marca no-error.
    if not avail tt-marca
    then do:
        message color red/with
        "Marcar o(s) registro(s) para processamento."
        view-as alert-box.
        return.
    end.
    def input parameter p-tipo as char.
    def buffer btitluc for titluc.
    def var vquem as char.
    def var dti-venda as date format "99/99/9999".
    def var dtf-venda as date format "99/99/9999".
    def var vmeta as log.
    
    /*******************************
    V-TIPODES = acha("PREMIO",contacor.campo3[2]).
    if v-tipodes = ?
    then v-tipodes = "".
        disp contacor.etbcod at 1 label "Filial"
               with frame f-libera 1 down centered row 10 
               /*color message*/ side-label overlay
               title "    Parametros   " + v-tipodes + " ".
        if contacor.etbcod > 0
        then do:
            find bestab where bestab.etbcod = contacor.etbcod
                        no-lock.
            disp bestab.etbnom no-label with frame f-libera.
        end.
        disp contacor.funcod at 1 label "Funcionario" 
                        with frame f-libera.
        /*find func where func.etbcod = contacor.etbcod and
                        func.funcod = contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-libera .
        */
        disp contacor.setcod at 1 label "Setor"with frame f-libera.
        if contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-libera.
        end.
        disp contacor.datemi at 1 label "Data"  with frame f-libera.
        disp contacor.datemi at 1 label "Data Inicio do pagamento"  
                format "99/99/9999"
                with frame f-libera.
            
        disp contacor.datven at 1 label "Liberar Periodo de"
                    format "99/99/9999"
             contacor.datpag      label "Ate"  format "99/99/9999"
                 with frame f-libera. 
        sresp = no.
        def var vmeta as log format "Sim/Nao".
        if  acha("VALIDAR-META",contacor.campo3[1]) = "SIM"
        then vmeta = yes.
        else vmeta = no.

        dti-venda = date(acha("DTI-VENDA",contacor.campo3[1])).
        dtf-venda = date(acha("DTF-VENDA",contacor.campo3[1])).
 
        disp vmeta at 1 label "Validar Meta?" with frame f-libera.
        disp dti-venda at 1 label "Periodo de Venda de"
               dtf-venda label "Ate"
               with frame f-libera .
    *****************/
    
    vmeta = yes.

    for each tt-previa: delete tt-previa. end.
    def buffer btt-previa for tt-previa.
    sresp = no.
    if p-tipo = "PREVIA"
    THEN message "Confirma PREVIA de pagamento de premios ?" update sresp.
    else if p-tipo = "LIBERA"
         then message "Confirma liberar pagamento de premios ?" update sresp.
    if sresp
    then do  :
        for each tt-marca no-lock,
            first complpmo where recid(complpmo) = tt-marca.rec:
            assign
                dti-venda = complpmo.dtlanini
                dtf-venda = complpmo.dtlanfim
                .
            for each estab where
                     estab.etbnom begins "DREBES-FIL" and
                     (if complpmo.etbcod > 0
                      then estab.etbcod = complpmo.etbcod else true)
                      no-lock.
                
                vmetaloja = no.
                vmeta-mov = no.

                run validar-meta(dti-venda, dtf-venda).
                for each tt-modal no-lock, 
                    each titluc where 
                         titluc.empcod = 19 and
                         titluc.titnat = yes and
                         titluc.modcod = tt-modal.modcod and
                         titluc.titdtven >= dti-venda and
                         titluc.titdtven <= dtf-venda and
                         titluc.etbcod = estab.etbcod /*and
                         titluc.vencod > 0*/ no-lock:

                    if titluc.titsit = "LIB" or
                       titluc.titsit = "PAG" or
                       titluc.titsit = "FOL"
                    then next.
                    
                    if  complpmo.forcod <> ? and
                        complpmo.forcod > 0 and
                       titluc.clifor <> complpmo.forcod
                    then next.
                       
                    if complpmo.setcod > 0
                    then do:
                            find foraut where foraut.forcod = titluc.clifor
                                no-lock no-error.
                            if not avail foraut or
                                complpmo.setcod <> foraut.setcod
                            then next.
                    end.
                    
                    if complpmo.vencod > 0 and
                        titluc.vencod <> complpmo.vencod
                    then next.

                    if can-find (first forne
                                 where forne.forcod = titluc.clifor
                                   and forne.fornom begins "Premio Plano BIS")
                        and titluc.vencod <> ?
                        and titluc.vencod <> 0
                        and titluc.vencod <> 150               
                    then do:
                    
                        find first bfunc where bfunc.etbcod = titluc.etbcod
                                           and bfunc.funcod = titluc.vencod
                                                    no-lock no-error.
                        if not avail bfunc then next.
                        find first tbclube where tbclube.nomclube = "ClubeBis"
                                             and tbclube.etbcod = bfunc.etbcod
                                             and tbclube.funcod = bfunc.funcod
                                                  no-lock no-error.
                        if not avail tbclube then next.
                        find first clien where clien.clicod = tbclube.clicod
                                                    no-lock no-error.
                        
                                 
                        assign v-tem-cont-ativo = no 
                               v-tem-parc-atraso = no.
                               
                        bl_contrato:       
                        for each contrato where contrato.clicod = clien.clicod
                                                no-lock:
                                                               
                            if can-find(first tabaux
                                        where tabaux.tabela = "PlanoBiz"
                               and tabaux.valor_campo = string(contrato.crecod))
                            then do:            
                                
                                bl_parcelas:                                
                                for each titulo where titulo.empcod = 19
                                              and titulo.titnat = no
                                              and titulo.modcod = "CRE"
                                             and titulo.etbcod = contrato.etbcod
                                             and titulo.clifor = clien.clicod
                                    and titulo.titnum = string(contrato.contnum)
                                                      no-lock.
                                   
                                   if titulo.titsit <> "LIB"
                                   then next.
                                                                      
                                   if titulo.titdtven < 
                                                (complpmo.dtlanfim - 20)  
                                       and titulo.titdtpag = ?
                                   then do:
                                       
                                       assign v-tem-parc-atraso = yes.
                                       leave bl_parcelas.

                                   end.
                                   else if titulo.titdtven > today
                                            and titulo.titdtpag = ?
                                        then assign v-tem-cont-ativo = yes.
                                   
                                end.
                                                               
                                if v-tem-parc-atraso
                                then leave bl_contrato.
                                
                            end.    
                        end.                                              
                        
                        if v-tem-parc-atraso
                            or not v-tem-cont-ativo
                        then next. 
                        if vmeta
                        then do:                  
                        find first ztt-previa
                             where ztt-previa.etbcod = bfunc.etbcod 
                               and ztt-previa.funcod = bfunc.funcod
                                                        no-lock no-error.
                        if not avail ztt-previa
                        then next.                                 
                        
                        if ztt-previa.venda-41 <= ztt-previa.meta-41
                            and ztt-previa.venda-31 <= ztt-previa.meta-31
                        then next.                    
                        end.                   
                    end.             
                     
                    disp "Processando.... "
                         titluc.etbcod
                         titluc.clifor
                         titluc.titnum
                         with frame f-tela 1 down no-label
                         width 80 row 19 overlay no-box color message.
                         
                    pause 0.

                    vquem = acha("PREMIO",titluc.titobs[2]).
                
                    if vquem = ? and
                        titluc.vencod > 0 and
                        titluc.vencod <> 150
                        then vquem = "VENDEDOR".
                    
                    if complpmo.vencod > 0 and
                        vquem <> "VENDEDOR" and
                        vquem <> "CREDIARISTA PLANO BIS"
                    then next.

                    if titluc.vencod = 150 or vquem = "CREDIARISTA"
                    then do:
                        find first btt-previa where
                               btt-previa.etbcod = titluc.etbcod and
                               btt-previa.funcod = titluc.vencod
                               no-error.
                        if not avail btt-previa
                        then do:
                            create btt-previa.
                            btt-previa.etbcod = titluc.etbcod.
                            btt-previa.funcod = titluc.vencod.
                            btt-previa.funnom = "CREDIARISTA".
                        end.
                        btt-previa.premio = btt-previa.premio 
                                + titluc.titvlcob. 
                    end.
                    else do:
                        /*
                        message titluc.titnum. pause.
                        */
                        if complpmo.vencod > 0 and vquem <> "VENDEDOR" and
                            vquem <> "CREDIARISTA PLANO BIS" AND
                            complpmo.vencod <> titluc.vencod
                        then next.             

                        if vquem = "VENDEDOR" OR
                           vquem = "CREDIARISTA PLANO BIS" 
                        then do:
                            find first btt-previa where
                               btt-previa.etbcod = titluc.etbcod and
                               btt-previa.funcod = titluc.vencod
                               no-error.
                            if not avail btt-previa
                            then do:
                                create btt-previa.
                                btt-previa.etbcod = titluc.etbcod.
                                btt-previa.funcod = titluc.vencod.
                                btt-previa.funnom = vquem.
                            end.
                            btt-previa.premio = btt-previa.premio 
                                + titluc.titvlcob.       
                        end.  
                        if vquem = "GERENTE"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 and
                                   tt-previa.funnom = "GERENTE"
                               no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "GERENTE".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                        end.
                        if vquem = "PROMOTOR"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 AND
                                   tt-previa.funnom = "PROMOTOR" 
                                   no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "PROMOTOR".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                        END.
                        if vquem = "TREINEE CONFECCAO"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 AND
                                   tt-previa.funnom = "TREINEE CONFECCAO" 
                                   no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "TREINEE CONFECCAO".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                        END.
                        if vquem = "TREINEE CREDIARIO"
                        then do:
                            find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 and
                                   tt-previa.funnom = "TREINEE CREDIARIO"
                               no-error.
                            if not avail tt-previa
                            then do:
                                create tt-previa.
                                tt-previa.etbcod = titluc.etbcod.
                                tt-previa.funcod = 0.
                                tt-previa.funnom = "TREINEE CREDIARIO".
                            end.
                            tt-previa.premio = tt-previa.premio 
                                + titluc.titvlcob.       
                        end. 
                    end.
                end.   
                if p-tipo = "LIBERA" or
                   p-tipo = "PREVIA"
                THEN DO:
              
                    for each tt-previa no-lock:
                        if vmeta = no
                        then tt-previa.libera = yes.
                        else do:
                            tt-previa.libera = no.
                            if tt-previa.funcod = 150 and
                               tt-previa.venda >= tt-previa.meta 
                            then tt-previa.libera = yes.
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "GERENTE" and
                                    tt-previa.venda >= tt-previa.meta
                            then tt-previa.libera = yes.   
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "PROMOTOR" and
                                    tt-previa.venda-31 >= tt-previa.meta-31
                            then tt-previa.libera = yes.
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "TREINEE CONFECCAO" and
                                    tt-previa.venda-41 >= tt-previa.meta-41
                            then tt-previa.libera = yes.       
                            else if tt-previa.funcod = 0 and
                                    tt-previa.funnom = "TREINEE CREDIARIO" and
                                    tt-previa.venda >= tt-previa.meta
                            then tt-previa.libera = yes.  
                            else if tt-previa.funcod > 0 and
                                tt-previa.funnom = "CREDIARISTA PLANO BIS" and
                                tt-previa.venda >= tt-previa.meta
                            then tt-previa.libera = yes.
                            else if tt-previa.funcod > 0 
                                then do:
                                    if tt-previa.meta-31 > 0 and
                                       tt-previa.venda-31 > 0 and
                                       tt-previa.meta-31 <= tt-previa.venda-31
                                    then tt-previa.libera = yes.
                                    if tt-previa.meta-41 > 0 and
                                       tt-previa.venda-41 > 0 and
                                       tt-previa.meta-41 <= tt-previa.venda-41
                                    then tt-previa.libera = yes.
                                end.
                        end.
                    end.
                end.
                if p-tipo = "LIBERA"
                then do:
                    for each tt-modal no-lock, 
                        each titluc where 
                             titluc.empcod = 19 and
                             titluc.titnat = yes and
                             titluc.modcod = tt-modal.modcod and
                             titluc.titdtven >= complpmo.dtlanini and
                             titluc.titdtven <= complpmo.dtlanfim and
                             titluc.etbcod = estab.etbcod no-lock:

                        if  (titluc.titsit <> "BLO" and
                             titluc.titsit <> "EXC")   or
                             titluc.evecod <> 5 
                        then next.    
                        
                        vquem = acha("PREMIO",titluc.titobs[2]).
                        
                        if vquem = "GERENTE"
                        then find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 and
                                   tt-previa.funnom = "GERENTE"
                               no-error.
                        else if vquem = "PROMOTOR"
                        then find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 AND
                                   tt-previa.funnom = "PROMOTOR" 
                                   no-error.
                        else if vquem = "TREINEE CONFECCAO"
                        then find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 AND
                                   tt-previa.funnom = "TREINEE CONFECCAO" 
                                   no-error.
                        else if vquem = "TREINEE CREDIARIO"
                        then find first tt-previa where
                                   tt-previa.etbcod = titluc.etbcod and
                                   tt-previa.funcod = 0 and
                                   tt-previa.funnom = "TREINEE CREDIARIO"
                               no-error.
                        else find first tt-previa where
                                        tt-previa.etbcod = titluc.etbcod and
                                        tt-previa.funcod = titluc.vencod
                                        no-error.
                        
                        if not avail tt-previa then next.
                                   
                        if complpmo.vencod > 0 and
                           titluc.vencod <> complpmo.vencod
                        then next.    
                        if  complpmo.forcod <> ? and
                        complpmo.forcod > 0 and
                        titluc.clifor <> complpmo.forcod
                        then next.
                        
                        if complpmo.setcod > 0
                        then do:
                            find foraut where foraut.forcod = titluc.clifor
                                no-lock no-error.
                            if not avail foraut or
                                complpmo.setcod <> foraut.setcod
                            then next.
                        end.
                    
                        vsitbiss = "" .
                    
                        /* Segunda verificacao LMN */    
                        
                        if can-find (first forne
                                 where forne.forcod = titluc.clifor
                                   and forne.fornom begins "Premio Plano BIS")
                            and titluc.vencod <> ?
                            and titluc.vencod <> 0
                            and titluc.vencod <> 150             
                        then do:
                    
                        find first bfunc where bfunc.etbcod = titluc.etbcod
                                           and bfunc.funcod = titluc.vencod
                                                    no-lock no-error.
                        if not avail bfunc then next.
                        find first tbclube where tbclube.nomclube = "ClubeBis"
                                             and tbclube.etbcod = bfunc.etbcod
                                             and tbclube.funcod = bfunc.funcod
                                                  no-lock no-error.
                        if not avail tbclube
                        then vsitbiss = "Nao cadastrado no Clube Bis".     
                        else do:
                        find first clien where clien.clicod = tbclube.clicod
                                                    no-lock no-error.
                        
                                 
                        assign v-tem-cont-ativo = no 
                               v-tem-parc-atraso = no.
                               
                        bl_contrato:       
                        for each contrato where contrato.clicod = clien.clicod
                                                no-lock:
                                                               
                            if can-find(first tabaux
                                        where tabaux.tabela = "PlanoBiz"
                               and tabaux.valor_campo = string(contrato.crecod))
                            then do:            
                                
                                bl_parcelas:                                
                                for each titulo where titulo.empcod = 19
                                              and titulo.titnat = no
                                              and titulo.modcod = "CRE"
                                             and titulo.etbcod = contrato.etbcod
                                             and titulo.clifor = clien.clicod
                                    and titulo.titnum = string(contrato.contnum)
                                                      no-lock.
                                   
                                   if titulo.titsit <> "LIB"
                                   then next.
                                                                      
                                   if titulo.titdtven < 
                                                (complpmo.dtlanfim - 20)  
                                       and titulo.titdtpag = ?
                                   then do:
                                       
                                       assign v-tem-parc-atraso = yes.
                                       leave bl_parcelas.

                                   end.
                                   else if titulo.titdtven > today
                                            and titulo.titdtpag = ?
                                        then assign v-tem-cont-ativo = yes.
                                   
                                end.
                                                               
                                if v-tem-parc-atraso
                                then leave bl_contrato.
    
                            end.
                         
                         end.                                              
                        
                        if v-tem-parc-atraso
                            or not v-tem-cont-ativo
                        then do:
                            if v-tem-parc-atraso
                            then vsitbiss = "Tem parcela em atraso.".
                            else if not v-tem-cont-ativo
                            then vsitbiss = "Nao possui contrato ativo.".
                        end. 
                                          
                        end.
                        end.    
                        /*
                        message tt-previa.funcod tt-previa.libera
                        vsitbiss. pause.
                        */
                        if vsitbiss = ""
                        then do:    
                        
                        
    
                        disp "Liberando.... "
                         titluc.etbcod
                         titluc.clifor
                         titluc.titnum
                         with frame f-tela1 1 down no-label
                         width 80 row 19 overlay no-box color message.
                         
                        pause 0.

                        if tt-previa.libera = yes
                        then do: 
                            find btitluc where 
                                 btitluc.empcod = titluc.empcod and
                                 btitluc.titnat = titluc.titnat and
                                 btitluc.modcod = titluc.modcod and
                                 btitluc.etbcod = titluc.etbcod and
                                 btitluc.clifor = titluc.clifor and
                                 btitluc.titnum = titluc.titnum and
                                 btitluc.titpar = titluc.titpar
                                 no-error.
                            if avail btitluc
                            then do transaction:
                                find first bfunc where 
                                           bfunc.etbcod = btitluc.etbcod and
                                           bfunc.funcod = btitluc.vencod
                                                    no-lock no-error.
                                
                                btitluc.titsit = "FOL".
                                vpct = 0.
                                vtotal = 0.
                                
                                run le-contacor.
                                run cria-tbpmofol.
                            end.
                        end.
                        else do:
                            find btitluc where 
                                 btitluc.empcod = titluc.empcod and
                                 btitluc.titnat = titluc.titnat and
                                 btitluc.modcod = titluc.modcod and
                                 btitluc.etbcod = titluc.etbcod and
                                 btitluc.clifor = titluc.clifor and
                                 btitluc.titnum = titluc.titnum and
                                 btitluc.titpar = titluc.titpar
                                 no-error.
                            if avail btitluc
                            then do transaction:
                                btitluc.titsit = "EXC".
                                vsitbiss = "Nao atingiu a meta de venda.".
                                btitluc.titobs[2] = btitluc.titobs[2] + 
                                            "|MOTIVO-BLB=" + vsitbiss.
                            end.
                        end.
                        end.
                        else do:
                            find btitluc where 
                                 btitluc.empcod = titluc.empcod and
                                 btitluc.titnat = titluc.titnat and
                                 btitluc.modcod = titluc.modcod and
                                 btitluc.etbcod = titluc.etbcod and
                                 btitluc.clifor = titluc.clifor and
                                 btitluc.titnum = titluc.titnum and
                                 btitluc.titpar = titluc.titpar
                                 no-error.
                            if avail btitluc
                            then do transaction:
                                assign
                                    btitluc.titsit = "PEN"
                                    btitluc.titobs[2] = btitluc.titobs[2] + 
                                            "|MOTIVO-BLB=" + vsitbiss.
                            end.
                        end.
                    end.
                    /***
                    do transaction:
                        complpmo.situacao = "L".
                    end.
                    ***/
                end.
            end.
            if p-tipo = "LIBERA"
            then do transaction:
                complpmo.situacao = "L".
            end.    
        end.
        
        /***
        for each tt-previa:
        disp tt-previa.
        end.
        ***/
        run imp-resultado(p-tipo).
    end.
end procedure.

procedure validar-meta:
    def input parameter dti-venda as date.
    def input parameter dtf-venda as date.
    def var vcatcod like produ.catcod.
    vmetaloja = no.
    vmeta-mov = no.
    for each tt-func. delete tt-func. end.    
    def var vclacod like clase.clacod.
    def var vtotalven as dec init 0.
    def var val_fin as dec.
    def var val_dev as dec.
    def var val_des as dec.
    def var val_acr as dec.
    def var val_com as dec init 0.
    def var vmet-promotor as dec.
    def buffer btt-previa for tt-previa.
    def buffer ctt-previa for tt-previa.
    def buffer dtt-previa for tt-previa.
    def buffer d-tt-previa for tt-previa.
    def buffer ett-previa for tt-previa.

    def var vmcrepes as dec.
    def var vvldesc as dec.
    def var vvlacre as dec.
    def var vvalor as dec.
    def var vignora as log.
    def buffer bmovim for movim.
    def var vcat as int.
    def var wacr as dec.
    def var acum-m as dec. /*** Totaliza Moveis ***/
    def var acum-c as dec. /*** Totaliza Confecção ***/
    def var acum-p as dec. /*** Totaliza Vendas Promotor - Telefonia ***/
    def var vdtimp as date.
    def var dia-m as dec.
    def var dia-c as dec.
    def var vj as int.

    disp "Processando vendas FILIAL " 
        string(estab.etbcod,"999") no-label
         with frame fdisp-v no-box side-label 1 down
         color message.
    pause 0.     
    
    def var vdata-p as date.
    do vdata-p = dti-venda to dtf-venda: 
    disp vdata-p no-label with frame fdisp-v.
    pause 0.
    for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.pladat = vdata-p
                         no-lock:
        
        if complpmo.vencod > 0 and
           plani.vencod <> complpmo.vencod
        then next.   
        find first tt-func where 
                   tt-func.etbcod = plani.etbcod and
                   tt-func.funcod = plani.vencod no-error.
        if not avail tt-func
        then do:
            create tt-func.
            tt-func.etbcod = plani.etbcod.
            tt-func.funcod = plani.vencod.
        end.        

        if complpmo.vencod = 0
        then do:
        find first tt-previa where
                   tt-previa.etbcod = plani.etbcod and
                   tt-previa.funcod = 0 and
                   tt-previa.funnom = "GERENTE"
                   no-error.
        if not avail tt-previa
        then do:
            create tt-previa.
            tt-previa.etbcod = plani.etbcod.
            tt-previa.funcod = 0.
            tt-previa.funnom = "GERENTE".
        end.
        find first ctt-previa where
                   ctt-previa.etbcod = plani.etbcod and
                   ctt-previa.funcod = 0 and
                   ctt-previa.funnom = "PROMOTOR"
                   no-error.
        if not avail ctt-previa
        then do:
            create ctt-previa.
            ctt-previa.etbcod = plani.etbcod.
            ctt-previa.funcod = 0.
            ctt-previa.funnom = "PROMOTOR".
        end.
        find first dtt-previa where
                   dtt-previa.etbcod = plani.etbcod and
                   dtt-previa.funcod = 150 and
                   dtt-previa.funnom = "CREDIARISTA"
                   no-error.
        if not avail dtt-previa
        then do:
            create dtt-previa.
            dtt-previa.etbcod = plani.etbcod.
            dtt-previa.funcod = 150.
            dtt-previa.funnom = "CREDIARISTA".
        end.
        find first d-tt-previa where
                   d-tt-previa.etbcod = plani.etbcod and
                   d-tt-previa.funcod = 0 and
                   d-tt-previa.funnom = "TREINEE CREDIARIO"
                   no-error.
        if not avail d-tt-previa
        then do:
            create d-tt-previa.
            d-tt-previa.etbcod = plani.etbcod.
            d-tt-previa.funcod = 0.
            d-tt-previa.funnom = "TREINEE CREDIARIO".
        end.
        find first ett-previa where
                   ett-previa.etbcod = plani.etbcod and
                   ett-previa.funcod = 0 and
                   ett-previa.funnom = "TREINEE CONFECCAO"
                   no-error.
        if not avail ett-previa
        then do:
            create ett-previa.
            ett-previa.etbcod = plani.etbcod.
            ett-previa.funcod = 0.
            ett-previa.funnom = "TREINEE CONFECCAO".
        end.
        end.
        
        find first btt-previa where 
                   btt-previa.etbcod = plani.etbcod and
                   btt-previa.funcod = plani.vencod
                   no-error.
        if not avail btt-previa
        then do:
            create btt-previa.
            btt-previa.etbcod = plani.etbcod .
            btt-previa.funcod = plani.vencod.
            btt-previa.funnom = "".
        end.    
        
        vcatcod = 0.

        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat 
                             no-lock:
            find produ where produ.procod = movim.procod no-lock.
            
            vcatcod = produ.catcod.
            if vcatcod = 35
            then vcatcod = 31.
            if vcatcod = 45
            then vcatcod = 41.
            
            val_fin = 0.                   
            val_des = 0.  
            val_dev = 0.  
            val_acr = 0. 
                         
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
            if val_acr = ? then val_acr = 0.
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
            if val_des = ? then val_des = 0.
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
            if val_dev = ? then val_dev = 0.

            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
            val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                        / (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            val_com = (movim.movpc * movim.movqtm) /* - val_dev */ - val_des 
                        + val_acr +  val_fin. 
            if val_com = ? then val_com = 0.
            /*     
            tt-func.valven = tt-func.valven + val_com.
            vtotalven = vtotalven + val_com.            
            tt-previa.venda = tt-previa.venda + val_com.
            */
            if vcatcod = 31
            then do:
                vclacod = produ.clacod.
                repeat:
                    find clase where clase.clacod = vclacod no-lock no-error.
                    if /*metven.clacod = 100 or
                       metven.clacod = 190 or
                       metven.clacod = 200*/
                       clase.clasup = 129000000         
                       and avail ctt-previa           
                    then do:
                        ctt-previa.venda-31 = ctt-previa.venda-31 + val_com.
                        leave.
                    end.
                    vclacod = clase.clasup.
                    if vclacod = 0
                    then leave.
                end.    
            end.
        end.

        assign
            acum-m = 0
            acum-c = 0
            acum-p = 0
            vj = 0.
        
        do vj = 1 to 2:
            if vj = 1
            then vcatcod = 31.
            else vcatcod = 41.
        
            if vcatcod <> 31
            then vignora = no.
            else vignora = yes.

            assign
                acum-m = 0
                acum-c = 0
                acum-p = 0
                dia-m = 0
                dia-c = 0
                .
                
            {venda2.i}
            
            if acum-p > 0 then
            message acum-p view-as alert-box.

            assign
                btt-previa.venda-31 = btt-previa.venda-31 + acum-m
                btt-previa.venda-41 = btt-previa.venda-41 + acum-c
                tt-func.valven = tt-func.valven + (acum-m + acum-c)
                vtotalven = vtotalven + (acum-m + acum-c)            
                .
            
            if complpmo.vencod = 0
            then
            assign
                ett-previa.venda-31 = ett-previa.venda-31 + acum-m
                ett-previa.venda-41 = ett-previa.venda-41 + acum-c
                d-tt-previa.venda = d-tt-previa.venda + (acum-m + acum-c)
                ctt-previa.venda = ctt-previa.venda + acum-p
                tt-previa.venda = tt-previa.venda + (acum-m + acum-c)
                .
    
        end. 
    end.
    end.
    hide frame fdisp-v no-pause.
    
    if complpmo.vencod = 0
    then do:
    find first btt-previa where 
               btt-previa.etbcod = estab.etbcod and
               btt-previa.funcod = 150
               no-lock no-error.
    if avail btt-previa
    then assign
             btt-previa.venda = vtotalven
             btt-previa.meta-31 = 0
             btt-previa.meta-41 = 0
             btt-previa.venda-31 = 0
             btt-previa.venda-41 = 0
                .
    end.
    def var vtotalmeta as dec init 0.
    def var vmeta-31 as dec init 0.
    def var vmeta-41 as dec init 0.

    find tabmeta where tabmeta.codtm  = 3 and
                   tabmeta.anoref = year(dtf-venda) and
                   tabmeta.mesref = month(dtf-venda) and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = estab.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   no-lock no-error.
    if avail tabmeta
    then vmcrepes = tabmeta.val_meta.
    for each duplic where duplic.fatnum = estab.etbcod and
                          duplic.duppc = month(dtf-venda)
                          no-lock.
        vtotalmeta = vtotalmeta + duplic.dupval + duplic.dupjur.
        vmeta-31 = vmeta-31 + duplic.dupjur.
        vmeta-41 = vmeta-41 + duplic.dupval.
    end.
    vmet-promotor = 0.
    for each metven where metven.etbcod = estab.etbcod and
                          metven.metano = year(dtf-venda) and
                          metven.metmes = month(dtf-venda) and
                          metven.clacod > 0
                          no-lock:
        find clase where clase.clacod = metven.clacod no-lock.
        if clase.clasup = 129000000
        then vmet-promotor = vmet-promotor + metven.metval.   
    end.                      

    def var vmetafun as dec init 0.
    for each btt-previa where btt-previa.etbcod = estab.etbcod:
        find first tvendfil where
                   tvendfil.anoref = year(dtf-venda) and
                   tvendfil.mesref = month(dtf-venda) and
                   tvendfil.etbcod = estab.etbcod
                    no-lock no-error.
        vmetafun = 0.
        if btt-previa.funcod = 0 and
           btt-previa.funnom = "GERENTE"
        then btt-previa.meta = btt-previa.meta + vtotalmeta.    
        ELSE if btt-previa.funcod = 0 AND
           btt-previa.funnom = "PROMOTOR"
        then assign btt-previa.meta-31 = btt-previa.meta-31 + 
            vmet-promotor
            btt-previa.meta = btt-previa.meta + vmet-promotor.
        else if btt-previa.funcod = 150 
        then btt-previa.meta = btt-previa.meta + vtotalmeta.
        ELSE if btt-previa.funcod = 0 AND
           btt-previa.funnom = "TREINEE CONFECCAO"
        then btt-previa.meta-41 = btt-previa.meta-41 + vmeta-41.
        else
        if btt-previa.funcod = 0 and
           btt-previa.funnom = "TREINEE CREDIARIO"
        then btt-previa.meta = btt-previa.meta + vtotalmeta.    
        else if btt-previa.venda-31 > 0 and
                btt-previa.venda-31 > btt-previa.venda-41
        then do:

            find first tabaux where
               tabaux.tabela = "META-VENDA-31" and
               tabaux.nome_campo = string(estab.etbcod,"999") +
                                   ";" + string(month(dtf-venda),"99")
               no-lock no-error.
            if avail tabaux and tabaux.valor_campo <> ""
            then do:
                if num-entries(tabaux.valor_campo,";") = 1
                then if not avail tvendfil
                            or tvendfil.moveis > int(tabaux.valor_campo)
                    then  vmetafun = vmeta-31 / int(tabaux.valor_campo).
                    else vmetafun = vmeta-31 / tvendfil.moveis.
                else if not avail tvendfil
                    or tvendfil.moveis > int(entry(1,tabaux.valor_campo,";"))
                    then vmetafun = vmeta-31 /
                                int(entry(1,tabaux.valor_campo,";")).
                    else vmetafun = vmeta-31 / tvendfil.moveis.
            end.
            else if avail tvendfil
            then vmetafun = vmeta-31 / tvendfil.moveis.
            else vmetafun = 0.
            if vmetafun = ? then vmetafun = 0.
            btt-previa.meta-31 = btt-previa.meta-31 + vmetafun.
        end.
        else if btt-previa.venda-41 > 0  and
                btt-previa.venda-41 > btt-previa.venda-31
        then do:

            find first tabaux where
               tabaux.tabela = "META-VENDA-41" and
               tabaux.nome_campo = string(estab.etbcod,"999") +
                                   ";" + string(month(dtf-venda),"99")
               no-lock no-error.
            if avail tabaux and tabaux.valor_campo <> ""
            then do:
                if num-entries(tabaux.valor_campo,";") = 1
                then if not avail tvendfil
                            or tvendfil.moda > int(tabaux.valor_campo)
                    then vmetafun = vmeta-41 / int(tabaux.valor_campo).
                    else vmetafun = vmeta-41 / tvendfil.moda.
                else if not avail tvendfil
                    or tvendfil.moda > int(entry(1,tabaux.valor_campo,";"))
                    then vmetafun = vmeta-41 /
                                int(entry(1,tabaux.valor_campo,";")).
                    else vmetafun = vmeta-41 / tvendfil.moda.
            end.
            else if avail tvendfil
            then vmetafun = vmeta-41 / tvendfil.moda.
            else vmetafun = 0.
            if vmetafun = ? then vmetafun = 0.
            btt-previa.meta-41 = btt-previa.meta-41 + vmetafun.
        end.

    end.

    for each tt-previa where 
             tt-previa.etbcod = estab.etbcod and
             tt-previa.funcod > 0:
        if tt-previa.venda-31 >= tt-previa.meta-31 or
           tt-previa.venda-41 >= tt-previa.meta-41
        then do:
            find first tt-func where 
                   tt-func.funcod = tt-previa.funcod no-error.
            if not avail tt-func
            then do:
                create tt-func.
                tt-func.funcod = tt-previa.funcod.
            end. 
        end.
    end.
                 
    vmetaloja = yes.
    if vtotalven < vtotalmeta
    then vmetaloja = no.    
end procedure.          
               
procedure imp-resultado:
    def input parameter p-tipo as char.

    def var vtotal as dec.
    def var vlib as dec format ">>>,>>9.99".
    def var vblo as dec format ">>>,>>9.99".
    def var varquivo as char.
    def var tlib as dec format ">>,>>>,>>9.99".
    def var tblo as dec format ">>,>>>,>>9.99".
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(p-tipo) + "premio."
                    + string(time).
    else varquivo = "..~\relat~\" + string(p-tipo) + "premio."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""ctacorp2"" 
                &Nom-Sis   = """ADMINISTRATIVO/RH""" 
                &Tit-Rel   = "string(CAPS(p-tipo)) + 
                            "" PAGAMENTO DE PREMIOS FOLHA ""
                            + string(v-tipodes,""x(20)"") " 
                &Width     = "110"
                &Form      = "frame f-cabcab"}
    def var vfunnom like func.funnom.
    for each tt-previa where 
            /*(if complpmo.etbcod > 0
             then tt-previa.etbcod = complpmo.etbcod
             else true) and tt-previa.premio > 0*/ 
            break by tt-previa.etbcod
                  by tt-previa.funcod:
        find estab where estab.etbcod = tt-previa.etbcod no-lock.
        find func where 
             func.etbcod = tt-previa.etbcod and
             func.funcod = tt-previa.funcod no-lock no-error.
        if avail func
        then vfunnom = func.funnom.
        else vfunnom = tt-previa.funnom.
        if first-of(tt-previa.etbcod)
        then do:
            disp estab.etbcod column-label "Fil"
                with frame f-rel down.
        end.            
        if tt-previa.libera
        then vlib = vlib + tt-previa.premio.
        else vblo = vblo + tt-previa.premio.
        
        disp tt-previa.funcod format ">>>>>>9" column-label "Func"
             vfunnom no-label format "x(20)"
             tt-previa.meta column-label "Meta"    format "->>,>>>,>>9.99"
             tt-previa.venda column-label "Venda"  format "->>,>>>,>>9.99"
             tt-previa.meta-31 column-label "Meta-31" format "->,>>>,>>9.99"
             tt-previa.venda-31 column-label "Venda-31" format "->,>>>,>>9.99"
             tt-previa.meta-41 column-label "Meta-41"   format "->,>>>,>>9.99"
             tt-previa.venda-41 column-label "Venda-41" format "->,>>>,>>9.99"
             tt-previa.premio  format ">>,>>9.99"
              column-label "Premio" (total by tt-previa.etbcod) 
             tt-previa.libera column-label "Sit" 
             with frame f-rel width 160.
            down with frame f-rel.

        if last-of(tt-previa.etbcod)
        then do:
            /*
            put fill("-",80) format "x(80)" skip.
            put "      Premio Liberado: " vlib
                "   Premio Bloqueado: " vblo
                skip.
            put fill("-",80) format "x(80)" skip.
            */
            tlib = tlib + vlib.
            tblo = tblo + vblo.
            vlib = 0.
            vblo = 0.
        end.        
    end.    
    put fill("-",80) format "x(80)" skip.
    put "      Premio Liberado: " tlib /* 10*/
        "   Premio Bloqueado: " tblo   /* 10*/
                skip.
    put fill("-",80) format "x(80)" skip.
    
    tlib = 0.
    tblo = 0.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure cria-tbpmofol:
    def var vdesconta as dec.
    vdesconta = 0.
    def var valor-cre as dec.
    valor-cre = 0.
    def var valor-deb as dec.
    valor-deb = 0.
    def buffer dcontacor for contacor.
    find tbpmofol where
         tbpmofol.anocomp = complpmo.anocomp and
         tbpmofol.mescomp = complpmo.mescomp and
         tbpmofol.etbcod  = tt-previa.etbcod and
         tbpmofol.funcod  = tt-previa.funcod and
         tbpmofol.apelido = tt-previa.funnom
         no-error.
    if not avail tbpmofol
    then do:
        create tbpmofol.
        assign
            tbpmofol.anocomp = complpmo.anocomp
            tbpmofol.mescomp = complpmo.mescomp
            tbpmofol.etbcod  = tt-previa.etbcod
            tbpmofol.funcod  = tt-previa.funcod
            tbpmofol.apelido = tt-previa.funnom
            tbpmofol.funnom  = tt-previa.funnom
            .
        if avail bfunc
        then tbpmofol.codfol  = bfunc.usercod.
    end.    
    assign
        tbpmofol.dtinclu = today
        tbpmofol.valcre = tbpmofol.valcre + titluc.titvlcob          
        . 
    
    vdesconta = 0.
    if vtotal > 0 and
       vpct > 0
    then do:
        vdesconta = titluc.titvlcob * (vpct / 100).    
        if vdesconta > vtotal
        then vdesconta = vtotal.
        tbpmofol.valdeb = tbpmofol.valdeb + vdesconta.
        valor-cre = vdesconta.
        for each contacor where contacor.natcor = no and
                        contacor.etbcod = tt-previa.etbcod and
                        contacor.clifor = ? and
                        contacor.funcod = tt-previa.funcod and
                        contacor.sitcor = "LIB" 
                        exclusive 
                        :

            if contacor.campo3[1] <> vtipo
            then next.
        
            if  contacor.campo3[1] = "COMPL" 
            then do:
                if contacor.datemi < 11/19/15
                then next.
                if month(contacor.datemi) = month(today) and
                    year(contacor.datemi)  = year(today)
                then.
                else next.
            end. 

            if contacor.valcob - contacor.valpag >= valor-cre
            then do on error undo:
                contacor.valpag = contacor.valpag + valor-cre.
                valor-deb = valor-deb + valor-cre.
                create dcontacor.
                find last bcontacor  use-index ndx-7 where 
                  bcontacor.etbcod = estab.etbcod
                  no-lock no-error.
                if not avail bcontacor
                then dcontacor.numcor = estab.etbcod * 10000000.
                else dcontacor.numcor = bcontacor.numcor + 1.
                assign
                    dcontacor.natcor = yes
                    dcontacor.etbcod = tt-previa.etbcod
                    dcontacor.funcod = tt-previa.funcod
                    dcontacor.datemi = today
                    dcontacor.datven = today
                    dcontacor.valcob = valor-cre
                    dcontacor.rec-titluc = ?
                    dcontacor.rec-conta = recid(contacor)
                    .
                valor-cre = 0.    
                if contacor.valcob = contacor.valpag
                then contacor.sitcor = "PAG".
                leave.
            end.
            else do on error undo:
                create dcontacor.
                find last bcontacor  use-index ndx-7 where 
                      bcontacor.etbcod = tt-previa.etbcod
                      no-lock no-error.
                if not avail bcontacor
                then dcontacor.numcor = tt-previa.etbcod * 10000000.
                else dcontacor.numcor = bcontacor.numcor + 1.
                assign
                    dcontacor.natcor = yes
                    dcontacor.etbcod = tt-previa.etbcod
                    dcontacor.funcod = tt-previa.funcod
                    dcontacor.datemi = today
                    dcontacor.datven = today
                    dcontacor.valcob = (contacor.valcob - contacor.valpag)
                    dcontacor.rec-titluc = ?
                    dcontacor.rec-conta = recid(contacor)
                    .

                valor-cre = valor-cre - (contacor.valcob - contacor.valpag).
                valor-deb = valor-deb + (contacor.valcob - contacor.valpag).
                contacor.valpag = contacor.valpag +
                                   (contacor.valcob - contacor.valpag).
                if contacor.valcob = contacor.valpag
                then contacor.sitcor = "PAG".                           
            end.    
            if valor-cre = 0
            then leave.
        end.
        tbpmofol.valdeb = tbpmofol.valdeb + vdesconta.
    end.
    tbpmofol.valliq = tbpmofol.valcre - tbpmofol.valdeb.

end procedure.
procedure le-contacor: 
    def buffer x-contacor for contacor.    
    for each contacor where contacor.natcor = no and
                        contacor.etbcod = tt-previa.etbcod and
                        contacor.clifor = ? and
                        contacor.funcod = tt-previa.funcod and
                        contacor.sitcor = "LIB" 
                        no-lock:
        if  contacor.campo3[1] = "COMPL" 
        then do:
            if contacor.datemi < 11/19/15
            then next.
            if month(contacor.datemi) = month(today) and
               year(contacor.datemi)  = year(today)
            then.
            else next.
        end.       
        create tt-contacor.
        buffer-copy contacor to tt-contacor.
    end.
    FOR EACH tt-contacor where tt-contacor.natcor = no and
                        tt-contacor.etbcod = tt-previa.etbcod and
                        tt-contacor.clifor = ? and
                        tt-contacor.funcod = tt-previa.funcod and
                        tt-contacor.sitcor = "LIB" 
                        no-lock
                        break 
                               by tt-contacor.campo3[1] desc
                               by tt-contacor.datemi.
                        /* By tipo de desconto */
 
        if first-of(tt-contacor.campo3[1])
        then do:
        
            assign vtotal = 0
                   vpct   = 0.             
        
        end.

        vtotal = vtotal + (tt-contacor.valcob - tt-contacor.valpag).

        if  last-of(tt-contacor.campo3[1])   
        then do:

            find first x-contacor
                 where x-contacor.natcor = yes and
                       x-contacor.etbcod = tt-previa.etbcod and
                                        x-contacor.clifor = ? and
                            x-contacor.funcod = tt-previa.funcod and
                            x-contacor.sitcor = "PAG"  and
                            x-contacor.modcod = "PCT"
                                no-lock no-error.
            if not avail x-contacor
            then find first x-contacor where x-contacor.natcor = yes and
                        x-contacor.etbcod = estab.etbcod and
                        x-contacor.clifor = ? and
                        x-contacor.funcod = 0 and
                        x-contacor.sitcor = "PAG"  and
                        x-contacor.modcod = "PCT"
                        no-lock no-error.
            if not avail x-contacor
            then find first x-contacor where x-contacor.natcor = yes and
                        x-contacor.etbcod = 0 and
                        x-contacor.clifor = ? and
                        x-contacor.funcod = 0 and
                        x-contacor.sitcor = "PAG"  and
                        x-contacor.modcod = "PCT"
                        no-lock no-error.
            if avail x-contacor
            then do:
        
                case (tt-contacor.campo3[1]):
            
                    when "EST"    then vpct = x-contacor.valcob.
                    when "COMPL"  then vpct = x-contacor.campo2[1].
                    otherwise vpct = 0.
                end case.
            
            end.
            else vpct = 0.
            vtipo = tt-contacor.campo3[1].
        end.
    end.
 
end procedure.


                                                 
