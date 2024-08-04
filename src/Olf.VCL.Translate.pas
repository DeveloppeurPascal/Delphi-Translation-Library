/// <summary>
/// ***************************************************************************
///
/// Delphi Translation Library (DLT)
///
/// Copyright 2023-2024 Patrick Prémartin under AGPL 3.0 license.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
/// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS IN THE SOFTWARE.
///
/// ***************************************************************************
///
/// Library and tools to translate Delphi projects contents
///
/// ***************************************************************************
///
/// Author(s) :
///      Patrick PREMARTIN
///
/// Site :
///      https://serialstreameur.fr/automatically-translate-your-programs-with-deepl-api.html
///
/// Project site :
///      https://github.com/DeveloppeurPascal/Delphi-Translation-Library
///
/// ***************************************************************************
/// File last update : 04/08/2024 08:23:58
/// Signature : 93c6ba7c3201e1a0b0bad2d339e4fd7c3c324fe2
/// ***************************************************************************
/// </summary>

unit Olf.VCL.Translate;

// This file has been created for a DelphiCon 2023 online conference demo.
// It depends on the DeepL proxy server given during this session.
//
// See https://serialstreameur.fr/automatically-translate-your-programs-with-deepl-api.html

interface

uses Olf.RTL.Translate;

type
  TOlfTranslateProject = class(TOlfTranslate)
  public
    class procedure TranslateProjectForms;
  end;

implementation

uses
  System.SysUtils, VCL.Forms;

{ TOlfTranslateProject }

class procedure TOlfTranslateProject.TranslateProjectForms;
var
  i: integer;
  OlfTranslate: IOlfTranslate;
begin
  for i := 0 to Application.ComponentCount - 1 do
    if supports(Application.Components[i], IOlfTranslate, OlfTranslate) then
      OlfTranslate.TranslateTexts;
end;

initialization

TOlfTranslateProject.onLanguageChangedEvent :=
  TOlfTranslateProject.TranslateProjectForms;

end.
