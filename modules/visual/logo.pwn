/*******************************************************************************
* NOME DO ARQUIVO :		modules/visual/logo.pwn
*
* DESCRIÇÃO :
*	   Mostra o logo para o jogador.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static Text:logo[6];

//------------------------------------------------------------------------------

ShowPlayerLogo(playerid)
{
    for(new i = 0; i < sizeof(logo); i++)
    {
        TextDrawShowForPlayer(playerid, logo[i]);
    }
}

//------------------------------------------------------------------------------

HidePlayerLogo(playerid)
{
    for(new i = 0; i < sizeof(logo); i++)
    {
        TextDrawHideForPlayer(playerid, logo[i]);
    }
}

//------------------------------------------------------------------------------

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_SPECTATING)
    {
        HidePlayerLogo(playerid);
    }
    else if(oldstate == PLAYER_STATE_SPECTATING)
    {
        ShowPlayerLogo(playerid);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    logo[0] = TextDrawCreate(479.686767, 388.433898, "L~n~");
    TextDrawLetterSize(logo[0], 0.501200, 2.340832);
    TextDrawAlignment(logo[0], 3);
    TextDrawColor(logo[0], 245170431);
    TextDrawSetShadow(logo[0], 0);
    TextDrawSetOutline(logo[0], 1);
    TextDrawBackgroundColor(logo[0], 255);
    TextDrawFont(logo[0], 1);
    TextDrawSetProportional(logo[0], 0);
    TextDrawSetShadow(logo[0], 0);

    logo[1] = TextDrawCreate(517.232849, 388.650299, "IBERTY");
    TextDrawLetterSize(logo[1], 0.501200, 2.340832);
    TextDrawAlignment(logo[1], 2);
    TextDrawColor(logo[1], -1);
    TextDrawSetShadow(logo[1], 0);
    TextDrawSetOutline(logo[1], 1);
    TextDrawBackgroundColor(logo[1], 255);
    TextDrawFont(logo[1], 1);
    TextDrawSetProportional(logo[1], 1);
    TextDrawSetShadow(logo[1], 0);

    logo[2] = TextDrawCreate(556.320190, 388.550323, "F");
    TextDrawLetterSize(logo[2], 0.501200, 2.340832);
    TextDrawAlignment(logo[2], 3);
    TextDrawColor(logo[2], 245170431);
    TextDrawSetShadow(logo[2], 0);
    TextDrawSetOutline(logo[2], 1);
    TextDrawBackgroundColor(logo[2], 255);
    TextDrawFont(logo[2], 1);
    TextDrawSetProportional(logo[2], 1);
    TextDrawSetShadow(logo[2], 0);

    logo[3] = TextDrawCreate(558.194213, 388.550231, "REEROAM");
    TextDrawLetterSize(logo[3], 0.501200, 2.340832);
    TextDrawAlignment(logo[3], 1);
    TextDrawColor(logo[3], -1);
    TextDrawSetShadow(logo[3], 0);
    TextDrawSetOutline(logo[3], 1);
    TextDrawBackgroundColor(logo[3], 255);
    TextDrawFont(logo[3], 1);
    TextDrawSetProportional(logo[3], 1);
    TextDrawSetShadow(logo[3], 0);

    logo[4] = TextDrawCreate(672.045349, 415.966949, ".");
    TextDrawLetterSize(logo[4], 15.529273, -0.774167);
    TextDrawAlignment(logo[4], 3);
    TextDrawColor(logo[4], -1);
    TextDrawSetShadow(logo[4], 0);
    TextDrawSetOutline(logo[4], 1);
    TextDrawBackgroundColor(logo[4], 255);
    TextDrawFont(logo[4], 1);
    TextDrawSetProportional(logo[4], 1);
    TextDrawSetShadow(logo[4], 0);
    TextDrawSetSelectable(logo[4], true);

    logo[5] = TextDrawCreate(559.868530, 410.500030, "www.freeroam.com");
    TextDrawLetterSize(logo[5], 0.272092, 1.436666);
    TextDrawAlignment(logo[5], 2);
    TextDrawColor(logo[5], -1);
    TextDrawSetShadow(logo[5], 0);
    TextDrawSetOutline(logo[5], 1);
    TextDrawBackgroundColor(logo[5], 255);
    TextDrawFont(logo[5], 1);
    TextDrawSetProportional(logo[5], 1);
    TextDrawSetShadow(logo[5], 0);
    return 1;
}
