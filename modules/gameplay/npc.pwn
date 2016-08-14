/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/npc.pwn
*
* DESCRIÇÃO :
*	   Manipula os NPCs do servidor.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

enum e_npc_cp_enum
{
    NPC_CHECKPOINT_SPAWN,
    NPC_CHECKPOINT_BAR
}
static gCheckpoint[e_npc_cp_enum];

//------------------------------------------------------------------------------

static const barDrinks[][][] =
{
    { 250,  SPECIAL_ACTION_DRINK_SPRUNK, "Sprunk"   },
    { 500,  SPECIAL_ACTION_DRINK_BEER,   "Cerveja"  },
    { 750,  SPECIAL_ACTION_DRINK_WINE,   "Vinho"    }
};

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    // Ator no spawn do freeroam
    CreateActor(23, 1114.0189, -1616.0543, 20.4688, 270.4110);
    gCheckpoint[NPC_CHECKPOINT_SPAWN] = CreateDynamicCP(1114.9579, -1616.0040, 20.4768, 1.0, 0, 0);
    // Ator no bar
    CreateActor(194, 498.4964, -77.5751, 998.7651, 356.4081);
    gCheckpoint[NPC_CHECKPOINT_BAR] = CreateDynamicCP(498.3891, -76.0320, 998.7578, 1.0, 0, 11);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerEnterDynamicCP(playerid, STREAMER_TAG_CP checkpointid)
{
    if (checkpointid == gCheckpoint[NPC_CHECKPOINT_SPAWN])
    {
        PlaySelectSound(playerid);
        ShowPlayerDialog(playerid, DIALOG_SPAWN_HELPER, DIALOG_STYLE_LIST, "{59c72c}LF - {ffffff}Comandos Gerais", "Comandos\nRegras\nCreditos", "Selecionar", "Fechar");
    }
    else if (checkpointid == gCheckpoint[NPC_CHECKPOINT_BAR])
    {
        PlaySelectSound(playerid);

        new output[80], string[24];
        strcat(output, "Nome\tPreço\n");
        for(new i = 0; i < sizeof(barDrinks); i++)
        {
            format(string, sizeof(string), "%s\t$%d\n", barDrinks[i][2], barDrinks[i][0][0]);
            strcat(output, string);
        }
        ShowPlayerDialog(playerid, DIALOG_BAR, DIALOG_STYLE_TABLIST_HEADERS, "{59c72c}LF - {ffffff}Bar", output, "Comprar", "Fechar");
    }
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_SPAWN_HELPER:
        {
            if(!response)
                PlayCancelSound(playerid);
            else
            {
                switch (listitem)
                {
                    case 0:
                        CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/cmds");
                    case 1:
                        CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/regras");
                    case 2:
                        CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/creditos");

                }
            }
        }
        case DIALOG_BAR:
        {
            if(!response)
                PlayCancelSound(playerid);
            else
            {
                if(GetPlayerCash(playerid) < barDrinks[listitem][0][0])
                {
                    PlayErrorSound(playerid);
                    SendClientMessage(playerid, COLOR_ERROR, "* Você não tem dinheiro suficiente.");
                }
                else
                {
                    PlayBuySound(playerid, 1054);
                    SendClientMessagef(playerid, COLOR_SUCCESS, "* Você comprou um %s.", barDrinks[listitem][2]);
                    GivePlayerCash(playerid, barDrinks[listitem][0][0]);
                    SetPlayerSpecialAction(playerid, barDrinks[listitem][1][0]);
                }
            }
        }
    }
    return 1;
}
