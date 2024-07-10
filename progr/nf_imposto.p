{admcab.i}

def var imposto as char.
def var datini as date.
def var datfim as date.
def var varquivo as char.

def var vmodcod like modal.modcod.

def temp-table tt-imposto
    field modcod like modal.modcod
    field forcod like forne.forcod
    field fornom like forne.fornom
    field forcgc like forne.forcgc
    field fatnum like fatudesp.fatnum
    field emissao like fatudesp.emissao
    field pagamento like titudesp.titdtpag
    field valtotal like fatudesp.val-total
    field valimpos like fatudesp.val-total 
    index i1 modcod forcod fatnum emissao
    index i2 modcod emissao
    index i3 modcod pagamento
    .
 
message 
"OPCOES DE IMPOSTO: ICMS, IPI, IRRF, ISS, INSS, PIS, COFINS, CSLL, CSRF," skip
"ACRESCIMO E DESCONTO!" view-as alert-box.

def var tp-data as log format "Emissao/Pagamento" init yes.

/* Formulario */
form imposto label "Imposto"  skip
     datini label "Data inicial"
     datfim label "Data final"    skip
     tp-data label "Tipo Data E/P"
with frame f01 title "Informe os dados abaixo:" with side-label width 80.

/* Atualiza variaveis */
update imposto
       datini
       datfim
       tp-data
with frame f01.

def var s-aluguel as log format "Sim/Nao".
message "Com aluguel?" update s-aluguel.

message "Gerando relatorio...".

for each tt-imposto:
    delete tt-imposto.
end.
    
