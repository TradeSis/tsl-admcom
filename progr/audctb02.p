{admcab.i}
def new shared temp-table tt-resumo
    field clifor like titulo.clifor
    field compra as dec
    field pagamento as dec
    field desconto as dec
    field juro as dec
    field debito as dec
    field credito as dec
    index i1 clifor.
    .

def new shared temp-table tt-forne like forne.


form vdti as date format "99/99/9999" label "Periodo de"
     vdtf as date format "99/99/9999" label "Ate"
     with frame f-data 1 down centered side-label
     .

update vdti vdtf with frame f-data.
if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
        "Periodo invalido"
        view-as alert-box.
    undo.
end.

def temp-table tt
    field linha as int
    field campo1 as char
    field campo2 as char
    field campo3 as char
    field campo4 as char.

def temp-table tt-for
    field  forcod as int
    field  fornom as char
    field  debito as dec
    field  credito as dec.

def var vok as log init yes.
run imp-val-for.
if vok = no then return.
for each tt-for:
    find first tt-resumo where tt-resumo.clifor = tt-for.forcod 
                no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.clifor = tt-for.forcod.
    end. 
    tt-resumo.debito = tt-for.debito.
    tt-resumo.credito = tt-for.credito.
end.
    
def var vcod as char format "x(18)".
def var varq as char.
def var varq1 as char.
def var sresp as log format "Sim/Nao".

def var vdata as date.
def stream stela.

def temp-table tt-fiscal like fiscal
    field numtit like titulo.titnum
    index i1 desti numero.
def temp-table tt-titulo like titulo
    index i1 clifor titnum titpar.


form with frame f-stream.

output stream stela to terminal.

/*** Exportando Contas a Pagar ****/

form with frame f-stream 1 down centered no-box row 7 no-label.

for each estab no-lock,
    each fiscal where fiscal.movtdc = 4       and
                          fiscal.desti  = estab.etbcod and
                          fiscal.plarec >= vdti   and
                          fiscal.plarec <= vdtf
                          no-lock.
        

    if fiscal.emite = 5027
    then next.
    if fiscal.opfcod <> 1102 and
       fiscal.opfcod <> 2102
    then next.
    if fiscal.emite = 533 or
       fiscal.emite = 100071
    then next.
        
    find forne where forne.forcod = fiscal.emite no-lock no-error.

    disp  "Contas A Pagar   (C)..." at 1
            forne.forcod fiscal.numero with frame f-stream
            row 10 1 down no-box centered no-label.
    pause 0.

    find first tt-resumo where tt-resumo.clifor = forne.forcod 
                no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.clifor = forne.forcod.
    end. 
    if tt-resumo.credito > 0
    then do:
    
    tt-resumo.compra = tt-resumo.compra + fiscal.platot.
    create tt-fiscal.
    buffer-copy fiscal to tt-fiscal.
    find first tt-forne where tt-forne.forcod = forne.forcod
                no-error.
    if not avail tt-forne
    then do:
        create tt-forne.
        buffer-copy forne to tt-forne.
    end.
    end.
end.

for each estab no-lock,
    each plani where plani.movtdc = 13       and
                          plani.emite  = estab.etbcod  and
                          plani.pladat >= vdti   and
                          plani.pladat <= vdtf
                          no-lock.
        
    find forne where forne.forcod = plani.desti no-lock no-error.

    disp  "Contas A Pagar   (D)..." at 1
            forne.forcod plani.numero with frame f-stream0
            row 11 1 down no-box centered no-label.
    pause 0.

    find first tt-resumo where tt-resumo.clifor = forne.forcod 
                no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.clifor = forne.forcod.
    end. 
    if tt-resumo.debito > 0
    then do:
        find first tt-fiscal where 
                   tt-fiscal.emite = plani.emite and
                   tt-fiscal.numero = plani.numero no-error.
        if not avail tt-fiscal
        then do:            
        tt-resumo.pagamento = tt-resumo.pagamento + plani.platot.
        create tt-fiscal.
        assign
                    tt-fiscal.movtdc = 13
                    tt-fiscal.emite  = plani.emite
                    tt-fiscal.desti  = plani.desti
                    tt-fiscal.numero = plani.numero
                    tt-fiscal.platot = plani.platot
                    tt-fiscal.plarec = plani.pladat
                    .
         end.           
         find first tt-forne where tt-forne.forcod = forne.forcod
                no-error.
        if not avail tt-forne
        then do:
            create tt-forne.
            buffer-copy forne to tt-forne.
        end.
    end.
end.


