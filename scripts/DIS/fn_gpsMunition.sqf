#include "includes.inc"
params ["_projectile", "_unit"];

_projectile addEventHandler ["HitPart", {
	params ["_projectile", "_hitEntity", "_projectileOwner", "_pos", "_velocity", "_normal", "_components", "_radius" ,"_surfaceType", "_instigator"];
    [_hitEntity, _instigator] remoteExec ["WL2_fnc_handleGpsDirect", 2];
}];

private _minimumSpeed = 150;
private _overrideRange = _unit getVariable ["WL2_overrideRange", 0];
if (_overrideRange > 0) then {
    _minimumSpeed = 300;
};

if (!isNull (missileTarget _projectile)) exitWith {};

private _gpsBombs = _unit getVariable ["DIS_gpsBombs", []];
_gpsBombs pushBack _projectile;
_gpsBombs = _gpsBombs select { alive _x };
_unit setVariable ["DIS_gpsBombs", _gpsBombs];

private _coordinates = +(_projectile getVariable ["DIS_targetCoordinates", getPosATL _unit]);
private _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
_coordinates set [2, 400];
_laserTarget setPosATL _coordinates;

private _terminalManeuver = false;
private _originalDistance = _projectile distance _laserTarget;
private _launchTime = serverTime;
private _originalSpeed = (velocityModelSpace _unit) # 1;

if (_overrideRange > 0) then {
    _coordinates set [2, 1000];
};

private _initialVectorUp = vectorUp _projectile;
_initialVectorUp set [0, 0];
_initialVectorUp set [1, 1];
_projectile setVectorDirAndUp [vectorDir _projectile, _initialVectorUp];

if (_overrideRange > 0) then {
    private _altitude = getPosASL _projectile select 2;
    while { _altitude < (_overrideRange / 6) } do {
        _altitude = getPosASL _projectile select 2;
        [_projectile, 90, 0] call BIS_fnc_setPitchBank;
        _projectile setVelocityModelSpace [0, 500, 0];
        sleep 0.1;
    };
};

sleep 1;

_projectile setMissileTarget [_laserTarget, true];

private _finalPosition = [];
while { alive _projectile } do {
    private _distanceToTarget = _projectile distance _laserTarget;
    private _speed = _originalSpeed - (serverTime - _launchTime) * 0.1;
    if (!_terminalManeuver) then {
        _projectile setVelocityModelSpace [0, _speed max _minimumSpeed, 0];
        _projectile setMissileTarget [_laserTarget, true];
    } else {
        private _currentPosition = getPosASL _projectile;
        private _missileTarget = missileTarget _projectile;
        if (alive _missileTarget) then {
            _finalPosition = getPosASL _missileTarget;
        };
        private _targetVectorDirAndUp = [_currentPosition, _finalPosition] call BIS_fnc_findLookAt;
        private _currentVectorDir = vectorDir _projectile;
        private _currentVectorUp = vectorUp _projectile;

        private _actualVectorDir = vectorLinearConversion [0, 1, 0.1, _currentVectorDir, _targetVectorDirAndUp # 0, true];
        private _actualVectorUp = vectorLinearConversion [0, 1, 0.1, _currentVectorUp, _targetVectorDirAndUp # 1, true];
        _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];

        _projectile setVelocityModelSpace [0, _speed max 100, 0];
    };

    if (_projectile distance2D _laserTarget < 200 && !_terminalManeuver) then {
        _terminalManeuver = true;

        _coordinates set [2, 0];
        private _enemiesNear = (_coordinates nearEntities 250) select {
            ([_x] call WL2_fnc_getAssetSide) != BIS_WL_playerSide &&
            alive _x &&
            lifeState _x != "INCAPACITATED" &&
            (_x getVariable ["WL_spawnedAsset", false] || isPlayer _x)
        };

        _finalPosition = [];
        if (count _enemiesNear == 0) then {
            _laserTarget setPosATL _coordinates;
            _finalPosition = AGLtoASL _coordinates;
            _projectile setMissileTarget [_laserTarget, true];
        } else {
            private _sortedEnemies = [_enemiesNear, [WL_ASSET_DATA], {
                private _assetData = _input0;
                private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
                WL_ASSET_FIELD(_assetData, _assetActualType, "cost", 0);
            }, "DESCEND"] call BIS_fnc_sortBy;

            private _closestEnemy = _sortedEnemies # 0;
            private _closestEnemyName = if (_closestEnemy isKindOf "Man") then {
                "Infantry";
            } else {
                [_closestEnemy] call WL2_fnc_getAssetTypeName;
            };
            _projectile setVariable ["DIS_terminalTarget", _closestEnemyName];

            _finalPosition = getPosASL _closestEnemy;
            _projectile setMissileTarget [_closestEnemy, true];
        };
    };

    if (!alive _laserTarget) then {
        _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
        _laserTarget setPosATL _coordinates;
    };

    sleep 0.001;
};

deleteVehicle _laserTarget;