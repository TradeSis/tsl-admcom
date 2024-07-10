/*  consnota.p  */
{admcab.i}

def buffer dev-plani for plani.
def input parameter par-rec as recid.
def var esqpos1 as int.
def var par-ok as log.
def var vps-valor as char.
def var recatu1 as recid.

def var esqcom1         as char format "x(15)" extent 5
            initial [" 1.Produtos ",
                     " 2.Etiquetas " , 
                     " 3.Espelho ", ""
                      ].

def var esqcom2         as char format "x(14)" extent 5
            initial ["  ",
                     "  ",
                     "  ",
                     "  ",
                     "  " ].


def buffer cancelador for func.
def buffer bplani for plani.
def var vhora as char.
def var vheader  as char.
def var vpctdescserv    as dec format ">>9.99%" label "Desc.Serv".
def var vpctdescprod    as dec format ">>9.99%" label "Desc.Prod".
def var vtotseguro      as dec.
def var vtotgarantia    as dec.
def var vlibcred as int.
def var vobs1           as char.

find plani where recid(plani) = par-rec no-lock.

def var vplanihora       as   char format "x(5)".

form
    esqcom1
    with frame f-com2
                 row screen-lines no-labels side-labels column 1
                 centered no-box.
view frame f-com2.


form header  vheader format "x(80)"
        with frame f-plani1 with no-underline.

form
        clien.ciccgc        /*colon 11*/    label "Cliente"
        clien.clicod        label "Cod."
        clien.clinom        no-label format "x(30)"
        plani.serie          colon 11       label "Serie"
        plani.numero                        label "No."
        plani.pladat         format "99/99/99"
        plani.dtinclu        format "99/99/99"   label "Inc"
        vplanihora           no-label
        plani.etbcod              colon 11 label "Estab"
        estab.etbnom no-label
        plani.indemi         no-label
        plani.notsit         no-label
        plani.ufemi label "UfEmi"
        plani.ufdes label "UfDes"
        plani.opccod     label "Op.Com." format ">>>9"
        tipmov.movtnom     no-label format "x(25)"
        func.funcod         colon 11       label "Vendedor"
        func.funape                      no-label
        plani.movtdc label "TipMov" format ">>9"
        plani.crecod label "Plano"  format ">>9"
        plani.NotPed label "Gaiola" format "x(25)"
        skip
        with frame f-plani1 width 81  side-label
                                row 3 centered overlay no-box.


form    skip(1)
        plani.biss           colon 11  label "Valor IRF"
        plani.bipi           label "Al.IRF" format ">>9.99%" colon 33       
        plani.aliss          label "Al.ISS" to 57
        plani.iss                           colon 63                              
        plani.vlserv         label "Servicos" colon 11
        plani.descserv       label "Desc.Serv"      colon 37
        vpctdescserv                               colon 63
        /*
        plani.acfserv        label "Acre.Serv"     colon 63
        */
        plani.bicms                              colon 11
        plani.icms                                  colon 37                         
        plani.bsubst             label "B.Subst"   colon 11
        plani.icmssubst                             colon 37
        plani.ipi                                 colon 63
        plani.protot             label "Produtos"  colon 11                          
        plani.descpro            label "Desc.Prod"  colon 37
        /*vpctdescprod                                colon 63*/
        
        plani.acfprod            label "Acre.Prod"  colon 63
        
        plani.frete                                colon 11
        plani.seguro                               colon 37                                                                         
        plani.desacess           label "Desp.Aces."     colon 63
              plani.platot                               colon 63
        with frame f-plani2 width 81  side-label
                        row 9 centered no-box
                        overlay.
                        
form
    cancelador.funape colon 15 label "Cancelado Por"
    vhora no-label
    with frame fhicam row 20 overlay color 
                message side-label centered no-box width 81.
form
     plani.notobs[1] label "Obs." colon 11
     plani.notobs[2] no-label colon 11
     skip(3)
     with frame fobs side-label row 17 overlay color input
                                        centered no-box width 81.
form
     bplani.numero label "**Cupom Fiscal Vinculado "
     with frame fextra row 8 column 47
                  color input side-label no-box
                                     overlay.
form
     bplani.numero label "**Nota Fiscal Vinculada"
     with frame fextra2 row 8 column 48 no-box
                                     color input side-label
                                     overlay.

form
     dev-plani.numero label "**Nota Fiscal Origem"
     with frame fextraorigem row 7 column 48 no-box
                                     color input side-label
                                     overlay.


form
     dev-plani.numero label "**Nota Fiscal Devolucao"
     with frame fextradevol row 7 column 48 no-box
                                     color input side-label
                                     overlay.