for each titulo where titulo.empcod    = 19 and
                      titulo.titnat    = yes and 
                      titulo.titdtpag >= vdti and
                      titulo.titdtpag <= vdtf and
                      titulo.titsit = "PAG" 
                      no-lock:
    find forne where forne.forcod = titulo.clifor no-lock no-error.
    if not avail forne then next.
    
    disp  "Contas A Pagar   (P)..." at 1
            forne.forcod titulo.titnum format "x(8)" with frame f-stream1
            row 12 1 down no-box centered no-label.
    pause 0.


    find first tt-resumo where tt-resumo.clifor = titulo.clifor 
                no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.clifor = titulo.clifor.
    end.
    if tt-resumo.debito > 0
    then do:
        
    tt-resumo.pagamento = tt-resumo.pagamento + titulo.titvlcob.
                
    create tt-titulo.
    buffer-copy titulo to tt-titulo.
    
    if titulo.titvldes > 0   /*** desconto ***/
    then do:
        tt-resumo.desconto = tt-resumo.desconto + titulo.titvldes.

    end.
    if titulo.titvljur > 0   /*** juro ***/
    then do:
        tt-resumo.juro = tt-resumo.juro + titulo.titvljur.
    end.

    find first tt-forne where tt-forne.forcod = titulo.clifor
                no-error.
    if not avail tt-forne
    then do:
        create tt-forne.
        buffer-copy forne to tt-forne.
    end.
    end.
end.

/***** divergencias ******/

def var vdif as dec.
for each tt-resumo:
    find first forne where forne.forcod = tt-resumo.clifor no-lock.
    
    if tt-resumo.debito = 0 and
       tt-resumo.credito = 0
    then next.   
    if tt-resumo.compra = 0 and
            tt-resumo.pagamento = 0 and
            tt-resumo.desconto = 0 and
            tt-resumo.juro = 0 and
            tt-resumo.debito = 0 and
            tt-resumo.credito = 0
    then next.
    if tt-resumo.compra = tt-resumo.credito and
            tt-resumo.pagamento = tt-resumo.debito /*and
            tt-resumo.desconto = 0 and
            tt-resumo.juro = 0 */                      
    then next.   

    vdif = tt-resumo.pagamento - tt-resumo.debito.
    if vdif = tt-resumo.desconto then next.

    if tt-resumo.pagamento <> tt-resumo.debito
    then do:
        for each tt-titulo where tt-titulo.clifor = tt-resumo.clifor :
                 delete tt-titulo.
        end.
        tt-resumo.pagamento = 0.
        for each lancxa where 
                 lancxa.datlan >= vdti and
                 lancxa.datlan <= vdtf and
                 lancxa.forcod = tt-resumo.clifor
                 no-lock.
            find titulo where titulo.empcod = 19 and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.clifor = tt-resumo.clifor and
                              titulo.titnum = lancxa.titnum and
                              titulo.titvlpag = lancxa.vallan and
                              titulo.titdtpag = lancxa.datlan
                              no-lock no-error.
           if avail titulo
           then do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                tt-resumo.pagamento = tt-resumo.pagamento + titulo.titvlpag.
           end.
            /**
           else do:
              if lancxa.titnum <> ""
              then do:
                create tt-titulo.
                assign
                    tt-titulo.clifor = lancxa.forcod
                    tt-titulo.titnum = lancxa.titnum
                    tt-titulo.etbcod = lancxa.etbcod 
                    tt-titulo.titvlcob = lancxa.vallan
                    tt-titulo.titvlpag = lancxa.vallan
                    tt-titulo.titdtven = lancxa.datlan
                    .
                tt-resumo.pagamento = tt-resumo.pagamento + tt-titulo.titvlpag.

              end.
           end.
           **/                  
        end. 
        if tt-resumo.pagamento > tt-resumo.debito
        then 
        for each lancxa where 
                 lancxa.datlan >= vdti and
                 lancxa.datlan <= vdtf and
                 lancxa.forcod = tt-resumo.clifor
                 no-lock.
            if lancxa.vallan = tt-resumo.debito
            then do:
                for each tt-titulo where
                         tt-titulo.clifor = tt-resumo.clifor :
                    if tt-titulo.titvlpag <> lancxa.vallan
                    then delete tt-titulo.
                end.             
            end.
        end.
    end.
    if tt-resumo.compra <> tt-resumo.credito
    then do:
        for each tt-fiscal where tt-fiscal.emite = tt-resumo.clifor :
                 delete tt-fiscal.
        end. 
        tt-resumo.compra = 0.
        for each lancxa where 
                 lancxa.datlan >= vdti and
                 lancxa.datlan <= vdtf and
                 lancxa.forcod = tt-resumo.clifor
                 no-lock.
            find titulo where titulo.empcod = 19 and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.clifor = tt-resumo.clifor and
                              titulo.titnum = lancxa.titnum and
                              titulo.titvlcob = lancxa.vallan and
                              titulo.titdtemi = lancxa.datlan
                              no-lock no-error.
           if avail titulo
           then do:
                create tt-fiscal.
                assign
                    tt-fiscal.movtdc = 4
                    tt-fiscal.emite = titulo.etbcod
                    tt-fiscal.desti = titulo.clifor
                    tt-fiscal.numtit = titulo.titnum
                    tt-fiscal.platot = titulo.titvlcob
                    tt-fiscal.plarec = titulo.titdtemi
                    .
                tt-resumo.compra = tt-resumo.compra + titulo.titvlcob.
           end.    
           else do:
                create tt-fiscal.
                assign
                    tt-fiscal.movtdc = 4
                    tt-fiscal.emite  = lancxa.forcod
                    tt-fiscal.desti  = lancxa.etbcod
                    tt-fiscal.numtit = lancxa.titnum
                    tt-fiscal.platot = lancxa.vallan
                    tt-fiscal.plarec = lancxa.datlan
                    .
                tt-resumo.compra = tt-resumo.compra + lancxa.vallan.
           end.               
        end. 
        /**
        if tt-resumo.pagamento > tt-resumo.debito
        then 
        for each lancxa where 
                 lancxa.datlan >= vdti and
                 lancxa.datlan <= vdtf and
                 lancxa.forcod = tt-resumo.clifor
                 no-lock.
            if lancxa.vallan = tt-resumo.debito
            then do:
                for each tt-titulo where
                         tt-titulo.clifor = tt-resumo.clifor :
                    if tt-titulo.titvlpag <> lancxa.vallan
                    then delete tt-titulo.
                end.             
            end.
        end.
            **/
    end.
