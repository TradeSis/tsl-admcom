{admcab.i} 
{setbrw.i}

ON F8 CLEAR.
ON PF8 CLEAR.
ON F5 GET.
ON PF5 GET.

def var vextenso as char extent 3.

def var vcheque as char.
def var vdig as int.
def var vdatini as date format "99/99/9999".
def var vdatfin as date format "99/99/9999".
def var vvalorm as dec.
def var vinicial as dec.
def var vfinal as dec.
def var vdescval as dec.
def var vdifer as dec.

def var vcidade like clifor.cidade.
def var vdatval as date format "99/99/9999".
def var vagfiscod as int.
def var vpctbonus as dec format ">>9.99%".
def var vqtdcli as int.
def var vvalvenda as dec format ">>,>>>,>>9.99".
def var vvalbonus as dec format ">>>,>>9.99".
def var vcntdesc as int.
def var vindex as char.
def var findex as int.
def var vqtd as int.
def var vdesc1 as char format "x(70)".
def var vdesc2 as char format "x(70)".
def var vdesc3 as char format "x(70)".
def var vdesc0 as char format "X(70)".
def var vdesc4 as char format "x(70)".
def var vi as int.
def var c-nome          as char form 'x(42)' extent 2.
def var c-campo1        as char form 'x(42)' extent 2.
def var c-campo2        as char form 'x(42)' extent 2.
def var c-campo3        as char form 'x(42)' extent 2.

def var ct-cont         as inte.
def var i-col1          as inte form "999" initial 001.
def var i-col2          as inte form "999" initial 065.
def var i-col3          as inte form "999" initial 099.
def var i-col4          as inte form "999" initial 149.

def var vcepini like clifor.cep.
def var vnomini like clifor.clfnom.
def var vnumini like desesp.codigo format ">>>>>>>>9".
def var vponini like desesp.valdes.

def var vquant as int.
def var vtiporel as char format "x(15)" extent 4
      init [" DESCONTO ", " CLIENTES ", " p/ CARTAO ", " USO "].
def var vestenso as char.
def var vselordem as char format "x(15)" extent 4
  init[" NUMERO ","   NOME  ","   CEP   ","  PONTOS  "].  
def var vnomes as char format "x(15)" extent 12
    init["janeiro","fevereiro","marco","abril","maio","junho","julho",
         "agosto","setembro","outubro","novembro","dezembro"].

def var vsit as char.
def buffer bcontrole for controle.

def temp-table tt-desesp 
    field codigo like desesp.codigo
    field clfnom like clifor.clfnom
    field destip like desesp.destip
    field cep like clifor.cep
    field valdes  like desesp.valdes
    field etbcod    like desesp.etbcod
    field descval like desesp.descval
    field cartao as log init no.

form controle.numini      column-label "Numero"
     controle.datini      column-label "Dt.Inicio"
     controle.datfim      column-label "Dt.Fim"
     controle.quantidade  column-label "Clientes"
     controle.valor       column-label "Valor"
     controle.validade    column-label "Validade"
     with frame f-linha down centered color with/red.

form tt-desesp.codigo  column-label "Numero" format ">>>>>>>>9"
     tt-desesp.valdes  column-label "Valor"  format ">>,>>9.99"
     tt-desesp.clfnom  column-label "Cliente" format "x(30)"
     tt-desesp.cep     column-label "CEP"
     tt-desesp.descval column-label "Desc" format ">>9.99"
     tt-desesp.etbcod  column-label "Uso" format ">>9"
     vsit no-label format "!!!"
     tt-desesp.cartao column-label "Car" format "Sim/Nao"
     with frame f-linha1 down centered color with/cyan
     title " Numero: " + controle.numini + " " + 
           " Periodo: " + string(controle.datini) + " a " +
        string(controle.datfim) width 80.    

form "Ordenando registros... " desesp.codigo format ">>>>>>>>9"
        vqtd "........Aguarde!!! "
      with frame f-disp 1 down row 18 no-label overlay
        color red/with centered no-box.