form
    vobs1 no-label format "x(25)"
    plani.seguro   label "Seguro"   to 63      format ">>>9.99"
    plani.isenta   label "Garantia" to 80      format ">>>9.99"
    with frame fgarantia row 9 col 1 no-box side-label
            width 80
                                     color input 
                                     overlay.


find clien where 
                 clien.clicod  = plani.desti no-lock no-error.
find forne where 
                 forne.forcod  = plani.emite no-lock no-error.
                 
    find tipmov of plani no-lock no-error.
if avail tipmov then
assign
    vheader = 
              tipmov.movtnom + "  " +  "NOTA FISCAL " .

vheader =  
    fill(" ",integer(string(truncate(((80 - length(vheader)) / 2),0),"999"))) +     vheader.

do:
        
    find estab where 
                  estab.etbcod  = plani.etbcod no-lock no-error .
    find func where 
                    func.funcod = plani.vencod no-lock no-error.
    if not avail func
    then do:
        find func where func.funcod = int(plani.usercod) no-lock no-error.
    end.
end.
find crepl of plani no-lock no-error.
do:
    find estab where estab.etbcod = plani.emite no-lock no-error.
end.    


run mostra-dados.

if plani.movtdc = 48
then esqcom1[2] = "".
repeat:
    pause 0.

    display esqcom1
            with frame f-com2.
    choose field esqcom1 auto-return with frame f-com2.
    esqpos1 = frame-index.
    hide frame f-com2 no-pause.
    if esqcom1[esqpos1] = " 1.Produtos "
    then do:
        run nfppro.p (input recid(plani)).
    end. 
    
    if esqcom1[esqpos1] = " 2.Etiquetas "  
    then do:
    
        if not connected ("bswms")
        then do.
            message "Conectando ao banco WMS...".
            connect bswms -N tcp -S 1922 -H server.dep93 
                        -cache ../wms/bswms.csh.
        end.
        if connected ("bswms")
        then run wbsetipla.p (recid(plani)). 
        
    end.
                              

    if esqcom1[esqpos1] = " 3.Espelho "  
    then do:
        message "Confirma Impressao ?" update sresp.
        if sresp
        then run impnfecom.p (input recid(plani)). 
    end.
    


end.
hide frame fclien       no-pause.
hide frame ftitulo      no-pause.
hide frame f-com2       no-pause.
hide frame fborder      no-pause.
hide frame feschis      no-pause.
hide frame fobs         no-pause.
hide frame f-plani1      no-pause.
hide frame f-plani2      no-pause.
hide frame fsin         no-pause.
hide frame fhicam       no-pause.
hide frame fextra2      no-pause.
hide frame fextra       no-pause.
hide frame fgarantia   no-pause.
hide frame fextraorigem no-pause.
hide frame fextradevol no-pause.
hide frame f-com2 no-pause.


Procedure mostra-dados.

display 
                            clien.ciccgc when avail clien
                            clien.clicod when avail clien
                            clien.clinom when avail clien
                            plani.serie
                            plani.numero
                            plani.pladat
                            plani.indemi
                            plani.notsit
                            plani.ufemi
                            plani.ufdes
                            plani.etbcod
                            estab.etbnom when avail estab
                            plani.opccod 
                            plani.movtdc
                            plani.crecod
                            tipmov.movtnom when avail tipmov
                            plani.dtinclu

                            string(plani.horinc,"HH:MM") @ vplanihora
                            func.funcod when avail func
                            func.funape when avail func
                            with frame f-plani1.
color display message func.funape plani.indemi plani.notsit
                      with frame f-plani1.
color display message plani.platot
            with frame f-plani2.
pause 0.

vpctdescserv = if plani.vlserv = 0
               then 0
               else round((plani.descserv / plani.vlserv) * 100,2).
vpctdescprod = if plani.protot = 0
               then 0
               else round((plani.descprod / plani.protot),2) * 100.
            

display plani.biss
        plani.bipi
        plani.aliss
        plani.iss
        plani.vlserv
        plani.descserv
        vpctdescserv
        plani.bicms
        plani.icms
        plani.bsubst
        plani.icmssubst
        plani.protot
        plani.descpro
        if plani.acfprod < 0
        then plani.acfprod * -1
        else plani.acfprod @ plani.acfprod
        /*vpctdescprod*/
        plani.frete
        plani.seguro
        plani.desacess
        plani.ipi
        plani.platot
        with frame f-plani2.

display plani.notobs[1]
        plani.notobs[2]
        with frame fobs .

pause 0.

end procedure.
