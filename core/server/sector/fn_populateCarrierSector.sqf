#include "includes.inc"
params ["_sector"];

// setViewDistance 4500;

private _sectorMarker = _sector getVariable "objectAreaComplete";
private _carrier = ((8 allObjects 0) select {
    _x isKindOf "Land_Carrier_01_hull_base_F" && _x inArea _sectorMarker;
}) # 0;

private _assetData = WL_ASSET_DATA;
private _unitsPool = [];
{
    private _class = _x;
    private _data = _y;
    private _unitSpawn = _data getOrDefault ["unitSpawn", 0];
    if (_unitSpawn > 0) then {
        _unitsPool pushBack _class;
    };
} forEach _assetData;

private _infantryGroups = [];
private _infantryUnits = [];
private _spawnLocations = _sector getVariable ["WL2_aircraftCarrierInf", []];

private _spawned = 0;
{
    if (_spawned > 50) then {
        break;
    };

    private _infantryGroup = createGroup independent;
    _infantryGroup deleteGroupWhenEmpty true;
    _infantryGroups pushBack _infantryGroup;

    private _spawnPosition = _x;

    for "_i" from 0 to 8 do {
        private _infantry = _infantryGroup createUnit [selectRandom _unitsPool, _spawnPosition, [], 0, "NONE"];
        _infantry setVehiclePosition [_spawnPosition, [], 5, "CAN_COLLIDE"];

        private _spawnHeight = getPosASL _infantry # 2;
        if (_spawnHeight < 10) then {
            deleteVehicle _infantry;
        } else {
            _infantry call WL2_fnc_newAssetHandle;
            _spawned = _spawned + 1;
            doStop _infantry;
            _infantry setUnitPos "MIDDLE";
            _infantry disableAI "PATH";
            _infantryUnits pushBack _infantry;
        };

        uiSleep 0.001;
    };

    _infantryGroup setBehaviour "COMBAT";
} forEach (_spawnLocations call BIS_fnc_arrayShuffle);

[_infantryUnits, _sector] spawn WL2_fnc_assetRelevanceCheck;