end. 
/*****************************/

disp  "Gerando Arquivos    ..." at 1
             with frame f-stream2
            row 13 1 down no-box centered no-label.
    pause 0.


/*** Exportando dados    ****/

def var vcliente as char.

if opsys = "unix" 
then varq = "../audit/cap_liv_" + 
                string(day(vdti),"99") + string(month(vdti),"99") +
                string(year(vdti),"9999") + "_" +
                string(day(vdtf),"99") + string(month(vdtf),"99") +
                string(year(vdtf),"9999") + ".txt".
else varq = "..\audit\cap_liv_" + 
                string(day(vdti),"99") + string(month(vdti),"99") +
                string(year(vdti),"9999") + "_" +
                string(day(vdtf),"99") + string(month(vdtf),"99") +
                string(year(vdtf),"9999") + ".txt".

output to value(varq).

find sispro where sispro.codred = 91 no-lock.

for each tt-fiscal where tt-fiscal.platot > 0 /* and
                         tt-fiscal.numero > 0*/ no-lock,
    first forne where forne.forcod = tt-fiscal.emite no-lock:    
    find first frete where frete.forcod = forne.forcod no-lock no-error.
    if avail frete
    then vcliente = "T" + string(forne.forcod,"9999999").
    else vcliente = "F" + string(forne.forcod,"9999999").
         
    put unformatted
            tt-fiscal.desti format ">>9"
            vcliente "          "
            "NF "
            string(tt-fiscal.numero) format "x(12)"
            year(tt-fiscal.plarec) format "9999"
            month(tt-fiscal.plarec) format "99"
            day(tt-fiscal.plarec) format "99"
            "C  "         format "!!!"
            tt-fiscal.platot * 100 format "9999999999999999"
            "+"
            year(tt-fiscal.plarec) format "9999"
            month(tt-fiscal.plarec) format "99"
            day(tt-fiscal.plarec) format "99"
            tt-fiscal.platot * 100 format "9999999999999999"
            year(tt-fiscal.plarec) format "9999"
            month(tt-fiscal.plarec) format "99"
            day(tt-fiscal.plarec) format "99"
            string(tt-fiscal.numero) format "x(12)"
            sispro.codest format "x(28)"
            "CADASTRAMENTO" format "x(150)"
            skip
            .
end.

find sispro where sispro.codred = 91 no-lock.

