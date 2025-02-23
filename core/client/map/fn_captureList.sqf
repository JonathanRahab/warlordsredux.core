#include "..\..\warlords_constants.inc"

private _captureDisplay = uiNamespace getVariable ["RscWLCaptureDisplay", objNull];
if (isNull _captureDisplay) then {
	"CaptureDisplay" cutRsc ["RscWLCaptureDisplay", "PLAIN", -1, true, true];
	_captureDisplay = uiNamespace getVariable "RscWLCaptureDisplay";
};

private _indicator = _captureDisplay displayCtrl 7005;
private _indicatorBackground = _captureDisplay displayCtrl 7004;
_indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0.7];

while { !BIS_WL_missionEnd } do {
	sleep WL_TIMEOUT_STANDARD;

	private _voteLocked = missionNamespace getVariable ["voteLocked", true];
	if (_voteLocked) then {continue;};
	private _side = BIS_WL_playerSide;
	private _sectorsBeingCaptured = BIS_WL_allSectors select {
		private _isBeingCaptured = _x getVariable ["BIS_WL_captureProgress", 0] > 0;
		private _revealed = _side in (_x getVariable ["BIS_WL_revealedBy", []]) || _side == independent;
		_isBeingCaptured && _revealed;
	};

	if (count _sectorsBeingCaptured == 0) then {
		_indicator ctrlSetText "";
		_indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0];
		continue;
	};

	private _captureIndicatorText = format ["<t size='1.8'>%1</t><br/>", localize "STR_WL2_CAPTURE_PROGRESS"];
	{
		private _sectorName = _x getVariable "BIS_WL_name";
		private _capturingTeam = _x getVariable ["BIS_WL_capturingTeam", independent];
		private _captureProgress = (_x getVariable ["BIS_WL_captureProgress", 0]) * 100;
		private _displayPercent = _captureProgress toFixed 1;
		private _captureColor = switch (_capturingTeam) do {
			case west: { "#004d99" };
			case east: { "#ff4b4b" };
			case independent: { "#00a300" };
		};
		_captureIndicatorText = _captureIndicatorText + format ["<t size='1.2' shadow='2' color='%1'>%2: %3%4</t><br/>", _captureColor, _sectorName, _displayPercent, "%"];
	} forEach _sectorsBeingCaptured;

	_indicator ctrlSetStructuredText (parseText _captureIndicatorText);
	_indicatorBackground ctrlSetBackgroundColor [0, 0, 0, 0.7];
	_indicatorBackground ctrlSetPositionH (0.09 + (count _sectorsBeingCaptured) * 0.04);
	_indicatorBackground ctrlCommit 0;
};