/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/drift.pwn
*
* DESCRIÇÃO :
*	   Permite que os drifts do jogadores gerem pontos.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

static Text:gDriftTextDraw[3];
static PlayerText:gDriftPointsPlayerTextDraw[MAX_PLAYERS][4];
static gPlayerPoints[MAX_PLAYERS];
static Timer:gPlayerTimer[MAX_PLAYERS] = {Timer:-1, ...};

//------------------------------------------------------------------------------

public OnDriftStart(playerid)
{
    if(!GetPlayerDriftState(playerid))
        return true;

    HideTotalDriftTextDraw(playerid);
	ShowPlayerDriftTextdraw(playerid);
	return true;
}

//------------------------------------------------------------------------------

public OnDriftUpdate(playerid, Float: drift_angle, Float: speed)
{
    if(!GetPlayerDriftState(playerid))
        return true;

    gPlayerPoints[playerid] += floatround(drift_angle);

    new points[16];
    valstr(points, gPlayerPoints[playerid]);
    PlayerTextDrawSetString(playerid, gDriftPointsPlayerTextDraw[playerid][0], points);
	return true;
}

//------------------------------------------------------------------------------

public OnDriftEnd(playerid, reason, Float: distance, time)
{
    if(!GetPlayerDriftState(playerid))
        return true;
    
    HidePlayerDriftTextdraw(playerid);

    new tmpstr[32];
    format(tmpstr, sizeof(tmpstr), "tempo: %02d segundos", time / 1000);
    PlayerTextDrawSetString(playerid, gDriftPointsPlayerTextDraw[playerid][1], tmpstr);
    format(tmpstr, sizeof(tmpstr), "pontos: %02d", gPlayerPoints[playerid]);
    PlayerTextDrawSetString(playerid, gDriftPointsPlayerTextDraw[playerid][2], tmpstr);
    format(tmpstr, sizeof(tmpstr), "distancia: %.2f", distance);
    PlayerTextDrawSetString(playerid, gDriftPointsPlayerTextDraw[playerid][3], tmpstr);

    TextDrawShowForPlayer(playerid, gDriftTextDraw[0]);
    TextDrawShowForPlayer(playerid, gDriftTextDraw[2]);
    PlayerTextDrawShow(playerid, gDriftPointsPlayerTextDraw[playerid][1]);
    PlayerTextDrawShow(playerid, gDriftPointsPlayerTextDraw[playerid][2]);
    PlayerTextDrawShow(playerid, gDriftPointsPlayerTextDraw[playerid][3]);

    gPlayerTimer[playerid] = defer HideTotalDriftTextDraw(playerid);

    gPlayerPoints[playerid] = 0;
	return true;
}

//------------------------------------------------------------------------------

ShowPlayerDriftTextdraw(playerid)
{
    TextDrawShowForPlayer(playerid, gDriftTextDraw[0]);
    TextDrawShowForPlayer(playerid, gDriftTextDraw[1]);
    PlayerTextDrawShow(playerid, gDriftPointsPlayerTextDraw[playerid][0]);
}

//------------------------------------------------------------------------------

HidePlayerDriftTextdraw(playerid)
{
    TextDrawHideForPlayer(playerid, gDriftTextDraw[0]);
    TextDrawHideForPlayer(playerid, gDriftTextDraw[1]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][0]);
    PlayerTextDrawSetString(playerid, gDriftPointsPlayerTextDraw[playerid][0], "0");
}

//------------------------------------------------------------------------------

timer HideTotalDriftTextDraw[7500](playerid)
{
    if(gPlayerTimer[playerid] != Timer:-1)
    {
        stop gPlayerTimer[playerid];
    }
    gPlayerTimer[playerid] = Timer:-1;
    TextDrawHideForPlayer(playerid, gDriftTextDraw[0]);
    TextDrawHideForPlayer(playerid, gDriftTextDraw[2]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][1]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][2]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][3]);
}

