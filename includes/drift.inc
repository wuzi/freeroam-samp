/*
	Drift Include by PawnHunter (Jayce)

	Description:
		An include which detects drifting with useful callbacks and function for whoever working in a drift gamemode or minigame.
	Start Date: 
		18-Jul-2016 | 11:45 AM.
	Latest Update Date:
		18-Jul-2016 | 10:15 PM.
	Version:
		1.00
*/


#if 	defined 	_drift_included
	#endinput
#endif


#include 	<a_samp>

#define 	_drift_included
#define 	MIN_DRIFT_ANGLE					(7.0)
#define  	MAX_DRIFT_ANGLE					(80.0)
#define 	MIN_DRIFT_SPEED					(45.0)

#define 	DRIFT_END_REASON_TIMEOUT		(0)
#define 	DRIFT_END_REASON_CRASH			(1)
#define 	DRIFT_END_REASON_OTHER			(2)
#define 	DRIFT_END_REASON_DISCONNECT		(3)
#define 	PROCESS_INTERVAL				(220)
#define 	DRIFT_TIMEOUT_INTERVAL			(7) 	// 7 update attempts which is PROCCESS_INTERVAL * 7

enum _: D_T_DATA { 

	Float:	V_HEALTH,
	Float:	P_STARTX,
	Float:	P_STARTY,
	bool:	P_DRIFTING,
	_:		D_STARTTICK,
	_:		T_TICK,
	_:		T_TIMEOUT
}

static 
		P_DATA[MAX_PLAYERS][D_T_DATA]
	;
static const 
		R_DATA[D_T_DATA]
	;
