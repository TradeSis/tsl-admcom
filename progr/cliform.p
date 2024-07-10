{admcab.i}
for each _field where _field._field-name = "clicod":
find _file where recid(_file) = _field._file-recid.
displ _field._format
      _field._label.

message "Altera tabela" _file._file-name "?" update sresp.
if sresp then assign _field._format = ">>>>>>>999".
end.
