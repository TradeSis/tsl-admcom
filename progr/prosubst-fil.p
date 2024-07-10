{admcab.i}

def input parameter p-recid as recid.

def buffer bprosubst for prosubst.
find bprosubst where recid(bprosubst) = p-recid no-lock no-error.

def var vetbcod like estab.etbcod.
form vetbcod label "Filial"  with frame f1 side-label 1 down 
                width 80.

def new shared temp-table tt-lj like estab.

{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Inclui","","  Exclui"," Relatorio"].
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


def buffer dprodu for produ.
def var vestmin as dec.

form prosubst.etbcod label "Filial"
     estab.etbnom no-label
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                Substituto: " + string(bprosubst.procod)
        + "     Substituido: " + string(bprosubst.prosub)
            format "x(78)"
            with frame f-1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

esqcom1[1] = "   ==>> ".
esqcom2[1] = "   ==>> ".
color disp message  esqcom1[1] with frame f-com1.

l1: repeat:
    esqcom1[1] = "   ==>> ".
    esqcom2[1] = "".
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 

    hide frame f-linha no-pause.
    clear frame f-linha all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if not esqregua 
    then color disp message esqcom1[esqpos1] with frame f-com1.
    else color disp message esqcom1[esqpos2] with frame f-com2.
    {sklclstb.i  
        &color = with/cyan
        &file = prosubst  
        &cfield = prosubst.etbcod
        &noncharacter = /* 
        &ofield = " 
                    estab.etbnom when avail estab
                    prosubst.situacao

                    "  
        &aftfnd1 = " find produ where produ.procod = prosubst.procod
                        no-lock no-error. 
                     find dprodu where dprodu.procod = prosubst.prosub
                        no-lock no-error.
                     find estab where estab.etbcod = prosubst.etbcod
                        no-lock no-error.
                        "
        &where  = " prosubst.tipo = ""F"" and
                    prosubst.procod = bprosubst.procod and
                    prosubst.prosub = bprosubst.prosub and
                    prosubst.situacao <> ""EXC"" 
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  ""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado.""
                        view-as alert-box.
                        esqpos1 = 2.
                        esqcom1[esqpos1] = ""  INCLUI"".
                        run aftselect.
                        if keyfunction(lastkey) = ""end-error""
                        then leave keys-loop.
                        else next l1.
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
hide frame f-1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    def buffer bprodu for produ.
    def buffer cprodu for produ.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        run sel-filial.
        
        for each tt-lj:
            
            find prosubst where prosubst.tipo = "F" and
                                prosubst.etbcod = tt-lj.etbcod and
                                prosubst.procod = bprosubst.procod and
                                prosubst.prosub = bprosubst.prosub
                                no-lock no-error.
            if not avail prosubst
            then do transaction:                    
                create prosubst.
                assign
                    prosubst.tipo = "F"
                    prosubst.etbcod = tt-lj.etbcod
                    prosubst.procod = bprosubst.procod
                    prosubst.prosub = bprosubst.prosub
                    prosubst.estmin = bprosubst.estmin
                    prosubst.datinclu = today
                    prosubst.horinclu = time
                    prosubst.datexp = today
                    prosubst.exportado = no
                    prosubst.situacao = "B"
                    .
            end.
            else do transaction:
                if prosubst.situacao = "EXC"
                then prosubst.situacao = "B".
            end.
        end.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        /*
        update prosubst.estmin
               prosubst.situacao
                with frame f-linha
                .
        */
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        sresp = no.
        MESSAGE "Confirma excluir? " update sresp.
        if sresp
        then do transaction:
            prosubst.situacao = "EXC" .   
        end.
    END.
    if esqcom1[esqpos1] = " Relatorio"
    THEN DO:
        run relatorio.
    END.

    if esqcom2[esqpos2] = "    "
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
    then varquivo = "/admcom/relat/prosubst_f." + string(time).
    else varquivo = "..~\relat~\prosubst_f."  + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """   CONTROLE PRODUTO SUBSTITUTO  """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    find produ where produ.procod = bprosubst.procod no-lock no-error.
    find dprodu where dprodu.procod = bprosubst.prosub no-lock no-error.
    disp 
             prosubst.procod column-label "Substituido"
             produ.pronom no-label  format "x(20)"
             prosubst.prosub column-label "Substituto"
             dprodu.pronom no-label format "x(20)"
             prosubst.estmin column-label "Minimo" format ">>>9"
             prosubst.situacao column-label "Sit" format "x"
                with frame f-disp 1 column side-label.
 
    for each prosubst where prosubst.situacao <> "EXC" and
                            prosubst.tipo = "F"  and
                            prosubst.procod = bprosubst.procod and
                             prosubst.prosub = bprosubst.prosub
            no-lock:
        find estab where estab.etbcod = prosubst.etbcod
                no-lock.
                
        disp prosubst.etbcod column-label "Fil"
             estab.etbnom no-label
                with frame f-disp down width 110 .
 
    end.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure sel-filial:
    def var vdesloja like estab.etbnom init "".
     
for each tt-lj:
    delete tt-lj.
end.
IF estab.etbcod > 0  /* cat <> "LOJA" */
THEN DO:
    vetbcod = 0.
    update vetbcod with frame f1.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message color red/white "Estabelecimento nao Cadastrado"
            view-as alert-box title "Menssagem".
            undo, retry.
        end.
        disp vetbcod estab.etbnom no-label skip with frame f1. 
        create tt-lj.
        tt-lj.etbcod = estab.etbcod.
    end.
    else do:
        run seletbgr.p.
        for each tt-lj break by tt-lj.etbcod:
            vdesloja = vdesloja + " * " + string(tt-lj.etbcod).
        end.
        if vdesloja <> ""
        then  disp vdesloja @ estab.etbnom with frame f1.
        else do:
         /*   disp vetbcod "EMPRESA" @ estab.etbnom with frame f1.
            find first tt-lj no-error.
            for each estab no-lock:
                create tt-lj.
                tt-lj.etbcod = estab.etbcod.
            end. */
        end.
    end.
END.
else disp vetbcod estab.etbnom with frame f1.

end procedure.