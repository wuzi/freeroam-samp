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
static PlayerText:gPlTextDrift[MAX_PLAYERS][3];
static gPlayerCombo[MAX_PLAYERS] = {1, ...};
static gPlayerPoints[MAX_PLAYERS];
static gPlayerBestScore[MAX_PLAYERS];
static gPlayerTotalScore[MAX_PLAYERS];
static Timer:gPlayerTimer[MAX_PLAYERS] = {Timer:-1, ...};

//------------------------------------------------------------------------------

public OnDriftStart(playerid)
{
    if(!GetPlayerDriftState(playerid))
        return true;

    HideTotalDriftTextDraw(playerid);
	ShowPlayerDriftTextdraw(playerid, GetPlayerDriftCounter(playerid));
	return true;
}

//------------------------------------------------------------------------------

public OnDriftUpdate(playerid, Float: drift_angle, Float: speed)
{
    if(!GetPlayerDriftState(playerid))
        return true;

    gPlayerPoints[playerid] += (floatround(drift_angle) * gPlayerCombo[playerid]);

    if(gPlayerPoints[playerid] > 500)
    {
        gPlayerCombo[playerid] = 4;
        PlayerTextDrawSetString(playerid, gPlTextDrift[playerid][2], "COMBO~n~x4");
    }
    else if(gPlayerPoints[playerid] > 350)
    {
        gPlayerCombo[playerid] = 3;
        PlayerTextDrawSetString(playerid, gPlTextDrift[playerid][2], "COMBO~n~x3");
    }
    else if(gPlayerPoints[playerid] > 150)
    {
        gPlayerCombo[playerid] = 2;
        PlayerTextDrawSetString(playerid, gPlTextDrift[playerid][2], "COMBO~n~x2");
    }

    if(GetPlayerDriftCounter(playerid) == 1)
    {
        new points[16];
        valstr(points, gPlayerPoints[playerid]);
        PlayerTextDrawSetString(playerid, gDriftPointsPlayerTextDraw[playerid][0], points);
    }
    else
    {
        new points[32];
        format(points, sizeof(points), "PONTOS:~n~%d", gPlayerPoints[playerid]);
        PlayerTextDrawSetString(playerid, gPlTextDrift[playerid][0], points);
    }
	return true;
}

//------------------------------------------------------------------------------

public OnDriftEnd(playerid, reason, Float: distance, time)
{
    if(!GetPlayerDriftState(playerid))
        return true;

    HidePlayerDriftTextdraw(playerid);

    gPlayerCombo[playerid] = 1;
    PlayerTextDrawSetString(playerid, gPlTextDrift[playerid][2], "COMBO~n~x1");

    if(reason == DRIFT_END_REASON_CRASH)
    {
        gPlayerPoints[playerid] = 0;
        GameTextForPlayer(playerid, "~r~bateu", 1500, 3);
    }

    if(gPlayerPoints[playerid] > gPlayerBestScore[playerid])
    {
        gPlayerBestScore[playerid] = gPlayerPoints[playerid];
    }

    if(GetPlayerDriftCounter(playerid))
    {
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
    }
    else
    {
        new tmpstr[32];
        format(tmpstr, sizeof(tmpstr), "best score: %d", gPlayerBestScore[playerid]);
        PlayerTextDrawSetString(playerid, gPlTextDrift[playerid][1], tmpstr);
    }

    gPlayerTotalScore[playerid] += gPlayerPoints[playerid];
    gPlayerPoints[playerid] = 0;

    SetPlayerScore(playerid, gPlayerTotalScore[playerid] / 1000);
	return true;
}

//------------------------------------------------------------------------------

ShowPlayerDriftTextdraw(playerid, toggle)
{
    if(toggle == 0)
    {
        PlayerTextDrawShow(playerid, gPlTextDrift[playerid][0]);
        PlayerTextDrawShow(playerid, gPlTextDrift[playerid][1]);
        PlayerTextDrawShow(playerid, gPlTextDrift[playerid][2]);
    }
    else
    {
        TextDrawShowForPlayer(playerid, gDriftTextDraw[0]);
        TextDrawShowForPlayer(playerid, gDriftTextDraw[1]);
        PlayerTextDrawShow(playerid, gDriftPointsPlayerTextDraw[playerid][0]);
    }
}

