(* C2PP
  ***************************************************************************

  Delphi Translation Library (DLT)

  Copyright 2023-2025 Patrick Prémartin under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  Library and tools to translate Delphi projects contents

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://translationlib.developpeur-pascal.fr/

  Project site :
  https://github.com/DeveloppeurPascal/Delphi-Translation-Library

  ***************************************************************************
  File last update : 2025-02-09T11:03:46.432+01:00
  Signature : 52b7f16236af164bfdb8cf52c8a6599857afd9a2
  ***************************************************************************
*)

unit Olf.RTL.Translate;

// This file has been created for a DelphiCon 2023 online conference demo.
// It depends on the DeepL proxy server given during this session.
//
// See https://serialstreameur.fr/automatically-translate-your-programs-with-deepl-api.html

interface

type
  TOlfGetTextAfterProc = reference to procedure(ToText: string);
  TOlfGetTextAfterEvent = procedure(ToText: string) of object;

  IOlfTranslate = interface(IInterface)
    ['{3377C5E1-3F2E-4B37-884A-505D106C2661}']
    procedure TranslateTexts;
  end;

  TOlfTranslate = class(TObject)
  private
    class var FTranslationServerURL: string;
    class var FCurrentLanguage: string;
    class var FDefaultLanguage: string;
    class function GetCurrentLanguage: string; static;
    class function GetDefaultLanguage: string; static;
    class function GetTranslationServerURL: string; static;
    class procedure SetCurrentLanguage(const Value: string); static;
    class procedure SetDefaultLanguage(const Value: string); static;
    class procedure SetTranslationServerURL(const Value: string); static;
  protected
    class var onLanguageChangedEvent: procedure of object;
  public
    class property CurrentLanguage: string read GetCurrentLanguage
      write SetCurrentLanguage;
    class property DefaultLanguage: string read GetDefaultLanguage
      write SetDefaultLanguage;
    class property TranslationServerURL: string read GetTranslationServerURL
      write SetTranslationServerURL;
    class function getText(FromText: string;
      CallBack: TOlfGetTextAfterProc = nil): string; overload;
    class function getText(ID, FromText: string;
      CallBack: TOlfGetTextAfterProc = nil): string; overload;
    class function getText(FromText: string; CallBack: TOlfGetTextAfterEvent)
      : string; overload;
    class function getText(ID, FromText: string;
      CallBack: TOlfGetTextAfterEvent): string; overload;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections, OlfSoftware.DeepL.ClientLib;

type
  TDefaultTextCache = TDictionary<string, string>;
  TTranslationsCache = TDictionary<string, string>;

var
  DefaultTextCache: TDefaultTextCache;
  TranslationsCache: TTranslationsCache;

  { TOlfTranslate }

class function TOlfTranslate.GetCurrentLanguage: string;
begin
  if FCurrentLanguage.IsEmpty then
    result := GetDefaultLanguage
  else
    result := FCurrentLanguage;
end;

class function TOlfTranslate.GetDefaultLanguage: string;
begin
  if FDefaultLanguage.IsEmpty then
    raise exception.Create('Default language not set !')
  else
    result := FDefaultLanguage;
end;

class function TOlfTranslate.getText(FromText: string;
  CallBack: TOlfGetTextAfterEvent): string;
begin
  result := getText(FromText,
    procedure(ToText: string)
    begin
      if assigned(CallBack) then
        CallBack(ToText);
    end);
end;

class function TOlfTranslate.getText(ID, FromText: string;
CallBack: TOlfGetTextAfterEvent): string;
begin
  result := getText(ID, FromText,
    procedure(ToText: string)
    begin
      if assigned(CallBack) then
        CallBack(ToText);
    end);
end;

class function TOlfTranslate.GetTranslationServerURL: string;
begin
  if FTranslationServerURL.IsEmpty then
    raise exception.Create('Translation server URL not set !')
  else
    result := FTranslationServerURL;
end;

class function TOlfTranslate.getText(ID, FromText: string;
CallBack: TOlfGetTextAfterProc): string;
begin
  if not DefaultTextCache.ContainsKey(ID) then
    DefaultTextCache.Add(ID, FromText);
  result := getText(DefaultTextCache.Items[ID], CallBack);
end;

class function TOlfTranslate.getText(FromText: string;
CallBack: TOlfGetTextAfterProc): string;
begin
  if TranslationsCache.ContainsKey(CurrentLanguage + FromText) then
    result := TranslationsCache.Items[CurrentLanguage + FromText]
  else if CurrentLanguage = DefaultLanguage then
  begin
    result := FromText;
    TranslationsCache.Add(CurrentLanguage + FromText, result);
  end
  else
  begin
{$IF Defined(IOS) or Defined(ANDROID)}
    result := FromText;
    DeepLTranslateTextASync('', DefaultLanguage, CurrentLanguage, FromText,
      procedure(OriginalText, TranslatedText, SourceLang, TargetLang: string)
      begin
        TranslationsCache.Add(TargetLang + OriginalText, TranslatedText);
        // if assigned(CallBack) then
        // CallBack(TranslatedText);
      end);
    // TODO : due to variable visibility with anonymous code, the callback
    // function may generate errors so I preferred cancle it in this release
{$ELSE}
    // TODO : replace blocking by non blocking call
    result := DeepLTranslateTextSync('', DefaultLanguage, CurrentLanguage,
      FromText);
    TranslationsCache.Add(CurrentLanguage + FromText, result);
{$ENDIF}
  end;
end;

class procedure TOlfTranslate.SetCurrentLanguage(const Value: string);
begin
  if (CurrentLanguage <> Value) then
  begin
    FCurrentLanguage := Value;
    if assigned(onLanguageChangedEvent) then
      onLanguageChangedEvent;
  end;
end;

class procedure TOlfTranslate.SetDefaultLanguage(const Value: string);
begin
  FDefaultLanguage := Value;
end;

class procedure TOlfTranslate.SetTranslationServerURL(const Value: string);
begin
  FTranslationServerURL := Value;
  DeepLSetAPIURL(FTranslationServerURL);
end;

initialization

TOlfTranslate.FTranslationServerURL := '';
TOlfTranslate.FCurrentLanguage := '';
TOlfTranslate.FDefaultLanguage := '';
TOlfTranslate.onLanguageChangedEvent := nil;

DefaultTextCache := TDefaultTextCache.Create;
TranslationsCache := TTranslationsCache.Create;

finalization

TranslationsCache.Free;
DefaultTextCache.Free;

end.
