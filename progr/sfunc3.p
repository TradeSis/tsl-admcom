def input parameter vfunc as int.
def output parameter vstatus as char format "x(40)".      


/* ----- TESTA SE FUNCIONARIO EXISTE --------- */
message "teste".
find gerloja.func where funcod = vfunc no-error.
     if not avail gerloja.func
     then do:
            vstatus = "FUNCIONARIO NAO EXISTE".
            disconnect gerloja.
            return.
      end. 

