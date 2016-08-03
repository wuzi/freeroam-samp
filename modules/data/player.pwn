/*******************************************************************************
* NOME DO ARQUIVO :        modules/data/player.pwn
*
* DESCRIÇÃO :
*       Manipula a conta dos jogadores, salvar, carregar, cadastrar, acessar.
*
* NOTES :
*       Este arquivo deve apenas conter dados de jogadores.
*
*
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

#define MAX_PLAYER_PASSWORD 32

//------------------------------------------------------------------------------

forward OnAccountLoad(playerid);
forward OnAccountCheck(playerid);
forward OnAccountRegister(playerid);
forward OnBannedAccountCheck(playerid);

//------------------------------------------------------------------------------

enum e_player_adata
{
    e_player_database_id,
    e_player_password[MAX_PLAYER_PASSWORD],
    e_player_regdate,
    e_player_email[64],
    e_player_ip[16],
    e_player_lastlogin
}
static gPlayerAccountData[MAX_PLAYERS][e_player_adata];

//------------------------------------------------------------------------------

enum e_player_bdata
{
    bool:e_player_banned,
    e_player_badmin_name[MAX_PLAYER_NAME],
    e_player_created_at,
    e_player_expire,
    e_player_reason[255]
}
static gPlayerBannedData[MAX_PLAYERS][e_player_bdata];

//------------------------------------------------------------------------------

enum PlayerState (<<= 1)
{
    E_PLAYER_STATE_NONE,
    E_PLAYER_STATE_LOGGED = 1
}
static PlayerState:gPlayerStates[MAX_PLAYERS];

//------------------------------------------------------------------------------

SetPlayerLogged(playerid, bool:set)
{
    if(set)
        gPlayerStates[playerid] |= E_PLAYER_STATE_LOGGED;
    else
        gPlayerStates[playerid] &= ~E_PLAYER_STATE_LOGGED;
}

//------------------------------------------------------------------------------

IsPlayerLogged(playerid)
{
    if(!IsPlayerConnected(playerid))
        return false;

    if(gPlayerStates[playerid] & E_PLAYER_STATE_LOGGED)
        return true;

    return false;
}

//------------------------------------------------------------------------------

SavePlayerAccount(playerid)
{
    // Caso o jogador não estiver logado, terminar função
    if(!IsPlayerLogged(playerid))
        return 0;

    // Salvar conta
    new query[90];
	mysql_format(gMySQL, query, sizeof(query), "UPDATE `users` SET `ip`='%s', `lastlogin`=%d WHERE `id`=%d", gPlayerAccountData[playerid][e_player_ip], gettime(), gPlayerAccountData[playerid][e_player_database_id]);
	mysql_pquery(gMySQL, query);
    return 1;
}

//------------------------------------------------------------------------------

ResetPlayerData(playerid)
{
    new ct = gettime();

    gPlayerStates[playerid] = E_PLAYER_STATE_NONE;

    gPlayerAccountData[playerid][e_player_database_id]  = 0;
    gPlayerAccountData[playerid][e_player_regdate]      = ct;
    gPlayerAccountData[playerid][e_player_lastlogin]    = ct;
}

//------------------------------------------------------------------------------

LoadPlayerAccount(playerid)
{
    new query[57 + MAX_PLAYER_NAME + 1], playerName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    mysql_format(gMySQL, query, sizeof(query),"SELECT * FROM `users` WHERE `username` = '%e' LIMIT 1", playerName);
    mysql_tquery(gMySQL, query, "OnAccountLoad", "i", playerid);
}

//------------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    ClearPlayerScreen(playerid);
    SetPlayerColor(playerid, 0xACACACFF);
    SendClientMessage(playerid, 0xA9C4E4FF, "Conectado ao banco de dados, por favor, aguarde...");
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerRequestClass(playerid, classid)
{
    new query[57 + MAX_PLAYER_NAME + 1], playerName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    mysql_format(gMySQL, query, sizeof(query),"SELECT * FROM `bans` WHERE `username` = '%e' LIMIT 1", playerName);
    mysql_tquery(gMySQL, query, "OnBannedAccountCheck", "i", playerid);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerRequestSpawn(playerid)
{
    if(!IsPlayerLogged(playerid))
    {
        SendClientMessage(playerid, 0xb44819ff, "* Você não está logado.");
        return -1;
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    SavePlayerAccount(playerid);
    SetPlayerLogged(playerid, false);
    ResetPlayerData(playerid);
    return 1;
}

//------------------------------------------------------------------------------

public OnAccountCheck(playerid)
{
	new rows, fields, playerName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields, gMySQL);
    GetPlayerName(playerid, playerName, sizeof(playerName));
	if(rows)
	{
        if(gPlayerBannedData[playerid][e_player_banned] && (gPlayerBannedData[playerid][e_player_expire] < 0 || gPlayerBannedData[playerid][e_player_expire] > gettime()))
        {
            new info[564];
            format(info, sizeof(info), "{ffffff}%s, esta conta está banida!\n\nData do banimento: {fe9ddd}%s.\n{ffffff}Autor do banimento: {fe9ddd}%s.\n{ffffff}Expiração do banimento: {fe9ddd}%s\n{ffffff}Motivo do banimento:\n{fe9ddd}%s",
            playerName, convertTimestamp(gPlayerBannedData[playerid][e_player_created_at]), gPlayerBannedData[playerid][e_player_badmin_name],
            (gPlayerBannedData[playerid][e_player_expire] > 0) ? convertTimestamp(gPlayerBannedData[playerid][e_player_expire]) : "Nunca", gPlayerBannedData[playerid][e_player_reason]);
            ShowPlayerDialog(playerid, DIALOG_BANNED, DIALOG_STYLE_MSGBOX, "Banido", info, "Sair", "");
            PlayErrorSound(playerid);
        }
        else
        {
            cache_get_field_content(0, "password", gPlayerAccountData[playerid][e_player_password], gMySQL, MAX_PLAYER_PASSWORD);
            gPlayerAccountData[playerid][e_player_database_id] = cache_get_field_content_int(0, "id", gMySQL);

            new info[104];
            format(info, sizeof(info), "Bem-vindo de volta, %s!\n\nVocê já possui uma conta.\nDigite sua senha para acessar.", playerName);
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Acesso", info, "Accessar", "Sair");
            PlaySelectSound(playerid);

            // Caso o banimento do jogador expirar, deletar da tabela de bans
            if(gPlayerBannedData[playerid][e_player_banned])
            {
                new query[57 + MAX_PLAYER_NAME + 1];
                mysql_format(gMySQL, query, sizeof(query),"DELETE FROM `bans` WHERE `username` = '%s'", playerName);
                mysql_tquery(gMySQL, query);
            }
        }
	}
    else
    {
        new info[102];
        format(info, sizeof(info), "Bem-vindo, %s!\n\nVocê não possui uma conta.\nDigite uma senha para cadastrar.", playerName);
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cadastro", info, "Cadastrar", "Sair");
        PlaySelectSound(playerid);
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnBannedAccountCheck(playerid)
{
	new rows, fields, playerName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields, gMySQL);
    GetPlayerName(playerid, playerName, sizeof(playerName));
	if(rows)
	{
        gPlayerBannedData[playerid][e_player_banned]                = true;
        gPlayerBannedData[playerid][e_player_created_at]            = cache_get_field_content_int(0, "created_at", gMySQL);
        gPlayerBannedData[playerid][e_player_expire]                = cache_get_field_content_int(0, "expire", gMySQL);
        cache_get_field_content(0, "admin", gPlayerBannedData[playerid][e_player_badmin_name], gMySQL, MAX_PLAYER_NAME);
        cache_get_field_content(0, "reason", gPlayerBannedData[playerid][e_player_reason], gMySQL, 255);
	}
    else
    {
        gPlayerBannedData[playerid][e_player_banned]   = false;
    }

    // Após checagem se a conta está banida, prosseguir com o carregamento normalmente.
    new query[57 + MAX_PLAYER_NAME + 1];
    mysql_format(gMySQL, query, sizeof(query),"SELECT * FROM `users` WHERE `username` = '%e' LIMIT 1", playerName);
    mysql_tquery(gMySQL, query, "OnAccountCheck", "i", playerid);
    return 1;
}

//------------------------------------------------------------------------------

public OnAccountRegister(playerid)
{
    gPlayerAccountData[playerid][e_player_database_id] = cache_insert_id();

    SetSpawnInfo(playerid, 255, 0, 2234.6855, -1260.9462, 23.9329, 270.0490, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);

    new playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
	printf("[mysql] new player account registered on database. ID: %d, Username: %s", gPlayerAccountData[playerid][e_player_database_id], playerName);
	return 1;
}

//------------------------------------------------------------------------------

public OnAccountLoad(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, gMySQL);
	if(rows)
	{
        GetPlayerIp(playerid, gPlayerAccountData[playerid][e_player_ip], 16);
        gPlayerAccountData[playerid][e_player_database_id]  = cache_get_field_content_int(0, "id", gMySQL);
        gPlayerAccountData[playerid][e_player_lastlogin]    = cache_get_field_content_int(0, "lastlogin", gMySQL);

        SetSpawnInfo(playerid, 255, 0, 2234.6855, -1260.9462, 23.9329, 270.0490, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);

        SetPlayerColor(playerid, 0xFFFFFFFF);
        SetPlayerLogged(playerid, true);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_LOGIN:
        {
            if(!response)
                return Kick(playerid);

            if(!strcmp(gPlayerAccountData[playerid][e_player_password], inputtext) && !isnull(gPlayerAccountData[playerid][e_player_password]) && !isnull(inputtext))
            {
                PlayConfirmSound(playerid);
                LoadPlayerAccount(playerid);
                SendClientMessage(playerid, 0x88AA62FF, "Conectado.");
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Acessar->Senha incorreta", "Senha incorreta!\nTente novamente:", "Acessar", "Sair"),
                PlayErrorSound(playerid);
            }
            return -2;
        }
        case DIALOG_REGISTER:
        {
            if(!response)
                Kick(playerid);
            else if(strlen(inputtext) < 6)
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cadastrar->Senha muito curta", "Tente novamente:", "Cadastrar", "Sair"),
                PlayErrorSound(playerid);
            else if(strlen(inputtext) > MAX_PLAYER_PASSWORD-1)
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cadastrar->Senha muito longa", "Tente novamente:", "Cadastrar", "Sair"),
                PlayErrorSound(playerid);
            else
            {
                PlayConfirmSound(playerid);
                SetPlayerLogged(playerid, true);
                SendClientMessage(playerid, 0x88AA62FF, "Cadastrado.");

                new playerIP[16], playerName[MAX_PLAYER_NAME];
                GetPlayerName(playerid, playerName, sizeof(playerName));
                GetPlayerIp(playerid, playerIP, sizeof(playerIP));

                new query[128];
                mysql_format(gMySQL, query, sizeof(query), "INSERT INTO `users` (`username`, `password`, `ip`, `regdate`) VALUES ('%e', '%e', '%s', %d)", playerName, inputtext, playerIP, gettime());
            	mysql_tquery(gMySQL, query, "OnAccountRegister", "i", playerid);
            }
            return -2;
        }
        case DIALOG_BANNED:
        {
            Kick(playerid);
            return -2;
        }
    }
    return 1;
}
