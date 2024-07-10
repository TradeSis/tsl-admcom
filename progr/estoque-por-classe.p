{admcab.i}

def var vcla-cod like clase.clacod.
def var vclacod like clase.clacod.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def new shared temp-table wpro
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field munic  like estab.munic format "x(20)"
    field prounven like produ.prounven
    field estvenda like estoq.estvenda
    field estcusto like estoq.estcusto 
    field estatual like estoq.estatual
    field wreserva like estoq.estatual
    field estproper like estoq.estproper
    field estprodat like estoq.estprodat
    .

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

update vcla-cod label "Classe" with frame f1 side-label width 80.

vclacod = vcla-cod.
if vclacod <> 0
then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom format "x(20)" no-label with frame f1.
end.
else undo.


    if vclacod <> 0
    then do:
        find first clase where clase.clasup = vclacod no-lock no-error. 
        if avail clase 
        then do:
            message "Montando Tabela Temporaria de Classes...".
            pause 2 no-message.
            run cria-tt-clase. 
            hide message no-pause.
        end. 
        else do:
            find clase where clase.clacod = vclacod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao Cadastrada".
                undo.
            end.

            create tt-clase.
            assign tt-clase.clacod = clase.clacod
                   tt-clase.clanom = clase.clanom.
        end.
    end.
 
def temp-table tt-produ
    field procod like produ.procod
    field pronom like produ.pronom
    field estlj as dec
    field estdp as dec
    index i1 pronom.

for each tt-clase no-lock:
    for each produ where produ.clacod = tt-clase.clacod no-lock:
        create tt-produ.
        tt-produ.procod = produ.procod.
        tt-produ.pronom = produ.pronom.
    end.
end.    

for each tt-produ :
    find produ where produ.procod = tt-produ.procod no-lock.
    find estoq where estoq.etbcod = setbcod and
                     estoq.procod = tt-produ.procod
                     no-lock no-error.
    if avail estoq and estoq.estatual <> 0
    then tt-produ.estlj = estoq.estatual.
    find estoq where estoq.etbcod = 900 and
                     estoq.procod = tt-produ.procod
                     no-lock no-error.
    if avail estoq and estoq.estatual <> 0
    then tt-produ.estdp = estoq.estatual.

    for each wpro:
        delete wpro.
    end.
        
    run disponivel.


    find first wpro where wpro.etbcod = 900
                     no-lock no-error.
           
    if avail wpro and
       wpro.wreserva > 0 and
       tt-produ.estdp <> 0
    then tt-produ.estdp = tt-produ.estdp - wpro.wreserva.
                    
end.

for each tt-produ:
    if tt-produ.estlj = 0 and
       tt-produ.estdp = 0
    then delete tt-produ. 
end.      
                     
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
    initial ["","","","",""].
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


form tt-produ.procod  column-label "Codigo"
     tt-produ.pronom  column-label "Descricao"  format "x(40)"
     tt-produ.estlj   column-label "Loja"    format "->>>>9"
     tt-produ.estdp   column-label "Dep.900" format "->>>>9"
     with frame f-linha 10 down 
     width 80 row 6.
                                                                         
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-produ  
        &cfield = tt-produ.pronom
        &ofield = " tt-produ.procod
                    tt-produ.estlj when tt-produ.estlj <> 0
                    tt-produ.estdp when tt-produ.estdp <> 0
                    "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message ""Nenhum registro encontrado."". 
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
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
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

                
procedure cria-tt-clase.
 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-clase where tt-clase.clacod = gclase.claco~d 
                                                        no-error.
                             if not avail tt-clase
                             then do:
                             
                                 create tt-clase. 
                                 assign tt-clase.clacod = gclase.clacod 
                                        tt-clase.clanom = gclase.clanom.
                                        
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.

procedure disponivel:
        
        def var reserva as dec.
        def var vespecial as dec.
        def var vdata as date.
        
        find estab where estab.etbcod = 900 no-lock.
           
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        if estab.etbcod = 900
        then do:

            reserva = 0. 
            vespecial = 0.  
            do vdata = today - 40 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                reserva = reserva + liped.lipqtd.
            
            end.

            /* pedido especial */

            for each liped where liped.pedtdc = 6 
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock,
                first pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum and
                                 pedid.pedsit = yes    and
                                 pedid.sitped = "P"
                                 no-lock.

                
                vespecial = vespecial + liped.lipqtd.
               end.
            end.
            
            if (estoq.estatual - vespecial) < 0
            then vespecial = 0.

            for each liped where liped.pedtdc = 3
                             and liped.predt  > vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                reserva = reserva + liped.lipqtd.
            end.
            
            /*********** Reservas do E-Commerce **********/
            for each liped where liped.pedtdc = 8
                             and liped.predt  = today
                             and liped.procod = produ.procod no-lock:
  
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid
                then next.
                                                                 
                reserva = reserva + liped.lipqtd.
            end.
            
            /*** fim de reservas futuras - sol 26212 ***/    
        end.           
         
        create wpro.
        assign wpro.etbcod = estab.etbcod
               wpro.etbnom = estab.etbnom
               wpro.munic  = estab.munic
               wpro.prounven = produ.prounven
               wpro.estvenda = estoq.estvenda
               wpro.estcusto = estoq.estcusto
               wpro.estatual = estoq.estatual
               wpro.estproper = estoq.estproper
               wpro.estprodat = estoq.estprodat.
    
        if wpro.etbcod = 900
        then wpro.wreserva = reserva + vespecial.
        
end procedure.
