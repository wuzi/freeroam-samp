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

static Text:logo[4];
static bool:isTextdrawVisible[MAX_PLAYERS];
static currentLogoText;
static logoText[][] =
{
    "www.libertyfreeroam.com.br",
    "O_RESPEITO_QUE_IMPOMOS_DEFINE_OQUE_SOMOS"
};

//------------------------------------------------------------------------------

ShowPlayerLogo(playerid)
{
    isTextdrawVisible[playerid] = true;
    for(new i = 0; i < sizeof(logo); i++)
    {
        TextDrawShowForPlayer(playerid, logo[i]);
    }
}

//------------------------------------------------------------------------------

HidePlayerLogo(playerid)
{
    isTextdrawVisible[playerid] = false;
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

task OnLogoUpdate[15000]()
{
    if(currentLogoText == sizeof(logoText))
        currentLogoText = 0;

    TextDrawSetString(logo[2], logoText[currentLogoText]);
    currentLogoText++;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    logo[0] = TextDrawCreate(554.716125, 386.749816, "LIBERTY_FREEROAM");
    TextDrawLetterSize(logo[0], 0.360175, 2.299999);
    TextDrawAlignment(logo[0], 2);
    TextDrawColor(logo[0], 2110249193);
    TextDrawSetShadow(logo[0], -22);
    TextDrawSetOutline(logo[0], 1);
    TextDrawBackgroundColor(logo[0], 255);
    TextDrawFont(logo[0], 1);
    TextDrawSetProportional(logo[0], 1);
    TextDrawSetShadow(logo[0], -22);

    logo[1] = TextDrawCreate(585.168090, 403.666656, ".");
    TextDrawLetterSize(logo[1], 9.103252, 0.625832);
    TextDrawAlignment(logo[1], 2);
    TextDrawColor(logo[1], -1);
    TextDrawSetShadow(logo[1], 0);
    TextDrawSetOutline(logo[1], 1);
    TextDrawBackgroundColor(logo[1], 255);
    TextDrawFont(logo[1], 1);
    TextDrawSetProportional(logo[1], 1);
    TextDrawSetShadow(logo[1], 0);

    logo[2] = TextDrawCreate(520.512451, 406.000213, "O_RESPEITO_QUE_IMPOMOS_DEFINE_OQUE_SOMOS~n~");
    TextDrawLetterSize(logo[2], 0.112327, 2.136665);
    TextDrawAlignment(logo[2], 1);
    TextDrawColor(logo[2], -10497);
    TextDrawSetShadow(logo[2], 101);
    TextDrawSetOutline(logo[2], 1);
    TextDrawBackgroundColor(logo[2], 11007);
    TextDrawFont(logo[2], 2);
    TextDrawSetProportional(logo[2], 1);
    TextDrawSetShadow(logo[2], 101);

    logo[3] = TextDrawCreate(563.615905, 421.750000, ".");
    TextDrawLetterSize(logo[3], 9.103252, 0.625832);
    TextDrawAlignment(logo[3], 2);
    TextDrawColor(logo[3], -1);
    TextDrawSetShadow(logo[3], 0);
    TextDrawSetOutline(logo[3], 1);
    TextDrawBackgroundColor(logo[3], 255);
    TextDrawFont(logo[3], 1);
    TextDrawSetProportional(logo[3], 1);
    TextDrawSetShadow(logo[3], 0);
    return 1;
}
