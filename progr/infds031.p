{admcab.i}
{setbrw.i}                                                                      

def input parameter v-rec as recid.

find fatudesp where recid(fatudesp) = v-rec no-lock.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom11         as char format "x(15)" extent 5
    initial ["","","","",""].
def var esqcom22         as char format "x(15)" extent 5
            initial ["","","","",""].
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
    esqcom11
    with frame f-com11
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom22
    with frame f-com22
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


def buffer bmodal for modal.

form lancxa.datlan  
     lancxa.etbcod format ">>9" column-label "Fil"
     lancxa.forcod format ">>>>>>>>>9" column-label "CliFor"
     lancxa.titnum format "x(10)" column-label "Numero"
     lancxa.modcod format "x(3)"       column-label "MTF"
     lancxa.cxacod column-label "Deb"
     lancxa.lancod column-label "Cre"
     lancxa.vallan
     with frame f-linha 12 down color with/cyan /*no-box*/
     centered OVERLAY title " LANCTB ".

def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    hide frame f-com11 no-pause.
    hide frame f-com22 no-pause.
    clear frame f-com11 all.
    clear frame f-com22 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 

    disp esqcom11 with frame f-com11.
    disp esqcom22 with frame f-com22.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color  = with/cyan
        &file   = lancxa   
        &cfield = lancxa.datlan
        &noncharacter = /* 
        &ofield = " lancxa.etbcod
                    lancxa.forcod
                    lancxa.titnum
                    lancxa.modcod
                    lancxa.cxacod
                    lancxa.lancod
                    lancxa.vallan
                    "  
        &aftfnd1 = " find modal where modal.modcod = lancxa.modcod
                        no-lock no-error.
                        "
        &where  = " 
                    /*
                    lancxa.datlan = fatudesp.inclusao and
                    lancxa.etbcod = fatudesp.etbcod and
                    lancxa.forcod = fatudesp.clicod and
                    lancxa.titnum = string(fatudesp.fatnum)
                    */
                    
                    lancxa.datlan = fatudesp.inclusao and
                    lancxa.titnum = string(int(fatudesp.fatnum))    and
                    lancxa.modcod = fatudesp.modctb and
                    lancxa.etbcod = fatudesp.etbcod

                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom11[esqpos1] = ""  EXCLUI"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with 
                        ""Nenhum registro para LANCTB.""
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
RETURN.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom11[esqpos1] = "  CONSULTA"
    THEN DO on error undo:

    END.
    if esqcom11[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom11[esqpos1] = "  EXCLUI"
    THEN DO:
    END.
    if esqcom22[esqpos2] = "  "
    THEN DO on error undo:
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
                    color display normal esqcom11[ve] with frame f-com11.
                    end.
                    color display message esqcom22[esqpos2] with frame f-com22.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom22[ve] with frame f-com22.
                    end.
                    esqpos2 = 1.
                    color display message esqcom11[esqpos1] with frame f-com11.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom11[esqpos1] with frame f-com11.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom11[esqpos1] with frame f-com11.
                end.
                else do:
                    color display normal esqcom22[esqpos2] with frame f-com22.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom22[esqpos2] with frame f-com22.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom11[esqpos1] with frame f-com11.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom11[esqpos1] with frame f-com11.
                end.
                else do:
                    color display normal esqcom22[esqpos2] with frame f-com22.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom22[esqpos2] with frame f-com22.
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

procedure exclui-documento:
    def var deletou-lancxa as log.
    def buffer btitulo for titulo.
    def buffer bfatudesp for fatudesp.
    
    
    find first bfatudesp where
            recid(bfatudesp) = a-seerec[frame-line]
            no-error.
    if avail bfatudesp
    then do:
        
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = yes and
                 titulo.modcod = bfatudesp.modcod and
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


