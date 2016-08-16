/*******************************************************************************
* NOME DO ARQUIVO :		modules/visual/deathmatch.pwn
*
* DESCRIÇÃO :
*	   Script responsável pela textdraw de pontos do deathmatch.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

static Text:gGlobalText[4];
static PlayerText:gPlayerText[MAX_PLAYERS][5];

//------------------------------------------------------------------------------

UpdatePlayerDeathmatchHud(playerid, kills, deaths, leaderid, leaderkills, endkills)
{
    new str[64];
    format(str, sizeof(str), "Abates: %02d", kills);
    PlayerTextDrawSetString(playerid, gPlayerText[playerid][0], str);
    format(str, sizeof(str), "Mortes: %02d", deaths);
    PlayerTextDrawSetString(playerid, gPlayerText[playerid][1], str);
    format(str, sizeof(str), "Abates: %02d", leaderkills);
    PlayerTextDrawSetString(playerid, gPlayerText[playerid][2], str);
    format(str, sizeof(str), "encerra_aos_%02d_abates", endkills);
    PlayerTextDrawSetString(playerid, gPlayerText[playerid][3], str);
    format(str, sizeof(str), "Lider: %s", GetPlayerNamef(leaderid));
    PlayerTextDrawSetString(playerid, gPlayerText[playerid][4], str);
}

//------------------------------------------------------------------------------

ShowPlayerDeathmatchHud(playerid)
{
    for(new i = 0; i < sizeof(gGlobalText); i++)
    {
        TextDrawShowForPlayer(playerid, gGlobalText[i]);
    }

    for(new i = 0; i < sizeof(gPlayerText[]); i++)
    {
        PlayerTextDrawShow(playerid, gPlayerText[playerid][i]);
    }
}

//------------------------------------------------------------------------------

HidePlayerDeathmatchHud(playerid)
{
    for(new i = 0; i < sizeof(gGlobalText); i++)
    {
        TextDrawHideForPlayer(playerid, gGlobalText[i]);
    }

    for(new i = 0; i < sizeof(gPlayerText[]); i++)
    {
        PlayerTextDrawHide(playerid, gPlayerText[playerid][i]);
    }
}

//------------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    gPlayerText[playerid][0] = CreatePlayerTextDraw(playerid, 478.600646, 178.000015, "abates:_10");
    PlayerTextDrawLetterSize(playerid, gPlayerText[playerid][1], 0.140000, 0.944592);
    PlayerTextDrawAlignment(playerid, gPlayerText[playerid][1], 1);
    PlayerTextDrawColor(playerid, gPlayerText[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, gPlayerText[playerid][1], 255);
    PlayerTextDrawFont(playerid, gPlayerText[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, gPlayerText[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][1], 0);

    gPlayerText[playerid][1] = CreatePlayerTextDraw(playerid, 528.369689, 178.000015, "mortes:_10");
    PlayerTextDrawLetterSize(playerid, gPlayerText[playerid][1], 0.140000, 0.944592);
    PlayerTextDrawAlignment(playerid, gPlayerText[playerid][1], 1);
    PlayerTextDrawColor(playerid, gPlayerText[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, gPlayerText[playerid][1], 255);
    PlayerTextDrawFont(playerid, gPlayerText[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, gPlayerText[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][1], 0);

    gPlayerText[playerid][2] = CreatePlayerTextDraw(playerid, 478.269744, 205.544021, "abates:_10");
    PlayerTextDrawLetterSize(playerid, gPlayerText[playerid][2], 0.140000, 0.944592);
    PlayerTextDrawAlignment(playerid, gPlayerText[playerid][2], 1);
    PlayerTextDrawColor(playerid, gPlayerText[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, gPlayerText[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, gPlayerText[playerid][2], 255);
    PlayerTextDrawFont(playerid, gPlayerText[playerid][2], 2);
    PlayerTextDrawSetProportional(playerid, gPlayerText[playerid][2], 1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][2], 0);

    gPlayerText[playerid][3] = CreatePlayerTextDraw(playerid, 492.670623, 223.345108, "encerra_aos_10_abates");
    PlayerTextDrawLetterSize(playerid, gPlayerText[playerid][3], 0.113000, 0.820148);
    PlayerTextDrawAlignment(playerid, gPlayerText[playerid][3], 1);
    PlayerTextDrawColor(playerid, gPlayerText[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, gPlayerText[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, gPlayerText[playerid][3], 255);
    PlayerTextDrawFont(playerid, gPlayerText[playerid][3], 2);
    PlayerTextDrawSetProportional(playerid, gPlayerText[playerid][3], 1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][3], 0);

    gPlayerText[playerid][4] = CreatePlayerTextDraw(playerid, 478.969787, 196.143447, "Lider:_");
    PlayerTextDrawLetterSize(playerid, gPlayerText[playerid][4], 0.140000, 0.944592);
    PlayerTextDrawAlignment(playerid, gPlayerText[playerid][4], 1);
    PlayerTextDrawColor(playerid, gPlayerText[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][4], 0);
    PlayerTextDrawSetOutline(playerid, gPlayerText[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, gPlayerText[playerid][4], 255);
    PlayerTextDrawFont(playerid, gPlayerText[playerid][4], 2);
    PlayerTextDrawSetProportional(playerid, gPlayerText[playerid][4], 1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][4], 0);
    return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    gGlobalText[0] = TextDrawCreate(474.999847, 150.592636, "box");
    TextDrawLetterSize(gGlobalText[0], 0.000000, 9.066665);
    TextDrawTextSize(gGlobalText[0], 568.000000, 0.000000);
    TextDrawAlignment(gGlobalText[0], 1);
    TextDrawColor(gGlobalText[0], -1);
    TextDrawUseBox(gGlobalText[0], 1);
    TextDrawBoxColor(gGlobalText[0], 105);
    TextDrawSetShadow(gGlobalText[0], 0);
    TextDrawSetOutline(gGlobalText[0], 0);
    TextDrawBackgroundColor(gGlobalText[0], 255);
    TextDrawFont(gGlobalText[0], 1);
    TextDrawSetProportional(gGlobalText[0], 1);
    TextDrawSetShadow(gGlobalText[0], 0);

    gGlobalText[1] = TextDrawCreate(488.600555, 150.177780, "pontos");
    TextDrawLetterSize(gGlobalText[1], 0.400000, 1.600000);
    TextDrawAlignment(gGlobalText[1], 1);
    TextDrawColor(gGlobalText[1], -1);
    TextDrawSetShadow(gGlobalText[1], 0);
    TextDrawSetOutline(gGlobalText[1], 0);
    TextDrawBackgroundColor(gGlobalText[1], 255);
    TextDrawFont(gGlobalText[1], 2);
    TextDrawSetProportional(gGlobalText[1], 1);
    TextDrawSetShadow(gGlobalText[1], 0);

    gGlobalText[2] = TextDrawCreate(475.833404, 186.866760, ".");
    TextDrawLetterSize(gGlobalText[2], 8.836000, 0.629333);
    TextDrawAlignment(gGlobalText[2], 1);
    TextDrawColor(gGlobalText[2], -1);
    TextDrawSetShadow(gGlobalText[2], 0);
    TextDrawSetOutline(gGlobalText[2], 0);
    TextDrawBackgroundColor(gGlobalText[2], 255);
    TextDrawFont(gGlobalText[2], 1);
    TextDrawSetProportional(gGlobalText[2], 1);
    TextDrawSetShadow(gGlobalText[2], 0);

    gGlobalText[3] = TextDrawCreate(475.833404, 214.168426, ".");
    TextDrawLetterSize(gGlobalText[3], 8.836000, 0.629333);
    TextDrawAlignment(gGlobalText[3], 1);
    TextDrawColor(gGlobalText[3], -1);
    TextDrawSetShadow(gGlobalText[3], 0);
    TextDrawSetOutline(gGlobalText[3], 0);
    TextDrawBackgroundColor(gGlobalText[3], 255);
    TextDrawFont(gGlobalText[3], 1);
    TextDrawSetProportional(gGlobalText[3], 1);
    TextDrawSetShadow(gGlobalText[3], 0);
    return 1;
}
