(* ::Package:: *)

(* ::Section:: *)
(*Declare*)


BeginPackage["Mathpix`"];
Mathpix::usage = "";
Begin["`Private`"];


(* ::Section:: *)
(*API*)
$Tokens = {
	{"trial", "34f1a4cea0eaca8540c95908b4dc84ab"},
	{"mathpix", "139ee4b61be2e4abcfb1238d9eb99902"}
};
If[
	MissingQ@PersistentValue["Mathpix", "Local"],
	PersistentValue["Mathpix", "Local"] = $Tokens[[2]];
];
$MathpixToken = PersistentValue["Mathpix", "Local"];
MathpixHTTP[img_] := Block[
	{jpeg, api, header, body},
	jpeg = "data:image/jpg;base64," <> ExportString[img, {"Base64", "JPEG"}];
	api = "https://api.mathpix.com/v3/latex";
	header = {
		"app_id" -> First@$MathpixToken,
		"app_key" -> Last@$MathpixToken,
		"Content-type" -> "application/json"
	};
	body = ExportString[{
		"src" -> jpeg, "formats" -> {"latex" -> "simplified", "mathml" -> True, "wolfram" -> True
		}}, "json"];
	HTTPRequest[api, <|"Headers" -> header, "Body" -> body, Method -> "POST"|>]
];


(* ::Section:: *)
(*Methods*)


MathpixPOST[http_HTTPRequest] := URLExecute[http, Interactive -> False, "RawJSON"];
$LaTeXRefine = {
	" _ " -> "_",
	" ^ " -> "^",
	"{ " -> "{",
	" }" -> "}",
	"( " -> "(",
	" )" -> ")"
};
MathpixNormal[raw_] := Fold[StringReplace, raw["latex"], $LaTeXRefine];
MathpixDisplay[raw_] := DisplayForm@ImportString@raw["mathml"];
MathpixExpression[raw_] := InputForm@WolframAlpha[raw["wolfram"], "WolframParse"];
MathpixConfidence[raw_] := "TODO";


(* ::Section:: *)
(*Interface*)


Mathpix[path_String, method_] := Mathpix[Import@path, method];
Mathpix[img_Image, method_ : N] := MathpixInterface[MathpixPOST@MathpixHTTP@img, method];
Mathpix[obj_Association, method_ : N] := MathpixInterface[obj, method];
MathpixInterface[raw_Association, m_] := Block[
	{}, (*Todo: Sow Error*)
	Switch[m,
		N, MathpixNormal@raw,
		E, MathpixExpression@raw,
		D, MathpixDisplay@raw,
		C, MathpixConfidence[raw],
		_, Iconize[raw, "MathpixAPI"]
	]
];


(* ::Section:: *)
(*Additional*)


End[];
SetAttributes[
	{ },
	{Protected, ReadProtected}
];
EndPackage[]