/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/imposto_nf." + string(time).
 else
 varquivo = "l:\relat\imposto_nf" + string(day(today)).
      
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""nf_imposto""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """NF POR IMPOSTO"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

if tp-data
then do:
/* CSRF */
if imposto matches "*csrf*"
then do:
    for each fatudesp where val-csll > 0 and 
                emissao >= datini and
                emissao <= datfim no-lock.
 
        find forne where forne.forcod = fatudesp.clicod no-lock no-error.
        find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
            and titudesp.modcod = fatudesp.modcod no-lock no-error.
        if not avail titudesp then next.


        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end.    
        else vmodcod = "".
           
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
            .
        end.
        tt-imposto.valtotal = tt-imposto.valtotal + fatudesp.val-total.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-csll. 
    end.
    for each fatudesp where val-pis > 0 
        and emissao >= datini and 
        emissao <= datfim no-lock.
        find forne where forne.forcod = fatudesp.clicod no-lock no-error.
        find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
            and titudesp.modcod = fatudesp.modcod no-lock no-error.
        if not avail titudesp then next.
        
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
        
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
            .
        end.
        tt-imposto.valtotal = tt-imposto.valtotal + fatudesp.val-total.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-pis.

    end.
    for each fatudesp where val-cofins > 0 
        and emissao >= datini and emissao <= datfim no-lock.
        find forne where forne.forcod = fatudesp.clicod no-lock no-error.
        find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
            and titudesp.modcod = fatudesp.modcod no-lock no-error.
        if not avail titudesp then next.
        
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
            .
        end.
        tt-imposto.valtotal = tt-imposto.valtotal + fatudesp.val-total.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-cofins.
    end.
    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total) format ">>,>>>,>>9.99"
             tt-imposto.valimpos(total) format ">>,>>>,>>9.99"
                            column-label "Val-CSRF"
             with frame f-i width 150 down.
        down with frame f-1.     
    end.
end.
/* CSLL  */
if imposto matches "*csll*"
then do:
    for each fatudesp where val-csll > 0 
            and emissao >= datini 
            and  emissao <= datfim no-lock.
        find forne where forne.forcod = fatudesp.clicod no-lock no-error.
        find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
            and titudesp.modcod = fatudesp.modcod no-lock no-error.
        if not avail titudesp then next.
    
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-csll.
    end.    
        /**********
        disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
            format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag 
            fatudesp.val-total
            fatudesp.val-csll with width 100.
        ***/

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-CSLL"
             with width 150.
    end.
        
end.

/* IPI  */
else if imposto matches "*ipi*"
then do:
    for each fatudesp where val-ipi > 0 and 
                emissao >= datini and 
                emissao <= datfim no-lock.                            
        find forne where forne.forcod = fatudesp.clicod no-lock no-error.
            
        find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
            and titudesp.modcod = fatudesp.modcod no-lock no-error.  
        if not avail titudesp then next.     
    /******                                    
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum            
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.val-ipi with width 100.  
         **********/
         
         if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-ipi.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-IPI"
             with width 150.
    end.
end.

/* ICMS  */                                                                   
else if imposto matches "*icms*"                                              
then do:                                                                        
    for each fatudesp where val-icms > 0 and 
    emissao >= datini and emissao <= datfim no-lock.                               find forne where forne.forcod = fatudesp.clicod no-lock no-error.        
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)      
    and titudesp.modcod = fatudesp.modcod no-lock no-error.                  
    if not avail titudesp then next.                          
    /****               
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum            
    format ">>>>>>>>>9" fatudesp.emissao label "Emissao" titudesp.titdtpag fatudesp.val-total
    fatudesp.val-icms with width 100. 
     **********/     
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-icms.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-ICMS"
             with width 150.
    end.
                                   
end.                                                                         

/* IRRF  */
else if imposto matches "*irrf*"
then do:
    for each fatudesp where val-ir > 0 and emissao >= datini 
    and emissao <= datfim no-lock.
    find forne where forne.forcod = fatudesp.clicod no-lock no-error.
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
    and titudesp.modcod = fatudesp.modcod no-lock no-error.
    if not avail titudesp then next.
    /***
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.val-ir with width 100.
    ***/
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-ir.
    end.
    for each tt-imposto where valimpos > 0:
        disp 
             tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-IRRF"
             format ">>>,>>>,>>9.9999"
             with width 150.
    end.

end.

/* ISS  */
else if imposto matches "*iss*"
then do:
    for each fatudesp where val-iss > 0 and emissao >= datini and emissao <= datfim no-lock.
    find forne where forne.forcod = fatudesp.clicod no-lock no-error.
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
    and titudesp.modcod = fatudesp.modcod no-lock no-error.
    if not avail titudesp then next.
    /***
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.val-iss with width 100.
    ***/
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-iss.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-ISS"
             with width 150.
    end.

end.

/* INSS  */
else if imposto matches "*inss*"
then do:
    for each fatudesp where val-inss > 0 and emissao >= datini and emissao <= datfim no-lock.
    find forne where forne.forcod = fatudesp.clicod no-lock no-error.
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
    and titudesp.modcod = fatudesp.modcod no-lock no-error.
    if not avail titudesp then next.
    /*
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.val-inss with width 100.
    **/
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-inss.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-INSS"
             with width 150.
    end.

end.

/* PIS  */
else if imposto matches "*pis*"
then do:
    for each fatudesp where val-pis > 0 and emissao >= datini and emissao <= datfim no-lock.
    find forne where forne.forcod = fatudesp.clicod no-lock no-error.
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
    and titudesp.modcod = fatudesp.modcod no-lock no-error.
    if not avail titudesp then next.
    /**
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.val-pis with width 100.
    **/
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end.    
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-pis.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-PIS"
             with width 150.
    end.

end.

/* COFINS  */
else if imposto matches "*cofins*"
then do:
    for each fatudesp where val-cofins > 0 and emissao >= datini and emissao <= datfim no-lock.
    find forne where forne.forcod = fatudesp.clicod no-lock no-error.
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
    and titudesp.modcod = fatudesp.modcod no-lock no-error.
    if not avail titudesp then next.
    /*
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.val-cofins with width 100.
    */
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-cofins.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-COFINS"
             with width 150.
    end.

end.

/* ACRESCIMO  */
else if imposto matches "*acrescimo*"
then do:
    for each fatudesp where acrescimo > 0 and emissao >= datini and emissao <= datfim no-lock.
    find forne where forne.forcod = fatudesp.clicod no-lock no-error.
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
    and titudesp.modcod = fatudesp.modcod no-lock no-error.
    if not avail titudesp then next.
    /*
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.acrescimo with width 100.
    */
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.acrescimo.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Acrescimo"
             with width 150.
    end.

end.

/* DESCONTO  */
else if imposto matches "*desconto*"
then do:
    for each fatudesp where desconto > 0 and emissao >= datini and emissao <= datfim no-lock.
    find forne where forne.forcod = fatudesp.clicod no-lock no-error.
    find first titudesp where titudesp.titnum = string(fatudesp.fatnum)
    and titudesp.modcod = fatudesp.modcod no-lock no-error.
    if not avail titudesp then next.
    /*
    disp forne.fornom format "x(15)" forne.forcgc fatudesp.fatnum
    format ">>>>>>>>>9" fatudesp.emissao titudesp.titdtpag fatudesp.val-total
    fatudesp.desconto with width 100.
    */
        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end. 
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.desconto.
    end.    

    for each tt-imposto:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Desconto"
             with width 150.
    end.

end.
end.
else do:
    for each titudesp where
         titudesp.titdtpag >= datini and
         titudesp.titdtpag <= datfim
         no-lock:
        find first fatudesp where
               fatudesp.clicod = titudesp.clifor and
               fatudesp.fatnum = int(titudesp.titnum) and
               fatudesp.emissao = titudesp.titdtemi  and
               fatudesp.modcod = titudesp.modcod
               no-lock no-error.
        if not avail fatudesp
        then next.    
               
        if fatudesp.desconto = 0 and
           fatudesp.acrescimo = 0 and
           fatudesp.val-cofins = 0 and
           fatudesp.val-pis = 0 and
           fatudesp.val-inss = 0 and
           fatudesp.val-iss = 0 and
           fatudesp.val-ir = 0 and
           fatudesp.val-icms = 0 and
           fatudesp.val-ipi = 0 and
           fatudesp.val-csll = 0
        then next.
               
        find forne where forne.forcod = fatudesp.clicod no-lock no-error. 

        if fatudesp.modctb = "ALF" or
           fatudesp.modctb = "ALJ"
        then do:
            if s-aluguel
            then  vmodcod = "ALUGUEL".
            else next.
        end.    
        else vmodcod = "".
 
        find first tt-imposto where
                   tt-imposto.modcod = vmodcod and
                   tt-imposto.forcod = forne.forcod and
                   tt-imposto.fatnum = fatudesp.fatnum and
                   tt-imposto.emissao = fatudesp.emissao
                   no-error.
        if not avail tt-imposto
        then do:            
            create tt-imposto.
            assign
                tt-imposto.modcod = vmodcod
                tt-imposto.forcod = forne.forcod
                tt-imposto.fornom = forne.fornom
                tt-imposto.forcgc = forne.forcgc
                tt-imposto.fatnum = fatudesp.fatnum
                tt-imposto.emissao = fatudesp.emissao
                tt-imposto.pagamento = titudesp.titdtpag
                tt-imposto.valtotal = fatudesp.val-total
            .
        end.
        if imposto = "ICMS"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-icms.
        else if imposto = "IPI"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-ipi.
        else if imposto = "IRRF"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-ir.
        else if imposto = "ISS"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-iss.
        else if imposto = "INSS"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-inss.
        else if imposto = "PIS"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-pis.
        else if imposto = "COFINS"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-cofins.
        else if imposto = "CSLL"
        then tt-imposto.valimpos = tt-imposto.valimpos + fatudesp.val-csll.
        else if imposto = "CSRF"
        then do:
            tt-imposto.valimpos = tt-imposto.valimpos + 
                (fatudesp.val-pis + fatudesp.val-cofins + fatudesp.val-csll).
        end.    
        else if imposto = "acrescimo"
        then tt-imposto.valimpos = tt-imposto.valimpos + 
                                    fatudesp.acrescimo.
        else if imposto = "desconto"
        then tt-imposto.valimpos = tt-imposto.valimpos + 
                                    fatudesp.desconto.
    end.
    for each tt-imposto where valimpos > 0:
        disp tt-imposto.fornom format "x(15)" 
             tt-imposto.forcgc 
             tt-imposto.fatnum format ">>>>>>>>>9" 
             tt-imposto.emissao 
             tt-imposto.pagamento 
             tt-imposto.valtotal(total)
             tt-imposto.valimpos(total) column-label "Val-Imposto"
             with width 150.
    end.
end.

output close.
   if opsys = "UNIX"
   then do:
   run visurel.p (input varquivo, input "NF PO IMPOSTO").
   end.
   else do:
   {mrod.i}
   end.
/* Finaliza o gerenciador de Impressao */