for each tt-titulo where tt-titulo.titvlpag > 0 /*and
                         titulo.titnum <> " "*/ no-lock,
    first forne where forne.forcod = tt-titulo.clifor no-lock:
    vcliente  = "F" + string(forne.forcod,"9999999").

    find first frete where frete.forcod = forne.forcod no-lock no-error.
    if avail frete
    then vcliente = "T" + string(forne.forcod,"9999999").
    else vcliente = "F" + string(forne.forcod,"9999999").

        put unformatted
            tt-titulo.etbcod format ">>9"
            vcliente "          "
            "DUP"
            tt-titulo.titnum format "x(12)"
            year(tt-titulo.titdtpag) format "9999"   
            month(tt-titulo.titdtpag) format "99"
            day(tt-titulo.titdtpag) format "99"
            "R  "         format "!!!"
            tt-titulo.titvlpag * 100 format "9999999999999999"
            "-"
            year(tt-titulo.titdtpag) format "9999"
            month(tt-titulo.titdtpag) format "99"
            day(tt-titulo.titdtpag) format "99"
            tt-titulo.titvlpag * 100 format "9999999999999999"
            year(tt-titulo.titdtpag) format "9999"
            month(tt-titulo.titdtpag) format "99"
            day(tt-titulo.titdtpag) format "99"
            tt-titulo.titnum + "/" + string(tt-titulo.titpar) format "x(12)"
            sispro.codest format "x(28)"
            "PAGAMENTOS" format "x(150)"
            skip
            .
end.

output close.

/*** Exportando clientes ****/

if opsys = "unix" 
then varq1 = "../audit/for_liv_" + 
                string(day(vdti),"99") + string(month(vdti),"99") +
                string(year(vdti),"9999") + "_" +
                string(day(vdtf),"99") + string(month(vdtf),"99") +
                string(year(vdtf),"9999") + ".txt".
else varq1 = "..\audit\for_liv_" + 
                string(day(vdti),"99") + string(month(vdti),"99") +
                string(year(vdti),"9999") + "_" +
                string(day(vdtf),"99") + string(month(vdtf),"99") +
                string(year(vdtf),"9999") + ".txt".

output to value(varq1).

for each tt-forne,
    first forne where forne.forcod = tt-forne.forcod no-lock:
    /*
    if forne.forcgc = ""
    then next.
    */
    disp  stream stela "Cadastro P. Juridica..." at 1
            forne.forcod  with frame f-stream3
            row 14 1 down no-box centered no-label.
    pause 0.


    find first frete where frete.forcod = forne.forcod no-lock no-error.
    if avail frete
    then vcod = "T" + string(forne.forcod,"9999999") + "          ". 
    else vcod = "F" + string(forne.forcod,"9999999") + "          ". 

    put unformatted
        vcod                 format "x(18)"        /* 001-018 */
        forne.forcgc         format "x(18)"        /* 019-036 */
        forne.forinest       format "x(20)"        /* 037-056 */
        " "                  format "x(14)"        /* 057-070 */
        forne.fornom         format "x(70)"        /* 071-140 */
        forne.forfant        format "x(70)"        /* 141-210 */
        forne.forrua         format "x(50)"        /* 211-280 */
        string(forne.fornum) format "x(10)"       
        forne.forcomp        format "x(10)"       
        forne.forbairro      format "x(20)"        /* 281-300 */
        forne.formunic       format "x(50)"        /* 301-350 */
        forne.ufecod         format "x(02)"        /* 351-352 */
        forne.forcep         format "x(08)"        /* 353-360 */
        forne.forpais        format "x(20)"        /* 361-380 */
        " "                  format "x(12)"        /* 381-392 */
        " "                  format "x(05)"        /* 393-397 */
        " "                  format "x(10)"        /* 398-407 */
        " "                  format "x(10)"        /* 408-417 */
        " "                  format "x(02)"        /* 418-419 */
        skip.
             
             
end.

output close.

output stream stela close.              

message color red/with
    skip
    "Arquivos gerados  " varq skip
    "                  " varq1 skip
    view-as alert-box.
 

def var varquivo as char.
sresp = yes.

message "Emitir resumo dos dados exportados? "
 update sresp.
