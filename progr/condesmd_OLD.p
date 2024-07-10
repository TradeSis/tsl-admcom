{admcab.i }
def var vltotven like plani.platot.
def var vtotpre  like plani.platot.
def var vltotdes like plani.platot.
def var vpercmed like plani.platot.
def var vdt-aux    as date.

def var vdti as date.
def var vdtf as date.
assign vltotven = 0
       vltotdes = 0
       vdtf = today
       vdti = today - 30 .

def var vdiver as log.

def var na-promocao as log.

def var vprecoliberado as log.
def var vpromo as log.

def new shared temp-table tt-ctpromoc like ctpromoc.

def buffer bctpromoc for ctpromoc.

def var vetbcod like estab.etbcod.
vetbcod = setbcod.
if vetbcod = 999
then do:
update vetbcod label "Filial"
    with frame f1 1 down width 80 side-label.
end.
disp vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f1.  
if setbcod <> 999
then do:
    sresp = no.
    run p-valsenha.
    if sresp = no then return.
end.
disp vdti at 1 label "Periodo de"
     vdtf label "ate"
     with frame f3 centered no-box side-label.
      
def temp-table tt-plani 
    field etbcod like plani.etbcod
    field placod like plani.placod
    field movtdc like plani.movtdc
    field numero like plani.numero
    field pladat like plani.pladat
    field platot like plani.platot
    field plades like plani.descprod
    field pctdes as dec
    field tipo   as char
    index i1 numero.
def var vok as log.
def var vokc as log.
/*
message "Iniciando Parte 1".
pause.
*/
def var vokd as log.

run p-carrega-tt-promo.

do vdt-aux = vdti to vdtf:
for each plani where plani.movtdc = 5
                 and plani.etbcod = vetbcod
                 and plani.pladat = vdt-aux
                 no-lock.
    /*
    display "Plani " numero format ">>>>>>>>>>9" pladat.
    pause 0.
    */
    
    if acha("DESCONTO_FUNCIONARIO",plani.notobs[3]) = "SIM"
    then next.
    
    vok = yes.
    vokc = yes.
    vokd = yes.
    for each movim where 
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc and
             movim.movdat = plani.pladat
             no-lock:
        find last produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ then next.
        if produ.clacod = 101 or
           produ.clacod = 102 or
           produ.clacod = 107 or
           produ.clacod = 109 or
           produ.clacod = 201 or
           produ.clacod = 191 or
           produ.clacod = 181 
        then do:
            vok = no.
            leave.
        end.   
        
        if produ.clacod = 100 or
           produ.clacod = 101 or
           produ.clacod = 102 or
           produ.clacod = 107 or
           produ.clacod = 190 or
           produ.clacod = 191 or
           produ.clacod = 201 or
           produ.clacod = 202 or
           produ.procod = 405248 or
           produ.procod = 1383 or
           produ.procod = 493563
         then next.
         /*       
         vdiver = yes.
         run p-altpreco3per ( output vdiver ).
                             
         if not vdiver
         then next.
         */
         /*
         if avail plani
         then do:
             vprecoliberado = no.
             vpromo = no.
             run leplapromo2.p(input recid(plani),
                              input movim.procod,
                              output vpromo,
                              output vprecoliberado).
             if vprecoliberado or vpromo
             then do:
             
                 vokd = no.
                 leave.
             
             end.
         end.
         */
        if produ.catcod <> 31
        then do:
            vokc = no.
            leave.
        end.    
        
    end.      
    if vokc = no then next.
    vltotven = vltotven + (if plani.biss > 0
                           then plani.biss 
                           else (plani.platot - plani.vlserv)).

    if vok = no then next.   

    if plani.notobs[2] <> ""
    then do:
        if substr(plani.notobs[2],1,1) <> "J" and
            dec(plani.notobs[2]) > 0
        then do:
        vltotdes = vltotdes + dec(plani.notobs[2]).
        create tt-plani.
        assign
            tt-plani.etbcod = plani.etbcod
            tt-plani.placod = plani.placod
            tt-plani.movtdc = plani.movtdc
            tt-plani.numero = plani.numero
            tt-plani.pladat = plani.pladat
            tt-plani.platot = if plani.biss > 0
                           then plani.biss else plani.platot
            tt-plani.plades = dec(plani.notobs[2])
            tt-plani.tipo = "V"
            .
         end.                   
    end.