forward	OnDriftStart(playerid);
forward	OnDriftUpdate(playerid, Float: drift_angle, Float: speed);
forward	OnDriftEnd(playerid, reason, Float: distance, time);
Float:	__GetPointDistanceToPoint(Float: x1, Float: y1, Float: x2, Float: y2) return floatsqroot( ( (x1-x2) * (x1-x2) ) + ( (y1-y2) * (y1-y2) ) );
bool:	__IsModelACar(modelid) 
{
	switch(modelid)
	{
		case 430, 446, 452, 453, 454, 472, 473, 484, 493, 595: return false; // Boats.
		case 448, 461, 462, 463, 468, 471, 481, 509, 510, 521, 522, 523, 581, 586: return false; // Bikes
		case 417, 425, 447, 460, 469, 476, 487, 488, 497, 511, 512, 513, 519, 520, 548, 553, 563, 577, 592, 593: return false; // Airplanes
		default: return true;
	}
	return true;
}
bool:	__IsVehicleDrivingBackwards(Float: x, Float: y, Float: z) // This function is made by Nero_3D.
{
	if(z < 90.0) {
		if(x > 0.0 && y < 0.0)	return true;
	} else if(z < 180.0) {
		if(x > 0.0 && y > 0.0)	return true;
	} else if(z < 270.0) {
		if(x < 0.0 && y > 0.0)	return true;
	} else if(x < 0.0 && y < 0.0)	return true;
	return false;
}
public OnPlayerDisconnect(playerid, reason)
{
	if(P_DATA[playerid][P_DRIFTING])
	{
		CallLocalFunction("OnDriftEnd", "iifi", playerid, DRIFT_END_REASON_DISCONNECT, 0.0,  0);
	}
	P_DATA[playerid] = R_DATA;
	#if defined D_OnPlayerDisconnect
		return D_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER && P_DATA[playerid][P_DRIFTING])	
	{
		new Float:_x, Float:_y, Float:_z;
		GetVehiclePos(GetPlayerVehicleID(playerid), _x, _y, _z);
		CallLocalFunction("OnDriftEnd", "iifi", playerid, DRIFT_END_REASON_OTHER, __GetPointDistanceToPoint(P_DATA[playerid][P_STARTX],  P_DATA[playerid][P_STARTY], _x, _y),  GetTickCount() - P_DATA[playerid][D_STARTTICK]);
		P_DATA[playerid] = R_DATA;
	}
	#if defined D_OnPlayerStateChange
		return D_OnPlayerStateChange(playerid, newstate, oldstate);
	#else
		return 1;
	#endif
}
public OnPlayerUpdate(playerid) {
	if(GetTickCount() > P_DATA[playerid][T_TICK])
	{
		new vehicleid;
		if( (vehicleid = GetPlayerVehicleID(playerid)) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER )
		{
			if(__IsModelACar(GetVehicleModel(vehicleid)))
			{
				new Float:x, Float:y, Float:z, Float:a, Float:d, Float:s, Float:drift_angle;
				GetVehicleVelocity(vehicleid, x, y, z);
				GetVehicleZAngle(vehicleid, a);
				s = floatround(floatsqroot( x*x + y*y + z*z) * 180);
				d = atan2(y, x);
				d = floatsub(d, 90.0);
				if(d < 0.0) d = floatadd(d, 360.0);
				drift_angle = a - d;
				if(drift_angle > 270.0) drift_angle -= 270.0;
				if(drift_angle < -270.0) drift_angle += 270.0;
				drift_angle = floatabs(drift_angle);
				switch (P_DATA[playerid][P_DRIFTING])
				{
					case 0:
					{
						if(MIN_DRIFT_ANGLE <= drift_angle <= MAX_DRIFT_ANGLE && s >= MIN_DRIFT_SPEED && !__IsVehicleDrivingBackwards(x, y, a))
						{
							P_DATA[playerid][P_DRIFTING] = true;
							P_DATA[playerid][D_STARTTICK] = GetTickCount();
							GetVehicleHealth(vehicleid, P_DATA[playerid][V_HEALTH]);
							GetPlayerPos(playerid, P_DATA[playerid][P_STARTX], P_DATA[playerid][P_STARTY], x);
							CallLocalFunction("OnDriftStart", "i", playerid);
						}
					}
					case 1:
					{
						new Float:vhealth, Float:_x, Float:_y, Float:_z;
						GetVehicleHealth(vehicleid, vhealth);
						GetVehiclePos(vehicleid, _x, _y, _z);

						if(vhealth < P_DATA[playerid][V_HEALTH]) 
						{
							CallLocalFunction("OnDriftEnd", "iifi", playerid, DRIFT_END_REASON_CRASH, __GetPointDistanceToPoint(P_DATA[playerid][P_STARTX],  P_DATA[playerid][P_STARTY], _x, _y),  GetTickCount() - P_DATA[playerid][D_STARTTICK]);
							P_DATA[playerid] = R_DATA;
						}
						else if(__IsVehicleDrivingBackwards(x, y, a) || s < MIN_DRIFT_SPEED)
						{
							CallLocalFunction("OnDriftEnd", "iifi", playerid, DRIFT_END_REASON_OTHER, __GetPointDistanceToPoint(P_DATA[playerid][P_STARTX],  P_DATA[playerid][P_STARTY], _x, _y),  GetTickCount() - P_DATA[playerid][D_STARTTICK]);
							P_DATA[playerid] = R_DATA;
						}
						else if(MIN_DRIFT_ANGLE <= drift_angle <= MAX_DRIFT_ANGLE && s >= MIN_DRIFT_SPEED)
						{
							P_DATA[playerid][T_TIMEOUT] = 0;
							CallLocalFunction("OnDriftUpdate", "iff", playerid, drift_angle, s);
						}
						else 
						{
							P_DATA[playerid][T_TIMEOUT]++;
							if(P_DATA[playerid][T_TIMEOUT] >= DRIFT_TIMEOUT_INTERVAL)
							{
								CallLocalFunction("OnDriftEnd", "iifi", playerid, DRIFT_END_REASON_TIMEOUT, __GetPointDistanceToPoint(P_DATA[playerid][P_STARTX],  P_DATA[playerid][P_STARTY], _x, _y),  GetTickCount() - P_DATA[playerid][D_STARTTICK]);
								P_DATA[playerid] = R_DATA;
							}
						}
					}
				}
			}
		}
		P_DATA[playerid][T_TICK] = GetTickCount() + PROCESS_INTERVAL;
	}
	#if defined D_OnPlayerUpdate
		return D_OnPlayerUpdate(playerid);
	#else
		return true;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect D_OnPlayerDisconnect
#if defined D_OnPlayerDisconnect
	forward D_OnPlayerDisconnect(playerid, reason);
#endif
#if defined _ALS_OnPlayerStateChange
	#undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif

#define OnPlayerStateChange D_OnPlayerStateChange
#if defined D_OnPlayerStateChange
	forward D_OnPlayerStateChange(playerid, newstate, oldstate);
#endif
#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif

#define OnPlayerUpdate D_OnPlayerUpdate
#if defined D_OnPlayerUpdate
	forward D_OnPlayerUpdate(playerid);
#endif