form with frame f-linha3.
form with frame f-sel overlay title " qual ordem? ".

run leini.p(input "CNTDESCONTO",
            output vvalorconfig).

vcntdesc = int(vvalorconfig).            

vinicial = 0.
vfinal = 0.

find first tcontrole where
           tcontrole.tipcon = vcntdesc no-lock no-error.

        
repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1.

    {sklcls.i
        &help = "ENTER=Seleciona F4=Retorna"
        &file         = controle
        &cfield       = controle.numini
        &noncharacter = /* 
        &ofield       = " 
                        controle.datini
                        controle.datfim
                        controle.quantidade
                        controle.valor
                        controle.validade
                        " 
        &where        = " controle.tipcon = tcontrole.tipcon "
        &color        = with
        &color1       = red
        &aftselect1    = "
                
                if keyfunction(lastkey) = ""return"" 
                then leave keys-loop.
                else next keys-loop.
                        "                
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave .

    if keyfunction(lastkey) = "return"
    then do:
        for each tt-desesp.
            delete tt-desesp.
        end.    
        update controle.validade.
        
        display vselordem with frame f-sel 1 down centered row 8
                no-label color with/black.
        choose field vselordem with frame f-sel.   
        vqtd = 0.
        if frame-index = 1   /*Numero*/
        then do:
            vindex = "d1".
            
            vdig = length(controle.numini).
            for each destip no-lock:
            for each   desesp where
                        desesp.destip = destip.destip and
                        substr(string(desesp.codigo),1,vdig) = controle.numini 
                        no-lock use-index des1,
                first clifor where
                              clifor.tclcod = 1 and
                              clifor.clfcod = 
                                int(substr(string(desesp.codigo),vdig + 1,7))     
                                no-lock .
                if desesp.valdes <= 0 and
                   desesp.descval = 0
                then next.
                vqtd = vqtd + 1.
                display desesp.codigo vqtd with frame f-disp .
                pause 0.                
                create tt-desesp.
                assign
                    tt-desesp.codigo = desesp.codigo
                    tt-desesp.clfnom = clifor.clfnom
                    tt-desesp.cep    = clifor.cep
                    tt-desesp.valdes = desesp.valdes
                    tt-desesp.descval = desesp.descval
                    tt-desesp.etbcod = desesp.etbcod
                    tt-desesp.destip = desesp.destip.
                if clifor.cartao = ?
                then.
                else tt-desesp.cartao = yes.
            end.
                        end.
        end. 
        if frame-index = 2   /*Nome*/
        then do:
            vindex = "d2".
            vdig = length(controle.numini).
            for each destip no-lock:
            for each    desesp where
                        desesp.destip = destip.destip and
                        substr(string(desesp.codigo),1,vdig) = controle.numini 
                        no-lock ,
                first clifor where
                              clifor.tclcod = 1 and
                              clifor.clfcod = 
                                int(substr(string(desesp.codigo),vdig + 1,7))     
                                no-lock break by clifor.clfnom.
                if desesp.valdes <= 0 and
                   desesp.descval = 0
                then next.
                vqtd = vqtd + 1.
                display desesp.codigo vqtd with frame f-disp .
                pause 0.                
                create tt-desesp.
                assign
                    tt-desesp.codigo = desesp.codigo
                    tt-desesp.clfnom = clifor.clfnom
                    tt-desesp.cep    = clifor.cep
                    tt-desesp.valdes = desesp.valdes
                    tt-desesp.descval = desesp.descval
                    tt-desesp.etbcod = desesp.etbcod
                    tt-desesp.destip = desesp.destip .
                if clifor.cartao = ?
                then.
                else tt-desesp.cartao = yes.

            end. 
            end.
        end.            
        if frame-index = 3   /*CEP*/
        then  do:
            vindex = "d3".
            vdig = length(controle.numini).
            for each destip no-lock:
            for each    desesp where
                        desesp.destip = destip.destip and
                        substr(string(desesp.codigo),1,vdig) = controle.numini 
                        no-lock ,
                first clifor where
                              clifor.tclcod = 1 and
                              clifor.clfcod = 
                                int(substr(string(desesp.codigo),vdig + 1,7))     
                                no-lock break by clifor.cep.
                if desesp.valdes <= 0 and
                   desesp.descval = 0
                then next.
                vqtd = vqtd + 1.
                display desesp.codigo vqtd with frame f-disp .
                pause 0.                
                create tt-desesp.
                assign
                    tt-desesp.codigo = desesp.codigo
                    tt-desesp.clfnom = clifor.clfnom
                    tt-desesp.cep    = clifor.cep
                    tt-desesp.valdes = desesp.valdes
                    tt-desesp.descval = desesp.descval
                    tt-desesp.etbcod = desesp.etbcod
                    tt-desesp.destip = desesp.destip.
                if clifor.cartao = ?
                then.
                else tt-desesp.cartao = yes.

            end. 
            end.
        end.
        if frame-index = 4   /*Valor*/
        then do:
            vindex = "d4".
            vdig = length(controle.numini).
            for each destip no-lock:
            for each    desesp where
                        desesp.destip = destip.destip and
                        substr(string(desesp.codigo),1,vdig) = controle.numini 
                        no-lock ,
                first clifor where
                              clifor.tclcod = 1 and
                              clifor.clfcod = 
                                int(substr(string(desesp.codigo),vdig + 1,7))     
                                no-lock break by desesp.valdes descending.
                if desesp.valdes <= 0 and
                   desesp.descval = 0
                then next.
                vqtd = vqtd + 1.
                display desesp.codigo vqtd with frame f-disp .
                pause 0.                
                create tt-desesp.
                assign
                    tt-desesp.codigo = desesp.codigo
                    tt-desesp.clfnom = clifor.clfnom
                    tt-desesp.cep    = clifor.cep
                    tt-desesp.valdes = desesp.valdes
                    tt-desesp.descval = desesp.descval
                    tt-desesp.etbcod = desesp.etbcod
                    tt-desesp.destip = desesp.destip.
                if clifor.cartao = ?
                then.
                else tt-desesp.cartao = yes.
            end. 
            end.
        end.

        hide frame f-sel no-pause.

        assign 
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.

        l1: repeat:

        {sklcls.i
            &help         = 
           "F4=Volta F5=Bloq F8=Proc F9=Bonus F10=Etiq F11=Relat F12=Desconto"
            &file         = tt-desesp
            &cfield       = tt-desesp.codigo
            &noncharacter = /* 
            &ofield       = " 
                    tt-desesp.valdes tt-desesp.clfnom tt-desesp.cep
                    tt-desesp.descval 
                    tt-desesp.etbcod when tt-desesp.etbcod > 0 
                    vsit tt-desesp.cartao 
                    " 
            &where = " true "
            &aftfnd1 = " if tt-desesp.destip = 999
                         then vsit = ""BLO"". else vsit = "" "".
                       "  
            &naoexiste1 = " bell. message color red/with 
                         ""Nenhum Registro Encontrado"" view-as alert-box
                         title "" Atencao!! "". leave keys-loop.  "
                                       
            &procura     = " codesesp.pc " 
            &color        = with
            &color1       = cyan
            &otherkeys1    = "
                if keyfunction(lastkey) = ""copy"" or
 keyfunction(lastkey) = ""paste"" or   keyfunction(lastkey) = ""new-line"" or
 keyfunction(lastkey) = ""insert-mode"" or keyfunction(lastkey) = ""delete-line"" or
                   keyfunction(lastkey) = ""cut""
                then do:
                    find first tt-desesp where recid(tt-desesp) =
                                        a-seerec[frame-line].
                    leave keys-loop.
                end.
                    "                
            &form         = " frame f-linha1 " } 
            
        if keyfunction(lastkey) = "end-error"
        then leave l1.
        
        if keyfunction(lastkey) = "copy"
        then do:
            
            disp vtiporel with frame f-rel 1 down centered no-label 
                    overlay row 8 title " relatorio de ?".
            choose field vtiporel with frame f-rel.
            findex = frame-index.
            update vinicial label "Valor Inicial"
                    vfinal  label "Valor Final" 
                    with frame fintervalo overlay
                    side-label color with/black centered.
            {selimpre.i}.

            assign varqsai = estab.dirrel + "codesesp." + string(time).
            
            {mdadmcab.i
                &Saida     = "value(varqsai)" 
                &Page-Size = "62"  
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""mapavend""
                &Nom-Sis   = """PERIODO "" + 
                                    string(controle.datini,""99/99/9999"") +
                            "" A ""   + 
                            string(controle.datfim,""99/99/9999"")"
                &Tit-Rel   = """ DESCONTO ESPECIAL NUMERO "" + 
                                string(controle.numini)"
                &Width     = "80"
                &Form      = "frame f-cabcab"}
            
            if findex < 3
            then view frame fintervalo.

            vdig = length(controle.numini).

            if vfinal = 0 then vfinal = 10000000.
            for each tt-desesp  where tt-desesp.valdes >= vinicial and
                                      tt-desesp.valdes <= vfinal no-lock :
                find first clifor where
                              clifor.tclcod = 1 and
                              clifor.clfcod = 
                             int(substr(string(tt-desesp.codigo),vdig + 1,7))                                    no-lock no-error.
                vcheque = "".
                find last cheque where cheque.cgccpf = clifor.cgccpf and
                           cheque.chepag = ? no-lock no-error.
                if avail cheque and cheque.chenom = clifor.clfnom
                then 
                    vcheque = "*".
                if findex = 1
                then do:
                disp tt-desesp.codigo  column-label "Numero" format ">>>>>>>>9"
                     clifor.clfnom  column-label "Cliente" format "x(40)"
                     tt-desesp.valdes  column-label "Valor"
                     tt-desesp.descval column-label "Desc"
                     with frame f-linha3 down.
                down with frame f-linha3.
                end.
                else if findex = 2
                then do:
                display clifor.clfcod(count)  column-label "Codigo"
                        clifor.clfnom   column-label "Nome" 
                        tt-desesp.valdes(total)    column-label "Valor"
                        tt-desesp.descval(total)   column-label "Desc."
                        clifor.fone     column-label "Telefone"
                        clifor.celular  column-label "Celular"
                        clifor.e-mail     column-label "E-mail"
                        clifor.endereco format "x(30)"    
                        clifor.numero
                        clifor.compl
                        clifor.cep
                        clifor.bairro  format "x(15)"
                        clifor.cidade  format "x(15)"
                        clifor.ufecod
                        vcheque no-label format "x"
                        with frame f-disp1 down width 140.
                down with frame f-disp1.
    
                end.
                else if findex = 3 and clifor.cartao = ?
                then do:
                    
                disp int(substr(string(tt-desesp.codigo,">>>>>>>>9"),3,7))
                    column-label "Codigo" format ">>>>>>>>9"
                     clifor.clfnom  column-label "Nome"
                     with frame f-disp2 down centered width 80.
                down with frame f-disp2.
                clear frame f-disp2.
                end.
                else if findex = 4 and tt-desesp.etbcod > 0
                then do:
                disp tt-desesp.codigo  column-label "Numero" format ">>>>>>>>9"
                     clifor.clfnom  column-label "Cliente" format "x(40)"
                     tt-desesp.valdes(total)  column-label "Valor"
                     tt-desesp.descval(total) column-label "Desc"
                     tt-desesp.etbcod  column-label "Uso"
                     with frame f-linha30 down .
                down with frame f-linha30.
                end.
            end.
            if findex = 1
            then do:
            down(2) with frame f-linha3.
             
            display "Total Geral Desconto" @ clifor.clfnom
                    controle.valor @ tt-desesp.valdes
                    with frame f-linha3.
            end.
            {mdadmrod.i 
                &Saida     = " value(varqsai) "}  
            hide frame f-rel.
            hide frame fintervalo.
        end.
        
        if keyfunction(lastkey) = "paste"
        then do:
        
            message "Desconto Total ? " update sresp.
            
            if sresp = yes 
            then do:
                vdescval = tt-desesp.descval.
                update vdescval 
                    with frame fdes centered color white/black.
            
                for each desesp where
                         desesp.destip = 1 and
                      substr(string(desesp.codigo),1,vdig) = controle.numini. 
                    vdifer = vdescval - desesp.descval.
                    desesp.valdes = desesp.valdes - vdifer.
                    desesp.descval = desesp.descval + vdifer.
                end.
                leave l1.
            end.
            else do:
                vdescval = tt-desesp.descval.
                update tt-desesp.descval with frame f-linha1.
                vdifer = tt-desesp.descval - vdescval.
                find first desesp where desesp.destip = 1 and
                                        desesp.codigo = tt-desesp.codigo
                                        no-error.
                if avail desesp
                then do:
                    desesp.valdes = desesp.valdes - vdifer.
                    desesp.descval = desesp.descval + vdifer.
                    tt-desesp.valdes = desesp.valdes.
                end.
                a-recid = recid(tt-desesp).
                a-seeid = -1.
                next l1.
            end.
            
        end.


        vnumini = 0. vnomini = "". vcepini = "".
        
        if keyfunction(lastkey) = "New-line" or
           keyfunction(lastkey) = "insert-mode"
        then do:
            if vindex = "d1"
            then 
                update vnumini label "Numero inicial" with frame fnum 1 down
                    centered side-label overlay row 10.
            else if vindex = "d2"
            then
                update vnomini label "Nome inicial" with frame fnom 1 down
                    centered side-label overlay row 10.
            else if vindex = "d3"
            then
                update vcepini label "CEP inicial" with frame fcep 1 down
                    centered side-label overlay row 10.

            update vinicial vfinal with frame fintervalo.

            {selimpre.i}.

            assign varqsai = estab.dirrel + "impbonus." + string(time).
            
            vdesc1 = " " + string(day(controle.datini),"99") + "/" +
                           string(month(controle.datini),"99") + "/" + 
                           string(year(controle.datini),"9999") + " a " +
                           string(day(controle.datfim),"99") + "/" +
                           string(month(controle.datfim),"99") + "/" + 
                           string(year(controle.datfim),"9999"). 

            vdesc2 = "Porto Alegre, " + string(day(today),"99") + " de " +
                     vnomes[month(today)] + " de " + string(year(today),"9999").
            vdesc3 = "Valido ate " + string(controle.validade,"99/99/99").

            vquant = 0.    
            vqtd = 0.
            output to value(varqsai).
            
            
            put control chr(27) + "P" + chr(15).
            
            /**
            put control chr(27).
            put "&l3A".
            put control chr(27).
            put "*o-1M".
            **/
            
            put skip(1).
            put control chr(27) + "0".
            /*put skip(1)*/.
                
            for each tt-desesp where 
                                      tt-desesp.valdes >= vinicial and
                                      tt-desesp.valdes <= vfinal :
                if tt-desesp.destip = 999
                then next.
                if vcepini <> "" and tt-desesp.cep < vcepini
                then next.
                if vnumini <> 0 and tt-desesp.codigo < vnumini
                then next.
                if vnomini <> "" and tt-desesp.clfnom < vnomini
                then next.
                
                vdesc0 = tt-desesp.clfnom.
 
                run extenso.p(input tt-desesp.valdes,
                              input "70",
                              output vextenso[1],
                              output vextenso[2]).
                assign
                    vextenso[1] = caps(vextenso[1]) +
                                  caps(vextenso[2]).

                vqtd = vqtd + 1.
                vquant = vquant + 1.

             /* if vqtd = 1 then
                  put skip(1). */

                put control chr(27) + "P" + chr(15).
                
                /*
                put control chr(27).
                put "(s008H".
                */
                
                put tt-desesp.valdes at 70 format ">,>>9.99" skip(3).
                
                put vdesc0 at 28 format "x(50)" skip(1).

                put control chr(27) + "P" + chr(15).
                
                /*  
                put control chr(27).
                put "(s013H".
                */
                
                put vextenso[1] format "x(70)" at 5 skip.
                if substr(vextenso[2], 1, 1) = "*" then
                  put skip(4).
                else
                  put vextenso[2] format "x(70)" at 5 skip(4).

                put control chr(27) + "P" + chr(15).
                /*
                put control chr(27).
                put "(s008H".
                */
                
                /*
                put control chr(27).
                put "(s013H".
                */
                
                put vdesc1 at 35 skip(1).

                /*
                put control chr(27).
                put "(s011H".
                */
                
                put vdesc2 at 25 skip(1).

                /*
                put control chr(27).
                put "(s013H".
                */
                
                put  "(" at 10
                      tt-desesp.codigo format ">>>>>>>>>9"
                      " )" skip(1).

                put  skip(9).
           
            end.
                
            put control chr(27) + "2".
            {mdadmrod.i 
                &Saida     = " value(varqsai) "}  

        end.
        
        if keyfunction(lastkey) = "delete-line"  or
           keyfunction(lastkey) = "CUT"
        then do:
            update vcepini label "CEP inicial" with frame fcep 1 down
                    centered side-label overlay row 10.
                    
            update vinicial vfinal with frame fintervalo.

            {selimpre.i}.

            assign varqsai = estab.dirrel + "codesesp." + string(time).

            /*********teste******/
            repeat on endkey undo:
                bell.
                sresp = yes.
                message color red/with
                    "Imprimir teste?"
                    view-as alert-box buttons yes-no title ""
                    update sresp.
                if sresp = no
                then leave.
                    
                output to value(varqsai).
           
                vqtd = 0.
                vquant = 0.
                vi = 0.

                for each tt-desesp where (if vcepini <> ""
                                          then tt-desesp.cep >= vcepini
                                          else true) and
                                          tt-desesp.valdes >= vinicial and
                                          tt-desesp.valdes <= vfinal :
                    vi = vi + 1.
                    if vi = 4
                    then leave.
                    find first clifor where
                              clifor.tclcod = 1 and
                              clifor.clfcod = 
                                int(substr(string(tt-desesp.codigo),3,7))     
                                no-lock no-error.
                    find first cidade where cidade.cidcod = clifor.cidcod no-lock no-error.
                    if avail cidade 
                    then vcidade = cidade.cidnom.
                    else vcidade = clifor.cidade.
                     
                    assign 
                        ct-cont             = ct-cont + 1
                        c-nome[ct-cont]     = trim(substring(clifor.clfnom,1,45))
                        c-campo1[ct-cont]   = trim(clifor.endereco) + ", " +  
                                              trim(clifor.numero) + " - " +
                                              trim(clifor.compl) 
                        c-campo2[ct-cont]   = trim(clifor.bairro).
                                          
                        c-campo3[ct-cont]   = clifor.cep    + "   " +
                                              trim(vcidade) + "   " +
                                              clifor.ufecod.

                    if ct-cont = 2 
                    then do :

                        put control chr(27) + "P" + chr(15).
                                                
                        put c-nome[1]     at i-col1
                            c-nome[2]     at i-col2
                         /* c-nome[3]     at i-col3 */
                         /* c-nome[4]     at i-col4 */
                            c-campo1[1]   at i-col1
                            c-campo1[2]   at i-col2
                         /* c-campo1[3]   at i-col3 */
                         /* c-campo1[4]   at i-col4 */
                            c-campo2[1]   at i-col1
                            c-campo2[2]   at i-col2
                         /* c-campo2[3]   at i-col3 */
                         /* c-campo2[4]   at i-col4 */               
                            c-campo3[1]   at i-col1
                            c-campo3[2]   at i-col2
                         /* c-campo3[3]   at i-col3 */
                         /* c-campo3[4]   at i-col4 */
                            skip(2).
                
                        assign c-nome     = ""
                               c-campo1 = ""
                               ct-cont    = 0.
                    end.
                end. 

                {mdadmrod.i &Saida     = " value(varqsai) "}.

            end.

            /***********/
            output to value(varqsai).
            
                       /* put unformat chr(15).*/
           
            vqtd = 0.
            vquant = 0.

            for each tt-desesp where (if vcepini <> ""
                                          then tt-desesp.cep >= vcepini
                                          else true) 
                                  and tt-desesp.valdes >= vinicial and
                                      tt-desesp.valdes <= vfinal :
                if tt-desesp.destip = 999
                then next.
                find first clifor where
                              clifor.tclcod = 1 and
                              clifor.clfcod = 
                                int(substr(string(tt-desesp.codigo),3,7))     
                                no-lock no-error.
                find first cidade where cidade.cidcod = clifor.cidcod no-lock no-error.
                if avail cidade 
                then vcidade = cidade.cidnom.
                else vcidade = clifor.cidade.
                     
                assign 
                    ct-cont             = ct-cont + 1
                    c-nome[ct-cont]     = trim(substring(clifor.clfnom,1,45))
                    c-campo1[ct-cont]   = trim(clifor.endereco) + ", " +  
                                          trim(clifor.numero) + " - " +
                                          trim(clifor.compl) 
                    c-campo2[ct-cont]   = trim(clifor.bairro).
                    c-campo3[ct-cont]   = clifor.cep    + "   " +
                                          Trim(vcidade) + "   " +
                                          clifor.ufecod.

                if ct-cont = 2 
                then do :
                    
                    put control chr(27) + "P" + chr(15) .
                         
                    put c-nome[1]     at i-col1
                        c-nome[2]     at i-col2 
                     /* c-nome[3]     at i-col3 */
                     /* c-nome[4]     at i-col4 */
                        c-campo1[1]   at i-col1
                        c-campo1[2]   at i-col2
                     /* c-campo1[3]   at i-col3 */
                     /* c-campo1[4]   at i-col4 */
                        c-campo2[1]   at i-col1
                        c-campo2[2]   at i-col2
                     /* c-campo2[3]   at i-col3 */
                     /* c-campo2[4]   at i-col4 */               
                        c-campo3[1]   at i-col1
                        c-campo3[2]   at i-col2
                     /* c-campo3[3]   at i-col3 */
                     /* c-campo3[4]   at i-col4 */
                        skip(2).
                
                    assign c-nome     = ""
                           c-campo1 = ""
                           ct-cont    = 0.
                end. 

            end.
   
            if ct-cont < 2
            then do:
                put control chr(27) + "P" + chr(15).
                     
                put c-nome[1]     at i-col1  /* 1. linha e 1. coluna */
                    c-nome[2]     at i-col2  /* 1. linha e 2. coluna */
                 /* c-nome[3]     at i-col3   1. linha e 3. coluna */
                 /* c-nome[4]     at i-col4 */ /* 1. linha 3 4. coluna */
                    c-campo1[1]   at i-col1 
                    c-campo1[2]   at i-col2
                 /* c-campo1[3]   at i-col3 */
                 /* c-campo1[4]   at i-col4 */
                    c-campo2[1]   at i-col1
                    c-campo2[2]   at i-col2
                 /* c-campo2[3]   at i-col3 */
                 /* c-campo2[4]   at i-col4 */
                    c-campo3[1]   at i-col1
                    c-campo3[2]   at i-col2
                 /* c-campo3[3]   at i-col3 */
                 /* c-campo3[4]   at i-col4 */            
                    skip(2).

                assign 
                    c-nome  = ""
                    ct-cont = 0.
                     
            end.
            
            {mdadmrod.i &Saida     = " value(varqsai) "}.

        end.
        leave l1.
        end.
    end.
end.