//------------------------------------------------------------------------------

HidePlayerDriftTextdraw(playerid, bool:hide_best_score = false)
{
    TextDrawHideForPlayer(playerid, gDriftTextDraw[0]);
    TextDrawHideForPlayer(playerid, gDriftTextDraw[1]);
    PlayerTextDrawHide(playerid, gDriftPointsPlayerTextDraw[playerid][0]);
    PlayerTextDrawSetString(playerid, gDriftPointsPlayerTextDraw[playerid][0], "0");

    // 2nd version
    PlayerTextDrawHide(playerid, gPlTextDrift[playerid][0]);
    PlayerTextDrawSetString(playerid, gPlTextDrift[playerid][0], "pontos:~n~0");
    if(hide_best_score) PlayerTextDrawHide(playerid, gPlTextDrift[playerid][1]);
    PlayerTextDrawHide(playerid, gPlTextDrift[playerid][2]);
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

    // 2nd drift hud
    gPlTextDrift[playerid][0] = CreatePlayerTextDraw(playerid, 316.000213, 111.599952, "PONTOS:~n~0");
    PlayerTextDrawLetterSize(playerid, gPlTextDrift[playerid][0], 0.533330, 2.219999);
    PlayerTextDrawAlignment(playerid, gPlTextDrift[playerid][0], 2);
    PlayerTextDrawColor(playerid, gPlTextDrift[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, gPlTextDrift[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, gPlTextDrift[playerid][0], 1);
    PlayerTextDrawBackgroundColor(playerid, gPlTextDrift[playerid][0], 255);
    PlayerTextDrawFont(playerid, gPlTextDrift[playerid][0], 2);
    PlayerTextDrawSetProportional(playerid, gPlTextDrift[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, gPlTextDrift[playerid][0], 0);

    gPlTextDrift[playerid][1] = CreatePlayerTextDraw(playerid, 603.499938, 0.055507, "BEST_SCORE:_1");
    PlayerTextDrawLetterSize(playerid, gPlTextDrift[playerid][1], 0.287997, 1.854961);
    PlayerTextDrawAlignment(playerid, gPlTextDrift[playerid][1], 3);
    PlayerTextDrawColor(playerid, gPlTextDrift[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, gPlTextDrift[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, gPlTextDrift[playerid][1], 1);
    PlayerTextDrawBackgroundColor(playerid, gPlTextDrift[playerid][1], 255);
    PlayerTextDrawFont(playerid, gPlTextDrift[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, gPlTextDrift[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, gPlTextDrift[playerid][1], 0);

    gPlTextDrift[playerid][2] = CreatePlayerTextDraw(playerid, 610.501770, 93.817070, "COMBO~n~x1");
    PlayerTextDrawLetterSize(playerid, gPlTextDrift[playerid][2], 0.533330, 2.219999);
    PlayerTextDrawAlignment(playerid, gPlTextDrift[playerid][2], 3);
    PlayerTextDrawColor(playerid, gPlTextDrift[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, gPlTextDrift[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, gPlTextDrift[playerid][2], 1);
    PlayerTextDrawBackgroundColor(playerid, gPlTextDrift[playerid][2], 255);
    PlayerTextDrawFont(playerid, gPlTextDrift[playerid][2], 2);
    PlayerTextDrawSetProportional(playerid, gPlTextDrift[playerid][2], 1);
    PlayerTextDrawSetShadow(playerid, gPlTextDrift[playerid][2], 0);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    gPlayerCombo[playerid] = 1;
    gPlayerPoints[playerid] = 0;
    gPlayerBestScore[playerid] = 0;
    gPlayerTotalScore[playerid] = 0;
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
