#include "includes.inc"

params ["_demolishableItems"];

if (cameraOn != player) exitWith { objNull };

if (count _demolishableItems == 0) exitWith { objNull };
if (count _demolishableItems > 1) then {
    _demolishableItems = [_demolishableItems, [], { 
        if (_x == cursorTarget) then {
            -1
        } else {
            player distance _x
        };
    }, "ASCEND"] call BIS_fnc_sortBy;
};
private _demolishTarget = _demolishableItems # 0;

private _strongholdSector = _demolishTarget getVariable ["WL_strongholdSector", objNull];
if (isNull _strongholdSector) exitWith { _demolishTarget };
private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", independent];
// if (_sectorOwner == BIS_WL_playerSide) exitWith { false };

private _strongholdRadius = _demolishTarget getVariable ["WL_strongholdRadius", 0];
private _strongholdArea = [
    getPosASL _demolishTarget,
    _strongholdRadius,
    _strongholdRadius,
    0,
    false
];
private _nearbyEnemies = _strongholdArea nearEntities [["Man"], false, true, false];
_nearbyEnemies = _nearbyEnemies select {
    lifeState _x != "INCAPACITATED" &&
    side group _x != side group player
};

if (count _nearbyEnemies > 0) exitWith { objNull };
_demolishTarget;