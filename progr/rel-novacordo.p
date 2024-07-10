{admcab.i}

def temp-table tt-acordo
    field etb_acordo like estab.etbcod
    field clicod like clien.clicod
    field clinom like clien.clinom
    field contnum_ori as char format "x(15)"
    field contnum_atu like contrato.contnum
    field id_acordo like novacordo.id_acordo
    field datinclu as date
    field datnovacao as date
    field motivo as char
    index i1 etb_acordo clicod
    .
    
def var vdti as date.
def var vdtf as date.
def var vsit as char extent 3 format "x(15)"
    init["PENDENTES","EFETIVADOS","CANCELADOS"].

update vdti label "Periodo acordo"
       vdtf label "a"
       with frame f-dt side-label width 80
       .

def var vindex as int.
disp vsit with frame f-sit no-label centered.
choose field vsit with frame f-sit.
vindex = frame-index.

def var varquivo as char.

for each novacordo use-index indx2 where 
         novacordo.dtinclu >= vdti and
         novacordo.dtinclu <= vdtf  no-lock.
    if (vindex = 1 or vindex = 2) and
        novacordo.situacao <> "PENDENTE"
    then next.     
    /*else if vindex = 2 and
        novacordo.situacao <> "EFETIVADO"
        then next.*/
        else if vindex = 3 and
            novacordo.situacao <> "CANCELADO"
            then next.

    find clien where clien.clicod = novacordo.clicod no-lock no-error.
    if vindex = 1
    then
    for each tit_novacao where
             tit_novacao.tipo = "" and
             tit_novacao.id_acordo = string(novacordo.id_acordo)
             no-lock:
        find first tt-acordo where
                   tt-acordo.contnum_ori = tit_novacao.ori_titnum
                    no-error.
        if not avail tt-acordo
        then do:
            create tt-acordo.        
            assign
                tt-acordo.etb_acordo = novacordo.etb_acordo
                tt-acordo.clicod = novacordo.clicod
                tt-acordo.clinom = clien.clinom
                tt-acordo.contnum_ori = tit_novacao.ori_titnum
                tt-acordo.contnum_atu = tit_novacao.ger_contnum
                tt-acordo.id_acordo = novacordo.id_acordo
                tt-acordo.datinclu = novacordo.dtinclu
                tt-acordo.datnovacao = novacordo.dtefetivacao
                .
            /*if 
                acha("RENEGOCIACAO",tit_novacao.tipo) <> ?
            then do:
                if acha("CANCELADA",tit_novacao.tipo) <> ?
                then tt-acordo.motivo = 
                    acha("CANCELADA",tit_novacao.tipo).
            end.*/
        end.                                                
    end.
    if vindex = 2
    then
    for each tit_novacao where
             tit_novacao.tipo = "RENEGOCIACAO" and
             tit_novacao.id_acordo = string(novacordo.id_acordo)
             no-lock:
        find first tt-acordo where
                   tt-acordo.contnum_ori = tit_novacao.ori_titnum
                    no-error.
        if not avail tt-acordo
        then do:
            create tt-acordo.        
            assign
                tt-acordo.etb_acordo = novacordo.etb_acordo
                tt-acordo.clicod = novacordo.clicod
                tt-acordo.clinom = clien.clinom
                tt-acordo.contnum_ori = tit_novacao.ori_titnum
                tt-acordo.contnum_atu = tit_novacao.ger_contnum
                tt-acordo.id_acordo = novacordo.id_acordo
                tt-acordo.datinclu = novacordo.dtinclu
                tt-acordo.datnovacao = novacordo.dtefetivacao
                .
            /*if 
                acha("RENEGOCIACAO",tit_novacao.tipo) <> ?
            then do:
                if acha("CANCELADA",tit_novacao.tipo) <> ?
                then tt-acordo.motivo = 
                    acha("CANCELADA",tit_novacao.tipo).
            end.*/
        end.                                                
    end.
    if vindex = 3
    then
    for each tit_novacao where
             tit_novacao.tipo begins "RENEGOCIACAO|CANCELADA|" and
             tit_novacao.id_acordo = string(novacordo.id_acordo)
             no-lock:
        find first tt-acordo where
                   tt-acordo.contnum_ori = tit_novacao.ori_titnum
                    no-error.
        if not avail tt-acordo
        then do:
            create tt-acordo.        
            assign
                tt-acordo.etb_acordo = novacordo.etb_acordo
                tt-acordo.clicod = novacordo.clicod
                tt-acordo.clinom = clien.clinom
                tt-acordo.contnum_ori = tit_novacao.ori_titnum
                tt-acordo.contnum_atu = tit_novacao.ger_contnum
                tt-acordo.id_acordo = novacordo.id_acordo
                tt-acordo.datinclu = novacordo.dtinclu
                tt-acordo.datnovacao = novacordo.dtefetivacao
                .
            /*if 
                acha("RENEGOCIACAO",tit_novacao.tipo) <> ?
            then do:
                if acha("CANCELADA",tit_novacao.tipo) <> ?
                then tt-acordo.motivo = 
                    acha("CANCELADA",tit_novacao.tipo).
            end.*/
        end.                                                
    end.

end.

varquivo = "/admcom/progr/novacordo." + string(time).

{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "150" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """ RELATORIO DE ACORDOS "" + vsit[vindex] " 
                &Width     = "150"
                &Form      = "frame f-cabcab"}

disp with frame f-dt.

         
if vindex = 1 or vindex = 2
then run disp-efe.
else run disp-can.

output close.

run visurel.p(varquivo,"").

procedure disp-efe:
    for each tt-acordo:
        disp tt-acordo.etb_acordo column-label "Filial"
             tt-acordo.clicod      column-label "Cliente" format ">>>>>>>>>9"
             tt-acordo.clinom   when avail clien    format "x(30)"
             tt-acordo.contnum_ori column-label "Contrato!original"
             tt-acordo.contnum_atu column-label "Novo!Contrato"
                        format ">>>>>>>>>9"
             tt-acordo.id_acordo column-label "Numero!Acordo"
             tt-acordo.datinclu column-label "Data!Acordo"
             tt-acordo.datnovacao column-label "Data!Novacao"
            with frame f-dc width 150 down.
    end.
end procedure.
procedure disp-can:
    for each tt-acordo:
        disp tt-acordo.etb_acordo column-label "Filial"
             tt-acordo.clicod      column-label "Cliente" format ">>>>>>>>>9"
             tt-acordo.clinom   when avail clien    format "x(30)"
             tt-acordo.contnum_ori column-label "Contrato!original"
             tt-acordo.contnum_atu column-label "Novo!Contrato"
                            format ">>>>>>>>>9"
             tt-acordo.id_acordo column-label "Numero!Acordo"
             tt-acordo.datinclu column-label "Data!Acordo"
             tt-acordo.motivo column-label "Motivo"
                        format "x(30)"
             with frame f-dd width 150 down.
    end.
end procedure.

