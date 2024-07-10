{admcab.i}
{setbrw.i}   

def var vetbcod like estab.etbcod.
vetbcod = setbcod.
update vetbcod label "Informe o codigo do CD" with side-label.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["  Consulta","  Inclui","  Exclui","  Assoc. NF","  Fechar"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["  Associadas","","","",""].
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

form plani.numero format ">>>>>>>>9" column-label "Numero"
     plani.etbcod format ">>9"
     plani.emite  format ">>>>>>>>>9" column-label "Emitente"
     forne.fornom format "x(20)" no-label
     plani.pladat column-label "Emissao"
     plani.dtinclu column-label "Entrada"
     plani.notsit column-label "Sit"
     with frame f-linha 12 down color with/cyan /*no-box*/
     .
                                                                         
disp "                          CONHECIMENTO DE FRETE       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
/*disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
*/
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var vdtinclu as date format "99/99/9999".
vdtinclu = today - 10.
def var v-nfsit  like plani.notsit.
v-nfsit = yes.
def var v-sit as char extent 2
    init["ABERTO","FECHADO"].
repeat:
disp v-sit with frame f-sit no-label  .
choose field v-sit with frame f-sit.
if frame-index = 1
then do:
    esqcom1[2] = "  Inclui". 
    esqcom1[3] = "  Exclui". 
    esqcom1[4] = "  Assoc. NF". 
    esqcom1[5] = "  Fechar".
    v-nfsit = yes.
end.
if frame-index = 2
then do:
    esqcom1[2] = "". esqcom1[3] = "". esqcom1[4] = "". esqcom1[5] = "".
    v-nfsit = no.
    update vdtinclu label "Inclusao desde" with frame f-data 1 down
    side-label column 30.
end.    

def buffer bplani for plani.
def buffer bmovim for movim.
def buffer bprodu for produ.


l1: repeat:
    clear frame f-com1 all.
    clear frame f-com2 all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    color disp message esqcom1[esqpos1] with frame f-com1.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = plani  
        &cfield = plani.numero
        &noncharacter = /* 
        &ofield = " plani.etbcod
                    plani.emite
                    forne.fornom when avail forne
                    plani.pladat
                    plani.dtinclu
                    plani.notsit
                    "  
        &aftfnd1 = " find forne where 
                          forne.forcod = plani.emite no-lock. "
        &where  = " plani.movtdc = 41  and
                    plani.etbcod = vetbcod and
                    plani.dtinclu >= vdtinclu and
                    plani.notsit = v-nfsit
                    /*
                    and can-find ( first docrefer where
                    docrefer.etbcod = plani.etbcod and
                    docrefer.codrefer = string(plani.emite) and
                    docrefer.serierefer = plani.serie and
                    docrefer.numerodr = plani.numero 
                    and can-find ( first
                    bplani where bplani.etbcod = docrefer.etbcod and
                                      bplani.emite  = docrefer.codedori and
                                      bplani.serie  = docrefer.serieori and
                                      bplani.numero = int(docrefer.numori)
                    and can-find (
                    first bmovim where bmovim.etbcod = bplani.etbcod and
                      bmovim.placod = bplani.placod and
                      bmovim.movtdc = bplani.movtdc  
                    and can-find (
                    first bprodu where bprodu.procod = bmovim.procod and
                      bprodu.catcod = 41
                      )  )   )   )   
                     */
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = "" ""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " sresp = no.
                        message ""Nenhum regitro encontrato. Deseja incluir?""
                        update sresp.
                        if sresp
                        then do:
                            esqcom1[esqpos1] = ""  inclui"".
                            color disp message esqcom1[2] with frame f-com1.
                            run aftselect.
                            esqcom1[esqpos1] = """".
                            color disp normal esqcom1[2] with frame f-com1.
                        end.
                        else leave l1.
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
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqregua
    then do:
        if esqcom1[esqpos1] = "  INCLUI"
        THEN DO on error undo:
            run inclui-CTE-moda.p.
        END.
        if esqcom1[esqpos1] = "  Assoc. NF"
        THEN DO:
            if not plani.notsit
            then do:
                bell.
                message color red/with
                "Conhecimento " plani.numero " ja FECHADO."
                view-as alert-box.
            end.  
            else do:
            find first docrefer where
                   docrefer.etbcod = plani.etbcod and
                   docrefer.codrefer = string(plani.emite) and
                   docrefer.serierefer = plani.serie and
                   docrefer.numerodr = plani.numero
                   no-lock no-error.
            if avail docrefer
            then do:
                bell.
                message color red/with
                "Conhecimento ja possui Notas associadas."
                view-as alert-box.
            end.           
            else do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run associa-CTE-moda.p(recid(plani)).   
                view frame f-com1.
                view frame f-com2.
                view frame f1.
                view frame f-linha.
                pause 0.
            end.
            end.
        END.
        if esqcom1[esqpos1] = "  CONSULTA"
        THEN DO:
            run consulta.
        END.
        if esqcom1[esqpos1] = "  fechar"
        then do:
            if not plani.notsit
            then do:
                bell.
                message color red/with
                "Conhecimento " plani.numero " ja FECHADO."
                view-as alert-box.
            end.    
            else do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run fechar-CTE-moda.p(recid(plani)).
                view frame f-com1.
                view frame f-com2.
                view frame f1.
                view frame f-linha.
                pause 0.
            end.
        end.
        if esqcom1[esqpos1] = "  exclui"
        then do:
            if not plani.notsit
            then do:
                bell.
                message color red/with
                "Conhecimento " plani.numero " ja FECHADO."
                view-as alert-box.
            end.  
            else do:
                find first docrefer where
                   docrefer.etbcod = plani.etbcod and
                   docrefer.codrefer = string(plani.emite) and
                   docrefer.serierefer = plani.serie and
                   docrefer.numerodr = plani.numero
                   no-lock no-error.
                if avail docrefer
                then do:
                    bell.
                    message color red/with
                    "Conhecimento possui Notas associadas."
                    view-as alert-box.
                end. 
                else do:
                    sresp = no.
                    message "Confirme EXCLUIR Conhecimento " plani.numero "?"
                    update sresp.
                    if sresp
                    then do on error undo:
                        delete plani.
                    end.
                end.
            end.    
        end.    
    end.
    else do:
        if esqcom2[esqpos2] = "  Associadas"
        THEN DO on error undo:
            hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run associadas-CTE-moda.p(recid(plani)).   
                view frame f-com1.
                view frame f-com2.
                view frame f1.
                view frame f-linha.
                pause 0.
        END.
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

def buffer cforne for forne.
def buffer cestab for estab.
    
form plani.etbcod label "Filial" colon 15
     cestab.etbnom  no-label
     plani.ufdes   label "Cod Barras NFE" colon 15 format "x(44)"
     cforne.forcgc label "Fornecedor" colon 15
     cforne.forcod no-label
     cforne.fornom no-label
     plani.opccod  label "Op. Fiscal" format "9999" colon 15 
     opcom.opcnom  no-label
     plani.numero colon 15
     plani.serie        label "Serie"
     plani.pladat colon 15
     plani.dtinclu colon 39
    with frame f-alt side-label width 80 row 5 color white/cyan.

form plani.bicms        label "Base Icms"  colon 17    format "zz,zzz,zz9.99"
     plani.icms         label "Valor Icms" colon 55      format "zz,zzz,zz9.99"
     plani.bsubst   label "Base Icms Subst" colon 17  format "zz,zzz,zz9.99"
     plani.icmssubs   label "Valor Substituicao" colon 55 format "zz,zzz,zz9.99"
     plani.desaces label "Desp.Acessorias" colon 55 format "zz,zzz,zz9.99"
     plani.seguro       label "Seguro" colon 55  format "zz,zzz,zz9.99"
     plani.platot       label "Total" format "zz,zzz,zz9.99" colon 55
     with frame f-alim overlay row 14 width 80 side-label.

procedure consulta:

    find cestab where cestab.etbcod = plani.etbcod no-lock no-error.
    find cforne where cforne.forcod = plani.emite no-lock no-error.
    find opcom where opcom.opccod = string(plani.opccod) no-lock no-error.
    
    disp plani.etbcod
         cestab.etbnom
         plani.ufdes 
         cforne.forcgc
         plani.serie
         plani.numero
         plani.opccod
         opcom.opcnom
         plani.pladat
         plani.dtinclu
         with frame f-alt.
    
    disp plani.bicms
         plani.icms
         plani.bsubst
         plani.icmssubst
         plani.desaces
         plani.seguro
         plani.platot
         with frame f-alim
         .

end procedure.