//------------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    gDriftPointsPlayerTextDraw[playerid][0] = CreatePlayerTextDraw(playerid, 508.100311, 308.636993, "0");
    PlayerTextDrawLetterSize(playerid, gDriftPointsPlayerTextDraw[playerid][0], 0.163000, 1.728592);
    PlayerTextDrawAlignment(playerid, gDriftPointsPlayerTextDraw[playerid][0], 2);
    PlayerTextDrawColor(playerid, gDriftPointsPlayerTextDraw[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, gDriftPointsPlayerTextDraw[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, gDriftPointsPlayerTextDraw[playerid][0], 255);
    PlayerTextDrawFont(playerid, gDriftPointsPlayerTextDraw[playerid][0], 2);
    PlayerTextDrawSetProportional(playerid, gDriftPointsPlayerTextDraw[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][0], 0);

    gDriftPointsPlayerTextDraw[playerid][1] = CreatePlayerTextDraw(playerid, 471.698608, 300.515686, "tempo:_0");
    PlayerTextDrawLetterSize(playerid, gDriftPointsPlayerTextDraw[playerid][1], 0.127000, 1.371851);
    PlayerTextDrawAlignment(playerid, gDriftPointsPlayerTextDraw[playerid][1], 1);
    PlayerTextDrawColor(playerid, gDriftPointsPlayerTextDraw[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, gDriftPointsPlayerTextDraw[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, gDriftPointsPlayerTextDraw[playerid][1], 255);
    PlayerTextDrawFont(playerid, gDriftPointsPlayerTextDraw[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, gDriftPointsPlayerTextDraw[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][1], 0);

    gDriftPointsPlayerTextDraw[playerid][2] = CreatePlayerTextDraw(playerid, 471.698608, 310.515686, "pontos:_0");
    PlayerTextDrawLetterSize(playerid, gDriftPointsPlayerTextDraw[playerid][2], 0.127000, 1.371851);
    PlayerTextDrawAlignment(playerid, gDriftPointsPlayerTextDraw[playerid][2], 1);
    PlayerTextDrawColor(playerid, gDriftPointsPlayerTextDraw[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, gDriftPointsPlayerTextDraw[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, gDriftPointsPlayerTextDraw[playerid][2], 255);
    PlayerTextDrawFont(playerid, gDriftPointsPlayerTextDraw[playerid][2], 2);
    PlayerTextDrawSetProportional(playerid, gDriftPointsPlayerTextDraw[playerid][2], 1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][2], 0);

    gDriftPointsPlayerTextDraw[playerid][3] = CreatePlayerTextDraw(playerid, 471.698608, 320.515686, "distancia:_0");
    PlayerTextDrawLetterSize(playerid, gDriftPointsPlayerTextDraw[playerid][3], 0.127000, 1.371851);
    PlayerTextDrawAlignment(playerid, gDriftPointsPlayerTextDraw[playerid][3], 1);
    PlayerTextDrawColor(playerid, gDriftPointsPlayerTextDraw[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, gDriftPointsPlayerTextDraw[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, gDriftPointsPlayerTextDraw[playerid][3], 255);
    PlayerTextDrawFont(playerid, gDriftPointsPlayerTextDraw[playerid][3], 2);
    PlayerTextDrawSetProportional(playerid, gDriftPointsPlayerTextDraw[playerid][3], 1);
    PlayerTextDrawSetShadow(playerid, gDriftPointsPlayerTextDraw[playerid][3], 0);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    gPlayerPoints[playerid] = 0;
    TextDrawHideForPlayer(playerid, gDriftTextDraw[0]);
    TextDrawHideForPlayer(playerid, gDriftTextDraw[1]);
    TextDrawHideForPlayer(playerid, gDriftTextDraw[2]);

    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][0]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][1]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][2]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][3]);
    return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    gDriftTextDraw[0] = TextDrawCreate(472.333343, 285.407470, "_");
    TextDrawLetterSize(gDriftTextDraw[0], 0.382333, 5.972147);
    TextDrawTextSize(gDriftTextDraw[0], 544.000000, 0.000000);
    TextDrawAlignment(gDriftTextDraw[0], 1);
    TextDrawColor(gDriftTextDraw[0], -1);
    TextDrawUseBox(gDriftTextDraw[0], 1);
    TextDrawBoxColor(gDriftTextDraw[0], 112);
    TextDrawSetShadow(gDriftTextDraw[0], 0);
    TextDrawSetOutline(gDriftTextDraw[0], 0);
    TextDrawBackgroundColor(gDriftTextDraw[0], 255);
    TextDrawFont(gDriftTextDraw[0], 1);
    TextDrawSetProportional(gDriftTextDraw[0], 1);
    TextDrawSetShadow(gDriftTextDraw[0], 0);

    gDriftTextDraw[1] = TextDrawCreate(496.666809, 282.918457, "Drift");
    TextDrawLetterSize(gDriftTextDraw[1], 0.163000, 1.728592);
    TextDrawAlignment(gDriftTextDraw[1], 1);
    TextDrawColor(gDriftTextDraw[1], 0x8cd100ff);
    TextDrawSetShadow(gDriftTextDraw[1], 0);
    TextDrawSetOutline(gDriftTextDraw[1], 0);
    TextDrawBackgroundColor(gDriftTextDraw[1], 255);
    TextDrawFont(gDriftTextDraw[1], 2);
    TextDrawSetProportional(gDriftTextDraw[1], 1);
    TextDrawSetShadow(gDriftTextDraw[1], 0);

    gDriftTextDraw[2] = TextDrawCreate(508.333282, 282.918457, "total_drift");
    TextDrawLetterSize(gDriftTextDraw[2], 0.163000, 1.728592);
    TextDrawAlignment(gDriftTextDraw[2], 2);
    TextDrawColor(gDriftTextDraw[2], 0x8cd100ff);
    TextDrawSetShadow(gDriftTextDraw[2], 0);
    TextDrawSetOutline(gDriftTextDraw[2], 0);
    TextDrawBackgroundColor(gDriftTextDraw[2], 255);
    TextDrawFont(gDriftTextDraw[2], 2);
    TextDrawSetProportional(gDriftTextDraw[2], 1);
    TextDrawSetShadow(gDriftTextDraw[2], 0);
    return 1;
}
