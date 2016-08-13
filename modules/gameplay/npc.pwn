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
        ShowPlayerDialog(playerid, DIALOG_SPAWN_HELPER, DIALOG_STYLE_MSGBOX,
            "Bem-vindo", "{ffffff}Bem-vindo ao {59c72c}L{ffffff}iberty {59c72c}F{ffffff}reeroam!\n\n\
            Para alterar seu modo de jogo utilize o comando /lobby.\n\
            Para visualizar os comandos disponíveis utilize o comando /cmds.\n\
            Não deixe de ler as /regras do servidor para evitar problemas.\n\
            Caso deseja conhecer as pessoas que fizeram o Liberty Freeroam ser possível digite /creditos.\n\n\
            Desejamos um bom jogo!",
            "Fechar", "");
    }
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_SPAWN_HELPER:
        {
            PlayCancelSound(playerid);
        }
    }
    return 1;
}
