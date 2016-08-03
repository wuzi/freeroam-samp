/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/colors.pwn
*
* DESCRIÇÃO :
*       Jogadores podem alterar sua cor do nome e radar.
*
* NOTAS :
*       -
*/

//------------------------------------------------------------------------------

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static color_list[][][] =
{
    { 0x7FFF00FF, "Verde" },
    { 0x248DC4FF, "Azul" },
    { 0xFF0000FF, "Vermelho" },
    { 0x80E5D4FF, "Cyan" },
    { 0xF0B017FF, "Amarelo" },
    { 0xFD8204FF, "Laranja" }
};

//------------------------------------------------------------------------------

YCMD:cores(playerid, params[], help)
{
    new colorlist[400];
    for(new i = 0; i < sizeof(color_list); i++)
    {
        new string[32];
        format(string, sizeof(string), "{%06x}%s\n", color_list[i][0][0] >>> 8, color_list[i][1]);
        strcat(colorlist, string);
    }
    ShowPlayerDialog(playerid, DIALOG_COLORS, DIALOG_STYLE_LIST, "Cores", colorlist, "Confirmar", "Cancelar");
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_COLORS:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                return 1;
            }
            SendClientMessagef(playerid, COLOR_SUCCESS, "* Você alterou sua cor para %s.", color_list[listitem][1]);
            SetPlayerColor(playerid, color_list[listitem][0][0]);
            PlayConfirmSound(playerid);
            return -2;
        }
    }
    return 1;
}