if sresp
then do:
    if opsys = "UNIX"
    then varquivo = "/admcom/audit/resu-pagar." + string(time).
    else varquivo = "l:~\audit~\resu-pagar." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "0"
        &Nom-Rel   = ""audctb01""
        &Nom-Sis   = """SISTEMA CONTABIL"""
        &Tit-Rel   = """RESUMO EXPORTACAO C. PAGAR PARA AUDTI"""
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    for each tt-resumo:
        find first forne where forne.forcod = tt-resumo.clifor no-lock.
         if tt-resumo.debito = 0 and
            tt-resumo.credito = 0
         then next.   
         if tt-resumo.compra = 0 and
            tt-resumo.pagamento = 0 and
            tt-resumo.desconto = 0 and
            tt-resumo.juro = 0 and
            tt-resumo.debito = 0 and
            tt-resumo.credito = 0
         then next.
         if tt-resumo.compra = tt-resumo.credito and
            tt-resumo.pagamento = tt-resumo.debito /*and
            tt-resumo.desconto = 0 and
            tt-resumo.juro = 0 */                      
         then next.   

         vdif = tt-resumo.pagamento - tt-resumo.debito.
         if vdif = tt-resumo.desconto then next.

         disp tt-resumo.clifor  column-label "Fornecedor"
             forne.fornom no-label format "x(15)"
             tt-resumo.compra(total) 
             column-label "Val.Comp" format ">>>>>>>>9.99"
             tt-resumo.pagamento(total)
             column-label "Val.Pago"    format ">>>>>>>>9.99"
             tt-resumo.desconto(total)
             column-label "Desconto"  format ">>>>>>9.99"
             tt-resumo.juro(total)
             column-label "Juro"      format ">>>>>>9.99"
             tt-resumo.debito(total)
             column-label "Debito"    format ">>>>>>>>9.99"
             tt-resumo.credito  (total)
             column-label "Credito"   format ">>>>>>>>9.99"
             /*vdif format "->>>>>>9.99"*/
            with frame f-resumo down width 120.
        down with frame f-resumo.
        put fill("-",100) format "x(100)".
        for each tt-titulo where tt-titulo.clifor = tt-resumo.clifor no-lock:
                put "      PAGAMENTO  " tt-titulo.titnum "  "
                tt-titulo.titdtemi "  " tt-titulo.titdtven "  "
                tt-titulo.titvlcob "  " tt-titulo.titvlpag skip.
        end.
        for each tt-fiscal where tt-fiscal.emite = tt-resumo.clifor no-lock.
                put "         COMPRA  "numtit "  " tt-fiscal.numero "  " 
                tt-fiscal.plarec  "  "
                tt-fiscal.platot skip. 
        end.
        put fill("=",100) format "x(100)".
    end.        
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end. 
end.

return.

procedure imp-val-for:
    
    def var v as int.
    def var vl as int.
    def var varq as char.
    if opsys = "UNIX"
    then varq = "/admcom/audit/for" + string(month(vdtf),"99") 
                 + string(year(vdtf),"9999") + ".dif".
    else varq = "l:\audit\for" + string(month(vdtf),"99") 
                 + string(year(vdtf),"9999") + ".dif".
    
    if search(varq) = ?
    then do:
        bell.
        message color red/with
        "Arquivo " varq " nao encontrado"
        view-as alert-box.
        vok = no.
        return.
    end.       
      
    input from value(varq).
    repeat:
        create tt .
        import campo1 campo2 campo3 .
        v = v + 1.
        linha = v.
    end.                 
    input close.

    def var vforcod as int.
    def var vfornom as char.
    def var vdebito as dec.
    def var vcredito as dec.
    for each tt.
    
        if linha > 31 and linha < 56
        then do:
            /*if linha = 32 
            then disp campo1.
            if linha = 35 or linha = 37
            then disp campo2.*/
        end. 
        else if linha >= 56
        then do:
            if campo1 = "BOT"
            then do:
                if vfornom <> ""
                then do:
                    create tt-for.
                    assign
                        tt-for.forcod = vforcod
                        tt-for.fornom = vfornom
                        tt-for.debito = vdebito
                        tt-for.credito = vcredito
                        vforcod = 0
                        vfornom = ""
                        vdebito = 0
                        vcredito = 0.
                
                end.
                v = 1.
                vl = linha + 1.
            end.
            if linha = vl
            then do:
                if v = 1
                then do:
                    vforcod = int(substr(campo1,3,9)).
                    v = v + 3.
                    vl = vl + 3.
                end.
                else if v = 4
                then do:
                    if campo1 = "" then leave.
                    vfornom = campo1.
                    v = v + 3.
                    vl = vl + 3.
                end.
                else if v = 7
                then do:
                    if campo2 <> "-"
                    then vdebito = dec(campo2).
                    v = v + 2.
                    vl = vl + 2.
                end.
                else  if v = 9
                then do:
                    if campo2 <> "-"
                    then vcredito = dec(campo2).
                    v = 0.
                    vl = 0.
                end.
            end.
        end.
    end.
end procedure.