end.
end.
for each plani where plani.movtdc = 30
                 and plani.etbcod = vetbcod
                 and plani.pladat = vdtf
                     no-lock:
    if plani.serie <> "U"
    then next.
    
    if acha("DESCONTO_FUNCIONARIO",plani.notobs[3]) = "SIM"
    then next.

    vok = yes.
    vokc = yes.
    for each movim where 
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc and
             movim.movdat = plani.pladat
             no-lock:
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ then next.
        if produ.clacod = 101 or
           produ.clacod = 102 or
           produ.clacod = 107 or
           produ.clacod = 109 or
           produ.clacod = 201 or
           produ.clacod = 191 or
           produ.clacod = 181 
        then do:
            vok = no.
            leave.
        end.
        if produ.catcod <> 31
        then do:
            vokc = no.
            leave.
        end.    
    end. 
    
    if vokc = no then next.
    vltotven = vltotven + (if plani.biss > 0
                               then plani.biss 
                               else plani.platot - plani.vlserv).

    if vok = no then next.   
    
    if plani.notobs[2] <> "" 
    then do:
        if substr(plani.notobs[2],1,1) <> "J" and
           dec(plani.notobs[2]) > 0 
        then do:
        vltotdes = vltotdes + dec(plani.notobs[2]).
        create tt-plani.
        assign
            tt-plani.etbcod = plani.etbcod
            tt-plani.placod = plani.placod
            tt-plani.movtdc = plani.movtdc
            tt-plani.numero = plani.numero
            tt-plani.pladat = plani.pladat
            tt-plani.platot = if plani.biss > 0
                           then plani.biss else plani.platot
            tt-plani.plades = dec(plani.notobs[2])
            tt-plani.tipo = "P"
            .  
        end.
    end.
end.

vpercmed = ((vltotdes / vltotven) * 100).

disp "   " at 1
     vltotven at 3 label "Venda   " format ">,>>>,>>9.99"
     vltotdes at 3 label "Desconto" format ">,>>>,>>9.99"
     vpercmed at 3 label "Percent " format ">>>9.99%"
     "    " at 1
     with frame f2 color message no-box
     row 8 column 1 side-label.

form tt-plani.numero format ">>>>>>>9"
     tt-plani.pladat
     tt-plani.platot
     tt-plani.plades format "->>>,>>9.99"
     /*tt-plani.pctdes label "Pct" format "->>9.99%"
     tt-plani.tipo no-label format "!"   */
     with frame f-linha down column 25 width 55
     title "  VENDAS COM DESCONTO  " .

for each tt-plani:
    if tt-plani.plades = 0
    then delete tt-plani.
    else tt-plani.pctdes = (tt-plani.plades / tt-plani.platot) * 100.
end.    
{setbrw.i}
    {sklcls.i
        &help = "                   ENTER = Produtos da venda"
        &file = tt-plani
        &cfield = tt-plani.numero
        &noncharacter = /*
        &ofield = "
            tt-plani.pladat 
            tt-plani.platot
            tt-plani.plades
            "
        &aftselect1 = "
            if keyfunction(lastkey) = ""RETURN""
            then do on endkey undo:
                for each movim where movim.etbcod = tt-plani.etbcod and
                                     movim.placod = tt-plani.placod and
                                     movim.movtdc = tt-plani.movtdc and
                                     movim.movdat = tt-plani.pladat
                                     no-lock.
                    find produ where produ.procod = movim.procod no-lock.
                    FIND ESTOQ WHERE estoq.etbcod = movim.etbcod and
                                     estoq.procod = produ.procod
                                     no-lock.
                    disp movim.procod 
                         produ.pronom  format ""x(30)""
                         movim.movqtm format "">>>9"" column-label ""Qtd""
                         movim.movpc  format "">,>>>,>>9.99""
                         estoq.estvenda  format "">,>>>,>>9.99""
                         with frame f-mov down
                         row 10 column 11 width 70 overlay
                         title ""  "" + string(tt-plani.numero) + ""  "" + 
                         string(tt-plani.pladat,""99/99/9999"") + ""  "" +
                         string(tt-plani.platot,"">>,>>9.99"") + ""  "" +
                         string(tt-plani.plades,"">>,>>9.99"") + ""  "".
                end.
                pause.
                next keys-loop.
            end.
            else next keys-loop.
            "                
        &where = true
        &form = " frame f-linha "
}              
        
procedure p-valsenha:
     def var vfuncod like func.funcod.
     def var vsenha like func.senha.
     def buffer bfunc for func.
     
     vfuncod = 0. vsenha = "". sresp = no.
     
     update vfuncod label "Matricula"
            vsenha  label "Senha" blank
            with frame f-senha side-label centered color message row 10.

     find bfunc where bfunc.etbcod = setbcod
                  and bfunc.funcod = vfuncod no-lock no-error.
     if not avail bfunc
     then do:
         message "Funcionario Invalido".
         sresp = no.
         undo, retry.
     end.
     if bfunc.funmec = no
     then do:
        message "Funcionario nao e gerente".
        sresp = no.
        undo, retry.
     end.
     if vsenha <> bfunc.senha
     then do:
         message "Senha invalida".
         sresp = no.
         undo, retry.
     end.
     else sresp = yes.
end.


procedure p-carrega-tt-promo:

    for each ctpromoc where ctpromoc.dtinicio <= vdtf
                        and ctpromoc.dtfim    >= vdti
                        and ctpromoc.linha = 0 no-lock,

        each bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia
                         and bctpromoc.produtovendacasada > 0
                         and bctpromoc.fincod > 0
                         and bctpromoc.linha > 0 no-lock:
               
        create tt-ctpromoc.
        buffer-copy bctpromoc to tt-ctpromoc.
                                  
        assign tt-ctpromoc.dtinicio = ctpromoc.dtinicio
               tt-ctpromoc.dtfim    = ctpromoc.dtfim.                         
 
    end.

end procedure.
