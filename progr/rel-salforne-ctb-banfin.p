{admcab.i new}

def var varquivo    as char.
def var varquivo2   as char.
def var vdt-aux     as date.
def var v-ano       as integer.
def var vsp         as char initial ";".
def var vforcod     like forne.forcod.
def shared var vdatref as date.
def var vanalitico as log format "Sim/Nao".
def var voq as char format "x(15)" extent 3
    init["DUPLICATAS","DESPESAS","GERAL"].
    
def shared temp-table tt-forne
    field forcod as integer
    field fornom as char
    field saldo as decimal
    index idx01 forcod.

def shared temp-table tt-ana
    field forcod like forne.forcod
    field fornom like forne.fornom
    field forcgc like forne.forcgc
    field titnum like fin.titulo.titnum
    field titpar like fin.titulo.titpar
    field modcod like fin.titulo.modcod
    field titdtemi like fin.titulo.titdtemi
    field titdtent like plani.dtinclu
    field titdtven like fin.titulo.titdtven
    field titdtpag like fin.titulo.titdtpag
    field titvlcob like fin.titulo.titvlcob
    field titvlpag like fin.titulo.titvlpag
    field titvldes like fin.titulo.titvldes
    field titsit   like fin.titulo.titsit
    field etbcod   like fin.titulo.etbcod
    index i1 forcod.

form
        with frame f01 side-labels .

def var vcsv as log format "Sim/Nao".

assign v-ano = year(today).

vdatref = date(month(today),01,year(today)) - 1.

vforcod = 0.    
/*
update  vforcod at 1 label "Fornecedor"
        help "Informe 0 para todos os fornecedores."
        with frame f01 width 80.

if vforcod > 0
then do:        
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne then undo.
    disp forne.fornom no-label with frame f01.
end.
else disp "Todos os fornecedores" @ forne.fornom with frame f01.
*/
vanalitico = yes.
vcsv = yes.
/***
update vdatref at 1 format "99/99/9999" label "Data referencia"
       help "Informe a data de referencia para saldo." 
       /*vanalitico at 1 label "Relatorio Analitico"
       vcsv at 1 label "Gerar Excel" */
       with frame f01 width 80.
        
vdt-aux = vdatref.        

def var vindex as int.
disp voq with frame f-oq centered no-label side-label.
choose field voq with frame f-oq.
vindex = frame-index.
***/

def var vtp as char
.
if vanalitico
then vtp = "a_".
else vtp = "s_".

def var vnomearq as char.
vnomearq = "relsalfornectb" 
                    + "_"
                    + string(vdatref,"99999999")
                    + "___"
                    + string(time)
                    + ".csv".

varquivo = "/admcom/relat/" + vnomearq.

varquivo2 = "/admcom/relat/relsalfornectb"
                    + "_"
                    + string(vdatref,"99999999")
                    + "_"
                    + string(time)
                    + ".txt".


def var vqtd as int.
vqtd = 0.
def var vdtinclu like plani.dtinclu.

def var vi as int.
for each banfin.titulo where      
                           titulo.empcod = 19 and
                          titulo.titnat = yes    and
                          titulo.modcod <> "DUP" and
                          (titulo.titdtpag >  vdt-aux or
                           titulo.titdtpag = ?)   
                              no-lock .
        

        if titulo.titsit = "EXC"                              
        then next.
        
        if titulo.clifor = 0 then next.

        if titulo.clifor =  110165     /* Descarta Cartao Presente */
            or titulo.modcod = "bon"   /* Descarta Bonus           */
        then next.

        disp "Processando DESPESAS...  " titulo.clifor titulo.titnum
            with frame frame-f 1 down no-label row 10 centered color message
            no-box.
        pause 0.   
        
        run p-carrega-tt.

end.

procedure p-carrega-tt.

    find first tt-forne where tt-forne.forcod = banfin.titulo.clifor
                            exclusive-lock no-error.
                            
    find first forne where forne.forcod = titulo.clifor no-lock no-error.

    if not avail tt-forne
    then do:
        
        create tt-forne.
        assign tt-forne.forcod = titulo.clifor
               tt-forne.fornom = if avail forne then forne.fornom
                                    else "Desconhecido"
                                    
                                    .
        
    end.                        
    
    assign tt-forne.saldo = tt-forne.saldo + titulo.titvlcob.
    
    create tt-ana.
    assign
            tt-ana.forcod = titulo.clifor
            tt-ana.fornom = if avail forne then forne.fornom
                        else "Nao Cadastrado"
            tt-ana.forcgc = forne.forcgc
            tt-ana.titnum = titulo.titnum
            tt-ana.titpar = titulo.titpar
            tt-ana.modcod = titulo.modcod
            tt-ana.titdtemi = titulo.titdtemi
            tt-ana.titdtent = if avail plani 
                              then plani.dtinclu
                              else titulo.titdtemi
            tt-ana.titdtven = titulo.titdtven
            tt-ana.titdtpag = titulo.titdtpag
            tt-ana.titvlcob = titulo.titvlcob
            tt-ana.titvlpag = titulo.titvlpag
            tt-ana.titvldes = titulo.titvldes
            tt-ana.titsit   = titulo.titsit
            tt-ana.etbcod   = titulo.etbcod
            .

end procedure.

