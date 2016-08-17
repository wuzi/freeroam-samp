/*******************************************************************************
* NOME DO ARQUIVO :		modules/visual/tutorial.pwn
*
* DESCRIÇÃO :
*	   Cria as textdraws do tutorial.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

static Text:gGlobalText[5];
static PlayerText:gPlayerText[MAX_PLAYERS][2];

//------------------------------------------------------------------------------

forward OnPlayerClickTutorial(playerid, bool:direction);

//------------------------------------------------------------------------------

ShowPlayerTutorialText(playerid)
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

HidePlayerTutorialText(playerid)
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

SetPlayerTutorialText(playerid, title[], text[])
{
    PlayerTextDrawSetString(playerid, gPlayerText[playerid][0], title);
    PlayerTextDrawSetString(playerid, gPlayerText[playerid][1], text);
}

//------------------------------------------------------------------------------

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(IsPlayerInTutorial(playerid))
    {
        if(clickedid == Text:INVALID_TEXT_DRAW)
        {
             SelectTextDraw(playerid, 0x74c624ff);
        }
        else if(clickedid == gGlobalText[3])
        {
            OnPlayerClickTutorial(playerid, false);
        }
        else if(clickedid == gGlobalText[4])
        {
            OnPlayerClickTutorial(playerid, true);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    gGlobalText[0] = TextDrawCreate(0.000000, 0.000000, "box");
    TextDrawLetterSize(gGlobalText[0], 0.000000, 10.000000);
    TextDrawTextSize(gGlobalText[0], 640.000000, 0.000000);
    TextDrawAlignment(gGlobalText[0], 1);
    TextDrawColor(gGlobalText[0], -1);
    TextDrawUseBox(gGlobalText[0], 1);
    TextDrawBoxColor(gGlobalText[0], 255);
    TextDrawSetShadow(gGlobalText[0], 0);
    TextDrawSetOutline(gGlobalText[0], 0);
    TextDrawBackgroundColor(gGlobalText[0], 255);
    TextDrawFont(gGlobalText[0], 1);
    TextDrawSetProportional(gGlobalText[0], 1);
    TextDrawSetShadow(gGlobalText[0], 0);

    gGlobalText[1] = TextDrawCreate(0.000000, 357.000000, "box");
    TextDrawLetterSize(gGlobalText[1], 0.000000, 10.000000);
    TextDrawTextSize(gGlobalText[1], 640.000000, 0.000000);
    TextDrawAlignment(gGlobalText[1], 1);
    TextDrawColor(gGlobalText[1], -1);
    TextDrawUseBox(gGlobalText[1], 1);
    TextDrawBoxColor(gGlobalText[1], 255);
    TextDrawSetShadow(gGlobalText[1], 0);
    TextDrawSetOutline(gGlobalText[1], 0);
    TextDrawBackgroundColor(gGlobalText[1], 255);
    TextDrawFont(gGlobalText[1], 1);
    TextDrawSetProportional(gGlobalText[1], 1);
    TextDrawSetShadow(gGlobalText[1], 0);

    gGlobalText[2] = TextDrawCreate(57.000000, 105.500000, "box");
    TextDrawLetterSize(gGlobalText[2], 0.000000, 25.6000000);
    TextDrawTextSize(gGlobalText[2], 595.000000, 0.000000);
    TextDrawAlignment(gGlobalText[2], 1);
    TextDrawColor(gGlobalText[2], -1);
    TextDrawUseBox(gGlobalText[2], 1);
    TextDrawBoxColor(gGlobalText[2], 171);
    TextDrawSetShadow(gGlobalText[2], 0);
    TextDrawSetOutline(gGlobalText[2], 0);
    TextDrawBackgroundColor(gGlobalText[2], 255);
    TextDrawFont(gGlobalText[2], 1);
    TextDrawSetProportional(gGlobalText[2], 1);
    TextDrawSetShadow(gGlobalText[2], 0);

    gGlobalText[3] = TextDrawCreate(259.999969, 375.681427, "LD_BEAT:left");
    TextDrawLetterSize(gGlobalText[3], 0.000000, 0.000000);
    TextDrawTextSize(gGlobalText[3], 18.000000, 24.000000);
    TextDrawAlignment(gGlobalText[3], 1);
    TextDrawColor(gGlobalText[3], -1);
    TextDrawSetShadow(gGlobalText[3], 0);
    TextDrawSetOutline(gGlobalText[3], 0);
    TextDrawBackgroundColor(gGlobalText[3], 255);
    TextDrawFont(gGlobalText[3], 4);
    TextDrawSetProportional(gGlobalText[3], 0);
    TextDrawSetShadow(gGlobalText[3], 0);
    TextDrawSetSelectable(gGlobalText[3], true);

    gGlobalText[4] = TextDrawCreate(355.467193, 375.681427, "LD_BEAT:right");
    TextDrawLetterSize(gGlobalText[4], 0.000000, 0.000000);
    TextDrawTextSize(gGlobalText[4], 18.000000, 24.000000);
    TextDrawAlignment(gGlobalText[4], 1);
    TextDrawColor(gGlobalText[4], -1);
    TextDrawSetShadow(gGlobalText[4], 0);
    TextDrawSetOutline(gGlobalText[4], 0);
    TextDrawBackgroundColor(gGlobalText[4], 255);
    TextDrawFont(gGlobalText[4], 4);
    TextDrawSetProportional(gGlobalText[4], 0);
    TextDrawSetShadow(gGlobalText[4], 0);
    TextDrawSetSelectable(gGlobalText[4], true);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    gPlayerText[playerid][0] = CreatePlayerTextDraw(playerid, 320.000213, 105.377769, "titulo");
    PlayerTextDrawLetterSize(playerid, gPlayerText[playerid][0], 0.400000, 1.600000);
    PlayerTextDrawAlignment(playerid, gPlayerText[playerid][0], 2);
    PlayerTextDrawColor(playerid, gPlayerText[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, gPlayerText[playerid][0], 1);
    PlayerTextDrawBackgroundColor(playerid, gPlayerText[playerid][0], 245170431);
    PlayerTextDrawFont(playerid, gPlayerText[playerid][0], 2);
    PlayerTextDrawSetProportional(playerid, gPlayerText[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][0], 0);

    gPlayerText[playerid][1] = CreatePlayerTextDraw(playerid, 58.666908, 153.170379, "texto");
    PlayerTextDrawLetterSize(playerid, gPlayerText[playerid][1], 0.259333, 1.001334);
    PlayerTextDrawTextSize(playerid, gPlayerText[playerid][1], 593.000000, 15.000000);
    PlayerTextDrawAlignment(playerid, gPlayerText[playerid][1], 1);
    PlayerTextDrawColor(playerid, gPlayerText[playerid][1], -1);
    PlayerTextDrawUseBox(playerid, gPlayerText[playerid][1], 1);
    PlayerTextDrawBoxColor(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, gPlayerText[playerid][1], 0);
    PlayerTextDrawFont(playerid, gPlayerText[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, gPlayerText[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, gPlayerText[playerid][1], 0);
    return 1;
}
