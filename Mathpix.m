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
	body = {
		"src" -> jpeg,
		"ocr" -> {"math", "text"},
		"formats" -> {
			"mathml" -> True,
			"wolfram" -> True
		},
		"format_options" -> <|
			"latex_styled" -> <|
				"transforms" -> {"rm_spaces"},
				"math_delims" -> {"$", "$"},
				"displaymath_delims" -> {"$$", "$$"}
			|>
		|>
	};
	HTTPRequest[api, <|"Headers" -> header, "Body" -> ExportString[body, "json"], Method -> "POST"|>]
];


MathpixTextRequest[img_] := Block[
	{jpeg, api, header, body},
	jpeg = "data:image/jpg;base64," <> ExportString[img, {"Base64", "JPEG"}];
	api = "https://api.mathpix.com/v3/text";
	header = {
		"app_id" -> First@$MathpixToken,
		"app_key" -> Last@$MathpixToken,
		"Content-type" -> "application/json"
	};
	body = {
		"src" -> jpeg,
		"format_options" -> <|
			"latex_styled" -> <|
				"transforms" -> {"rm_spaces"},
				"math_delims" -> {"$", "$"},
				"displaymath_delims" -> {"$$", "$$"}
			|>
		|>
	};
	HTTPRequest[api, <|"Headers" -> header, "Body" -> ExportString[body, "json"], Method -> "POST"|>]
];


(* ::Section:: *)
(*Methods*)


$LaTeXRefine = {
	" _ " -> "_",
	" ^ " -> "^",
	"{ " -> "{",
	" }" -> "}",
	"( " -> "(",
	" )" -> ")",
	"\\[\n" -> "$$",
	"\n\\]" -> "$$",
	"\\(" ->"$",
	" \\)" ->"$"
};


MathpixPOST[http_HTTPRequest] := URLExecute[http, "Interactive" -> False, "RawJSON"];
MathpixNormal[raw_] := raw["latex_styled"];
MathpixDisplay[raw_] := Module[
	{url = URLEncode@raw["latex_styled"], png},
	png = Import["https://latex.codecogs.com/gif.latex?" <> url, "GIF"];
	Echo["", "Preview:"];
	Print@png;
	DisplayForm@ImportString@raw["mathml"]
];
MathpixExpression[raw_] := InputForm@WolframAlpha[raw["wolfram"], "WolframParse"];
MathpixConfidence[raw_] := "TODO";
MathpixText[raw_] := Fold[StringReplace, raw["text"], $LaTeXRefine];


(* ::Section:: *)
(*Interface*)


Mathpix[path_String, method_] := Mathpix[Import@path, method];
Mathpix[img_Image, method_ : N] := Switch[
	method,
	Text, MathpixInterface[MathpixPOST@MathpixTextRequest@img, method],
	_ , MathpixInterface[MathpixPOST@MathpixHTTP@img, method]
];
Mathpix[obj_Association, method_ : N] := MathpixInterface[obj, method];
Mathpix[imgs_List] := Module[
	{ ans, parser, ass},
	parser[img_] := (
		ass = MathpixPOST[MathpixHTTP@img];
		If[
			ass["error"] != "",
			Echo[ass["error"], "Error: "];
			Return["\\text{failed}"],
			Return[ass["latex_styled"]]
		]
	);
	ans = "$$" <> StringRiffle[parser /@ imgs, "$$\n$$"] <> "$$";
	CopyToClipboard@ans;
	ans
];
MathpixInterface[raw_Association, m_] := Block[
	{ans},
	If[raw["error"] != "", Echo[raw["error"], "Error: "]];
	ans = Switch[m,
		N, MathpixNormal@raw,
		E, MathpixExpression@raw,
		D, MathpixDisplay@raw,
		C, MathpixConfidence[raw],
		Text, MathpixText[raw],
		_, Iconize[raw, "MathpixAPI"]
	];
	CopyToClipboard@ans;
	ans
];


(* ::Section:: *)
(*Additional*)


End[];
SetAttributes[
	{ },
	{Protected, ReadProtected}
];
EndPackage[]
