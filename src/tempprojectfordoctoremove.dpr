program tempprojectfordoctoremove;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Olf.FMX.Translate in 'Olf.FMX.Translate.pas',
  Olf.RTL.Translate in 'Olf.RTL.Translate.pas',
  Olf.VCL.Translate in 'Olf.VCL.Translate.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insérer du code ici }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
