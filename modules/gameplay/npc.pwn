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

static gCheckpoint;

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    // Ator no spawn do freeroam
    CreateActor(23, 1114.0189, -1616.0543, 20.4688, 270.4110);
    gCheckpoint = CreateDynamicCP(1114.9579, -1616.0040, 20.4768, 1.0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerEnterDynamicCP(playerid, STREAMER_TAG_CP checkpointid)
{
    if (checkpointid == gCheckpoint)
    {
        PlaySelectSound(playerid);
        ShowPlayerDialog(playerid, DIALOG_SPAWN_HELPER, DIALOG_STYLE_LIST, "{59c72c}LF - {ffffff}Comandos Gerais", "Comandos\nRegras\nCreditos", "Selecionar", "Fechar");
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
    }
    return 1;
}
